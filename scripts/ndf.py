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
UNIT_PREFIX = "// PTO-UNIT: "
STATE_PREFIX = "// PTO-STATE: "
STATE_ID = re.compile(r"PTO-STATE-[A-Z0-9]+(?:-[A-Z0-9]+)*")
STATE_CLASSIFICATION = re.compile(r"[a-z0-9]+(?:-[a-z0-9]+)*")
STATE_SCOPES = {"pe", "bundle", "core", "memory-agent", "acr", "system"}
ASL_VAR = re.compile(r"^\s*var\s+(_[A-Za-z][A-Za-z0-9_]*)\s*:")

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


@dataclass(frozen=True)
class PtoState:
    state_id: str
    classification: tuple[str, ...]
    scope: str
    owner: str
    members: tuple[str, ...]
    depends_on: tuple[str, ...]
    source: Path
    line: int


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


def _string_array(
    metadata: dict[str, object], name: str, source: Path, line: int
) -> tuple[tuple[str, ...], list[str]]:
    value = metadata.get(name)
    if not isinstance(value, list) or any(
        not isinstance(item, str) or not item for item in value
    ):
        return (), [f"{source}:{line}: PTO state {name} must be an array of non-empty strings"]
    return tuple(value), []


def parse_state_records(text: str, source: Path, unit_id: str) -> tuple[PtoState, ...]:
    """Parse and validate every PTO-STATE record owned by one ASL unit."""

    declared = {
        match.group(1)
        for line in text.splitlines()
        if (match := ASL_VAR.match(line)) is not None
    }
    required = {"id", "classification", "scope", "owner", "members", "depends_on"}
    records: list[PtoState] = []
    errors: list[str] = []
    state_ids: set[str] = set()
    owned_members: set[str] = set()
    for line_number, line in enumerate(text.splitlines(), start=1):
        if not line.startswith(STATE_PREFIX):
            continue
        try:
            metadata = json.loads(line.removeprefix(STATE_PREFIX))
        except json.JSONDecodeError as error:
            errors.append(f"{source}:{line_number}: invalid PTO state metadata: {error}")
            continue
        if not isinstance(metadata, dict):
            errors.append(f"{source}:{line_number}: PTO state metadata must be an object")
            continue
        for name in sorted(required - metadata.keys()):
            errors.append(f"{source}:{line_number}: missing PTO state metadata field {name}")
        for name in sorted(metadata.keys() - required):
            errors.append(f"{source}:{line_number}: unknown PTO state metadata field {name}")
        if metadata.keys() != required:
            continue

        state_id = metadata["id"]
        owner = metadata["owner"]
        scope = metadata["scope"]
        classification, classification_errors = _string_array(
            metadata, "classification", source, line_number
        )
        members, member_errors = _string_array(metadata, "members", source, line_number)
        dependencies, dependency_errors = _string_array(
            metadata, "depends_on", source, line_number
        )
        local_errors = classification_errors + member_errors + dependency_errors
        if not isinstance(state_id, str) or STATE_ID.fullmatch(state_id) is None:
            local_errors.append(
                f"{source}:{line_number}: PTO state id must be an uppercase PTO-STATE identity"
            )
        if classification and any(
            STATE_CLASSIFICATION.fullmatch(item) is None for item in classification
        ):
            local_errors.append(
                f"{source}:{line_number}: PTO state classification must contain lowercase segments"
            )
        if not classification:
            local_errors.append(
                f"{source}:{line_number}: PTO state classification must not be empty"
            )
        if not isinstance(scope, str) or scope not in STATE_SCOPES:
            local_errors.append(f"{source}:{line_number}: unsupported PTO state scope {scope}")
        if not isinstance(owner, str) or owner != unit_id:
            local_errors.append(
                f"{source}:{line_number}: PTO state owner {owner} does not match same-file unit {unit_id}"
            )
        if not members:
            local_errors.append(f"{source}:{line_number}: PTO state members must not be empty")
        if len(members) != len(set(members)):
            local_errors.append(
                f"{source}:{line_number}: PTO state members must not contain duplicates"
            )
        for member in members:
            if member not in declared:
                local_errors.append(
                    f"{source}:{line_number}: state member {member} is not a same-file ASL var"
                )
            if member in owned_members:
                local_errors.append(
                    f"{source}:{line_number}: state member {member} belongs to multiple families"
                )
        for dependency in dependencies:
            if STATE_ID.fullmatch(dependency) is None:
                local_errors.append(
                    f"{source}:{line_number}: invalid PTO state dependency {dependency}"
                )
        if isinstance(state_id, str) and state_id in state_ids:
            local_errors.append(f"{source}:{line_number}: duplicate PTO state {state_id}")
        errors.extend(local_errors)
        if local_errors:
            continue
        state_ids.add(state_id)
        owned_members.update(members)
        records.append(
            PtoState(
                state_id=state_id,
                classification=classification,
                scope=scope,
                owner=owner,
                members=members,
                depends_on=dependencies,
                source=source,
                line=line_number,
            )
        )
    if errors:
        raise NdfValidationError(errors)
    return tuple(records)


def _state_unit_id(text: str, source: Path) -> str:
    records: list[str] = []
    for line_number, line in enumerate(text.splitlines(), start=1):
        prefix = next(
            (
                candidate
                for candidate in (UNIT_PREFIX, INSTRUCTION_PREFIX)
                if line.startswith(candidate)
            ),
            None,
        )
        if prefix is None:
            continue
        try:
            metadata = json.loads(line.removeprefix(prefix))
        except json.JSONDecodeError as error:
            raise NdfValidationError(
                [f"{source}:{line_number}: invalid ASL unit metadata: {error}"]
            ) from error
        if not isinstance(metadata, dict) or not isinstance(metadata.get("id"), str):
            raise NdfValidationError(
                [f"{source}:{line_number}: ASL unit metadata requires string id"]
            )
        records.append(metadata["id"])
    if len(records) != 1:
        raise NdfValidationError(
            [f"{source}: PTO state owner file requires exactly one ASL unit record"]
        )
    return records[0]


def state_index(root: Path) -> dict[str, PtoState]:
    """Return the complete, dependency-closed PTO state catalog under *root*."""

    asl_root = root / "asl" if (root / "asl").is_dir() else root
    states: dict[str, PtoState] = {}
    errors: list[str] = []
    for path in sorted(asl_root.rglob("*.asl")):
        text = path.read_text(encoding="utf-8")
        if STATE_PREFIX not in text:
            continue
        source = path.relative_to(root) if path.is_relative_to(root) else path
        try:
            unit_id = _state_unit_id(text, source)
            records = parse_state_records(text, source, unit_id)
        except NdfValidationError as error:
            errors.extend(error.errors)
            continue
        for record in records:
            if record.state_id in states:
                errors.append(f"duplicate PTO state {record.state_id}")
            else:
                states[record.state_id] = record
    for state in states.values():
        for dependency in state.depends_on:
            if dependency not in states:
                errors.append(
                    f"{state.source}:{state.line}: unknown PTO state dependency {dependency}"
                )

    remaining = set(states)
    resolved: set[str] = set()
    while True:
        ready = {
            state_id
            for state_id in remaining
            if set(states[state_id].depends_on) <= resolved
        }
        if not ready:
            break
        remaining -= ready
        resolved |= ready
    for state_id in sorted(remaining):
        state = states[state_id]
        errors.append(f"{state.source}:{state.line}: cyclic PTO state dependency {state_id}")
    if errors:
        raise NdfValidationError(errors)
    return states


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
    try:
        states = state_index(root)
    except NdfValidationError as error:
        errors.extend(error.errors)
        states = {}
    known_ids = set(by_id) | _instruction_identities(root) | set(states)
    for clause in clauses:
        for reference in clause.references:
            if reference not in known_ids:
                errors.append(
                    f"{clause.source.as_posix()}: unknown NDF reference {reference}"
                )
    return sorted(set(errors))
