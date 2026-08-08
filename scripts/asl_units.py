#!/usr/bin/env python3
"""Discover, validate, order, and compare PTO ASL source units."""

from __future__ import annotations

import json
import re
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Sequence


UNIT_PREFIX = "// PTO-UNIT: "
INSTRUCTION_PREFIX = "// PTO-INSTRUCTION: "
APPROVED_SURFACES = ("arch", "block", "scalar", "tile")
MAX_HANDWRITTEN_LINES = 500
SYNTHETIC_DECODER_NODE = "generated:decoders"
UNIT_ID = re.compile(r"PTO-[A-Z0-9]+(?:-[A-Z0-9]+)*")


@dataclass(frozen=True)
class AslUnit:
    unit_id: str
    surface: str
    classification: tuple[str, ...]
    depends_on: tuple[str, ...]
    source_path: Path
    mnemonic: str | None
    line_count: int


def _metadata_record(path: Path, text: str) -> tuple[dict[str, object], str]:
    records: list[tuple[str, str]] = []
    for line in text.splitlines():
        for prefix in (UNIT_PREFIX, INSTRUCTION_PREFIX):
            if line.startswith(prefix):
                records.append((prefix, line[len(prefix) :]))
    if len(records) != 1:
        raise ValueError(f"{path}: expected exactly one PTO metadata record, found {len(records)}")
    prefix, payload = records[0]
    try:
        metadata = json.loads(payload)
    except json.JSONDecodeError as error:
        raise ValueError(f"{path}: invalid PTO metadata JSON: {error}") from error
    if not isinstance(metadata, dict):
        raise ValueError(f"{path}: PTO metadata must be a JSON object")
    return metadata, prefix


def _string_field(metadata: dict[str, object], name: str, path: Path) -> str:
    value = metadata.get(name)
    if not isinstance(value, str) or not value:
        raise ValueError(f"{path}: PTO metadata field {name} must be a non-empty string")
    return value


def _string_tuple_field(metadata: dict[str, object], name: str, path: Path) -> tuple[str, ...]:
    value = metadata.get(name)
    if not isinstance(value, list) or any(not isinstance(item, str) or not item for item in value):
        raise ValueError(f"{path}: PTO metadata field {name} must be an array of non-empty strings")
    return tuple(value)


def load_units(root: Path, *, source_prefix: Path = Path("asl")) -> tuple[AslUnit, ...]:
    """Load all metadata-bearing ASL files below *root* in stable path order."""

    units: list[AslUnit] = []
    for path in sorted(root.rglob("*.asl")) if root.exists() else []:
        text = path.read_text(encoding="utf-8")
        relative = path.relative_to(root)
        source_path = source_prefix / relative
        metadata, prefix = _metadata_record(source_path, text)
        unit_id = _string_field(metadata, "id", source_path)
        surface = _string_field(metadata, "surface", source_path)
        classification = _string_tuple_field(metadata, "classification", source_path)
        depends_on = _string_tuple_field(metadata, "depends_on", source_path)
        mnemonic: str | None = None
        if prefix == INSTRUCTION_PREFIX:
            mnemonic = _string_field(metadata, "mnemonic", source_path)
        units.append(
            AslUnit(
                unit_id=unit_id,
                surface=surface,
                classification=classification,
                depends_on=depends_on,
                source_path=source_path,
                mnemonic=mnemonic,
                line_count=len(text.splitlines()),
            )
        )
    return tuple(sorted(units, key=lambda unit: unit.source_path.as_posix()))


def _expected_classification(unit: AslUnit) -> tuple[str, ...]:
    parts = unit.source_path.parts
    if len(parts) < 3 or parts[0] != "asl":
        return ()
    parents = tuple(parts[2:-1])
    if unit.mnemonic is not None:
        return parents
    return (*parents, unit.source_path.stem)


def _validate_units(
    units: Sequence[AslUnit], *, require_complete_dependencies: bool
) -> list[str]:
    errors: list[str] = []
    by_id: dict[str, list[AslUnit]] = {}
    for unit in units:
        by_id.setdefault(unit.unit_id, []).append(unit)
        if not UNIT_ID.fullmatch(unit.unit_id):
            errors.append(f"{unit.source_path}: invalid ASL unit ID {unit.unit_id}")
        if unit.surface not in APPROVED_SURFACES:
            errors.append(f"{unit.source_path}: unknown ASL surface {unit.surface}")
        path_parts = unit.source_path.parts
        path_surface = path_parts[1] if len(path_parts) > 1 and path_parts[0] == "asl" else ""
        if path_surface != unit.surface:
            errors.append(
                f"{unit.source_path}: surface does not match path: metadata {unit.surface}, path {path_surface}"
            )
        expected = _expected_classification(unit)
        if unit.classification != expected:
            errors.append(
                f"{unit.source_path}: classification does not match path: metadata "
                f"{'/'.join(unit.classification)}, path {'/'.join(expected)}"
            )
        if unit.mnemonic is not None:
            expected_stem = re.sub(r"[^A-Za-z0-9._-]+", "_", unit.mnemonic).strip("_")
            if unit.source_path.stem != expected_stem:
                errors.append(
                    f"{unit.source_path}: mnemonic does not match filename: {unit.mnemonic}"
                )
        if unit.line_count > MAX_HANDWRITTEN_LINES:
            errors.append(
                f"{unit.source_path}: exceeds {MAX_HANDWRITTEN_LINES} physical lines: {unit.line_count}"
            )
        if len(set(unit.depends_on)) != len(unit.depends_on):
            errors.append(f"{unit.source_path}: duplicate ASL dependency")
    for unit_id, owners in sorted(by_id.items()):
        if len(owners) > 1:
            paths = ", ".join(owner.source_path.as_posix() for owner in owners)
            errors.append(f"duplicate ASL unit ID {unit_id}: {paths}")
    if require_complete_dependencies:
        known = set(by_id) | {SYNTHETIC_DECODER_NODE}
        for unit in units:
            for dependency in unit.depends_on:
                if dependency not in known:
                    errors.append(f"{unit.source_path}: unknown ASL dependency {dependency}")
        if not errors:
            try:
                topological_order(units)
            except ValueError as error:
                errors.append(str(error))
    return errors


def validate_layout(root: Path, units: Sequence[AslUnit]) -> list[str]:
    """Validate the complete four-surface ASL tree and return every error."""

    errors: list[str] = []
    entries = {path.name: path for path in root.iterdir()} if root.exists() else {}
    for expected in APPROVED_SURFACES:
        path = entries.get(expected)
        if path is None:
            errors.append(f"missing ASL root directory: {expected}")
        elif not path.is_dir():
            errors.append(f"ASL root entry is not a directory: {expected}")
    for name in sorted(set(entries) - set(APPROVED_SURFACES)):
        errors.append(f"unexpected ASL root entry: {name}")
    errors.extend(_validate_units(units, require_complete_dependencies=True))
    return errors


def validate_surface(root: Path, surface: str, units: Sequence[AslUnit]) -> list[str]:
    """Validate one migrated surface while sibling roots remain transitional."""

    if surface not in APPROVED_SURFACES:
        return [f"unknown ASL surface: {surface}"]
    path = root / surface
    errors = [] if path.is_dir() else [f"missing ASL root directory: {surface}"]
    errors.extend(_validate_units(units, require_complete_dependencies=False))
    for unit in units:
        if unit.surface != surface:
            errors.append(f"{unit.source_path}: unit is outside selected surface {surface}")
    return errors


def topological_order(
    units: Sequence[AslUnit],
    synthetic_nodes: tuple[str, ...] = (SYNTHETIC_DECODER_NODE,),
) -> tuple[str, ...]:
    """Return stable unit IDs in dependency order or raise on an invalid graph."""

    nodes = {unit.unit_id for unit in units}
    if len(nodes) != len(units):
        raise ValueError("duplicate ASL unit IDs prevent dependency ordering")
    if nodes.intersection(synthetic_nodes):
        raise ValueError("ASL unit ID collides with synthetic dependency node")
    nodes.update(synthetic_nodes)
    dependencies: dict[str, set[str]] = {node: set() for node in nodes}
    paths = {unit.unit_id: unit.source_path.as_posix() for unit in units}
    for unit in units:
        for dependency in unit.depends_on:
            if dependency not in nodes:
                raise ValueError(f"unknown ASL dependency {dependency} for {unit.unit_id}")
        dependencies[unit.unit_id].update(unit.depends_on)

    def key(node: str) -> tuple[int, str]:
        if node in paths:
            return (0, paths[node])
        return (1, node)

    ordered: list[str] = []
    remaining = set(nodes)
    while remaining:
        ready = sorted(
            (node for node in remaining if not dependencies[node].intersection(remaining)),
            key=key,
        )
        if not ready:
            cycle = ", ".join(sorted(remaining))
            raise ValueError(f"ASL dependency cycle: {cycle}")
        for node in ready:
            ordered.append(node)
            remaining.remove(node)
    return tuple(ordered)


def generate_source_order(root: Path) -> tuple[str, ...]:
    """Return deterministic ASL source paths with one decoder marker."""

    asl_root = root / "asl"
    units = load_units(asl_root)
    errors = validate_layout(asl_root, units)
    if errors:
        raise ValueError("\n".join(errors))
    by_id = {unit.unit_id: unit.source_path.as_posix() for unit in units}
    return tuple(
        "@generated-decoder@" if node == SYNTHETIC_DECODER_NODE else by_id[node]
        for node in topological_order(units)
    )


@dataclass(frozen=True)
class _AslSymbol:
    name: str
    kind: str
    signature: str
    body: str


_DECLARATION = re.compile(
    r"^(?P<modifiers>(?:(?:pure|readonly|impdef|implementation)\s+)*)"
    r"func\s+(?P<function>[A-Za-z_][A-Za-z0-9_]*)\b"
    r"|^procedure\s+(?P<procedure>[A-Za-z_][A-Za-z0-9_]*)\b"
    r"|^(?P<declaration>constant|var|type)\s+(?P<declaration_name>[A-Za-z_][A-Za-z0-9_]*)\b"
)


def _normalize_asl(lines: Iterable[str]) -> str:
    normalized: list[str] = []
    for line in lines:
        content = line.split("//", 1)[0].strip()
        if content:
            normalized.append(" ".join(content.split()))
    return " ".join(normalized)


def _symbols_from_text(text: str) -> list[_AslSymbol]:
    lines = text.splitlines()
    symbols: list[_AslSymbol] = []
    index = 0
    while index < len(lines):
        line = lines[index]
        if line[:1].isspace() or line.startswith("//"):
            index += 1
            continue
        match = _DECLARATION.match(line)
        if match is None:
            index += 1
            continue
        if match.group("function") is not None:
            name = match.group("function")
            modifiers = match.group("modifiers").split()
            if "implementation" in modifiers:
                kind = "implementation"
            elif "impdef" in modifiers:
                kind = "impdef"
            else:
                kind = "func"
        elif match.group("procedure") is not None:
            name = match.group("procedure")
            kind = "procedure"
        else:
            name = match.group("declaration_name")
            kind = match.group("declaration")
        start = index
        is_callable = "func " in line or line.startswith("procedure ")
        if is_callable:
            while index < len(lines) and lines[index].strip() != "begin":
                index += 1
            signature_end = index
            if index < len(lines):
                index += 1
                while index < len(lines):
                    if not lines[index][:1].isspace() and lines[index].strip() == "end;":
                        index += 1
                        break
                    index += 1
            signature = _normalize_asl(lines[start:signature_end])
            body = _normalize_asl(lines[signature_end:index])
        else:
            while index < len(lines):
                stripped = lines[index].strip()
                index += 1
                if stripped.endswith(";") or stripped == "};":
                    break
            block = lines[start:index]
            first = _normalize_asl(block[:1])
            signature = re.sub(r"\s*=.*", "", first) if line.startswith(("constant ", "var ")) else first
            body = _normalize_asl(block)
        symbols.append(_AslSymbol(name=name, kind=kind, signature=signature, body=body))
    return symbols


def _legacy_surface(path: Path) -> str | None:
    parts = path.parts
    if len(parts) < 2 or parts[0] != "asl":
        return None
    first = parts[1]
    if first in {"bundle", "block"}:
        return "block"
    if first in {"scalar", "tile"}:
        return first
    if first in {"numeric", "profiles"} or len(parts) == 2:
        return "arch"
    return None


def _current_surface(path: Path) -> str | None:
    parts = path.parts
    if len(parts) >= 3 and parts[0] == "asl" and parts[1] in APPROVED_SURFACES:
        return parts[1]
    return _legacy_surface(path)


def _symbol_label(symbol: _AslSymbol) -> str:
    if symbol.kind in {"implementation", "impdef"}:
        return f"{symbol.name} [{symbol.kind}]"
    return symbol.name


def _collect_symbols(
    files: Iterable[tuple[Path, str]], surfaces: set[str], *, legacy: bool
) -> tuple[dict[tuple[str, str, str], _AslSymbol], list[str]]:
    symbols: dict[tuple[str, str, str], _AslSymbol] = {}
    errors: list[str] = []
    for path, text in files:
        surface = _legacy_surface(path) if legacy else _current_surface(path)
        if surface not in surfaces:
            continue
        for symbol in _symbols_from_text(text):
            key = (symbol.kind, symbol.name, symbol.signature)
            if key in symbols:
                side = "baseline" if legacy else "current"
                errors.append(f"duplicate {side} ASL symbol {_symbol_label(symbol)}")
                continue
            symbols[key] = symbol
    return symbols, errors


def _git_asl_files(repo: Path, ref: str) -> list[tuple[Path, str]]:
    result = subprocess.run(
        ["git", "ls-tree", "-r", "--name-only", ref, "--", "asl"],
        cwd=repo,
        text=True,
        capture_output=True,
        check=True,
    )
    files: list[tuple[Path, str]] = []
    for raw_path in result.stdout.splitlines():
        path = Path(raw_path)
        if path.suffix != ".asl":
            continue
        text = subprocess.check_output(
            ["git", "show", f"{ref}:{path.as_posix()}"], cwd=repo, text=True
        )
        files.append((path, text))
    return files


def compare_ref_to_tree(
    repo: Path,
    before_ref: str,
    after_root: Path,
    surfaces: tuple[str, ...],
) -> list[str]:
    """Compare named ASL signatures and bodies at a Git ref with a migrated tree."""

    selected = set(surfaces)
    unknown = selected - set(APPROVED_SURFACES)
    if unknown:
        return [f"unknown ASL surface: {name}" for name in sorted(unknown)]
    baseline, errors = _collect_symbols(_git_asl_files(repo, before_ref), selected, legacy=True)
    current_files = [
        (Path("asl") / path.relative_to(after_root), path.read_text(encoding="utf-8"))
        for path in sorted(after_root.rglob("*.asl"))
    ]
    current, current_errors = _collect_symbols(current_files, selected, legacy=False)
    errors.extend(current_errors)
    baseline_groups: dict[tuple[str, str], list[_AslSymbol]] = {}
    current_groups: dict[tuple[str, str], list[_AslSymbol]] = {}
    for symbol in baseline.values():
        baseline_groups.setdefault((symbol.kind, symbol.name), []).append(symbol)
    for symbol in current.values():
        current_groups.setdefault((symbol.kind, symbol.name), []).append(symbol)
    for key in sorted(set(baseline_groups) | set(current_groups)):
        before_group = baseline_groups.get(key, [])
        after_group = current_groups.get(key, [])
        if not after_group:
            errors.extend(f"missing ASL symbol: {_symbol_label(symbol)}" for symbol in before_group)
            continue
        if not before_group:
            errors.extend(f"unexpected ASL symbol: {_symbol_label(symbol)}" for symbol in after_group)
            continue
        if len(before_group) == len(after_group) == 1:
            before = before_group[0]
            after = after_group[0]
            label = _symbol_label(before)
            if before.signature != after.signature:
                errors.append(f"changed ASL symbol signature: {label}")
            elif before.body != after.body:
                errors.append(f"changed ASL symbol body: {label}")
            continue
        before_by_signature = {symbol.signature: symbol for symbol in before_group}
        after_by_signature = {symbol.signature: symbol for symbol in after_group}
        label = _symbol_label(before_group[0])
        if set(before_by_signature) != set(after_by_signature):
            errors.append(f"changed ASL symbol signature: {label}")
            continue
        for signature in sorted(before_by_signature):
            if before_by_signature[signature].body != after_by_signature[signature].body:
                errors.append(f"changed ASL symbol body: {label}")
    return errors
