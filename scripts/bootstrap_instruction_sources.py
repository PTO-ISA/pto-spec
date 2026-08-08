#!/usr/bin/env python3
"""One-time migration from checked catalogs to mnemonic ASL contract sources."""

from __future__ import annotations

import argparse
import json
import re
from collections import defaultdict
from pathlib import Path

from scripts.instruction_docs import ROOT, load_instruction_index, mnemonic_file_name


TILE_CATEGORY = {
    "Tile-Tile Elementwise": "tile-tile-elementwise",
    "Unary Tile Elementwise": "unary-tile-elementwise",
    "Tile Scalar Elementwise": "tile-scalar-elementwise",
    "Tile Operation Reduce": "reduction",
    "1D Vector+2D Tile": "vector-tile-expansion",
    "MATRIX Operation": "matrix",
    "Tile Memory Operation": "memory",
    "Complex Layout Transformation": "complex-layout",
}
TILE_SUBCATEGORY = {
    "算术计算": "arithmetic",
    "算数计算": "arithmetic",
    "逻辑计算": "logical",
    "超越函数": "transcendental",
    "2D到一行": "column-reduction",
    "2D到一列": "row-reduction",
    "一行和2D": "row-expansion",
    "一列和2D": "column-expansion",
    "矩阵乘矩阵": "matrix-matrix",
    "矩阵乘向量": "matrix-vector",
    "规则访存": "regular",
    "不规则访存": "irregular",
    "原子不规则访存": "irregular",
    "PE间搬运": "pe-movement",
    "初始化操作": "initialization",
    "直方图": "initialization",
    "格式转换": "format-conversion",
    "Layout变换": "layout",
    "Tile搬运": "layout",
    "排序": "sorting",
    "Union操作": "union",
}


def _identifier(mnemonic: str) -> str:
    return re.sub(r"[^A-Za-z0-9]+", "_", mnemonic).strip("_")


def _read_frontmatter(path: Path) -> dict[str, object]:
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        raise ValueError(f"{path}: missing JSON frontmatter")
    end = text.find("\n---\n", 4)
    if end < 0:
        raise ValueError(f"{path}: unterminated JSON frontmatter")
    return json.loads(text[4:end])


def _tile_metadata(root: Path, mnemonic: str) -> tuple[tuple[str, ...], tuple[str, ...]]:
    matches = sorted((root / "docs/tile").rglob(f"{mnemonic}.md"))
    if len(matches) != 1:
        raise ValueError(f"expected one mirrored page for {mnemonic}, found {len(matches)}")
    page = matches[0]
    metadata = _read_frontmatter(page)
    xlsx = metadata["xlsx"]
    category_label = xlsx["category"].splitlines()[0]
    subcategory_label = xlsx["subcategory"]
    try:
        classification = (
            TILE_CATEGORY[category_label],
            TILE_SUBCATEGORY[subcategory_label],
        )
    except KeyError as error:
        raise ValueError(
            f"{page}: unknown workbook classification {category_label!r}/{subcategory_label!r}"
        ) from error
    source_lines = [line.strip() for line in metadata["bundle"].splitlines() if line.strip()]
    block_lines: list[str] = []
    active_form = False
    for line in source_lines:
        if line.startswith("BSTART"):
            if active_form:
                block_lines.append("BSTOP")
            block_lines.append(line)
            active_form = True
        elif active_form and line.startswith("B."):
            block_lines.append(line)
        else:
            if active_form:
                block_lines.append("BSTOP")
                active_form = False
            block_lines.append(f"# {line}")
    if not active_form:
        raise ValueError(f"{page}: Tile block contains no BSTART")
    if block_lines[-1] != "BSTOP":
        block_lines.append("BSTOP")
    if classification[0] == "matrix":
        block_lines = [
            line.replace("B.DIM LB0 M", "B.DIM LB0 N")
            .replace("B.DIM LB1 N", "B.DIM LB1 M")
            .replace("B.DIM LB2 K", "B.DIM LB2 Col")
            for line in block_lines
        ]
    return classification, tuple(block_lines)


def _block_classification(mnemonic: str) -> tuple[str, ...]:
    if mnemonic in {"B.CATR", "B.DATR", "B.DIM", "C.B.DIMI"}:
        return ("attributes",)
    if mnemonic.startswith("B.IO"):
        return ("operands",)
    if mnemonic in {"BSTART", "BSTOP", "C.BSTOP", "B.HINT", "B.TEXT"}:
        return ("lifecycle",)
    if mnemonic.startswith(("C.BSTART", "L.BSTART", "HL.BSTART")) or mnemonic == "XB":
        return ("encoding",)
    if mnemonic.startswith("BSTART"):
        return ("execution",)
    return ("lifecycle",)


def _metadata_line(metadata: dict[str, object]) -> str:
    return "// PTO-INSTRUCTION: " + json.dumps(
        metadata, ensure_ascii=False, sort_keys=True, separators=(",", ":")
    )


def _block_normative_contract(mnemonic: str) -> str:
    if mnemonic == "B.DIM":
        return """type BundleDimensionRole of enumeration {
    BundleDimension_ValidColumns,
    BundleDimension_ValidRows,
    BundleDimension_PhysicalColumns
};

pure func BundleDimensionIndexOfRole(role: BundleDimensionRole)
    => BundleDimensionIndex
begin
    case role of
        when BundleDimension_ValidColumns => return 0;
        when BundleDimension_ValidRows => return 1;
        when BundleDimension_PhysicalColumns => return 2;
    end;
end;

"""
    if mnemonic == "B.IOT":
        return """pure func InstructionContractZeroMaskIsNoOp_B_IOT(
    pe_mask: bits(4)) => boolean
begin
    return pe_mask == Zeros{4};
end;

pure func InstructionContractHasMaskOnlySharedCompanion_B_IOT() => boolean
begin
    return FALSE;
end;

pure func InstructionContractPerPECapacity_B_IOT(
    size_code: integer {1..7}) => integer
begin
    return TileSizeCodeBytes(size_code);
end;

pure func InstructionContractCoreCapacity_B_IOT(
    size_code: integer {1..7}, pe_mask: bits(4)) => integer
begin
    return TileCoreAllocationBytes(pe_mask,
        InstructionContractPerPECapacity_B_IOT(size_code));
end;

"""
    if mnemonic == "B.IOS":
        return """pure func InstructionContractSharedIsSource_B_IOS(
    size_code: integer {0..7}) => boolean
begin
    return size_code == 0;
end;

pure func InstructionContractPerPECapacity_B_IOS(
    size_code: integer {1..7}) => integer
begin
    return TileSizeCodeBytes(size_code);
end;

pure func InstructionContractCoreCapacity_B_IOS(
    size_code: integer {1..7}, pe_mask: bits(4)) => integer
begin
    return TileCoreAllocationBytes(pe_mask,
        InstructionContractPerPECapacity_B_IOS(size_code));
end;

"""
    return ""


def _render_scalar(
    mnemonic: str, forms: list[tuple[int, dict[str, object]]]
) -> tuple[tuple[str, ...], str]:
    family = forms[0][1]["semantic_family"].lower()
    handlers = {form["semantic_handler"] for _, form in forms}
    if len(handlers) != 1:
        raise ValueError(f"{mnemonic}: scalar forms disagree on semantic handler")
    handler = handlers.pop()
    identifier = _identifier(mnemonic)
    metadata = {
        "assembly": list(dict.fromkeys(form["asm"] for _, form in forms)),
        "block": [],
        "catalog_indices": [index for index, _ in forms],
        "catalog_records": [form for _, form in forms],
        "classification": [family],
        "mnemonic": mnemonic,
        "summary": f"Execute the {mnemonic} scalar instruction contract.",
        "surface": "scalar",
    }
    text = (
        _metadata_line(metadata)
        + "\n// DOC-BEGIN: decode\n"
        + f"readonly func InstructionContractOperation_{identifier}() => ScalarOperation\n"
        + "begin\n"
        + f"    return ScalarOperation_{identifier};\n"
        + "end;\n"
        + "// DOC-END: decode\n"
        + "// DOC-BEGIN: operation\n"
        + f"readonly func InstructionContractHandler_{identifier}() => ScalarSemanticHandler\n"
        + "begin\n"
        + f"    return ScalarHandler_{handler};\n"
        + "end;\n"
        + "// DOC-END: operation\n"
    )
    return (family,), text


def _render_block(
    mnemonic: str, forms: list[tuple[int, dict[str, object]]]
) -> tuple[tuple[str, ...], str]:
    handlers = {form["semantic_handler"] for _, form in forms}
    if len(handlers) != 1:
        raise ValueError(f"{mnemonic}: command forms disagree on semantic handler")
    handler = handlers.pop()
    identifier = _identifier(mnemonic)
    classification = _block_classification(mnemonic)
    summary = next(
        (form["semantic_summary"] for _, form in forms if form.get("semantic_summary")),
        f"Execute the {mnemonic} block instruction contract.",
    )
    metadata = {
        "assembly": list(dict.fromkeys(form["asm"] for _, form in forms)),
        "block": [],
        "catalog_indices": [index for index, _ in forms],
        "catalog_records": [form for _, form in forms],
        "classification": list(classification),
        "mnemonic": mnemonic,
        "summary": summary,
        "surface": "block",
    }
    comparisons = [
        f"(operation == CommandOperation_{form['form_id']})" for _, form in forms
    ]
    text = (
        _metadata_line(metadata)
        + "\n// DOC-BEGIN: decode\n"
        + f"readonly func InstructionContractMatches_{identifier}(operation: CommandOperation) => boolean\n"
        + "begin\n"
        + "    return "
        + " ||\n           ".join(comparisons)
        + ";\n"
        + "end;\n"
        + "// DOC-END: decode\n"
        + "// DOC-BEGIN: operation\n"
        + _block_normative_contract(mnemonic)
        + f"readonly func InstructionContractHandler_{identifier}() => CommandSemanticHandler\n"
        + "begin\n"
        + f"    return CommandHandler_{handler};\n"
        + "end;\n"
        + "// DOC-END: operation\n"
    )
    return classification, text


def _render_tile(
    root: Path, mnemonic: str, index: int, operation: dict[str, object]
) -> tuple[tuple[str, ...], str]:
    classification, block = _tile_metadata(root, mnemonic)
    handler = operation["semantic_handler"]
    identifier = _identifier(mnemonic)
    metadata = {
        "assembly": [f"{mnemonic} <bundle operands>"],
        "block": list(block),
        "catalog_indices": [index],
        "catalog_records": [operation],
        "classification": list(classification),
        "mnemonic": mnemonic,
        "summary": f"Execute the {mnemonic} Tile operation contract.",
        "surface": "tile",
    }
    normative_contract = ""
    if classification[0] == "matrix":
        normative_contract = (
            f"readonly func InstructionContractMatrixShapeLegal_{identifier}("
            "left: TileIndex, right: TileIndex) => boolean\n"
            "begin\n"
            "    return TileMatrixShapeLegal(left, right);\n"
            "end;\n\n"
        )
    if mnemonic == "TLOAD":
        normative_contract += (
            "pure func InstructionContractDestinationShapeLegal_TLOAD(\n"
            "    size_code: integer {1..7}, columns: integer {0..65535},\n"
            "    valid_rows: integer {0..65535},\n"
            "    valid_columns: integer {0..65535},\n"
            "    data_type: TileDataType) => boolean\n"
            "begin\n"
            "    return TileDescriptorShapeLegal(TileSizeCodeBytes(size_code), columns,\n"
            "        valid_rows, valid_columns, data_type);\n"
            "end;\n\n"
        )
    text = (
        _metadata_line(metadata)
        + "\n// DOC-BEGIN: decode\n"
        + f"readonly func InstructionContractOperation_{identifier}() => TileOperation\n"
        + "begin\n"
        + f"    return TileOperation_{identifier};\n"
        + "end;\n"
        + "// DOC-END: decode\n"
        + "// DOC-BEGIN: operation\n"
        + normative_contract
        + f"readonly func InstructionContractHandler_{identifier}() => TileSemanticHandler\n"
        + "begin\n"
        + f"    return TileHandler_{handler};\n"
        + "end;\n"
        + "// DOC-END: operation\n"
    )
    return classification, text


def _grouped(items: list[dict[str, object]], identity: str) -> dict[str, list[tuple[int, dict[str, object]]]]:
    grouped: dict[str, list[tuple[int, dict[str, object]]]] = defaultdict(list)
    for index, item in enumerate(items):
        grouped[item[identity]].append((index, item))
    return grouped


def bootstrap_instruction_sources(root: Path = ROOT) -> None:
    if load_instruction_index(root):
        raise ValueError("mnemonic ASL sources already exist; bootstrap is one-time only")
    catalog_root = root / "spec/catalog"
    scalar = json.loads((catalog_root / "scalar-forms.json").read_text(encoding="utf-8"))["forms"]
    command = json.loads((catalog_root / "command-forms.json").read_text(encoding="utf-8"))["forms"]
    tile = json.loads((catalog_root / "tile-operations.json").read_text(encoding="utf-8"))["operations"]

    rendered: list[tuple[str, tuple[str, ...], str, str]] = []
    for mnemonic, forms in _grouped(scalar, "mnemonic").items():
        classification, text = _render_scalar(mnemonic, forms)
        rendered.append(("scalar", classification, mnemonic, text))
    for mnemonic, forms in _grouped(command, "mnemonic").items():
        classification, text = _render_block(mnemonic, forms)
        rendered.append(("block", classification, mnemonic, text))
    for index, operation in enumerate(tile):
        mnemonic = operation["name"]
        classification, text = _render_tile(root, mnemonic, index, operation)
        rendered.append(("tile", classification, mnemonic, text))

    for surface, classification, mnemonic, text in rendered:
        path = (
            root
            / "asl"
            / surface
            / Path(*classification)
            / f"{mnemonic_file_name(mnemonic)}.asl"
        )
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.parse_args()
    bootstrap_instruction_sources(ROOT)
    print(f"bootstrapped {len(load_instruction_index(ROOT))} mnemonic ASL sources")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
