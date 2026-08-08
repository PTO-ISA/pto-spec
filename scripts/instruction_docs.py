#!/usr/bin/env python3
"""Generate and verify instruction Markdown from mnemonic ASL sources."""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from scripts.asl_units import AslUnit, load_units  # noqa: E402
from scripts.ndf import instruction_clause_id  # noqa: E402


METADATA_PREFIX = "// PTO-INSTRUCTION: "
REGION_BEGIN = re.compile(r"^// DOC-BEGIN: ([a-z][a-z0-9-]*)$")
REGION_END = re.compile(r"^// DOC-END: ([a-z][a-z0-9-]*)$")
SURFACES = {"arch", "scalar", "block", "tile"}
TILE_CLASSIFICATIONS = {
    "tile-tile-elementwise",
    "unary-tile-elementwise",
    "tile-scalar-elementwise",
    "reduction",
    "vector-tile-expansion",
    "matrix",
    "memory",
    "complex-layout",
}
SURFACE_ORDER = ("arch", "block", "scalar", "tile")
SUPPLEMENTARY_BEGIN = "<!-- SUPPLEMENTARY-BEGIN -->"
SUPPLEMENTARY_END = "<!-- SUPPLEMENTARY-END -->"
LEGACY_BANNER = (
    "> Historical, non-normative material. This page is excluded from the active "
    "PTO architecture and release closure."
)
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

    @property
    def ndf_id(self) -> str:
        return instruction_clause_id(self.surface, self.mnemonic)

    @property
    def relative_instruction_path(self) -> Path:
        return self.markdown_path.relative_to("docs")

    @property
    def markdown_path(self) -> Path:
        return doc_path_for(self.source_path)


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
    regions = _parse_regions(path, lines)
    for required_region in ("decode", "operation"):
        if required_region not in regions:
            raise ValueError(f"{path}: missing documentation region {required_region}")
    catalog_records = tuple(metadata["catalog_records"])
    catalog_indices = tuple(metadata["catalog_indices"])
    if not catalog_records:
        raise ValueError(f"{path}: instruction has no catalog records")
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
    return sorted(records, key=lambda record: (record.surface, record.classification, record.mnemonic))


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
    for catalog_record in record.catalog_records:
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
                "| Operation | Family | Selector | Function | Mode | Handler |",
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
    for catalog_record in record.catalog_records:
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
    for catalog_record in record.catalog_records:
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


def render_page(record: InstructionRecord, supplementary: str = "") -> str:
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
        "## Assembly",
        "",
        "```asm",
        *record.assembly,
        "```",
        "",
        *_encoding_section(record),
        *_operands_section(record),
        "## Decode",
        "",
        *_generated_region(record, "decode"),
        "",
    ]
    if record.surface == "tile":
        lines.extend(
            [
                "## Block composition",
                "",
                "```asm",
                *record.block,
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
            *_legality_section(record),
            *_operational_section(record),
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
        "asl": "ASL",
        "dtype": "Data Type",
        "gpr": "GPR",
        "ndf": "NDF",
        "pe": "PE",
        "pto": "PTO",
        "tso": "TSO",
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
    if slug in {"agu", "alu", "amo", "bru", "fsu", "sys"}:
        return slug.upper()
    return " ".join(part.capitalize() for part in slug.split("-"))


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
    for surface in SURFACE_ORDER:
        classifications = by_surface.get(surface)
        if not classifications:
            continue
        lines.append(f"  - {surface.capitalize()}:")
        for classification in sorted(classifications):
            indent = 6
            for part in classification:
                lines.append(f"{' ' * indent}- {_display_name(part)}:")
                indent += 4
            for record in sorted(
                classifications[classification],
                key=lambda item: item.markdown_path.as_posix(),
            ):
                target = record.markdown_path.relative_to(markdown_root).as_posix()
                title = (
                    record.mnemonic
                    if record.mnemonic is not None
                    else _unit_title(record)
                )
                lines.append(f"{' ' * indent}- {title}: {target}")
    if root is not None:
        status_groups: list[tuple[str, list[Path]]] = []
        for name in ("decisions", "open"):
            directory = root / "docs/status" / name
            pages = sorted(directory.rglob("*.md")) if directory.exists() else []
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
        "  status/legacy/**\n"
        "  mkdocs/**\n"
        "  superpowers/**\n"
        "theme:\n"
        "  name: mkdocs\n"
        "strict: true\n"
        + render_nav(records, Path("docs"), root)
    )


def _render_legacy_page(markdown: str, path: Path) -> str:
    lines = markdown.splitlines()
    try:
        title_index = next(
            index for index, line in enumerate(lines) if line.startswith("# ")
        )
    except StopIteration as error:
        raise ValueError(f"{path}: legacy Markdown page has no level-one title") from error
    remainder = lines[title_index + 1 :]
    while remainder and not remainder[0].strip():
        remainder.pop(0)
    if remainder and remainder[0] == LEGACY_BANNER:
        remainder.pop(0)
        while remainder and not remainder[0].strip():
            remainder.pop(0)
    rendered = [*lines[: title_index + 1], "", LEGACY_BANNER]
    if remainder:
        rendered.extend(["", *remainder])
    return "\n".join(rendered).rstrip() + "\n"


def _write_legacy_banners(root: Path) -> None:
    directory = root / "docs/status/legacy"
    for path in sorted(directory.rglob("*.md")) if directory.exists() else []:
        path.write_text(
            _render_legacy_page(path.read_text(encoding="utf-8"), path),
            encoding="utf-8",
        )


def check_legacy_banners(root: Path = ROOT) -> list[str]:
    errors: list[str] = []
    directory = root / "docs/status/legacy"
    for path in sorted(directory.rglob("*.md")) if directory.exists() else []:
        relative = path.relative_to(root).as_posix()
        current = path.read_text(encoding="utf-8")
        try:
            expected = _render_legacy_page(current, path)
        except ValueError as error:
            errors.append(str(error))
        else:
            if current != expected:
                errors.append(f"{relative}: missing non-normative legacy banner")
    return errors


def generate_tree(root: Path = ROOT) -> None:
    _write_legacy_banners(root)
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
            + check_normative_legacy_links(ROOT)
            + check_legacy_banners(ROOT)
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
