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
METADATA_PREFIX = "// PTO-INSTRUCTION: "
REGION_BEGIN = re.compile(r"^// DOC-BEGIN: ([a-z][a-z0-9-]*)$")
REGION_END = re.compile(r"^// DOC-END: ([a-z][a-z0-9-]*)$")
SURFACES = {"scalar", "block", "tile"}
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
SURFACE_ORDER = ("scalar", "block", "tile")
SUPPLEMENTARY_BEGIN = "<!-- SUPPLEMENTARY-BEGIN -->"
SUPPLEMENTARY_END = "<!-- SUPPLEMENTARY-END -->"
VERSION_PATTERN = re.compile(r"\b0\.58(?:\.0)?\b")


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
    def relative_instruction_path(self) -> Path:
        return Path(self.surface, *self.classification, f"{mnemonic_file_name(self.mnemonic)}.md")

    @property
    def markdown_path(self) -> Path:
        return Path("docs/instructions") / self.relative_instruction_path


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
        records.append(record)
    return sorted(records, key=lambda record: (record.surface, record.classification, record.mnemonic))


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


def render_page(record: InstructionRecord, supplementary: str = "") -> str:
    lines = [
        f"# {record.mnemonic}",
        "",
        record.summary,
        "",
        f"<!-- ASL-SOURCE: {record.source_path.as_posix()} -->",
        "",
        "## Assembly",
        "",
        "```asm",
        *record.assembly,
        "```",
        "",
        "## Decode",
        "",
        *_generated_region(record, "decode"),
        "",
        "## Assembler symbols",
        "",
        "Supplementary operand names and examples may be added here.",
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
            "## Legality and exceptions",
            "",
            "Normative legality is embedded from the ASL source above.",
            "",
            "## Operational information",
            "",
            "Supplementary implementation-neutral guidance may be added here.",
            "",
            SUPPLEMENTARY_BEGIN,
            supplementary.rstrip(),
            SUPPLEMENTARY_END,
            "",
        ]
    )
    return "\n".join(lines)


def _display_name(slug: str) -> str:
    if slug in {"agu", "alu", "amo", "bru", "fsu", "sys"}:
        return slug.upper()
    return " ".join(part.capitalize() for part in slug.split("-"))


def render_nav(records: list[InstructionRecord]) -> str:
    by_surface: dict[str, dict[tuple[str, ...], list[InstructionRecord]]] = {}
    for record in records:
        by_surface.setdefault(record.surface, {}).setdefault(record.classification, []).append(record)

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
            for record in sorted(classifications[classification], key=lambda item: item.mnemonic):
                target = record.markdown_path.relative_to("docs").as_posix()
                lines.append(f"{' ' * indent}- {record.mnemonic}: {target}")
    return "\n".join(lines) + "\n"


def _render_mkdocs_config(records: list[InstructionRecord]) -> str:
    return (
        "site_name: PTO ISA Reference\n"
        "docs_dir: ..\n"
        "site_dir: ../../build/mkdocs-site\n"
        "theme:\n"
        "  name: mkdocs\n"
        "strict: true\n"
        + render_nav(records)
    )


def generate_tree(root: Path = ROOT) -> None:
    records = load_instruction_index(root)
    for record in records:
        path = root / record.markdown_path
        path.parent.mkdir(parents=True, exist_ok=True)
        supplementary = ""
        if path.exists():
            supplementary = _extract_supplementary(path.read_text(encoding="utf-8"))
        path.write_text(render_page(record, supplementary), encoding="utf-8")
    mkdocs_directory = root / "docs/mkdocs"
    mkdocs_directory.mkdir(parents=True, exist_ok=True)
    (mkdocs_directory / "generated-nav.yml").write_text(render_nav(records), encoding="utf-8")
    (mkdocs_directory / "mkdocs.yml").write_text(
        _render_mkdocs_config(records), encoding="utf-8"
    )


def _instruction_markdown_files(root: Path) -> set[Path]:
    base = root / "docs/instructions"
    files: set[Path] = set()
    if not base.exists():
        return files
    for surface in sorted(SURFACES):
        directory = base / surface
        if not directory.exists():
            continue
        for path in directory.rglob("*.md"):
            if path.name == "README.md" or "support" in path.relative_to(directory).parts:
                continue
            files.add(path.relative_to(root))
    return files


def check_tree(root: Path = ROOT) -> list[str]:
    errors: list[str] = []
    records = load_instruction_index(root)
    expected_pages = {record.markdown_path: record for record in records}
    actual_pages = _instruction_markdown_files(root)

    for record in records:
        asl_relative = record.source_path.relative_to("asl")
        expected_asl = Path(
            record.surface,
            *record.classification,
            f"{mnemonic_file_name(record.mnemonic)}.asl",
        )
        if asl_relative != expected_asl:
            errors.append(
                f"{record.mnemonic} metadata classification "
                f"{'/'.join(record.classification)} does not match ASL path {asl_relative.as_posix()}"
            )
        page_path = root / record.markdown_path
        if not page_path.exists():
            errors.append(
                f"missing Markdown page for {record.mnemonic}: {record.markdown_path.as_posix()}"
            )
        else:
            current = page_path.read_text(encoding="utf-8")
            try:
                expected = render_page(record, _extract_supplementary(current))
            except ValueError as error:
                errors.append(f"invalid Markdown regions for {record.mnemonic}: {error}")
            else:
                if current != expected:
                    errors.append(f"stale generated Markdown page for {record.mnemonic}")

    for path in sorted(actual_pages - set(expected_pages)):
        errors.append(f"missing ASL source for {path.as_posix()}")
    return errors


def check_version_neutrality(root: Path = ROOT) -> list[str]:
    errors: list[str] = []
    active_files = list((root / "asl").rglob("*.asl"))
    instruction_root = root / "docs/instructions"
    if instruction_root.exists():
        active_files.extend(instruction_root.rglob("*.md"))
    architecture = root / "docs/architecture.md"
    if architecture.exists():
        active_files.append(architecture)
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
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args(argv)
    if args.command == "generate":
        generate_tree(ROOT)
    if args.check or args.command is None:
        errors = (
            check_tree(ROOT)
            + check_catalog_projection(ROOT)
            + check_version_neutrality(ROOT)
        )
        if errors:
            print("\n".join(errors), file=sys.stderr)
            return 1
        print(f"instruction docs passed: {len(load_instruction_index(ROOT))} mnemonic records")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
