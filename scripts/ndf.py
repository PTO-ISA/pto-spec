#!/usr/bin/env python3
"""Parse and validate PTO's ASL-backed Normative Design Format regions."""

from __future__ import annotations

import json
import re
from dataclasses import dataclass
from pathlib import Path


CLAUSE_ID = re.compile(r"PTO-[A-Z0-9]+(?:-[A-Z0-9]+)*")
REGION_BEGIN = re.compile(r"^// NDF-BEGIN: (PTO-[A-Z0-9]+(?:-[A-Z0-9]+)*)$")
REGION_END = re.compile(r"^// NDF-END: (PTO-[A-Z0-9]+(?:-[A-Z0-9]+)*)$")
METADATA_PREFIX = "// ndf: "
REFERENCE = re.compile(r"\[\[(PTO-[A-Z0-9]+(?:-[A-Z0-9]+)*)\]\]")
MARKDOWN_NDF = re.compile(r"(?:\{#PTO-[A-Z0-9-]+\}|<!--\s*ndf:)")
INSTRUCTION_PREFIX = "// PTO-INSTRUCTION: "

KINDS = {
    "intent": "L0",
    "contract": "L1",
    "mechanism": "L2",
    "executable": "L3",
}
LAYERS = {
    "architecture",
    "scalar",
    "block",
    "tile",
    "state",
    "memory",
    "concurrency",
}
STATUSES = {"open", "accepted"}
ACTIVE_MARKDOWN: frozenset[Path] = frozenset()
BACKUP_SUFFIXES = (".bak", ".old", ".orig", ".save", ".tmp", "~")
STATUS_LEGACY_PREFIX = Path("docs/status/legacy")
STATUS_LEGACY_REFERENCE = "docs/status/legacy/"


@dataclass(frozen=True)
class NdfClause:
    clause_id: str
    kind: str
    level: str
    layer: str
    status: str
    body: str
    source: Path
    line: int
    references: tuple[str, ...]


class NdfValidationError(ValueError):
    def __init__(self, errors: list[str]):
        super().__init__("\n".join(errors))
        self.errors = tuple(errors)


def is_allowed_legacy_path(path: Path) -> bool:
    """Return whether *path* is inside the sole permitted historical tree."""

    return path == STATUS_LEGACY_PREFIX or STATUS_LEGACY_PREFIX in path.parents


def instruction_clause_id(surface: str, mnemonic: str) -> str:
    """Return the stable NDF identity for one mnemonic ASL source."""

    surface_slug = re.sub(r"[^A-Z0-9]+", "-", surface.upper()).strip("-")
    mnemonic_slug = re.sub(r"[^A-Z0-9]+", "-", mnemonic.upper()).strip("-")
    if not surface_slug or not mnemonic_slug:
        raise ValueError("instruction NDF identity requires surface and mnemonic")
    return f"PTO-INST-{surface_slug}-{mnemonic_slug}"


def _parse_metadata(raw: str, source: Path, line: int) -> tuple[dict[str, str], list[str]]:
    values: dict[str, str] = {}
    errors: list[str] = []
    for token in raw.split():
        if token.count("=") != 1:
            errors.append(f"{source}:{line}: invalid NDF metadata token {token}")
            continue
        name, value = token.split("=", 1)
        if name in values:
            errors.append(f"{source}:{line}: duplicate NDF metadata field {name}")
        values[name] = value
    required = {"kind", "level", "layer", "status"}
    for name in sorted(required - values.keys()):
        errors.append(f"{source}:{line}: missing NDF metadata field {name}")
    for name in sorted(values.keys() - required):
        errors.append(f"{source}:{line}: unknown NDF metadata field {name}")
    if "kind" in values and values["kind"] not in KINDS:
        errors.append(f"{source}:{line}: unknown NDF kind {values['kind']}")
    if values.get("kind") in KINDS and values.get("level") != KINDS[values["kind"]]:
        errors.append(
            f"{source}:{line}: kind {values['kind']} requires level {KINDS[values['kind']]}"
        )
    if "layer" in values and values["layer"] not in LAYERS:
        errors.append(f"{source}:{line}: unknown NDF layer {values['layer']}")
    if "status" in values and values["status"] not in STATUSES:
        errors.append(f"{source}:{line}: unknown NDF status {values['status']}")
    return values, errors


def parse_ndf_regions(text: str, source: Path) -> tuple[NdfClause, ...]:
    """Parse every NDF region in one ASL source or raise all local errors."""

    clauses: list[NdfClause] = []
    errors: list[str] = []
    active_id: str | None = None
    active_line = 0
    metadata_line = 0
    metadata_raw: str | None = None
    body_lines: list[str] = []

    for line_number, line in enumerate(text.splitlines(), start=1):
        begin = REGION_BEGIN.fullmatch(line)
        end = REGION_END.fullmatch(line)
        if begin:
            if active_id is not None:
                errors.append(f"{source}:{line_number}: nested NDF region {begin.group(1)}")
                continue
            active_id = begin.group(1)
            active_line = line_number
            metadata_line = 0
            metadata_raw = None
            body_lines = []
            continue
        if end:
            if active_id is None:
                errors.append(f"{source}:{line_number}: unmatched NDF end {end.group(1)}")
                continue
            if end.group(1) != active_id:
                errors.append(
                    f"{source}:{line_number}: mismatched NDF end {end.group(1)} for {active_id}"
                )
            if metadata_raw is None:
                errors.append(f"{source}:{active_line}: NDF clause {active_id} has no metadata")
                values: dict[str, str] = {}
            else:
                values, metadata_errors = _parse_metadata(
                    metadata_raw, source, metadata_line
                )
                errors.extend(metadata_errors)
            body = "\n".join(body_lines).strip()
            if not body:
                errors.append(f"{source}:{active_line}: NDF clause {active_id} has an empty body")
            if not errors or all(not error.startswith(f"{source}:") for error in errors):
                clauses.append(
                    NdfClause(
                        clause_id=active_id,
                        kind=values["kind"],
                        level=values["level"],
                        layer=values["layer"],
                        status=values["status"],
                        body=body,
                        source=source,
                        line=active_line,
                        references=tuple(REFERENCE.findall(body)),
                    )
                )
            active_id = None
            continue
        if active_id is None:
            if line.startswith("// NDF-BEGIN:"):
                errors.append(f"{source}:{line_number}: invalid NDF clause ID")
            continue
        if line.startswith(METADATA_PREFIX):
            if metadata_raw is not None:
                errors.append(f"{source}:{line_number}: duplicate NDF metadata line")
            else:
                metadata_raw = line[len(METADATA_PREFIX) :]
                metadata_line = line_number
        elif line.startswith("//"):
            body_lines.append(line[2:].removeprefix(" "))
        else:
            errors.append(f"{source}:{line_number}: NDF body line must be an ASL comment")

    if active_id is not None:
        errors.append(f"{source}:{active_line}: unterminated NDF clause {active_id}")
    if errors:
        raise NdfValidationError(errors)
    return tuple(clauses)


def _repository_files(root: Path) -> list[Path]:
    return sorted(path for path in root.rglob("*") if path.is_file() and ".git" not in path.parts)


def _instruction_identities(root: Path) -> set[str]:
    identities: set[str] = set()
    for path in sorted((root / "asl").rglob("*.asl")) if (root / "asl").exists() else []:
        for line in path.read_text(encoding="utf-8").splitlines():
            if not line.startswith(INSTRUCTION_PREFIX):
                continue
            try:
                metadata = json.loads(line[len(INSTRUCTION_PREFIX) :])
                identities.add(instruction_clause_id(metadata["surface"], metadata["mnemonic"]))
            except (json.JSONDecodeError, KeyError, TypeError, ValueError):
                continue
    return identities


def check_repository(root: Path) -> list[str]:
    """Return deterministic NDF and single-current-tree validation errors."""

    errors: list[str] = []
    files = _repository_files(root)
    for path in files:
        relative = path.relative_to(root)
        lower_parts = tuple(part.lower() for part in relative.parts)
        allowed_legacy = is_allowed_legacy_path(relative)
        if ("legacy" in lower_parts or "archive" in lower_parts) and not allowed_legacy:
            errors.append(f"forbidden legacy specification path: {relative.as_posix()}")
        if relative.as_posix().startswith(("asl/", "docs/")) and path.name.lower().endswith(
            BACKUP_SUFFIXES
        ):
            errors.append(f"forbidden backup specification path: {relative.as_posix()}")
        if relative in ACTIVE_MARKDOWN:
            body = path.read_text(encoding="utf-8")
            if MARKDOWN_NDF.search(body):
                errors.append(
                    f"{relative.as_posix()}: active NDF clause must be owned by ASL"
                )
        if (
            (relative.as_posix().startswith("asl/") and relative.suffix == ".asl")
            or relative in ACTIVE_MARKDOWN
        ) and STATUS_LEGACY_REFERENCE in path.read_text(encoding="utf-8"):
            errors.append(
                f"{relative.as_posix()}: normative reference targets non-normative legacy material"
            )

    clauses: list[NdfClause] = []
    asl_root = root / "asl"
    if asl_root.exists():
        for path in sorted(asl_root.rglob("*.asl")):
            relative = path.relative_to(root)
            try:
                clauses.extend(parse_ndf_regions(path.read_text(encoding="utf-8"), relative))
            except NdfValidationError as error:
                errors.extend(error.errors)

    by_id: dict[str, NdfClause] = {}
    for clause in clauses:
        if clause.clause_id in by_id:
            errors.append(f"duplicate NDF clause {clause.clause_id}")
        else:
            by_id[clause.clause_id] = clause
    known_ids = set(by_id) | _instruction_identities(root)
    for clause in clauses:
        for reference in clause.references:
            if reference not in known_ids:
                errors.append(
                    f"{clause.source.as_posix()}: unknown NDF reference {reference}"
                )
    return sorted(set(errors))
