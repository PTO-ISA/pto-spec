#!/usr/bin/env python3
"""Generate the decoded, catalog-total operation/role applicability matrix.

Each accepted operation-role pair gets an independent decoded BSTART, all
required attributes/operands, and a B.SUBVIEW (source) or B.ASSEMBLE
INIT_LAST (destination) before normal dispatch.  Effect classes are parsed
from the normative ASL carrier function, so Python cannot create a second
classification owner.
"""

from __future__ import annotations

import argparse
import json
import re
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OPS = ROOT / "spec/catalog/tile-operations.json"
FORMS = ROOT / "spec/catalog/command-forms.json"
EFFECT_OWNER = ROOT / "asl/block/model/operands/portable-carriers.asl"
EVIDENCE = ROOT / "spec/evidence/bundle-operation-fixture-matrix.json"
TEST_DIR = ROOT / "tests/asl/block/model/operands/subview-descriptor"
CELL_SIZE_CODE = 1
PE_MODE = 0b111
SHARED_FIXTURE_ID = 16
CELL_REARRANGEMENT_OPERATIONS = {
    "TPERMUTE", "TSHUF", "TPACK", "TUNPACK",
}

FIXTURE_RECIPES = {
    "TEPL": "cube-parent-local-view",
    "CUBE": "cube-parent-local-view",
    "TLSU": "shared-pe-nonzero",
}

KNOWN_FIELDS = {
    "destination0", "destination1", "destination2",
    *(f"source{i}" for i in range(8)),
    "address", "scalar0", "scalar1", "diagonal", "flag0",
    "positive0", "positive1", "positive2", "natural0", "natural1",
    "comparison", "numeric_control", "selected_byte", "sort_width",
}

DATA_TYPE_NAMES = {
    1: "TileDataType_FP32",
    4: "TileDataType_FP16",
    7: "TileDataType_E4M3",
    13: "TileDataType_E8M0",
    17: "TileDataType_S32",
    19: "TileDataType_S8",
    25: "TileDataType_U32",
    26: "TileDataType_U16",
    27: "TileDataType_U8",
}


def load(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def canonical_effect_classes() -> dict[str, str]:
    """Read the one normative handler classification owner from ASL."""
    text = EFFECT_OWNER.read_text(encoding="utf-8")
    match = re.search(
        r"pure func BundleProducerEffectClassOfHandler\(.*?\nend;",
        text,
        flags=re.DOTALL,
    )
    if not match:
        raise ValueError("canonical ASL effect-class owner is missing")
    pairs = re.findall(
        r"when\s+(.*?)\s*=>\s*\n?\s*return\s+"
        r"BundleProducerEffect_(\w+);",
        match.group(0),
        flags=re.DOTALL,
    )
    result: dict[str, str] = {}
    names = {
        "RollbackSafe": "rollback-safe",
        "AtomicAuxiliary": "atomic-auxiliary",
        "NonRollbackAuxiliary": "nonrollback-auxiliary",
    }
    for handlers, effect in pairs:
        if effect not in names:
            raise ValueError(f"unknown canonical effect class {effect}")
        for handler in handlers.split(","):
            handler = handler.strip()
            if not handler.startswith("TileHandler_"):
                continue
            name = handler.removeprefix("TileHandler_")
            if name in result:
                raise ValueError(f"duplicate canonical effect class for {name}")
            result[name] = names[effect]
    return result


def start_matches(forms: list[dict]) -> dict[str, int]:
    result: dict[str, int] = {}
    for form in forms:
        mnemonic = form["mnemonic"]
        if not mnemonic.startswith("BSTART"):
            continue
        encodings = form.get("encoding", [])
        if len(encodings) != 1:
            continue
        encoding = encodings[0]
        result[mnemonic] = int(encoding["match"], 16) & int(
            encoding["mask"], 16
        )
    return result


def fixture_data_type(row: dict) -> int:
    """Return the smallest schema-supported concrete B.DATR type.

    This is a fixture choice, not a second operation-legality owner.  The
    authoritative operation schema remains the catalog/NDF and the ASL
    handler performs the actual legality check.
    """
    name = row.get("name", row.get("operation"))
    if name == "TGPR2T":
        return 27  # TGPR2T always publishes a numeric U8 CUBE destination.
    if name in CELL_REARRANGEMENT_OPERATIONS:
        return 25  # U32 is accepted by every CELL rearrangement data role.
    if name in {
        "TAND", "TOR", "TXOR", "TSHL", "TSHR", "TNOT",
        "TANDS", "TORS", "TXORS", "TSHLS", "TSHRS",
    }:
        return 27  # U8, accepted by the integer/logical schemas.
    if name in {"TCI", "TTRI"}:
        return 17  # S32, accepted generation type.
    if row["family"] == "CUBE":
        if name in {
            "TMATMUL_MX", "TMATMUL_MX_BIAS", "TMATMUL_MX_ACC",
            "TGEMV_MX", "TGEMV_MX_BIAS", "TGEMV_MX_ACC",
        }:
            return 7  # E4M3 primary MX input; scale roles use E8M0 below.
        return 4  # FP16 is the smallest ordinary matrix fixture.
    return 4


def datr_word(row: dict) -> int | None:
    """Encode only schema-required fixture attributes."""
    dtype = fixture_data_type(row)
    contract = row.get("datr_contract", {})
    allowed = set(contract.get("allowed_nonzero_fields", []))
    if "DataType" not in allowed:
        # Omission preserves the BSTART source type.  Emitting an otherwise
        # zero B.DATR would make its zero DataType an explicit FP64 override.
        return None
    # B.DATR is present to exercise the decoded attribute path, but every
    # nonzero field must come from the authoritative operation contract.
    # In particular, ordinary elementwise operations do not accept a
    # secondary DataType, and must-zero unions cannot carry PadValue.
    # B.DATR's fixed command discriminator includes bit 12 regardless of
    # which operation-owned union fields are nonzero.
    word = 0x00001023
    encoded_dtype = dtype
    word |= encoded_dtype << 20
    return word


def start_word(row: dict, starts: dict[str, int]) -> int:
    mnemonic = row["command_mnemonic"]
    if mnemonic not in starts:
        raise ValueError(f"missing canonical BSTART form for {mnemonic}")
    word = starts[mnemonic]
    if row["family"] == "TEPL":
        word |= int(row["mode"]) << 25
        word |= int(row["function"]) << 20
    return word | (fixture_data_type(row) << 27)


def tile_fields(row: dict) -> list[str]:
    fields = [operand["field"] for operand in row["operands"]]
    unknown = sorted(set(fields) - KNOWN_FIELDS)
    if unknown:
        raise ValueError(f"{row['name']}: unknown operand fields {unknown}")
    roles = [
        field for field in fields
        if field.startswith("source") or field.startswith("destination")
    ]
    # The accepted complete-bundle stream is source roles followed by
    # destination roles.  Reordering only the encoded carrier sequence keeps
    # catalog role identity intact while ensuring B.ASSEMBLE is the terminal
    # modifier group for destination cases.
    return [field for field in roles if field.startswith("source")] + [
        field for field in roles if field.startswith("destination")
    ]


def fixture_recipe(row: dict) -> str:
    """Select a named recipe from the authoritative operation family."""
    if row.get("name", row.get("operation")) in CELL_REARRANGEMENT_OPERATIONS:
        return "cell-rearrangement-cube-view"
    try:
        recipe = FIXTURE_RECIPES[row["family"]]
    except KeyError as error:
        raise ValueError(
            f"{row['name']}: no authoritative fixture recipe for {row['family']}"
        ) from error
    if recipe == "shared-pe-nonzero" and PE_MODE == 0:
        raise ValueError(f"{row['name']}: Shared recipe requires nonzero PE mode")
    return recipe


def cube_source_recipe(row: dict) -> dict[int, tuple[int, str]]:
    """Return the exact parent type/layout for each encoded Local source tile.

    Role identity comes from the accepted operation catalog.  Auxiliary
    sources are materialized as RowMajor by the normative subview carrier,
    but their persistent CUBE parent still needs a schema-supported concrete
    type and a harmless parent layout for the descriptor copy.
    """
    name = row.get("name", row.get("operation"))
    if row["family"] != "CUBE" and name not in CELL_REARRANGEMENT_OPERATIONS:
        return {}
    if name in CELL_REARRANGEMENT_OPERATIONS:
        if "operands" not in row:
            return {
                role_number(field) + 1: (
                    row["fixture_role_data_types"][field],
                    row["fixture_role_layouts"][field],
                )
                for field in row["fixture_role_data_types"]
            }
        return {
            role_number(operand["field"]) + 1: (
                27 if name == "TPERMUTE" and
                operand["field"] == "source2" else 25,
                "TileLayout_CUBE_M32",
            )
            for operand in row["operands"]
            if operand["field"].startswith("source")
        }
    primary_dtype = fixture_data_type(row)
    result: dict[int, tuple[int, str]] = {}
    operands = row.get("operands")
    if operands is None:
        return {
            role_number(field) + 1: (
                row["fixture_role_data_types"][field],
                row["fixture_role_layouts"][field],
            )
            for field in row.get("fixture_role_data_types", {})
        }
    for operand in operands:
        field = operand["field"]
        if not field.startswith("source"):
            continue
        tile = role_number(field) + 1
        role = operand["role"]
        if role in {"row-scale", "column-scale"}:
            dtype = 13
        elif role in {"bias", "accumulator"}:
            dtype = 1
        else:
            dtype = primary_dtype
        if role in {"row-scale", "column-scale"}:
            layout = "TileLayout_CUBE_M32"
        else:
            layout = (
                "TileLayout_CUBE_N8"
                if role in {"right", "right-matrix"}
                else "TileLayout_CUBE_M16"
            )
        result[tile] = (dtype, layout)
    return result


def fixture_role_data_types(row: dict) -> dict[str, int]:
    """Expose role-level concrete types used by the named fixture recipe."""
    recipe = cube_source_recipe(row)
    return {
        field: recipe[role_number(field) + 1][0]
        for field in (
            operand["field"] for operand in row.get("operands", [])
            if operand["field"].startswith("source")
        )
    } if recipe else {}


def fixture_role_layouts(row: dict) -> dict[str, str]:
    recipe = cube_source_recipe(row)
    return {
        field: recipe[role_number(field) + 1][1]
        for field in (
            operand["field"] for operand in row.get("operands", [])
            if operand["field"].startswith("source")
        )
    } if recipe else {}


def fixture_role_kinds(row: dict) -> dict[str, str]:
    return {
        operand["field"]: operand["role"]
        for operand in row.get("operands", [])
        if operand["field"].startswith("source")
    }


def role_number(role: str) -> int:
    return int(role[6:] if role.startswith("source") else role[11:])


def gpr_word(row: dict) -> int | None:
    scalar_fields = [
        operand["field"] for operand in row["operands"]
        if operand["field"] in {"address", "scalar0", "scalar1", "diagonal", "flag0"}
    ]
    if not scalar_fields:
        return None
    if len(scalar_fields) > 3:
        raise ValueError(f"{row['name']}: more than three B.IOR inputs")
    word = 0x13
    for slot in range(len(scalar_fields)):
        word |= (2 + slot) << (15 + slot * 5)
    return word


def binding_groups(row: dict, selected_role: str | None = None) -> list[list[str]]:
    """Build the accepted B.IOT stream shape for the selected operation.

    B.IOT carries at most two ordered sources and one destination.  The
    complete-bundle schemas retain the few two-group forms explicitly (TSEL,
    TFMA, and the dynamic CUBE streams); ordinary operations use one group.
    """
    fields = tile_fields(row)
    if not fields:
        return []
    if row["name"] == "TGPR2T":
        # TGPR2T source0..source3 are carried by its dedicated 3+1 B.IOR
        # stream.  Its only Local Tile carrier is the destination B.IOT.
        return [["destination0"]]
    if row["family"] == "TLSU":
        # B.IOS carries exactly one Shared source or destination and the
        # Shared operation schemas consume one binding.  A role case binds
        # only the selected role; full Shared execution remains Stage 3.
        target = selected_role if selected_role and selected_role != "operation" else fields[0]
        return [[target]]
    sources = [field for field in fields if field.startswith("source")]
    destinations = [field for field in fields if field.startswith("destination")]
    if row["name"] in {"TSEL", "TFMA"}:
        return [sources[:2], sources[2:] + destinations]
    if len(sources) <= 2 and len(destinations) <= 1:
        return [sources + destinations]
    groups: list[list[str]] = []
    remaining = list(sources)
    while len(remaining) > 2:
        groups.append(remaining[:2])
        remaining = remaining[2:]
    groups.append(remaining + destinations)
    return groups


def destination_fixture_size_code(row: dict, role: str) -> int:
    name = row.get("name", row.get("operation"))
    return CELL_SIZE_CODE


def local_binding(row: dict, roles: list[str], final: bool) -> int:
    last = (1 if final else 0) << 19
    sources = [role for role in roles if role.startswith("source")]
    destinations = [role for role in roles if role.startswith("destination")]
    if len(sources) > 2 or len(destinations) > 1:
        raise ValueError(f"unsupported B.IOT fixture group {roles}")
    word = (0x4013 if len(sources) == 2 else
            0x5013 if len(sources) == 1 else 0x6013)
    for position, source in enumerate(sources):
        word |= (role_number(source) + 1) << (20 + position * 6)
    if destinations:
        size_code = destination_fixture_size_code(row, destinations[0])
        word |= (size_code << 15) | (role_number(destinations[0]) << 7)
    return word | (PE_MODE << 9) | last


def shared_binding(role: str, ordinal: int) -> int:
    # Shared IDs are encoded register names and must remain unique even when
    # source0 and destination0 coexist in one operation-role recipe.
    shared_id = 16 + ordinal
    size = 0 if role.startswith("source") else CELL_SIZE_CODE
    return 0x1013 | (shared_id << 20) | (size << 15) | (PE_MODE << 9)


def subview_word(source_select: bool = False, size_code: int = 1) -> int:
    return 0x53 | (1 << 31 if source_select else 0) | (size_code << 7)


def assemble_word(size_code: int = CELL_SIZE_CODE) -> int:
    return 0x1053 | (1 << 31) | (1 << 11) | (size_code << 7)


def dimension_words(row: dict) -> list[int]:
    # One FP16 M16 CELL is a 1x4 logical view. Matrix handlers retain their
    # compact one-value defaults; ordinary Local handlers use the view shape.
    name = row.get("name", row.get("operation"))
    if name == "TGPR2T":
        return [0x43 | (4 << 20), 0x1043 | (32 << 20)]
    if name in CELL_REARRANGEMENT_OPERATIONS:
        return []
    if name == "TTRANS":
        return [0x43 | (2 << 20),
                0x1043 | (2 << 20),
                0x2043 | (2 << 20)]
    values = (1, 1, 1) if row["family"] == "CUBE" else (4, 1, 4)
    return [0x43 | (values[0] << 20),
            0x1043 | (values[1] << 20),
            0x2043 | (values[2] << 20)]


def fixture(row: dict, operation_index: int, role: str, starts: dict[str, int],
            effect_classes: dict[str, str], case_index: int) -> dict:
    fields = tile_fields(row)
    groups = binding_groups(row, role)
    if role != "operation" and role not in fields:
        raise ValueError(f"{row['name']}: role {role} is not in catalog")
    handler = row["semantic_handler"]
    recipe = fixture_recipe(row)
    if handler not in effect_classes:
        raise ValueError(f"{row['name']}: handler lacks canonical effect class")
    role_kind = ("source" if role.startswith("source") else
                 "destination" if role.startswith("destination") else "operation")
    selected_source_select = any(
        role in [field for field in group if field.startswith("source")] and
        [field for field in group if field.startswith("source")].index(role) == 1
        for group in groups
    ) if role_kind == "source" else False
    expected_fault = None
    outcome = "normal-success"
    if row["family"] == "TLSU":
        # Stage 3 closes the three accepted collective Shared operations with
        # a concrete decoded success witness.  The remaining TLSU operations
        # deliberately retain their exact pre-effect rejection: B.IOS is not
        # a generic substitute for their Local schemas.
        if row["name"] in {"TLOAD", "TSTORE", "TMOV"}:
            outcome = "shared-stage3-success"
        else:
            # The address-only TLSU form reaches the same aligned-address
            # preflight as the two regular memory operations.  Its fixture
            # intentionally supplies an unaligned decoded B.IOR base.
            expected_fault = ("Fault_DataAlignment"
                              if row["name"] == "TPREFETCH"
                              else "Fault_TileLegality")
            outcome = "shared-stage3-fault"
    elif (role_kind == "destination" and
          effect_classes[handler] == "nonrollback-auxiliary"):
        expected_fault = "Fault_TileLegality"
        outcome = "nonrollback-pre-effect-fault"
    elif (role_kind == "source" and role == "source0" and
          row["name"] in {"TSEL", "TSELS"}):
        expected_fault = "Fault_TileLegality"
        outcome = "predicate-role-pre-effect-fault"
    elif (role_kind == "source" and
          row["name"] in CELL_REARRANGEMENT_OPERATIONS):
        # These TEPL handlers require persistent CUBE operands.  B.SUBVIEW is
        # total and materializes a bounded RowMajor view for a non-CUBE decode
        # family, so the selected handler rejects that source before effects.
        expected_fault = "Fault_TileLegality"
        outcome = "cell-rearrangement-subview-pre-effect-fault"
    result_index = case_index + 1
    test_id = f"PTO-AVS-BLOCK-RANGE-OPERATION-MATRIX-{result_index:03d}"
    return {
        "case_id": f"RANGE-MATRIX-CASE-{result_index:04d}",
        "operation_index": operation_index,
        "operation": row["name"],
        "family": row["family"],
        "semantic_handler": handler,
        "handler_effect_class": effect_classes[handler],
        "fixture_recipe": recipe,
        "role": role,
        "role_kind": role_kind,
        "all_required_roles": fields,
        "decoded_start": f"0x{start_word(row, starts):08x}",
        "decoded_attributes": (["B.DATR"] if datr_word(row) is not None else []) + ["B.DIM"] + (["B.FPATR"] if row["family"] == "CUBE" else []),
        "decoded_operand_commands": ["B.IOR", "B.IOT", "B.IOS"],
        "modifier": ("none" if row["name"] == "TGPR2T" and
                      role_kind == "source" else
                      "B.SUBVIEW" if role_kind == "source" else
                      "B.ASSEMBLE INIT_LAST" if role_kind == "destination" else "none"),
        "binding_groups": groups,
        "binding_words": [
            f"0x{(shared_binding(group[0], i) if row['family'] == 'TLSU' else local_binding(row, group, i == len(groups) - 1)):08x}"
            for i, group in enumerate(groups)
        ],
        "modifier_word": (f"0x{subview_word(selected_source_select, 1):08x}" if role_kind == "source" else
                          f"0x{assemble_word(destination_fixture_size_code(row, role)):08x}" if role_kind == "destination" else None),
        "modifier_words": (
            [f"0x{subview_word(selected_source_select, 1):08x}"]
            if role_kind == "source" else []
        ),
        "normal_dispatch": "ExecuteBundleTileOperation",
        "expected_fault": expected_fault,
        "outcome": outcome,
        "observable": (
            f"decoded {('B.SUBVIEW' if role_kind == 'source' else 'B.ASSEMBLE INIT_LAST' if role_kind == 'destination' else 'BSTART/B.IOR operation path')} reaches normal dispatch for {role}; "
            + (f"the supported Shared collective commits its exact register or GM observable ({outcome})"
               if outcome == "shared-stage3-success" else
               f"Fault_TileLegality is raised before handler/effects ({outcome})"
               if expected_fault else
               "the handler commits and the destination/generation observable is defined")
        ),
        "test_id": test_id,
        "row_assertion": (f"case_{result_index:04d}_exact_fault"
                          if expected_fault else
                          f"case_{result_index:04d}_normal_commit"),
        "gpr_word": (f"0x{gpr_word(row):08x}" if gpr_word(row) is not None else None),
        "fixture_data_type": fixture_data_type(row),
        "fixture_role_data_types": fixture_role_data_types(row),
        "fixture_role_layouts": fixture_role_layouts(row),
        "fixture_role_kinds": fixture_role_kinds(row),
        "datr_word": (f"0x{datr_word(row):08x}" if datr_word(row) is not None else None),
        "destination_size_code": (
            destination_fixture_size_code(row, role)
            if role_kind == "destination" else CELL_SIZE_CODE
        ),
    }


def asl_word(value: int) -> str:
    return f"Zeros{{64}} + 0x{value:08x}"


def source_valid_columns(row: dict, source: str) -> int:
    name = row.get("name", row.get("operation"))
    if name == "TPERMUTE":
        return 4 if source == "source2" else 1
    if name in {"TSHUF", "TPACK", "TUNPACK"}:
        return 1
    if name == "TROWEXPAND":
        return 1
    if name in {
        "TROWEXPANDADD", "TROWEXPANDSUB", "TROWEXPANDMUL",
        "TROWEXPANDDIV", "TROWEXPANDMAX", "TROWEXPANDMIN",
        "TROWEXPANDEXPDIF",
    }:
        return 1 if source == "source1" else 4
    if name == "TTRANS":
        return 2
    return 4


def source_valid_rows(row: dict, source: str) -> int:
    name = row.get("name", row.get("operation"))
    return 2 if name == "TTRANS" else 1


def source_fixture_data_type(row: dict, source: str) -> int:
    name = row.get("name", row.get("operation"))
    if name == "TPERMUTE" and source == "source2":
        return 27
    if name == "TSHUF" and source == "source1":
        return 25
    if name in {"TGATHER", "TSCATTER"} and source == "source1":
        return 17
    return fixture_data_type(row)


def source_physical_columns(row: dict, source: str) -> int:
    name = row.get("name", row.get("operation"))
    if name == "TROWEXPAND":
        return 1
    if name in {
        "TROWEXPANDADD", "TROWEXPANDSUB", "TROWEXPANDMUL",
        "TROWEXPANDDIV", "TROWEXPANDMAX", "TROWEXPANDMIN",
        "TROWEXPANDEXPDIF",
    } and source == "source1":
        return 1
    return 4


def row_major_rows(data_type: int, columns: int = 4) -> int:
    element_bits = (
        32 if data_type in {1, 17, 25}
        else 16 if data_type in {4, 26}
        else 8
    )
    return (128 * 8) // element_bits // columns


def setup_lines(row: dict, role_kind: str) -> list[str]:
    dtype = fixture_data_type(row)
    dtype_name = DATA_TYPE_NAMES[dtype]
    operation_name = row.get("name", row.get("operation"))
    index_source_fixture = operation_name in {"TGATHER", "TSCATTER"}
    local_dtype = dtype_name
    for field in row["all_required_roles"]:
        if field.startswith("source"):
            tile = role_number(field) + 1
            role_dtype = source_fixture_data_type(row, field)
            if role_dtype != dtype:
                local_dtype = (
                    f"(if tile == {tile} then {DATA_TYPE_NAMES[role_dtype]} "
                    f"else {local_dtype})"
                )
    gpr2 = (
        "0x00000101" if operation_name == "TPACK"
        else "0x00000100" if operation_name == "TUNPACK"
        else "0" if operation_name == "TIMG2COL"
        else "1"
    )
    lines = [
        "    ResetProfileState();",
        "    WriteGPR(0, Zeros{PTO_XLEN});",
        f"    WriteGPR(2, Zeros{{PTO_XLEN}} + {gpr2});",
        "    WriteGPR(3, Zeros{PTO_XLEN});",
        "    WriteGPR(4, Zeros{PTO_XLEN} + 1);",
    ]
    if row["family"] == "TLSU":
        return lines
    if (row["family"] == "CUBE" or
            operation_name in CELL_REARRANGEMENT_OPERATIONS):
        source_recipe = cube_source_recipe(row)
        selected_source = row["role"] if role_kind == "source" else None
        auxiliary_roles = {"bias"}
        for field in sorted(
            row["fixture_role_data_types"], key=role_number
        ):
            tile = role_number(field) + 1
            role_dtype, role_layout = source_recipe[tile]
            role_kind_name = row["fixture_role_kinds"][field]
            if role_kind_name in auxiliary_roles and field != selected_source:
                rows = row_major_rows(role_dtype, 1)
                lines += [
                    f"    ConfigureTileForMask({tile}, 128, {rows}, 1, 1, 1,",
                    f"        {DATA_TYPE_NAMES[role_dtype]}, TileLayout_RowMajor,",
                    "        TileLocation_Matrix, '1111');",
                    f"    InstallRelativeTileFixture({tile}, {tile});",
                    f"    MarkTileValidRegionDefined({tile});",
                ]
            else:
                valid_columns = (
                    source_valid_columns(row, field)
                    if operation_name in CELL_REARRANGEMENT_OPERATIONS else 1
                )
                lines += [
                    f"    let configured_{tile} = ConfigureCubeTileForMask(",
                    f"        {tile}, 128, 1, {valid_columns}, {DATA_TYPE_NAMES[role_dtype]},",
                    f"        {role_layout}, TileLocation_Matrix, '1111');",
                    f"    assert configured_{tile};",
                    f"    InstallRelativeTileFixture({tile}, {tile});",
                    f"    MarkTileValidRegionDefined({tile});",
                ]
    else:
        selected_source = row["role"] if role_kind == "source" else None
        selected_tile = (
            role_number(selected_source) + 1
            if selected_source is not None else 0
        )
        selected_columns = (
            source_valid_columns(row, selected_source)
            if selected_source is not None else 4
        )
        selected_rows = (
            source_valid_rows(row, selected_source)
            if selected_source is not None else 1
        )
        selected_dtype = (
            source_fixture_data_type(row, selected_source)
            if selected_source is not None else dtype
        )
        selected_layout = (
            "TileLayout_CUBE_N8"
            if selected_dtype in {1, 17, 25} or
               (index_source_fixture and selected_source == "source1")
            else "TileLayout_CUBE_M16"
        )
        ordinary_rows = str(row_major_rows(dtype))
        ordinary_physical_columns = "4"
        ordinary_valid_rows = "1"
        ordinary_location = (
            "(if tile == 1 then TileLocation_Matrix else TileLocation_Any)"
            if operation_name == "TIMG2COL" else "TileLocation_Any"
        )
        predicate_source_ordinary = (
            operation_name in {"TSEL", "TSELS"} and
            selected_source != "source0"
        )
        predicate_lines = (
            [
                "        if tile == 1 then",
                "            ConfigurePredicateTileForMask(tile, 128,",
                "                16, 4, 1, 4, '1111');",
                f"        elsif tile == {selected_tile} then",
            ]
            if predicate_source_ordinary else
            [f"        if tile == {selected_tile} then"]
        )
        lines += [
            "    for tile = 1 to 8 looplimit 8 do",
            *predicate_lines,
            "            let configured =",
            f"            ConfigureCubeTileForMask(tile, 128, {selected_rows},",
            f"                {selected_columns}, {local_dtype}, {selected_layout},",
            "                TileLocation_Matrix, '1111');",
            "            assert configured;",
            "        else",
            "            ConfigureTileForMask(tile, 128,",
            "                ordinary_rows_placeholder, source_physical_columns_placeholder, ordinary_valid_rows_placeholder,",
            f"                source_valid_columns_placeholder, {local_dtype},",
            f"                TileLayout_RowMajor, {ordinary_location}, '1111');",
            "        end;",
            "        InstallRelativeTileFixture(tile, tile);",
            "        MarkTileValidRegionDefined(tile);",
            "    end;",
        ]
        # The nonselected Local source shape can differ by role. Expand the
        # placeholder into one exact ASL conditional derived from the catalog
        # role numbering used by B.IOT.
        ordinary_columns = "4"
        for field in row["all_required_roles"]:
            if field.startswith("source"):
                tile = role_number(field) + 1
                role_dtype = source_fixture_data_type(row, field)
                physical_columns = source_physical_columns(row, field)
                columns = source_valid_columns(row, field)
                valid_rows = source_valid_rows(row, field)
                if physical_columns != 4:
                    ordinary_physical_columns = (
                        f"(if tile == {tile} then {physical_columns} else "
                        f"{ordinary_physical_columns})"
                    )
                role_rows = row_major_rows(role_dtype, physical_columns)
                if role_rows != row_major_rows(dtype):
                    ordinary_rows = (
                        f"(if tile == {tile} then {role_rows} else "
                        f"{ordinary_rows})"
                    )
                if columns != 4:
                    ordinary_columns = (
                        f"(if tile == {tile} then {columns} else "
                        f"{ordinary_columns})"
                    )
                if valid_rows != 1:
                    ordinary_valid_rows = (
                        f"(if tile == {tile} then {valid_rows} else "
                        f"{ordinary_valid_rows})"
                    )
        lines = [
            line.replace("source_valid_columns_placeholder", ordinary_columns)
                .replace("source_physical_columns_placeholder",
                         ordinary_physical_columns)
                .replace("ordinary_rows_placeholder", ordinary_rows)
                .replace("ordinary_valid_rows_placeholder",
                         ordinary_valid_rows)
            for line in lines
        ]
        if predicate_source_ordinary:
            lines += [
                "    for column = 0 to 3 looplimit 4 do",
                "        WriteTilePredicateBit(1, 0, column, column MOD 2 == 0);",
                "    end;",
            ]
        if operation_name == "TIMG2COL":
            lines += [
                "    ConfigureTileFeatureMapDescriptor(1,",
                "        TileFeatureMapLayout_NC1HWC0, 1, 1, 1, 1, 1, 4,",
                "        1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 4,",
                "        Zeros{PTO_XLEN}, FALSE);",
            ]
    return lines


def render_case(row: dict) -> list[str]:
    if row["outcome"] == "shared-stage3-success":
        return render_shared_stage3_case(row)
    lines = setup_lines(row, row["role_kind"])
    lines += [
        f"    let started = ExecuteCommandInstruction({asl_word(int(row['decoded_start'], 16))}, 32);",
        "    assert started == CommandExecution_Executed;",
    ]
    if "B.FPATR" in row["decoded_attributes"]:
        lines += [
            f"    let fpatr = ExecuteCommandInstruction({asl_word(0x00002023)}, 32);",
            "    assert fpatr == CommandExecution_Executed;",
        ]
    if row["datr_word"] is not None:
        lines += [
            f"    let datr = ExecuteCommandInstruction({asl_word(int(row['datr_word'], 16))}, 32);",
            "    assert datr == CommandExecution_Executed;",
        ]
    for value in dimension_words(row):
        lines += [
            f"    let dim_{value:x} = ExecuteCommandInstruction({asl_word(value)}, 32);",
            f"    assert dim_{value:x} == CommandExecution_Executed;",
        ]
    if row["operation"] == "TGPR2T":
        lines += [
            "    WriteGPR(5, Zeros{PTO_XLEN} + 1);",
            f"    let tgpr_sources_0 = ExecuteCommandInstruction({asl_word(0x20310013)}, 32);",
            f"    let tgpr_sources_1 = ExecuteCommandInstruction({asl_word(0x00028013)}, 32);",
            "    assert tgpr_sources_0 == CommandExecution_Executed;",
            "    assert tgpr_sources_1 == CommandExecution_Executed;",
        ]
    if row["gpr_word"] is not None:
        lines += [
            f"    let ior = ExecuteCommandInstruction({asl_word(int(row['gpr_word'], 16))}, 32);",
            "    assert ior == CommandExecution_Executed;",
        ]
    for index, (binding, group) in enumerate(zip(row["binding_words"], row["binding_groups"])):
        lines += [
            f"    let bind_{index} = ExecuteCommandInstruction({asl_word(int(binding, 16))}, 32);",
            f"    assert bind_{index} == CommandExecution_Executed;",
        ]
        source_fields = [field for field in group if field.startswith("source")]
        for source_position, source in enumerate(source_fields):
            if row["role"] == source:
                modifier = subview_word(source_position == 1, 1)
                lines += [
                    f"    let modifier_{index}_{source_position} = ExecuteCommandInstruction({asl_word(modifier)}, 32);",
                    f"    assert modifier_{index}_{source_position} == CommandExecution_Executed;",
                ]
        # A selected source-role case still binds the operation's required
        # destination, but B.ASSEMBLE belongs only to the destination-role
        # case.  This keeps nonrollback handlers on their ordinary direct
        # path for legal source-role coverage; the destination-role case is
        # the exact pre-effect B.ASSEMBLE rejection witness.
        if (row["family"] != "TLSU" and
                row["role_kind"] == "destination" and
                row["role"] in group):
            modifier = assemble_word(row["destination_size_code"])
            lines += [
                f"    let assemble_{index} = ExecuteCommandInstruction({asl_word(modifier)}, 32);",
                f"    assert assemble_{index} == CommandExecution_Executed;",
            ]
    if row["family"] != "TLSU":
        lines += [
            f"    assert BundleOperationBindingsComplete({row['operation_index']});",
        ]
    if row["expected_fault"] is None and row["family"] != "TLSU":
        lines += [
            "    let prepared_stage2 = PrepareSelectedBundleStage2();",
            "    assert prepared_stage2;",
            f"    assert SelectedBundleClosedSchemasLegal({row['operation_index']});",
            "    assert SelectedBundleTileMasksLegal();",
        ]
    if row["operation"] in {"TADD", "TSUB", "TMUL", "TDIV", "TREM", "TMAX", "TMIN"}:
        lines.append(
            f"    assert SelectedBundleClosedBinarySchemaLegal({row['operation_index']});"
        )
    lines.append("    let completed = ExecuteBundleTileOperation();")
    if row["expected_fault"]:
        lines += [
            "    assert !completed;",
            f"    assert _LastFault == {row['expected_fault']};",
        ]
    else:
        lines += [
            "    assert completed;",
            "    if !completed then assert _LastFault == Fault_TileLegality; end;",
            "    assert _LastFault == Fault_None;",
            "    var observed_destination: TileIndex = 0;",
            "    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do",
            "        if _BundleTileBindings[[binding]].valid &&",
            "           _BundleTileBindings[[binding]].destination_valid then",
            "            observed_destination = _BundleTileBindings[[binding]].destination;",
            "        end;",
            "    end;",
            "    assert _Tiles[[observed_destination]].allocated &&",
            "           _Tiles[[observed_destination]].contents_defined;",
        ]
        if row["role_kind"] == "destination":
            destination_slot = role_number(row["role"])
            lines += [
                f"    let completed_writer_{destination_slot} = CompleteBundleLocalGenerationWriterEvent(",
                f"        BundleLocalGenerationSlot({destination_slot}, '1111'), _BundleExecutionDomainToken,",
                f"        0, BundleLocalGenerationCellCount({row['destination_size_code']}));",
                f"    assert completed_writer_{destination_slot};",
                f"    assert _LocalGenerations[[BundleLocalGenerationSlot({destination_slot}, '1111')]].published;",
            ]
    lines += ["    return TRUE;"]
    return lines


def render_shared_stage3_case(row: dict) -> list[str]:
    """Render one executable B.IOS collective witness for Stage 3.

    The generic Local recipe cannot prove these forms: TLOAD/TSTORE have no
    Local tile binding in their Shared schema, and TMOV changes selector plus
    uses one B.IOS and one B.IOT binding.  Keep those differences explicit in
    the generated fixture instead of treating B.IOS as a Local carrier.
    """
    name = row["operation"]
    dtype = DATA_TYPE_NAMES[fixture_data_type(row)]
    shared_id = f"(Zeros{{6}} + {SHARED_FIXTURE_ID}) as SharedTileID"
    common = [
        "    ResetProfileState();",
        "    WriteGPR(0, Zeros{PTO_XLEN});",
        "    WriteGPR(2, Zeros{PTO_XLEN});",
        "    WriteGPR(3, Zeros{PTO_XLEN} + 8);",
        "    WriteGPR(4, Zeros{PTO_XLEN} + 1);",
    ]
    if name == "TLOAD":
        lines = common + [
            "    _Memory[[0]] = Zeros{8} + 0x2a;",
            f"    let started = ExecuteCommandInstruction({asl_word(int(row['decoded_start'], 16))}, 32);",
            "    assert started == CommandExecution_Executed;",
        ]
        for value in dimension_words(row):
            lines += [
                f"    let dim_{value:x} = ExecuteCommandInstruction({asl_word(value)}, 32);",
                f"    assert dim_{value:x} == CommandExecution_Executed;",
            ]
        lines += [
            f"    let ior = ExecuteCommandInstruction({asl_word(int(row['gpr_word'], 16))}, 32);",
            "    assert ior == CommandExecution_Executed;",
            f"    let shared = ExecuteCommandInstruction({asl_word(shared_binding('destination0', 0))}, 32);",
            "    assert shared == CommandExecution_Executed;",
            f"    let assemble = ExecuteCommandInstruction({asl_word(assemble_word())}, 32);",
            "    assert assemble == CommandExecution_Executed;",
            "    let completed = ExecuteBundleTileOperation();",
            "    assert completed && _LastFault == Fault_None;",
            f"    assert SharedTileFullyInitialized({shared_id});",
            f"    assert ReadSharedTileWord({shared_id}, 0) == Zeros{{PTO_XLEN}} + 0x2a;",
        ]
    elif name == "TSTORE":
        lines = common + [
            f"    ConfigureTile(0, 128, 1, 4, 1, 4, {dtype}, TileLayout_RowMajor, TileLocation_Any);",
            "    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x2a);",
            "    MarkTileValidRegionDefined(0);",
            f"    InstallSharedTile({shared_id}, _Tiles[[0]], '1111');",
            f"    let started = ExecuteCommandInstruction({asl_word(int(row['decoded_start'], 16))}, 32);",
            "    assert started == CommandExecution_Executed;",
        ]
        for value in dimension_words(row):
            lines += [
                f"    let dim_{value:x} = ExecuteCommandInstruction({asl_word(value)}, 32);",
                f"    assert dim_{value:x} == CommandExecution_Executed;",
            ]
        lines += [
            f"    let ior = ExecuteCommandInstruction({asl_word(int(row['gpr_word'], 16))}, 32);",
            "    assert ior == CommandExecution_Executed;",
            f"    let shared = ExecuteCommandInstruction({asl_word(shared_binding('source0', 0))}, 32);",
            "    assert shared == CommandExecution_Executed;",
            f"    let subview = ExecuteCommandInstruction({asl_word(subview_word(False, 1))}, 32);",
            "    assert subview == CommandExecution_Executed;",
            "    let completed = ExecuteBundleTileOperation();",
            "    assert completed && _LastFault == Fault_None;",
            "    assert _Memory[[0]] == Zeros{8} + 0x2a;",
        ]
    elif row["role_kind"] == "source":
        lines = common + [
            f"    ConfigureTile(0, 128, 1, 4, 1, 4, {dtype}, TileLayout_RowMajor, TileLocation_Any);",
            "    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x2a);",
            "    MarkTileValidRegionDefined(0);",
            f"    InstallSharedTile({shared_id}, _Tiles[[0]], '1111');",
            f"    let started = ExecuteCommandInstruction({asl_word(int(row['decoded_start'], 16))}, 32);",
            "    assert started == CommandExecution_Executed;",
            f"    let shared = ExecuteCommandInstruction({asl_word(shared_binding('source0', 0))}, 32);",
            "    assert shared == CommandExecution_Executed;",
            f"    let subview = ExecuteCommandInstruction({asl_word(subview_word(False, 1))}, 32);",
            "    assert subview == CommandExecution_Executed;",
            f"    let local = ExecuteCommandInstruction({asl_word(local_binding(row, ['destination0'], True))}, 32);",
            "    assert local == CommandExecution_Executed;",
            f"    assert SharedTilePublished({shared_id});",
            "    assert BundleSharedSubviewLegal(0);",
            f"    assert BundleSharedTMOVDestinationSchemaLegal({shared_id}, 2);",
            "    assert SelectedBundleTileMasksLegal();",
            "    let completed = ExecuteBundleTileOperation();",
            "    assert completed && _LastFault == Fault_None;",
            "    let destination = _BundleTileBindings[[0]].destination;",
            "    assert _Tiles[[destination]].contents_defined;",
            "    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0x2a;",
        ]
    else:
        lines = common + [
            f"    ConfigureTile(1, 128, 1, 4, 1, 4, {dtype}, TileLayout_RowMajor, TileLocation_Any);",
            "    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x2a);",
            "    MarkTileValidRegionDefined(1);",
            f"    let started = ExecuteCommandInstruction({asl_word(int(row['decoded_start'], 16))}, 32);",
            "    assert started == CommandExecution_Executed;",
            f"    let shared = ExecuteCommandInstruction({asl_word(shared_binding('destination0', 0))}, 32);",
            "    assert shared == CommandExecution_Executed;",
            f"    let assemble = ExecuteCommandInstruction({asl_word(assemble_word())}, 32);",
            "    assert assemble == CommandExecution_Executed;",
            f"    let local = ExecuteCommandInstruction({asl_word(local_binding(row, ['source0'], True))}, 32);",
            "    assert local == CommandExecution_Executed;",
            "    let completed = ExecuteBundleTileOperation();",
            "    assert completed && _LastFault == Fault_None;",
            f"    assert SharedTileFullyInitialized({shared_id});",
            f"    assert ReadSharedTileWord({shared_id}, 0) == Zeros{{PTO_XLEN}} + 0x2a;",
        ]
    lines += ["    return TRUE;"]
    return lines


def render_case_file(row: dict) -> str:
    test_id = row["test_id"]
    suffix = row["case_id"].split("-")[-1]
    lines = [
        f'// PTO-TEST: {{"id":"{test_id}","source":"asl/block/model/operands/subview-descriptor.asl","requirements":["PTO-B-SUBVIEW-DESCRIPTOR-001","PTO-BLOCK-TILE-OPERATION-APPLICABILITY-001","PTO-B-ASSEMBLE-PRODUCER-EFFECT-ELIGIBILITY-001"],"kind":"execution","summary":"One decoded operation-role case exercises its required source or destination role through normal dispatch.","pass_condition":"The case binds its authoritative fixture recipe and catalog-required operands/attributes, reaches normal modifier and applicability preflight, then asserts its exact normal observable or pre-effect fault.","related_sources":["asl/block/model/operands/subview-descriptor.asl","asl/block/model/operands/range-modifiers.asl","asl/block/model/operands/portable-carriers.asl"]}}',
        f"// Generated by scripts/generate-bundle-operation-matrix.py; case: {row['case_id']}",
        f"// {row['case_id']} {row['operation']} {row['role']} -> {row['row_assertion']}",
        f"func RunCase_{suffix}() => boolean",
        "begin",
    ]
    lines += render_case(row)
    lines += [
        "end;",
        "",
        "func main() => integer",
        "begin",
        f"    let result_{suffix} = RunCase_{suffix}();",
        f"    assert result_{suffix};",
        "    return 0;",
        "end;",
        "",
    ]
    return "\n".join(lines)


def build() -> tuple[dict, dict[Path, str]]:
    operations = load(OPS)["operations"]
    starts = start_matches(load(FORMS)["forms"])
    effect_classes = canonical_effect_classes()
    catalog_handlers = {row["semantic_handler"] for row in operations}
    missing = sorted(catalog_handlers - set(effect_classes))
    if missing:
        raise ValueError(f"canonical effect owner missing handlers: {missing}")
    rows: list[dict] = []
    case_index = 0
    for operation_index, operation in enumerate(operations):
        fields = tile_fields(operation)
        if not fields:
            # TPREFETCH is the one accepted address-only operation.  Retain a
            # decoded normal-dispatch operation case so catalog totality is
            # fail-closed even though it has no source/destination modifier
            # role; the 290 source/destination cases remain the core matrix.
            item = fixture(operation, operation_index, "operation", starts,
                           effect_classes, case_index)
            rows.append(item)
            case_index += 1
            continue
        for role in fields:
            item = fixture(operation, operation_index, role, starts, effect_classes, case_index)
            rows.append(item)
            case_index += 1
    expected_count = sum(len(tile_fields(operation)) or 1 for operation in operations)
    if len(rows) != expected_count or len({row["case_id"] for row in rows}) != len(rows):
        raise ValueError("operation-role matrix is not total and unique")
    if len({row["test_id"] for row in rows}) != len(rows):
        raise ValueError("each operation-role case must own one independent result ID")
    for row in rows:
        if row["role"] != "operation" and row["role"] not in row["all_required_roles"]:
            raise ValueError(f"unknown fixture role {row['role']}")
        if row["fixture_recipe"] != fixture_recipe(row):
            raise ValueError(f"fixture recipe drift for {row['operation']}")
        if row["handler_effect_class"] not in {
            "rollback-safe", "atomic-auxiliary", "nonrollback-auxiliary"
        }:
            raise ValueError(f"unknown effect class for {row['operation']}")
        if row["family"] == "TLSU" and PE_MODE == 0:
            raise ValueError("Shared fixture must use nonzero decoded PE mode")
    handler_rows = defaultdict(set)
    for row in rows:
        handler_rows[row["semantic_handler"]].add(row["handler_effect_class"])
    if set(handler_rows) != catalog_handlers or any(len(v) != 1 for v in handler_rows.values()):
        raise ValueError("effect classification closure is contradictory")
    outcome_counts = Counter(row["outcome"] for row in rows)
    if set(outcome_counts) != {
        "normal-success", "shared-stage3-success", "shared-stage3-fault",
        "nonrollback-pre-effect-fault", "predicate-role-pre-effect-fault",
        "cell-rearrangement-subview-pre-effect-fault",
    }:
        raise ValueError("matrix outcome classification is incomplete")
    evidence = {
        "schema_version": 3,
        "status": "closed",
        "accepted_operation_count": len(operations),
        "operation_role_case_count": len(rows),
        "independent_result_file_count": len(rows),
        "normal_dispatch": "ExecuteBundleTileOperation",
        "fixture_rule": "Every accepted operation-role record has an independent decoded authoritative-family fixture recipe, exactly its selected Local source B.SUBVIEW or Local destination B.ASSEMBLE INIT_LAST or Shared B.IOS role case, all required roles/attributes, and an exact normal or fault assertion.",
        "effect_class_owner": "asl/block/model/operands/portable-carriers.asl::BundleProducerEffectClassOfHandler",
        "handler_effect_classification": {key: next(iter(value)) for key, value in sorted(handler_rows.items())},
        "effect_class_counts": dict(sorted(Counter(row["handler_effect_class"] for row in rows).items())),
        "outcome_counts": dict(sorted(outcome_counts.items())),
        "closure": {
            "unknown_roles_fail": True,
            "unknown_recipes_fail": True,
            "missing_handler_class_fail": True,
            "duplicate_or_contradictory_class_fail": True,
            "decoded_shared_pe_mode": PE_MODE,
            "independent_case_results": True,
        },
        "operation_role_matrix": rows,
    }
    result_files = {
        TEST_DIR / f"block-exec-range-operation-matrix-{index:03d}.asl":
            render_case_file(row)
        for index, row in enumerate(rows, start=1)
    }
    return evidence, result_files


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    evidence, result_files = build()
    expected_evidence = json.dumps(evidence, indent=2) + "\n"
    expected_paths = {
        path for path in result_files
    }
    observed_paths = set(
        TEST_DIR.glob("block-exec-range-operation-matrix-*.asl")
    )
    if args.check:
        if not EVIDENCE.exists() or EVIDENCE.read_text(encoding="utf-8") != expected_evidence:
            raise SystemExit(f"stale generated evidence: {EVIDENCE}")
        for path, content in result_files.items():
            if not path.exists() or path.read_text(encoding="utf-8") != content:
                raise SystemExit(f"stale generated AVS result file: {path}")
        extra = sorted(observed_paths - expected_paths)
        if extra:
            raise SystemExit(
                "unexpected generated AVS result file: "
                + ", ".join(path.as_posix() for path in extra)
            )
        return 0
    EVIDENCE.parent.mkdir(parents=True, exist_ok=True)
    TEST_DIR.mkdir(parents=True, exist_ok=True)
    EVIDENCE.write_text(expected_evidence, encoding="utf-8")
    for stale in sorted(observed_paths - expected_paths):
        stale.unlink()
    for path, content in result_files.items():
        path.write_text(content, encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
