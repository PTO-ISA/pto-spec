#!/usr/bin/env python3
"""Generate and verify instruction Markdown from mnemonic ASL sources."""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass, replace
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from scripts.asl_units import AslUnit, load_units  # noqa: E402
from scripts.instruction_contracts import (  # noqa: E402
    ResolvedInstructionContract,
    load_field_domains,
    resolve_instruction_contract,
)
from scripts.ndf import instruction_clause_id  # noqa: E402
from scripts.tile_taxonomy import (  # noqa: E402
    TILE_CLASSIFICATIONS,
    TILE_ENGINES,
    derive_tile_catalog_record,
)


METADATA_PREFIX = "// PTO-INSTRUCTION: "
REGION_BEGIN = re.compile(r"^// DOC-BEGIN: ([a-z][a-z0-9-]*)$")
REGION_END = re.compile(r"^// DOC-END: ([a-z][a-z0-9-]*)$")
SURFACES = {"arch", "scalar", "block", "tile"}
SURFACE_ORDER = ("arch", "block", "scalar", "tile")
SUPPLEMENTARY_BEGIN = "<!-- SUPPLEMENTARY-BEGIN -->"
SUPPLEMENTARY_END = "<!-- SUPPLEMENTARY-END -->"
VERSION_PATTERN = re.compile(r"\b0\.58(?:\.0)?\b")


def doc_path_for(source_path: Path) -> Path:
    """Return the exact active Markdown mirror for one ASL source path."""

    if len(source_path.parts) < 3 or source_path.parts[0] != "asl":
        raise ValueError(f"ASL source path is outside the four-surface tree: {source_path}")
    if source_path.suffix != ".asl":
        raise ValueError(f"ASL source path does not name an .asl file: {source_path}")
    if source_path.parts[1] not in SURFACES:
        raise ValueError(f"unknown ASL surface in source path: {source_path}")
    return Path("docs", *source_path.parts[1:]).with_suffix(".md")


def mnemonic_file_name(mnemonic: str) -> str:
    return re.sub(r"[^A-Za-z0-9._-]+", "_", mnemonic).strip("_")


@dataclass(frozen=True)
class InstructionRecord:
    mnemonic: str
    surface: str
    classification: tuple[str, ...]
    summary: str
    assembly: tuple[str, ...]
    block: tuple[str, ...]
    catalog_records: tuple[dict[str, object], ...]
    catalog_indices: tuple[int, ...]
    source_path: Path
    regions: dict[str, str]
    engine: str | None
    alias_of: str | None
    alias_engine: str | None
    contract: ResolvedInstructionContract | None = None
    alias_catalog_records: tuple[dict[str, object], ...] = ()

    @property
    def ndf_id(self) -> str:
        return instruction_clause_id(self.surface, self.mnemonic)

    @property
    def relative_instruction_path(self) -> Path:
        return self.markdown_path.relative_to("docs")

    @property
    def markdown_path(self) -> Path:
        return doc_path_for(self.source_path)

    @property
    def display_catalog_records(self) -> tuple[dict[str, object], ...]:
        return self.catalog_records or self.alias_catalog_records


@dataclass(frozen=True)
class DocRecord:
    unit: AslUnit
    instruction: InstructionRecord | None

    @property
    def unit_id(self) -> str:
        return self.unit.unit_id

    @property
    def surface(self) -> str:
        return self.unit.surface

    @property
    def classification(self) -> tuple[str, ...]:
        return self.unit.classification

    @property
    def mnemonic(self) -> str | None:
        return self.unit.mnemonic

    @property
    def source_path(self) -> Path:
        return self.unit.source_path

    @property
    def markdown_path(self) -> Path:
        return doc_path_for(self.source_path)


def _parse_regions(path: Path, lines: list[str]) -> dict[str, str]:
    regions: dict[str, str] = {}
    active_name: str | None = None
    active_lines: list[str] = []
    for line_number, line in enumerate(lines, start=1):
        begin = REGION_BEGIN.fullmatch(line)
        end = REGION_END.fullmatch(line)
        if begin:
            if active_name is not None:
                raise ValueError(f"{path}:{line_number}: nested documentation region")
            active_name = begin.group(1)
            if active_name in regions:
                raise ValueError(f"{path}:{line_number}: duplicate region {active_name}")
            active_lines = []
        elif end:
            if active_name != end.group(1):
                raise ValueError(f"{path}:{line_number}: unmatched region end {end.group(1)}")
            regions[active_name] = "\n".join(active_lines).rstrip() + "\n"
            active_name = None
            active_lines = []
        elif active_name is not None:
            active_lines.append(line)
    if active_name is not None:
        raise ValueError(f"{path}: unterminated region {active_name}")
    return regions


def _load_record(root: Path, path: Path) -> InstructionRecord | None:
    lines = path.read_text(encoding="utf-8").splitlines()
    metadata_lines = [line for line in lines if line.startswith(METADATA_PREFIX)]
    if not metadata_lines:
        return None
    if len(metadata_lines) != 1:
        raise ValueError(f"{path}: expected exactly one PTO-INSTRUCTION metadata line")
    try:
        metadata = json.loads(metadata_lines[0][len(METADATA_PREFIX) :])
    except json.JSONDecodeError as error:
        raise ValueError(f"{path}: invalid PTO-INSTRUCTION metadata: {error}") from error

    required = {
        "mnemonic",
        "surface",
        "classification",
        "summary",
        "assembly",
        "block",
        "catalog_records",
        "catalog_indices",
    }
    missing = sorted(required - metadata.keys())
    if missing:
        raise ValueError(f"{path}: missing instruction metadata fields: {', '.join(missing)}")
    surface = metadata["surface"]
    if surface not in SURFACES:
        raise ValueError(f"{path}: unknown instruction surface {surface}")
    classification = tuple(metadata["classification"])
    if not classification:
        raise ValueError(f"{path}: empty instruction classification")
    if surface == "tile" and classification[0] not in TILE_CLASSIFICATIONS:
        raise ValueError(f"{path}: unknown Tile classification {classification[0]}")
    engine = metadata.get("engine")
    if surface == "tile":
        if engine not in TILE_ENGINES:
            raise ValueError(f"{path}: unknown or missing Tile engine {engine!r}")
    elif engine is not None:
        raise ValueError(f"{path}: non-Tile instruction must not declare an engine")
    regions = _parse_regions(path, lines)
    for required_region in ("decode", "operation"):
        if required_region not in regions:
            raise ValueError(f"{path}: missing documentation region {required_region}")
    raw_catalog_records = metadata["catalog_records"]
    if not isinstance(raw_catalog_records, list) or any(
        not isinstance(record, dict) for record in raw_catalog_records
    ):
        raise ValueError(f"{path}: catalog_records must be an array of objects")
    catalog_records = tuple(raw_catalog_records)
    if surface == "tile":
        try:
            catalog_records = tuple(
                derive_tile_catalog_record(
                    record,
                    classification=classification[0],
                    engine=engine,
                )
                for record in catalog_records
            )
        except ValueError as error:
            raise ValueError(f"{path}: {error}") from error
    catalog_indices = tuple(metadata["catalog_indices"])
    alias_of = metadata.get("alias_of")
    alias_engine = metadata.get("alias_engine")
    if alias_of is not None:
        if surface != "block" or not isinstance(alias_of, str) or not alias_of:
            raise ValueError(f"{path}: only Block instructions may declare alias_of")
        if alias_engine not in {"VEC", "SFU"}:
            raise ValueError(f"{path}: Block engine alias must declare VEC or SFU")
        if catalog_records or catalog_indices:
            raise ValueError(f"{path}: encoding alias must not own catalog records")
    elif not catalog_records:
        raise ValueError(f"{path}: instruction has no catalog records")
    elif alias_engine is not None:
        raise ValueError(f"{path}: alias_engine requires alias_of")
    if len(catalog_records) != len(catalog_indices):
        raise ValueError(f"{path}: catalog_records and catalog_indices lengths differ")
    if any(record.get("mnemonic", record.get("name")) != metadata["mnemonic"] for record in catalog_records):
        raise ValueError(f"{path}: catalog record identity differs from mnemonic")
    return InstructionRecord(
        mnemonic=metadata["mnemonic"],
        surface=surface,
        classification=classification,
        summary=metadata["summary"],
        assembly=tuple(metadata["assembly"]),
        block=tuple(metadata["block"]),
        catalog_records=catalog_records,
        catalog_indices=catalog_indices,
        source_path=path.relative_to(root),
        regions=regions,
        engine=engine,
        alias_of=alias_of,
        alias_engine=alias_engine,
    )


def load_instruction_index(root: Path = ROOT) -> list[InstructionRecord]:
    records: list[InstructionRecord] = []
    by_mnemonic: dict[str, Path] = {}
    by_ndf_id: dict[str, Path] = {}
    for path in sorted((root / "asl").rglob("*.asl")):
        record = _load_record(root, path)
        if record is None:
            continue
        if record.mnemonic in by_mnemonic:
            raise ValueError(
                f"duplicate instruction mnemonic {record.mnemonic}: "
                f"{by_mnemonic[record.mnemonic]} and {record.source_path}"
            )
        by_mnemonic[record.mnemonic] = record.source_path
        if record.ndf_id in by_ndf_id:
            raise ValueError(
                f"duplicate instruction NDF identity {record.ndf_id}: "
                f"{by_ndf_id[record.ndf_id]} and {record.source_path}"
            )
        by_ndf_id[record.ndf_id] = record.source_path
        records.append(record)
    by_name = {record.mnemonic: record for record in records}
    resolved: list[InstructionRecord] = []
    for record in records:
        if record.alias_of is None:
            resolved.append(record)
            continue
        target = by_name.get(record.alias_of)
        if target is None:
            raise ValueError(
                f"{record.source_path}: unknown instruction alias target {record.alias_of}"
            )
        if target.alias_of is not None:
            raise ValueError(f"{record.source_path}: instruction alias chain is forbidden")
        if target.surface != record.surface:
            raise ValueError(f"{record.source_path}: alias target surface differs")
        resolved.append(
            replace(record, alias_catalog_records=target.catalog_records)
        )
    units = load_units(root / "asl")
    domains = load_field_domains(units)
    units_by_path = {unit.source_path: unit for unit in units}
    contracted = [
        replace(
            record,
            contract=resolve_instruction_contract(
                units_by_path[record.source_path], domains, require_complete=False
            ),
        )
        for record in resolved
    ]
    return sorted(
        contracted,
        key=lambda record: (record.surface, record.classification, record.mnemonic),
    )


def load_doc_index(root: Path = ROOT) -> list[DocRecord]:
    """Load every ASL unit and bind mnemonic units to instruction metadata."""

    units = load_units(root / "asl")
    instructions = {
        record.source_path: record for record in load_instruction_index(root)
    }
    records: list[DocRecord] = []
    for unit in units:
        instruction = instructions.get(unit.source_path)
        if (unit.mnemonic is None) != (instruction is None):
            raise ValueError(
                f"{unit.source_path}: ASL unit and instruction metadata disagree"
            )
        records.append(DocRecord(unit=unit, instruction=instruction))
    return records


def _generated_region(record: InstructionRecord, name: str) -> list[str]:
    source = record.source_path.as_posix()
    return [
        f"<!-- GENERATED-ASL-BEGIN: {name} source={source} -->",
        "```asl",
        record.regions[name].rstrip(),
        "```",
        f"<!-- GENERATED-ASL-END: {name} -->",
    ]


def _extract_supplementary(markdown: str) -> str:
    if SUPPLEMENTARY_BEGIN not in markdown:
        return markdown.rstrip()
    before, remainder = markdown.split(SUPPLEMENTARY_BEGIN, 1)
    del before
    if SUPPLEMENTARY_END not in remainder:
        raise ValueError("unterminated supplementary Markdown region")
    supplementary, after = remainder.split(SUPPLEMENTARY_END, 1)
    if after.strip():
        raise ValueError("content after supplementary Markdown region")
    return supplementary.strip("\n")


def _markdown_cell(value: object) -> str:
    return str(value).replace("|", "\\|").replace("\n", " ")


def _encoding_section(record: InstructionRecord) -> list[str]:
    encoded_rows: list[list[str]] = []
    tile_rows: list[list[str]] = []
    field_rows: list[list[str]] = []
    for catalog_record in record.display_catalog_records:
        identity = str(
            catalog_record.get("form_id", catalog_record.get("name", record.mnemonic))
        )
        encodings = catalog_record.get("encoding", [])
        if encodings:
            constraints = json.dumps(
                catalog_record.get("constraints", []),
                ensure_ascii=False,
                sort_keys=True,
                separators=(",", ":"),
            )
            for encoding in encodings:
                encoded_rows.append(
                    [
                        identity,
                        str(catalog_record.get("encoding_kind", "")),
                        str(encoding.get("width_bits", catalog_record.get("length_bits", ""))),
                        f"{encoding.get('match', '')} / {encoding.get('mask', '')}",
                        constraints,
                    ]
                )
            for field in catalog_record.get("fields", []):
                pieces = json.dumps(
                    field.get("pieces", []),
                    ensure_ascii=False,
                    sort_keys=True,
                    separators=(",", ":"),
                )
                field_rows.append(
                    [
                        identity,
                        str(field.get("name", "")),
                        str(field.get("width", "")),
                        str(field.get("signedness", "")),
                        pieces,
                    ]
                )
        else:
            tile_rows.append(
                [
                    identity,
                    str(catalog_record.get("family", "")),
                    str(catalog_record.get("selector", "")),
                    str(catalog_record.get("function", "")),
                    str(catalog_record.get("mode", "")),
                    str(catalog_record.get("semantic_handler", "")),
                ]
            )

    lines = ["## Encoding", ""]
    if record.alias_of is not None:
        lines.extend(
            [
                f"This spelling reuses the exact encoding owned by `{record.alias_of}`.",
                "",
            ]
        )
    if encoded_rows:
        lines.extend(
            [
                "| Form | Kind | Bits | Match / mask | Constraints |",
                "| --- | --- | ---: | --- | --- |",
                *[
                    "| " + " | ".join(_markdown_cell(cell) for cell in row) + " |"
                    for row in encoded_rows
                ],
                "",
            ]
        )
    if field_rows:
        lines.extend(
            [
                "### Fields",
                "",
                "| Form | Field | Bits | Signedness | Pieces |",
                "| --- | --- | ---: | --- | --- |",
                *[
                    "| " + " | ".join(_markdown_cell(cell) for cell in row) + " |"
                    for row in field_rows
                ],
                "",
            ]
        )
    if tile_rows:
        lines.extend(
            [
                "| Operation | Encoding carrier | Selector | Function | Mode | Handler |",
                "| --- | --- | --- | ---: | ---: | --- |",
                *[
                    "| " + " | ".join(_markdown_cell(cell) for cell in row) + " |"
                    for row in tile_rows
                ],
                "",
            ]
        )
    return lines


def _operands_section(record: InstructionRecord) -> list[str]:
    rows: list[list[str]] = []
    seen: set[tuple[str, str]] = set()
    if record.contract is not None:
        for operand in record.contract.operands:
            row = (str(operand.get("field", "")), str(operand.get("role", "")))
            if row not in seen:
                seen.add(row)
                rows.append(list(row))
    else:
        for catalog_record in record.display_catalog_records:
            for operand in catalog_record.get("operands", []):
                row = (str(operand.get("field", "")), str(operand.get("role", "")))
                if row not in seen:
                    seen.add(row)
                    rows.append(list(row))
            if not catalog_record.get("operands"):
                for field in catalog_record.get("fields", []):
                    row = (str(field.get("name", "")), "encoded operand or control")
                    if row not in seen:
                        seen.add(row)
                        rows.append(list(row))
    lines = ["## Operands and results", ""]
    if rows:
        lines.extend(
            [
                "| Field | Architectural role |",
                "| --- | --- |",
                *[
                    "| " + " | ".join(_markdown_cell(cell) for cell in row) + " |"
                    for row in rows
                ],
                "",
            ]
        )
    else:
        lines.extend(["This instruction has no explicit operand fields.", ""])
    return lines


def _contract_values(record: InstructionRecord, keys: tuple[str, ...]) -> list[str]:
    values: list[str] = []
    for catalog_record in record.display_catalog_records:
        for key in keys:
            value = catalog_record.get(key)
            if value in (None, "", [], {}):
                continue
            rendered = (
                f"`{value}`"
                if isinstance(value, str)
                else f"`{json.dumps(value, ensure_ascii=False, sort_keys=True)}`"
            )
            entry = f"- **{key.replace('_', ' ').capitalize()}:** {rendered}"
            if entry not in values:
                values.append(entry)
    return values


def _legality_section(record: InstructionRecord) -> list[str]:
    lines = ["## Legality and exceptions", ""]
    values = _contract_values(
        record,
        ("constraints", "legality_handler", "fault_contract", "datr_contract"),
    )
    lines.extend(values or ["- No additional catalog constraint beyond decode legality."])
    lines.append("")
    return lines


def _operational_section(record: InstructionRecord) -> list[str]:
    lines = ["## Operational information", ""]
    values = _contract_values(
        record,
        (
            "semantic_summary",
            "semantic_handler",
            "effect_contract",
            "restart_contract",
            "state_effects",
        ),
    )
    lines.extend(values or [f"- **Summary:** {record.summary}"])
    lines.append("")
    return lines


def _encoding_class_section(record: InstructionRecord) -> list[str]:
    contract = record.contract
    if contract is None:
        return []
    lines = [
        "## Encoding class",
        "",
        f"- **Class:** `{contract.encoding_class}`",
        f"- **Standalone opcode:** `{'yes' if contract.standalone_opcode else 'no'}`",
        "",
    ]
    if not contract.standalone_opcode:
        lines.extend(["This operation has no standalone opcode.", ""])
    return lines


def _field_disposition_section(record: InstructionRecord) -> list[str]:
    contract = record.contract
    if contract is None or not contract.field_domains:
        return []
    lines = ["## Field value dispositions", ""]
    for field_name, domain in contract.field_domains:
        lines.extend(
            [
                f"### {field_name} (`{domain.contract_id}`)",
                "",
                domain.role,
                "",
                f"**Encoded zero:** {domain.zero_meaning}",
                "",
                "| Code | Disposition | Meaning |",
                "| ---: | --- | --- |",
            ]
        )
        assigned = dict(domain.assigned)
        reserved = set(domain.reserved)
        for value in range(1 << domain.width):
            if value in assigned:
                disposition = "assigned"
                meaning = assigned[value]
            elif value in reserved:
                disposition = "reserved"
                meaning = "future extension"
            else:  # pragma: no cover - the validator makes this unreachable
                raise ValueError(
                    f"{domain.contract_id}: unresolved rendered value {value}"
                )
            lines.append(f"| {value} | {disposition} | {meaning} |")
        lines.extend(["", f"**Reserved-value behavior:** {domain.rejection}", ""])
    return lines


def _format_ranges(ranges: tuple[tuple[int, int], ...]) -> str:
    if not ranges:
        return "none"
    return ", ".join(
        str(start) if start == end else f"{start}–{end}"
        for start, end in ranges
    )


def _format_other_owners(values: tuple[tuple[int, str], ...]) -> str:
    if not values:
        return "none"
    return ", ".join(f"{value} ({owner})" for value, owner in values)


def _encoded_field_closure_section(record: InstructionRecord) -> list[str]:
    contract = record.contract
    if contract is None or not contract.encoded_fields:
        return []
    lines = [
        "## Encoded field closure",
        "",
        "Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.",
        "",
        "| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |",
        "| --- | --- | ---: | --- | --- | --- | --- | --- |",
    ]
    for field in contract.encoded_fields:
        lines.append(
            "| "
            + " | ".join(
                _markdown_cell(value)
                for value in (
                    field.form_id,
                    field.field_name,
                    field.width,
                    _format_ranges(field.assigned_ranges),
                    _format_other_owners(field.other_owner_values),
                    _format_ranges(field.reserved_ranges),
                    field.role,
                    field.zero_meaning,
                )
            )
            + " |"
        )
    lines.append("")
    for field in contract.encoded_fields:
        if field.reserved_ranges:
            lines.append(
                f"- `{field.form_id}.{field.field_name}` reserved values: {field.rejection}"
            )
    if any(field.reserved_ranges for field in contract.encoded_fields):
        lines.append("")
    return lines


def _contract_list_section(title: str, values: tuple[str, ...]) -> list[str]:
    return [f"## {title}", "", *[f"- {value}" for value in values], ""]


def _resolved_contract_sections(record: InstructionRecord) -> list[str]:
    contract = record.contract
    if contract is None:
        return [*_legality_section(record), *_operational_section(record)]
    lines: list[str] = []
    lines.extend(_contract_list_section("Defaults and encoded zero", contract.defaults))
    lines.extend(_contract_list_section("Legality", contract.legality))
    lines.extend(_contract_list_section("State effects", contract.state_effects))
    lines.extend(
        [
            "## Memory effects and ordering",
            "",
            "### Memory effects",
            "",
            *[f"- {value}" for value in contract.memory_effects],
            "",
            "### Ordering",
            "",
            *[f"- {value}" for value in contract.ordering],
            "",
        ]
    )
    lines.extend(_contract_list_section("Exceptions", contract.exceptions))
    lines.extend(_contract_list_section("Examples", contract.examples))
    return lines


def render_page(record: InstructionRecord, supplementary: str = "") -> str:
    assembly = (
        record.contract.canonical_assembly
        if record.contract is not None
        else record.assembly
    )
    lines = [
        f"<!-- GENERATED FROM: {record.source_path.as_posix()} -->",
        f"# {record.mnemonic}",
        "",
        f"**Normative ASL source:** `{record.source_path.as_posix()}`",
        "",
        record.summary,
        "",
        f"## Normative identity {{#{record.ndf_id}}}",
        "",
        f"<!-- ndf: kind=executable level=L3 layer={record.surface} status=accepted -->",
        "",
        "The current instruction contract is owned by the ASL source linked above.",
        "",
    ]
    if record.surface == "tile":
        lines.extend(
            [
                "## Classification and execution engine",
                "",
                f"- **Instruction class:** `{record.classification[0]}`",
                f"- **Execution engine:** `{record.engine}`",
                "",
            ]
        )
    if record.alias_of is not None:
        lines.extend(
            [
                "## Alias contract",
                "",
                f"- **Encoding owner:** `{record.alias_of}`",
                f"- **Canonical engine:** `{record.alias_engine}`",
                "",
            ]
        )
    lines.extend(
        [
            "## Assembly",
            "",
            "```asm",
            *assembly,
            "```",
            "",
            *_encoding_section(record),
            *_encoding_class_section(record),
            *_field_disposition_section(record),
            *_encoded_field_closure_section(record),
            *_operands_section(record),
            "## Decode",
            "",
            *_generated_region(record, "decode"),
            "",
        ]
    )
    block_composition = (
        record.contract.block_composition
        if record.contract is not None
        else record.block
    )
    if block_composition != ("none",) and (record.surface == "tile" or record.contract):
        lines.extend(
            [
                "## Block composition",
                "",
                "```asm",
                *block_composition,
                "```",
                "",
            ]
        )
    lines.extend(
        [
            "## Operation",
            "",
            *_generated_region(record, "operation"),
            "",
            *_resolved_contract_sections(record),
            SUPPLEMENTARY_BEGIN,
            supplementary.rstrip(),
            SUPPLEMENTARY_END,
            "",
        ]
    )
    return "\n".join(lines)


def _unit_title(record: DocRecord) -> str:
    if record.mnemonic is not None:
        return record.mnemonic
    words = record.source_path.stem.replace("_", "-").split("-")
    acronyms = {
        "acr": "ACR",
        "agu": "AGU",
        "alu": "ALU",
        "amo": "AMO",
        "asl": "ASL",
        "bru": "BRU",
        "cube": "CUBE",
        "dtype": "Data Type",
        "fsu": "FSU",
        "gpr": "GPR",
        "io": "IO",
        "mx": "MX",
        "ndf": "NDF",
        "pe": "PE",
        "pto": "PTO",
        "sfu": "SFU",
        "sys": "SYS",
        "tepl": "TEPL",
        "tlsu": "TLSU",
        "tso": "TSO",
        "vec": "VEC",
    }
    return " ".join(acronyms.get(word.lower(), word.capitalize()) for word in words)


def render_unit_page(
    record: DocRecord,
    source_text: str,
    supplementary: str = "",
) -> str:
    """Render one active page from its sole normative ASL owner."""

    if record.instruction is not None:
        return render_page(record.instruction, supplementary)
    source = record.source_path.as_posix()
    lines = [
        f"<!-- GENERATED FROM: {source} -->",
        f"# {_unit_title(record)}",
        "",
        f"**Normative ASL source:** `{source}`",
        "",
        "This page is a generated reference view of the normative ASL unit.",
        "",
        f"## ASL unit identity {{#{record.unit_id}}}",
        "",
        "## Normative ASL",
        "",
        f"<!-- GENERATED-ASL-BEGIN: unit source={source} -->",
        "```asl",
        source_text.rstrip(),
        "```",
        "<!-- GENERATED-ASL-END: unit -->",
        "",
        SUPPLEMENTARY_BEGIN,
        supplementary.rstrip(),
        SUPPLEMENTARY_END,
        "",
    ]
    return "\n".join(lines)


def _display_name(slug: str) -> str:
    acronyms = {
        "agu",
        "alu",
        "amo",
        "asl",
        "bru",
        "cube",
        "fsu",
        "gpr",
        "io",
        "mx",
        "ndf",
        "pe",
        "pto",
        "sfu",
        "sys",
        "tepl",
        "tlsu",
        "uop",
        "vec",
    }
    return " ".join(
        part.upper() if part.lower() in acronyms else part.capitalize()
        for part in slug.split("-")
    )


def _render_nav_groups(
    lines: list[str],
    classifications: dict[tuple[str, ...], list[InstructionRecord | DocRecord]],
    markdown_root: Path,
) -> None:
    tree: dict[str, object] = {}
    records_key = "__records__"
    for classification, records in classifications.items():
        node = tree
        for part in classification:
            node = node.setdefault(part, {})  # type: ignore[assignment]
        node.setdefault(records_key, []).extend(records)  # type: ignore[union-attr]

    def render_node(node: dict[str, object], indent: int) -> None:
        for part in sorted(key for key in node if key != records_key):
            lines.append(f"{' ' * indent}- {_display_name(part)}:")
            render_node(node[part], indent + 4)  # type: ignore[arg-type]
        records = node.get(records_key, [])
        for record in sorted(
            records,  # type: ignore[arg-type]
            key=lambda item: item.markdown_path.as_posix(),
        ):
            target = record.markdown_path.relative_to(markdown_root).as_posix()
            title = record.mnemonic if record.mnemonic is not None else _unit_title(record)
            lines.append(f"{' ' * indent}- {title}: {target}")

    render_node(tree, 6)


def render_nav(
    records: list[InstructionRecord | DocRecord],
    markdown_root: Path = Path("docs"),
    root: Path | None = None,
) -> str:
    by_surface: dict[
        str, dict[tuple[str, ...], list[InstructionRecord | DocRecord]]
    ] = {}
    for record in records:
        group = (
            record.classification
            if isinstance(record, InstructionRecord) or record.mnemonic is not None
            else record.classification[:-1]
        )
        by_surface.setdefault(record.surface, {}).setdefault(group, []).append(record)

    lines = ["nav:"]
    if root is not None:
        lines.extend(
            [
                "  - Development:",
                "      - Getting started: development/getting-started.md",
                "      - Repository layout: development/repository-layout.md",
                "  - Governance:",
                "      - ADR process and decision index: governance/adr-process.md",
                "      - Validation: governance/validation.md",
                "  - Releases:",
                "      - Release index: releases/index.md",
            ]
        )
    for surface in SURFACE_ORDER:
        classifications = by_surface.get(surface)
        if not classifications:
            continue
        lines.append(f"  - {surface.capitalize()}:")
        _render_nav_groups(lines, classifications, markdown_root)
    if root is not None:
        status_groups: list[tuple[str, list[Path]]] = []
        for name in ("decisions", "open"):
            directory = root / "docs/status" / name
            pages = (
                sorted(
                    path
                    for path in directory.rglob("*.md")
                    if path.name != "0000-template.md"
                )
                if directory.exists()
                else []
            )
            if pages:
                status_groups.append((name, pages))
        if status_groups:
            lines.append("  - Status:")
            for name, pages in status_groups:
                lines.append(f"      - {_display_name(name)}:")
                for path in pages:
                    relative = path.relative_to(root / "docs").as_posix()
                    title_match = re.search(
                        r"^#\s+(.+)$",
                        path.read_text(encoding="utf-8"),
                        re.MULTILINE,
                    )
                    title = title_match.group(1).strip() if title_match else path.stem
                    yaml_title = json.dumps(title, ensure_ascii=False)
                    lines.append(f"          - {yaml_title}: {relative}")
    return "\n".join(lines) + "\n"


def _render_mkdocs_config(records: list[DocRecord], root: Path) -> str:
    return (
        "site_name: PTO ISA Reference\n"
        "site_description: Generated projection of the normative PTO ASL instruction sources\n"
        "docs_dir: ..\n"
        "site_dir: ../../build/mkdocs-site\n"
        "use_directory_urls: false\n"
        "exclude_docs: |\n"
        "  mkdocs/**\n"
        "theme:\n"
        "  name: mkdocs\n"
        "strict: true\n"
        + render_nav(records, Path("docs"), root)
    )


def generate_tree(root: Path = ROOT) -> None:
    records = load_doc_index(root)
    for record in records:
        path = root / record.markdown_path
        path.parent.mkdir(parents=True, exist_ok=True)
        supplementary = ""
        if path.exists():
            supplementary = _extract_supplementary(path.read_text(encoding="utf-8"))
        source_text = (root / record.source_path).read_text(encoding="utf-8")
        path.write_text(
            render_unit_page(record, source_text, supplementary),
            encoding="utf-8",
        )
    mkdocs_directory = root / "docs/mkdocs"
    mkdocs_directory.mkdir(parents=True, exist_ok=True)
    (mkdocs_directory / "generated-nav.yml").write_text(
        render_nav(records, Path("docs"), root), encoding="utf-8"
    )
    (mkdocs_directory / "mkdocs.yml").write_text(
        _render_mkdocs_config(records, root), encoding="utf-8"
    )


def _active_markdown_files(root: Path) -> set[Path]:
    files: set[Path] = set()
    for surface in sorted(SURFACES):
        directory = root / "docs" / surface
        if not directory.exists():
            continue
        for path in directory.rglob("*.md"):
            files.add(path.relative_to(root))
    return files


def check_tree(root: Path = ROOT) -> list[str]:
    errors: list[str] = []
    records = load_doc_index(root)
    expected_pages = {record.markdown_path: record for record in records}
    actual_pages = _active_markdown_files(root)

    for record in records:
        if record.instruction is not None:
            instruction = record.instruction
            asl_relative = record.source_path.relative_to("asl")
            expected_asl = Path(
                record.surface,
                *record.classification,
                f"{mnemonic_file_name(instruction.mnemonic)}.asl",
            )
            if asl_relative != expected_asl:
                errors.append(
                    f"{instruction.mnemonic} metadata classification "
                    f"{'/'.join(record.classification)} does not match ASL path "
                    f"{asl_relative.as_posix()}"
                )
        page_path = root / record.markdown_path
        identity = record.mnemonic or record.unit_id
        if not page_path.exists():
            errors.append(
                f"missing Markdown page for {identity}: {record.markdown_path.as_posix()}"
            )
        else:
            current = page_path.read_text(encoding="utf-8")
            try:
                expected = render_unit_page(
                    record,
                    (root / record.source_path).read_text(encoding="utf-8"),
                    _extract_supplementary(current),
                )
            except ValueError as error:
                errors.append(f"invalid Markdown regions for {identity}: {error}")
            else:
                if current != expected:
                    errors.append(f"stale generated Markdown page for {identity}")

    for path in sorted(actual_pages - set(expected_pages)):
        errors.append(f"missing ASL source for {path.as_posix()}")
    return errors


def check_version_neutrality(root: Path = ROOT) -> list[str]:
    errors: list[str] = []
    active_files = list((root / "asl").rglob("*.asl"))
    for surface in sorted(SURFACES):
        surface_root = root / "docs" / surface
        if surface_root.exists():
            active_files.extend(surface_root.rglob("*.md"))
    for path in sorted(active_files):
        for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
            match = VERSION_PATTERN.search(line)
            if match:
                relative = path.relative_to(root).as_posix()
                errors.append(
                    f"{relative}:{line_number}: active normative surface contains release version "
                    f"{match.group(0)}"
                )
    return errors


def check_navigation(root: Path = ROOT) -> list[str]:
    config = root / "docs/mkdocs/mkdocs.yml"
    if not config.exists():
        return ["missing MkDocs configuration: docs/mkdocs/mkdocs.yml"]
    lines = config.read_text(encoding="utf-8").splitlines()
    try:
        nav_start = lines.index("nav:")
    except ValueError:
        return ["MkDocs configuration is missing navigation"]
    navigation = "\n".join(lines[nav_start + 1 :])
    if re.search(r"(?:^|[\s:])status/legacy/", navigation):
        return ["MkDocs navigation includes non-normative legacy material"]
    return []


def check_navigation_projection(root: Path = ROOT) -> list[str]:
    records = load_doc_index(root)
    projections = (
        (
            root / "docs/mkdocs/generated-nav.yml",
            render_nav(records, Path("docs"), root),
        ),
        (
            root / "docs/mkdocs/mkdocs.yml",
            _render_mkdocs_config(records, root),
        ),
    )
    errors: list[str] = []
    for path, expected in projections:
        relative = path.relative_to(root).as_posix()
        if not path.exists() or path.read_text(encoding="utf-8") != expected:
            errors.append(f"stale generated MkDocs navigation: {relative}")
    return errors


def check_normative_legacy_links(root: Path = ROOT) -> list[str]:
    errors: list[str] = []
    active_files = list((root / "asl").rglob("*.asl"))
    for surface in sorted(SURFACES):
        directory = root / "docs" / surface
        if directory.exists():
            active_files.extend(directory.rglob("*.md"))
    for path in sorted(active_files):
        if "docs/status/legacy/" in path.read_text(encoding="utf-8"):
            errors.append(
                f"{path.relative_to(root).as_posix()}: normative reference targets "
                "non-normative legacy material"
            )
    return errors


def check_catalog_projection(root: Path = ROOT) -> list[str]:
    errors: list[str] = []
    records = load_instruction_index(root)
    catalog_specs = {
        "scalar": ("scalar-forms.json", "forms"),
        "block": ("command-forms.json", "forms"),
        "tile": ("tile-operations.json", "operations"),
    }
    for surface, (file_name, member) in catalog_specs.items():
        indexed: list[tuple[int, dict[str, object]]] = []
        for record in records:
            if record.surface != surface:
                continue
            indexed.extend(zip(record.catalog_indices, record.catalog_records, strict=True))
        indices = [index for index, _ in indexed]
        if len(indices) != len(set(indices)):
            errors.append(f"{surface} mnemonic ASL records contain duplicate catalog indices")
            continue
        projected = [item for _, item in sorted(indexed, key=lambda pair: pair[0])]
        catalog_path = root / "spec/catalog" / file_name
        if not catalog_path.exists():
            if projected:
                errors.append(f"missing {surface} catalog {catalog_path.relative_to(root).as_posix()}")
            continue
        catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
        if catalog.get(member, []) != projected:
            errors.append(f"{surface} catalog projection differs from mnemonic ASL records")
    return errors


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", nargs="?", choices=("generate",), default=None)
    parser.add_argument("--write", action="store_true")
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args(argv)
    if args.command == "generate" or args.write:
        generate_tree(ROOT)
    if args.check or args.command is None:
        errors = (
            check_tree(ROOT)
            + check_catalog_projection(ROOT)
            + check_version_neutrality(ROOT)
            + check_navigation(ROOT)
            + check_navigation_projection(ROOT)
            + check_normative_legacy_links(ROOT)
        )
        if errors:
            print("\n".join(errors), file=sys.stderr)
            return 1
        records = load_doc_index(ROOT)
        print(
            "instruction docs passed: "
            f"{len(records)} ASL units, "
            f"{sum(record.mnemonic is not None for record in records)} mnemonic records"
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
