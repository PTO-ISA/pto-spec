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
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Callable, Mapping, Sequence

from scripts.asl_units import (
    AslUnit,
    _symbols_from_text,
    generate_source_order,
    load_units,
)
from scripts.ndf import NdfValidationError, instruction_clause_id, parse_ndf_regions


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


@dataclass(frozen=True)
class AslTestPoint:
    test_id: str
    source: Path
    requirements: tuple[str, ...]
    kind: str
    summary: str
    pass_condition: str
    related_sources: tuple[Path, ...]
    path: Path
    sha256: str


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


def _expected_test_path(source: Path, test_id: str) -> Path:
    return (
        Path("tests/asl") / source.relative_to("asl").with_suffix("") / f"{test_id}.asl"
    )


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


def load_test_points(root: Path, units: Sequence[AslUnit]) -> tuple[AslTestPoint, ...]:
    """Load all independent tests below *root* and reject ambiguous ownership."""

    known_sources = {unit.source_path for unit in units}
    loaded: list[tuple[AslTestPoint, str, tuple[str, ...]]] = []
    test_root = root / "tests/asl"
    raw_files: list[tuple[Path, Path, str, dict[str, object]]] = []
    for absolute in sorted(test_root.rglob("*.asl")) if test_root.exists() else []:
        relative = absolute.relative_to(root)
        text = absolute.read_text(encoding="utf-8")
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
        expected = _expected_test_path(source, test_id)
        if relative != expected:
            raise ValueError(
                f"{relative}: test path does not mirror source; expected {expected}"
            )
        requirements = _strings(metadata, "requirements", relative)
        kind = _string(metadata, "kind", relative)
        if kind not in SUPPORTED_KINDS:
            raise ValueError(f"{relative}: unsupported ASL test kind {kind}")
        related_sources = tuple(
            _source_path(item, "related_sources", relative)
            for item in _strings(metadata, "related_sources", relative)
        )
        for related in related_sources:
            if related not in known_sources:
                raise ValueError(f"{relative}: unknown related ASL source {related}")
        helpers = _validate_main(relative, text)
        loaded.append(
            (
                AslTestPoint(
                    test_id=test_id,
                    source=source,
                    requirements=requirements,
                    kind=kind,
                    summary=_string(metadata, "summary", relative),
                    pass_condition=_string(metadata, "pass_condition", relative),
                    related_sources=related_sources,
                    path=relative,
                    sha256=hashlib.sha256(text.encode("utf-8")).hexdigest(),
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
    for point in sorted(points, key=lambda item: item.test_id):
        for requirement in point.requirements:
            if requirement not in requirements:
                errors.append(f"unknown NDF requirement {requirement}")
            else:
                owned_requirements.add(requirement)
    for requirement, executable in sorted(requirements.items()):
        if executable and requirement not in owned_requirements:
            errors.append(
                f"executable NDF requirement has no ASL test owner: {requirement}"
            )
    return sorted(set(errors))


def matrix(points: Sequence[AslTestPoint]) -> list[dict[str, object]]:
    """Return the stable release matrix for *points*."""

    return [
        {
            "id": point.test_id,
            "path": point.path.as_posix(),
            "source": point.source.as_posix(),
            "requirements": list(point.requirements),
            "kind": point.kind,
            "sha256": point.sha256,
        }
        for point in sorted(points, key=lambda item: item.test_id)
    ]


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


def _repository(
    root: Path,
) -> tuple[tuple[AslUnit, ...], tuple[AslTestPoint, ...], dict[str, bool]]:
    units = load_units(root / "asl")
    points = load_test_points(root, units)
    requirements = requirement_index(root, units)
    return units, points, requirements


def _write_result(
    result_dir: Path,
    *,
    point: AslTestPoint,
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
        "path": point.path.as_posix(),
        "sha256": point.sha256,
        "status": status,
        "returncode": returncode,
        "duration_seconds": round(duration, 6),
        "command": list(command),
        "error": error,
    }
    (result_dir / "result.json").write_text(
        json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )


def execute_test_point(
    root: Path,
    point: AslTestPoint,
    *,
    timeout_seconds: int = DEFAULT_TIMEOUT_SECONDS,
    run: Callable[..., subprocess.CompletedProcess[str]] = subprocess.run,
) -> int:
    """Assemble and run exactly one test point, recording a fail-closed result."""

    build = root / "build"
    result_dir = build / "asl-test-results" / point.test_id
    order_path = build / "asl-source-order.txt"
    decoder_path = build / "decoders.asl"
    model_path = build / "pto-spec.asl"
    test_path = build / "asl-test-results" / point.test_id / "test.asl"
    build.mkdir(parents=True, exist_ok=True)
    result_dir.mkdir(parents=True, exist_ok=True)
    started = time.monotonic()
    command: list[str] = []
    log_parts: list[str] = []
    try:
        order_path.write_text(
            "\n".join(generate_source_order(root)) + "\n", encoding="utf-8"
        )
        decoder_command = [sys.executable, str(root / "scripts/generate-asl-decoders")]
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
        assembly_commands = (
            [
                str(root / "scripts/assemble-asl"),
                "--order",
                str(order_path),
                "--decoder",
                str(decoder_path),
                "--output",
                str(model_path),
            ],
            [
                str(root / "scripts/assemble-asl"),
                str(test_path),
                str(model_path),
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
    arguments = parser.parse_args(argv)
    if arguments.page_size <= 0 or arguments.page < 0:
        print(
            "error: page size must be positive and page must be nonnegative",
            file=sys.stderr,
        )
        return 2
    root = arguments.root.resolve()
    try:
        units, points, requirements = _repository(root)
        errors = validate_test_coverage(points, units, requirements)
        if errors:
            raise ValueError("\n".join(errors))
        entries = matrix(points)
        page_count = max(1, math.ceil(len(entries) / arguments.page_size))
        if arguments.page >= page_count:
            raise ValueError(
                f"page {arguments.page} is outside matrix page count {page_count}"
            )
        start = arguments.page * arguments.page_size
        include = entries[start : start + arguments.page_size]
        commit = subprocess.run(
            ["git", "rev-parse", "HEAD"],
            cwd=root,
            text=True,
            capture_output=True,
            check=True,
        ).stdout.strip()
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    print(
        json.dumps(
            {
                "commit": commit,
                "page": arguments.page,
                "page_count": page_count,
                "test_count": len(entries),
                "include": include,
            },
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
        points = load_test_points(root, units)
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
