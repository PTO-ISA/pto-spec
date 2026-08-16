#!/usr/bin/env python3
"""Discover, validate, schedule, and execute independent PTO ASL test points."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import os
import re
import shlex
import shutil
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Callable, Mapping, Sequence, TextIO

from scripts.asl_units import (
    AslUnit,
    _symbols_from_text,
    generate_source_order,
    load_units,
)
from scripts.ndf import NdfValidationError, instruction_clause_id, parse_ndf_regions
from scripts.asl_validation_shards import EMPTY_VALIDATION_SHARD, VALIDATION_CALL


TEST_PREFIX = "// PTO-TEST: "
TEST_ID = re.compile(r"PTO-AVS-[A-Z0-9]+(?:-[A-Z0-9]+)*")
SUPPORTED_KINDS = frozenset(
    {
        "decode-positive",
        "decode-negative",
        "execution",
        "boundary",
        "fault",
        "atomicity",
        "ordering",
        "state-transition",
        "static-invariant",
    }
)
SEMANTIC_TEST_KINDS = frozenset(
    {
        "execution",
        "boundary",
        "fault",
        "atomicity",
        "ordering",
        "state-transition",
    }
)
TEST_KIND_TYPES = {
    "decode-positive": "decode",
    "decode-negative": "decode",
    "execution": "exec",
    "boundary": "bound",
    "fault": "fault",
    "atomicity": "atomic",
    "ordering": "order",
    "state-transition": "state",
    "static-invariant": "static",
}
TEST_FILENAME = re.compile(
    r"(?P<group>arch|block|scalar|tile)-"
    r"(?P<type>decode|exec|bound|fault|atomic|order|state|static)-"
    r"(?P<name>[a-z0-9]+(?:-[a-z0-9]+)*)-"
    r"(?P<sequence>[0-9]{3})\.asl"
)
FORBIDDEN_TEST_NAME_TOKENS = frozenset(
    {"test", "execution", "validate", "validation"}
)
MAX_TEST_FILENAME_LENGTH = 68
MAX_TEST_LINE_COUNT = 300
REJECTED_TEST_SUMMARY_PREFIXES = (
    "migrated independent behavior point for ",
    "run test",
    "validate execution",
)
METADATA_FIELDS = frozenset(
    {
        "id",
        "source",
        "requirements",
        "kind",
        "summary",
        "pass_condition",
        "related_sources",
    }
)
DEFAULT_TIMEOUT_SECONDS = 360 * 60
MAX_LOG_EXCERPT_CHARS = 8192


@dataclass(frozen=True)
class AslTestPoint:
    test_id: str
    display_name: str
    source: Path
    requirements: tuple[str, ...]
    kind: str
    summary: str
    pass_condition: str
    related_sources: tuple[Path, ...]
    path: Path
    sha256: str
    validation_entrypoint: str | None
    validation_sha256: str


@dataclass(frozen=True)
class AslExecutionPoint:
    """Exact matrix fields required to execute and report one independent point."""

    test_id: str
    display_name: str
    source: Path
    kind: str
    path: Path
    sha256: str
    validation_entrypoint: str | None
    validation_sha256: str


@dataclass(frozen=True)
class PreparedAslInputs:
    """Immutable model and validation inputs shared by one matrix page."""

    model_path: Path
    validation_paths: Mapping[str | None, Path]


def _string(metadata: dict[str, object], field: str, path: Path) -> str:
    value = metadata.get(field)
    if not isinstance(value, str) or not value:
        raise ValueError(f"{path}: PTO-TEST field {field} must be a non-empty string")
    return value


def _strings(metadata: dict[str, object], field: str, path: Path) -> tuple[str, ...]:
    value = metadata.get(field)
    if not isinstance(value, list) or any(
        not isinstance(item, str) or not item for item in value
    ):
        raise ValueError(
            f"{path}: PTO-TEST field {field} must be an array of non-empty strings"
        )
    items = tuple(value)
    if len(items) != len(set(items)):
        raise ValueError(f"{path}: PTO-TEST field {field} contains duplicates")
    return items


def _metadata(path: Path, text: str) -> dict[str, object]:
    records = [
        line[len(TEST_PREFIX) :]
        for line in text.splitlines()
        if line.startswith(TEST_PREFIX)
    ]
    if len(records) != 1:
        raise ValueError(
            f"{path}: expected exactly one PTO-TEST record, found {len(records)}"
        )
    try:
        value = json.loads(records[0])
    except json.JSONDecodeError as error:
        raise ValueError(f"{path}: invalid PTO-TEST JSON: {error}") from error
    if not isinstance(value, dict):
        raise ValueError(f"{path}: PTO-TEST metadata must be a JSON object")
    fields = set(value)
    if fields != METADATA_FIELDS:
        missing = ", ".join(sorted(METADATA_FIELDS - fields)) or "none"
        extra = ", ".join(sorted(fields - METADATA_FIELDS)) or "none"
        raise ValueError(
            f"{path}: PTO-TEST fields must be exact; missing: {missing}; extra: {extra}"
        )
    return value


def _source_path(value: str, field: str, path: Path) -> Path:
    source = Path(value)
    if source.is_absolute() or ".." in source.parts or source.as_posix() != value:
        raise ValueError(
            f"{path}: PTO-TEST field {field} must be a normalized relative path"
        )
    if len(source.parts) < 3 or source.parts[0] != "asl" or source.suffix != ".asl":
        raise ValueError(f"{path}: PTO-TEST field {field} must name an ASL unit")
    return source


def _expected_test_directory(source: Path) -> Path:
    return Path("tests/asl") / source.relative_to("asl").with_suffix("")


def _mnemonic_slug(mnemonic: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", mnemonic.lower()).strip("-")


def _validate_test_filename(
    path: Path, source: Path, kind: str, mnemonic: str | None
) -> None:
    if len(path.name) > MAX_TEST_FILENAME_LENGTH:
        raise ValueError(
            f"{path}: test filename must be at most "
            f"{MAX_TEST_FILENAME_LENGTH} characters"
        )
    match = TEST_FILENAME.fullmatch(path.name)
    if match is None or match.group("sequence") == "000":
        raise ValueError(
            f"{path}: canonical test filename must be "
            "<group>-<type>-<name>-<NNN>.asl with NNN in 001..999"
        )
    expected_group = source.parts[1]
    if match.group("group") != expected_group:
        raise ValueError(
            f"{path}: test filename group must be {expected_group} for {source}"
        )
    expected_type = TEST_KIND_TYPES[kind]
    if match.group("type") != expected_type:
        raise ValueError(
            f"{path}: test filename type must be {expected_type} for kind {kind}"
        )
    name = match.group("name")
    owner_slug = (
        _mnemonic_slug(mnemonic)
        if mnemonic is not None
        else _mnemonic_slug(source.stem)
    )
    if mnemonic is not None:
        if name != owner_slug and not name.startswith(owner_slug + "-"):
            raise ValueError(
                f"{path}: instruction test filename must include mnemonic "
                f"{owner_slug} immediately after {expected_type}"
            )
    purpose = (
        name[len(owner_slug) :].removeprefix("-")
        if name == owner_slug or name.startswith(owner_slug + "-")
        else name
    )
    tokens = frozenset(purpose.split("-")) if purpose else frozenset()
    forbidden = sorted(tokens & FORBIDDEN_TEST_NAME_TOKENS)
    if forbidden:
        raise ValueError(
            f"{path}: test filename contains forbidden purpose token "
            + ", ".join(forbidden)
        )


def _validate_test_purpose(path: Path, summary: str) -> None:
    normalized = " ".join(summary.lower().split())
    if any(normalized.startswith(prefix) for prefix in REJECTED_TEST_SUMMARY_PREFIXES):
        raise ValueError(
            f"{path}: PTO-TEST summary must describe its purpose without a "
            "migration or execution placeholder"
        )


def _display_name(unit: AslUnit, kind: str, summary: str) -> str:
    owner = (
        unit.mnemonic
        if unit.mnemonic is not None
        else f"{unit.surface.upper()} {'/'.join(unit.classification)}"
    )
    return f"{owner} | {kind} | {summary}"


def _validate_main(path: Path, text: str) -> tuple[str, ...]:
    symbols = _symbols_from_text(text)
    integer_main = [
        symbol
        for symbol in symbols
        if symbol.kind == "func"
        and symbol.name == "main"
        and symbol.signature == "func main() => integer"
    ]
    all_main = [symbol for symbol in symbols if symbol.name == "main"]
    if len(integer_main) != 1 or len(all_main) != 1:
        raise ValueError(f"{path}: expected exactly one integer main() declaration")
    return tuple(
        symbol.name
        for symbol in symbols
        if symbol.kind in {"func", "procedure", "implementation", "impdef"}
        and symbol.name != "main"
    )


def load_test_points(
    root: Path,
    units: Sequence[AslUnit],
    *,
    validation_resources: Mapping[str, str] | None = None,
) -> tuple[AslTestPoint, ...]:
    """Load all independent tests below *root* and reject ambiguous ownership."""

    units_by_source = {unit.source_path: unit for unit in units}
    known_sources = set(units_by_source)
    loaded: list[tuple[AslTestPoint, str, tuple[str, ...]]] = []
    test_root = root / "tests/asl"
    raw_files: list[tuple[Path, Path, str, dict[str, object]]] = []
    for absolute in sorted(test_root.rglob("*.asl")) if test_root.exists() else []:
        relative = absolute.relative_to(root)
        text = absolute.read_text(encoding="utf-8")
        line_count = len(text.splitlines())
        if line_count > MAX_TEST_LINE_COUNT:
            raise ValueError(
                f"{relative}: independent ASL test point contains {line_count} lines; "
                f"at most {MAX_TEST_LINE_COUNT} lines are allowed"
            )
        metadata = _metadata(relative, text)
        raw_files.append((absolute, relative, text, metadata))
    raw_ids: dict[str, list[Path]] = {}
    for _, relative, _, metadata in raw_files:
        test_id = _string(metadata, "id", relative)
        raw_ids.setdefault(test_id, []).append(relative)
    for test_id, paths in sorted(raw_ids.items()):
        if len(paths) > 1:
            owners = ", ".join(path.as_posix() for path in paths)
            raise ValueError(f"duplicate ASL test ID {test_id}: {owners}")

    for _, relative, text, metadata in raw_files:
        test_id = _string(metadata, "id", relative)
        if TEST_ID.fullmatch(test_id) is None:
            raise ValueError(f"{relative}: invalid ASL test ID {test_id}")
        source = _source_path(_string(metadata, "source", relative), "source", relative)
        if source not in known_sources:
            raise ValueError(f"{relative}: unknown ASL source {source}")
        expected_directory = _expected_test_directory(source)
        if relative.parent != expected_directory:
            raise ValueError(
                f"{relative}: test path does not mirror source; expected directory "
                f"{expected_directory}"
            )
        requirements = _strings(metadata, "requirements", relative)
        kind = _string(metadata, "kind", relative)
        summary = _string(metadata, "summary", relative)
        if kind not in SUPPORTED_KINDS:
            raise ValueError(f"{relative}: unsupported ASL test kind {kind}")
        _validate_test_filename(
            relative, source, kind, units_by_source[source].mnemonic
        )
        _validate_test_purpose(relative, summary)
        related_sources = tuple(
            _source_path(item, "related_sources", relative)
            for item in _strings(metadata, "related_sources", relative)
        )
        for related in related_sources:
            if related not in known_sources:
                raise ValueError(f"{relative}: unknown related ASL source {related}")
        helpers = _validate_main(relative, text)
        uncommented = "\n".join(line.split("//", 1)[0] for line in text.splitlines())
        validation_entrypoints = sorted(
            set(VALIDATION_CALL.findall(uncommented)) - set(helpers)
        )
        if len(validation_entrypoints) > 1:
            raise ValueError(
                f"{relative}: test calls multiple generated validation entrypoints: "
                + ", ".join(validation_entrypoints)
            )
        validation_entrypoint = (
            validation_entrypoints[0] if validation_entrypoints else None
        )
        if validation_entrypoint is None:
            validation_sha256 = hashlib.sha256(
                EMPTY_VALIDATION_SHARD.encode()
            ).hexdigest()
        else:
            if validation_resources is None:
                raise ValueError(
                    f"{relative}: validation resources are required for "
                    f"{validation_entrypoint}"
                )
            validation_sha256 = validation_resources.get(validation_entrypoint, "")
            if not validation_sha256:
                raise ValueError(
                    f"{relative}: unknown generated validation entrypoint "
                    f"{validation_entrypoint}"
                )
        loaded.append(
            (
                AslTestPoint(
                    test_id=test_id,
                    display_name=_display_name(units_by_source[source], kind, summary),
                    source=source,
                    requirements=requirements,
                    kind=kind,
                    summary=summary,
                    pass_condition=_string(metadata, "pass_condition", relative),
                    related_sources=related_sources,
                    path=relative,
                    sha256=hashlib.sha256(text.encode("utf-8")).hexdigest(),
                    validation_entrypoint=validation_entrypoint,
                    validation_sha256=validation_sha256,
                ),
                text,
                helpers,
            )
        )

    helper_owners: dict[str, set[Path]] = {}
    for point, _, helpers in loaded:
        for helper in helpers:
            helper_owners.setdefault(helper, set()).add(point.path)
    for point, text, _ in loaded:
        uncommented = "\n".join(line.split("//", 1)[0] for line in text.splitlines())
        for helper, owners in sorted(helper_owners.items()):
            if point.path in owners:
                continue
            if re.search(rf"\b{re.escape(helper)}\s*\(", uncommented):
                owner_list = ", ".join(path.as_posix() for path in sorted(owners))
                raise ValueError(
                    f"{point.path}: cross-test function dependency {helper}; owned by {owner_list}"
                )

    return tuple(sorted((item[0] for item in loaded), key=lambda point: point.test_id))


def validate_test_coverage(
    points: Sequence[AslTestPoint],
    units: Sequence[AslUnit],
    requirements: Mapping[str, bool],
) -> list[str]:
    """Return deterministic source and executable-requirement coverage errors."""

    errors: list[str] = []
    owned_sources = {point.source for point in points}
    for unit in sorted(units, key=lambda item: item.source_path.as_posix()):
        if unit.source_path not in owned_sources:
            errors.append(f"ASL unit has no mirrored test owner: {unit.source_path}")
    owned_requirements: set[str] = set()
    requirement_kinds: dict[str, set[str]] = {}
    for point in sorted(points, key=lambda item: item.test_id):
        for requirement in point.requirements:
            if requirement not in requirements:
                errors.append(f"unknown NDF requirement {requirement}")
            else:
                owned_requirements.add(requirement)
                requirement_kinds.setdefault(requirement, set()).add(point.kind)
    for requirement, executable in sorted(requirements.items()):
        if executable and requirement not in owned_requirements:
            errors.append(
                f"executable NDF requirement has no ASL test owner: {requirement}"
            )
        elif (
            executable
            and requirement.startswith("PTO-INST-")
            and not (requirement_kinds.get(requirement, set()) & SEMANTIC_TEST_KINDS)
        ):
            errors.append(
                "executable instruction requirement has no semantic ASL test owner: "
                f"{requirement}"
            )
    return sorted(set(errors))


def matrix(points: Sequence[AslTestPoint]) -> list[dict[str, object]]:
    """Return the stable release matrix for *points*."""

    return [
        {
            "id": point.test_id,
            "display_name": point.display_name,
            "path": point.path.as_posix(),
            "source": point.source.as_posix(),
            "requirements": list(point.requirements),
            "kind": point.kind,
            "sha256": point.sha256,
            "validation_entrypoint": point.validation_entrypoint,
            "validation_sha256": point.validation_sha256,
        }
        for point in sorted(points, key=lambda item: item.test_id)
    ]


def matrix_pages(
    entries: Sequence[Mapping[str, object]],
    commit: str,
    page_size: int,
) -> list[dict[str, object]]:
    """Return complete deterministic pages with stable round-robin assignment."""

    if page_size <= 0:
        raise ValueError("page size must be positive")
    ordered = sorted(entries, key=lambda entry: str(entry.get("id", "")))
    page_count = max(1, math.ceil(len(ordered) / page_size))
    return [
        {
            "commit": commit,
            "page": page,
            "page_count": page_count,
            "test_count": len(ordered),
            "include": ordered[page::page_count],
        }
        for page in range(page_count)
    ]


def _exact_commit(root: Path) -> str:
    return subprocess.run(
        ["git", "rev-parse", "HEAD"],
        cwd=root,
        text=True,
        capture_output=True,
        check=True,
    ).stdout.strip()


def _release_matrix(root: Path) -> tuple[str, list[dict[str, object]]]:
    units, points, requirements = _repository(root)
    errors = validate_test_coverage(points, units, requirements)
    if errors:
        raise ValueError("\n".join(errors))
    return _exact_commit(root), matrix(points)


def export_matrix_pages(
    root: Path,
    output_dir: Path,
    *,
    page_size: int,
) -> dict[str, object]:
    """Discover once, write every exact matrix page, and return its compact index."""

    root = root.resolve()
    commit, entries = _release_matrix(root)
    pages = matrix_pages(entries, commit, page_size)
    output_dir.mkdir(parents=True, exist_ok=True)
    expected = {f"page-{page['page']}.json" for page in pages}
    for stale in output_dir.glob("page-*.json"):
        if stale.name not in expected:
            stale.unlink()
    for page in pages:
        path = output_dir / f"page-{page['page']}.json"
        temporary = path.with_suffix(".json.tmp")
        temporary.write_text(
            json.dumps(page, separators=(",", ":"), sort_keys=True) + "\n",
            encoding="utf-8",
        )
        temporary.replace(path)
    return {
        "commit": commit,
        "page_count": len(pages),
        "pages": list(range(len(pages))),
        "test_count": len(entries),
    }


def requirement_index(root: Path, units: Sequence[AslUnit]) -> dict[str, bool]:
    """Build the repository's NDF identity-to-executable index."""

    requirements: dict[str, bool] = {}
    for unit in units:
        path = root / unit.source_path
        try:
            clauses = parse_ndf_regions(
                path.read_text(encoding="utf-8"), unit.source_path
            )
        except NdfValidationError as error:
            raise ValueError("\n".join(error.errors)) from error
        for clause in clauses:
            if clause.clause_id in requirements:
                raise ValueError(f"duplicate NDF requirement {clause.clause_id}")
            requirements[clause.clause_id] = clause.kind == "executable"
        if unit.mnemonic is not None:
            identity = instruction_clause_id(unit.surface, unit.mnemonic)
            if identity in requirements:
                raise ValueError(f"duplicate NDF requirement {identity}")
            requirements[identity] = True
    return requirements


def load_validation_resources(root: Path) -> dict[str, str]:
    """Load exact generated validation-closure hashes for matrix binding."""

    command = [
        str(root / "scripts/generate-asl-decoders"),
        "--kind",
        "validation-index",
    ]
    completed = subprocess.run(
        command,
        cwd=root,
        text=True,
        capture_output=True,
        check=False,
    )
    if completed.returncode != 0:
        raise ValueError(
            "validation index generation failed:\n"
            + completed.stdout
            + completed.stderr
        )
    try:
        document = json.loads(completed.stdout)
    except json.JSONDecodeError as error:
        raise ValueError(f"invalid generated validation index: {error}") from error
    if not isinstance(document, dict) or document.get("schema") != 1:
        raise ValueError("invalid generated validation index schema")
    entries = document.get("validation")
    if not isinstance(entries, list):
        raise ValueError("generated validation index has no validation entries")
    resources: dict[str, str] = {}
    for entry in entries:
        if not isinstance(entry, dict):
            raise ValueError("generated validation index contains a non-object entry")
        name = entry.get("name")
        sha256 = entry.get("closure_sha256")
        if not isinstance(name, str) or not name:
            raise ValueError("generated validation index contains an invalid name")
        if not isinstance(sha256, str) or re.fullmatch(r"[0-9a-f]{64}", sha256) is None:
            raise ValueError(
                f"generated validation index contains an invalid closure hash for {name}"
            )
        if name in resources:
            raise ValueError(f"duplicate generated validation entrypoint {name}")
        resources[name] = sha256
    return resources


def _repository(
    root: Path,
) -> tuple[tuple[AslUnit, ...], tuple[AslTestPoint, ...], dict[str, bool]]:
    units = load_units(root / "asl")
    points = load_test_points(
        root,
        units,
        validation_resources=load_validation_resources(root),
    )
    requirements = requirement_index(root, units)
    return units, points, requirements


def _write_result(
    result_dir: Path,
    *,
    point: AslTestPoint | AslExecutionPoint,
    status: str,
    command: Sequence[str],
    returncode: int | None,
    duration: float,
    error: str | None,
    log: str,
) -> None:
    result_dir.mkdir(parents=True, exist_ok=True)
    (result_dir / "aslref.log").write_text(log, encoding="utf-8")
    payload = {
        "id": point.test_id,
        "display_name": point.display_name,
        "path": point.path.as_posix(),
        "source": point.source.as_posix(),
        "kind": point.kind,
        "sha256": point.sha256,
        "validation_entrypoint": point.validation_entrypoint,
        "validation_sha256": point.validation_sha256,
        "status": status,
        "returncode": returncode,
        "duration_seconds": round(duration, 6),
        "command": list(command),
        "error": error,
        "log_excerpt": "" if status == "passed" else log[-MAX_LOG_EXCERPT_CHARS:],
    }
    (result_dir / "result.json").write_text(
        json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )


def _github_escape(value: object, *, property_value: bool = False) -> str:
    escaped = str(value).replace("%", "%25").replace("\r", "%0D").replace("\n", "%0A")
    if property_value:
        escaped = escaped.replace(":", "%3A").replace(",", "%2C")
    return escaped


def _markdown_escape(value: object) -> str:
    return str(value).replace("|", "\\|").replace("\r", " ").replace("\n", " ")


def _result_objects(result_root: Path) -> tuple[list[dict[str, object]], list[str]]:
    values: list[dict[str, object]] = []
    errors: list[str] = []
    for path in (
        sorted(result_root.rglob("result.json")) if result_root.exists() else []
    ):
        try:
            value = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as error:
            errors.append(f"invalid result {path}: {error}")
            continue
        if not isinstance(value, dict):
            errors.append(f"invalid result {path}: expected JSON object")
            continue
        values.append(value)
    return values, errors


def report_page_results(
    matrix_path: Path,
    result_root: Path,
    *,
    summary_path: Path | None,
    output: TextIO = sys.stdout,
) -> int:
    """Report one exact ASL page with GitHub summary and failure annotations."""

    try:
        document = json.loads(matrix_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        print(f"error: invalid matrix {matrix_path}: {error}", file=output)
        return 1
    if not isinstance(document, dict) or not isinstance(document.get("include"), list):
        print(f"error: invalid matrix schema {matrix_path}", file=output)
        return 1
    page = document.get("page")
    planned: dict[str, dict[str, object]] = {}
    errors: list[str] = []
    for entry in document["include"]:
        if not isinstance(entry, dict) or not isinstance(entry.get("id"), str):
            errors.append("matrix contains an invalid entry")
            continue
        test_id = str(entry["id"])
        if test_id in planned:
            errors.append(f"duplicate planned result {test_id}")
        planned[test_id] = entry

    results, load_errors = _result_objects(result_root)
    errors.extend(load_errors)
    observed: dict[str, dict[str, object]] = {}
    for result in results:
        test_id = result.get("id")
        if not isinstance(test_id, str) or not test_id:
            errors.append("result contains an invalid ID")
            continue
        if test_id in observed:
            errors.append(f"duplicate observed result {test_id}")
            continue
        observed[test_id] = result

    rows: list[dict[str, object]] = []
    metadata_fields = (
        "path",
        "sha256",
        "display_name",
        "source",
        "kind",
        "validation_entrypoint",
        "validation_sha256",
    )
    for test_id, entry in sorted(planned.items()):
        result = observed.get(test_id)
        row_errors: list[str] = []
        if result is None:
            row_errors.append("missing result")
            result = {}
        else:
            for field in metadata_fields:
                if result.get(field) != entry.get(field):
                    row_errors.append(f"{field} mismatch")
            if result.get("status") != "passed":
                row_errors.append(
                    str(result.get("error") or f"status {result.get('status')}")
                )
                if result.get("returncode") is not None:
                    row_errors.append(f"return code {result['returncode']}")
        status = "PASS" if not row_errors else "FAIL"
        display_name = str(entry.get("display_name") or test_id)
        duration = result.get("duration_seconds", "-")
        print(f"{status} {display_name} [{test_id}] ({duration}s)", file=output)
        if row_errors:
            message = "; ".join(row_errors)
            log_excerpt = str(result.get("log_excerpt") or "")
            if log_excerpt:
                message += "\n" + log_excerpt
            print(
                "::error "
                f"file={_github_escape(entry.get('path', ''), property_value=True)},"
                f"title={_github_escape(display_name, property_value=True)}::"
                f"{_github_escape(message)}",
                file=output,
            )
        rows.append(
            {
                "status": status,
                "display_name": display_name,
                "id": test_id,
                "kind": entry.get("kind", ""),
                "duration": duration,
                "errors": row_errors,
                "log_excerpt": result.get("log_excerpt", ""),
            }
        )

    for test_id in sorted(set(observed) - set(planned)):
        errors.append(f"unplanned result {test_id}")
    for error in errors:
        print(
            f"::error title=ASL page {_github_escape(page, property_value=True)}::{_github_escape(error)}",
            file=output,
        )

    summary_lines = [
        f"## ASL page {page}",
        "",
        "| Status | Test | Stable ID | Kind | Duration (s) |",
        "| --- | --- | --- | --- | ---: |",
    ]
    for row in rows:
        summary_lines.append(
            f"| {row['status']} | {_markdown_escape(row['display_name'])} | "
            f"`{_markdown_escape(row['id'])}` | {_markdown_escape(row['kind'])} | "
            f"{_markdown_escape(row['duration'])} |"
        )
    failures = [row for row in rows if row["status"] == "FAIL"]
    for row in failures:
        summary_lines.extend(
            [
                "",
                f"### FAIL {_markdown_escape(row['display_name'])}",
                "",
                f"- ID: `{_markdown_escape(row['id'])}`",
                f"- Reason: {_markdown_escape('; '.join(row['errors']))}",
            ]
        )
        if row["log_excerpt"]:
            summary_lines.extend(
                ["", "```text", str(row["log_excerpt"]).replace("```", "` ` `"), "```"]
            )
    for error in errors:
        summary_lines.append(f"\n- Framework error: {_markdown_escape(error)}")
    if summary_path is not None:
        summary_path.parent.mkdir(parents=True, exist_ok=True)
        with summary_path.open("a", encoding="utf-8") as summary:
            summary.write("\n".join(summary_lines) + "\n")
    return 1 if errors or failures else 0


def execute_test_point(
    root: Path,
    point: AslTestPoint | AslExecutionPoint,
    *,
    timeout_seconds: int = DEFAULT_TIMEOUT_SECONDS,
    run: Callable[..., subprocess.CompletedProcess[str]] = subprocess.run,
    prepared: PreparedAslInputs | None = None,
) -> int:
    """Assemble and run exactly one test point, recording a fail-closed result."""

    build = root / "build"
    result_dir = build / "asl-test-results" / point.test_id
    order_path = result_dir / "asl-source-order.txt"
    decoder_path = result_dir / "decoders.asl"
    validation_path = result_dir / "validation.asl"
    model_path = result_dir / "pto-spec.asl"
    test_path = result_dir / "test.asl"
    build.mkdir(parents=True, exist_ok=True)
    result_dir.mkdir(parents=True, exist_ok=True)
    started = time.monotonic()
    command: list[str] = []
    log_parts: list[str] = []
    try:
        if prepared is None:
            order_path.write_text(
                "\n".join(generate_source_order(root)) + "\n", encoding="utf-8"
            )
            decoder_command = [
                sys.executable,
                str(root / "scripts/generate-asl-decoders"),
                "--kind",
                "decoder",
            ]
            decoder_result = run(
                decoder_command,
                cwd=root,
                text=True,
                capture_output=True,
                timeout=timeout_seconds,
                check=False,
            )
            if decoder_result.returncode != 0:
                raise RuntimeError(
                    "decoder generation failed:\n"
                    + decoder_result.stdout
                    + decoder_result.stderr
                )
            decoder_path.write_text(decoder_result.stdout, encoding="utf-8")
            if point.validation_entrypoint is None:
                validation_text = EMPTY_VALIDATION_SHARD
            else:
                validation_command = [
                    sys.executable,
                    str(root / "scripts/generate-asl-decoders"),
                    "--kind",
                    "validation-shard",
                    "--entrypoint",
                    point.validation_entrypoint,
                ]
                validation_result = run(
                    validation_command,
                    cwd=root,
                    text=True,
                    capture_output=True,
                    timeout=timeout_seconds,
                    check=False,
                )
                log_parts.append(validation_result.stderr)
                if validation_result.returncode != 0:
                    raise RuntimeError(
                        "validation shard generation failed:\n"
                        + validation_result.stdout
                        + validation_result.stderr
                    )
                validation_text = validation_result.stdout
            validation_hash = hashlib.sha256(validation_text.encode()).hexdigest()
            if validation_hash != point.validation_sha256:
                raise ValueError(
                    f"validation shard hash mismatch for {point.test_id}: "
                    f"expected {point.validation_sha256}, observed {validation_hash}"
                )
            validation_path.write_text(validation_text, encoding="utf-8")
            model_input = model_path
            preparation_commands = (
                [
                    str(root / "scripts/assemble-asl"),
                    "--order",
                    str(order_path),
                    "--decoder",
                    str(decoder_path),
                    "--output",
                    str(model_path),
                ],
            )
        else:
            shared_validation = prepared.validation_paths.get(
                point.validation_entrypoint
            )
            if shared_validation is None:
                raise ValueError(
                    "prepared page is missing validation input for "
                    f"{point.validation_entrypoint or '<none>'}"
                )
            validation_text = shared_validation.read_text(encoding="utf-8")
            validation_hash = hashlib.sha256(validation_text.encode()).hexdigest()
            if validation_hash != point.validation_sha256:
                raise ValueError(
                    f"prepared validation hash mismatch for {point.test_id}: "
                    f"expected {point.validation_sha256}, observed {validation_hash}"
                )
            shutil.copyfile(shared_validation, validation_path)
            model_input = prepared.model_path
            preparation_commands = ()
        assembly_commands = preparation_commands + (
            [
                str(root / "scripts/assemble-asl"),
                str(test_path),
                str(model_input),
                str(validation_path),
                str(root / point.path),
            ],
        )
        for assembly_command in assembly_commands:
            assembled = run(
                assembly_command,
                cwd=root,
                text=True,
                capture_output=True,
                timeout=timeout_seconds,
                check=False,
            )
            log_parts.extend((assembled.stdout, assembled.stderr))
            if assembled.returncode != 0:
                raise RuntimeError(
                    f"ASL assembly failed with exit {assembled.returncode}"
                )
        aslref = shlex.split(os.environ.get("ASLREF", "./scripts/aslref"))
        command = [*aslref, "--type-check-strict", str(test_path)]
        completed = run(
            command,
            cwd=root,
            text=True,
            capture_output=True,
            timeout=timeout_seconds,
            check=False,
        )
        log_parts.extend((completed.stdout, completed.stderr))
        status = "passed" if completed.returncode == 0 else "failed"
        _write_result(
            result_dir,
            point=point,
            status=status,
            command=command,
            returncode=completed.returncode,
            duration=time.monotonic() - started,
            error=None if completed.returncode == 0 else "ASLRef execution failed",
            log="".join(log_parts),
        )
        return 0 if completed.returncode == 0 else 1
    except subprocess.TimeoutExpired as error:
        message = f"timeout after {timeout_seconds} seconds: {error.cmd}"
        log_parts.append(message + "\n")
        _write_result(
            result_dir,
            point=point,
            status="timeout",
            command=command,
            returncode=None,
            duration=time.monotonic() - started,
            error=message,
            log="".join(log_parts),
        )
        return 1
    except (OSError, RuntimeError, ValueError) as error:
        message = str(error)
        log_parts.append(message + "\n")
        _write_result(
            result_dir,
            point=point,
            status="error",
            command=command,
            returncode=None,
            duration=time.monotonic() - started,
            error=message,
            log="".join(log_parts),
        )
        return 1


def check_main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--fixtures-only", type=Path)
    arguments = parser.parse_args(argv)
    root = (arguments.fixtures_only or arguments.root).resolve()
    try:
        units, points, requirements = _repository(root)
        errors = validate_test_coverage(points, units, requirements)
    except (OSError, ValueError) as error:
        errors = [str(error)]
        points = ()
    for error in errors:
        print(f"error: {error}", file=sys.stderr)
    if errors:
        return 1
    if arguments.fixtures_only is not None:
        print(
            json.dumps(
                {"include": matrix(points), "test_count": len(points)},
                separators=(",", ":"),
                sort_keys=True,
            )
        )
    else:
        print(f"ASL test closure passed: {len(points)} independent points")
    return 0


def matrix_main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--page-size", type=int, default=200)
    parser.add_argument("--page", type=int, default=0)
    parser.add_argument("--output-dir", type=Path)
    arguments = parser.parse_args(argv)
    if arguments.page_size <= 0 or arguments.page < 0:
        print(
            "error: page size must be positive and page must be nonnegative",
            file=sys.stderr,
        )
        return 2
    root = arguments.root.resolve()
    try:
        if arguments.output_dir is not None:
            payload = export_matrix_pages(
                root,
                arguments.output_dir.resolve(),
                page_size=arguments.page_size,
            )
        else:
            commit, entries = _release_matrix(root)
            pages = matrix_pages(entries, commit, arguments.page_size)
            if arguments.page >= len(pages):
                raise ValueError(
                    f"page {arguments.page} is outside matrix page count {len(pages)}"
                )
            payload = pages[arguments.page]
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    print(
        json.dumps(
            payload,
            separators=(",", ":"),
            sort_keys=True,
        )
    )
    return 0


def run_main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--id", required=True)
    parser.add_argument(
        "--timeout-seconds",
        type=int,
        default=int(
            os.environ.get("PTO_ASL_TEST_TIMEOUT_SECONDS", DEFAULT_TIMEOUT_SECONDS)
        ),
    )
    arguments = parser.parse_args(argv)
    root = arguments.root.resolve()
    try:
        units = load_units(root / "asl")
        points = load_test_points(
            root,
            units,
            validation_resources=load_validation_resources(root),
        )
        point = next((item for item in points if item.test_id == arguments.id), None)
        if point is None:
            raise ValueError(f"unknown ASL test ID {arguments.id}")
    except (OSError, ValueError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    return execute_test_point(
        root,
        point,
        timeout_seconds=arguments.timeout_seconds,
    )
