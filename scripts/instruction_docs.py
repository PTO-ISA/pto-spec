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


@dataclass(frozen=True)
class InstructionRecord:
    mnemonic: str
    surface: str
    classification: tuple[str, ...]
    summary: str
    assembly: tuple[str, ...]
    block: tuple[str, ...]
    source_path: Path
    regions: dict[str, str]

    @property
    def relative_instruction_path(self) -> Path:
        return Path(self.surface, *self.classification, f"{self.mnemonic}.md")

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

    required = {"mnemonic", "surface", "classification", "summary", "assembly", "block"}
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
    return InstructionRecord(
        mnemonic=metadata["mnemonic"],
        surface=surface,
        classification=classification,
        summary=metadata["summary"],
        assembly=tuple(metadata["assembly"]),
        block=tuple(metadata["block"]),
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


def render_page(record: InstructionRecord) -> str:
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
        ]
    )
    return "\n".join(lines)


def generate_tree(root: Path = ROOT) -> None:
    for record in load_instruction_index(root):
        path = root / record.markdown_path
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(render_page(record), encoding="utf-8")


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
        expected_asl = Path(record.surface, *record.classification, f"{record.mnemonic}.asl")
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
        elif page_path.read_text(encoding="utf-8") != render_page(record):
            errors.append(f"stale generated Markdown page for {record.mnemonic}")

    for path in sorted(actual_pages - set(expected_pages)):
        errors.append(f"missing ASL source for {path.as_posix()}")
    return errors


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", nargs="?", choices=("generate",), default=None)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args(argv)
    if args.command == "generate":
        generate_tree(ROOT)
    if args.check or args.command is None:
        errors = check_tree(ROOT)
        if errors:
            print("\n".join(errors), file=sys.stderr)
            return 1
        print(f"instruction docs passed: {len(load_instruction_index(ROOT))} mnemonic records")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
