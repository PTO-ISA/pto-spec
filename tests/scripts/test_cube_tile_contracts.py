from __future__ import annotations

import re
import unittest
from pathlib import Path

from scripts.asl_units import load_units


ROOT = Path(__file__).resolve().parents[2]

CUBE_TILE_TO_START = {
    "TMATMUL": "BSTART.TMATMUL",
    "TMATMUL_BIAS": "BSTART.TMATMUL.BIAS",
    "TMATMUL_ACC": "BSTART.TMATMUL.ACC",
    "TMATMUL_MX": "BSTART.TMATMULMX",
    "TMATMUL_MX_BIAS": "BSTART.TMATMULMX.BIAS",
    "TMATMUL_MX_ACC": "BSTART.TMATMULMX.ACC",
    "TGEMV": "BSTART.TGEMV",
    "TGEMV_BIAS": "BSTART.TGEMV.BIAS",
    "TGEMV_ACC": "BSTART.TGEMV.ACC",
    "TGEMV_MX": "BSTART.TGEMVMX",
    "TGEMV_MX_BIAS": "BSTART.TGEMVMX.BIAS",
    "TGEMV_MX_ACC": "BSTART.TGEMVMX.ACC",
}

CUBE_OPERAND_ROLES = {
    "TMATMUL": ("destination", "left", "right"),
    "TMATMUL_BIAS": ("destination", "left", "right", "bias"),
    "TMATMUL_ACC": ("destination", "accumulator", "left", "right"),
    "TMATMUL_MX": ("destination", "left", "row-scale", "right", "column-scale"),
    "TMATMUL_MX_BIAS": (
        "destination",
        "left",
        "row-scale",
        "right",
        "column-scale",
        "bias",
    ),
    "TMATMUL_MX_ACC": (
        "destination",
        "accumulator",
        "left",
        "row-scale",
        "right",
        "column-scale",
    ),
    "TGEMV": ("destination", "left-vector", "right-matrix"),
    "TGEMV_BIAS": ("destination", "left-vector", "right-matrix", "bias"),
    "TGEMV_ACC": ("destination", "accumulator", "left-vector", "right-matrix"),
    "TGEMV_MX": (
        "destination",
        "left-vector",
        "row-scale",
        "right-matrix",
        "column-scale",
    ),
    "TGEMV_MX_BIAS": (
        "destination",
        "left-vector",
        "row-scale",
        "right-matrix",
        "column-scale",
        "bias",
    ),
    "TGEMV_MX_ACC": (
        "destination",
        "accumulator",
        "left-vector",
        "row-scale",
        "right-matrix",
        "column-scale",
    ),
}


class CubeTileContractTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.by_mnemonic = {
            unit.mnemonic: unit
            for unit in load_units(ROOT / "asl")
            if unit.mnemonic is not None
        }

    def test_tile_pages_share_their_normative_block_schema(self) -> None:
        aligned_keys = ("block_composition", "defaults", "exceptions", "legality", "ordering")
        for tile_name, start_name in CUBE_TILE_TO_START.items():
            with self.subTest(tile=tile_name):
                tile = self.by_mnemonic[tile_name]
                start = self.by_mnemonic[start_name]
                tile_contract = tile.metadata["contract"]
                start_contract = start.metadata["contract"]

                self.assertEqual(tile.metadata["block"], start_contract["block_composition"])
                for key in aligned_keys:
                    self.assertEqual(tile_contract[key], start_contract[key])

    def test_tile_catalog_routes_to_the_exact_start_and_cube_function(self) -> None:
        for tile_name, start_name in CUBE_TILE_TO_START.items():
            with self.subTest(tile=tile_name):
                tile = self.by_mnemonic[tile_name]
                start = self.by_mnemonic[start_name]
                record = tile.metadata["catalog_records"][0]
                source = (ROOT / start.source_path).read_text(encoding="utf-8")
                identifier = start_name.replace(".", "_")
                function_match = re.search(
                    rf"InstructionContractCubeFunction_{identifier}\(\).*?"
                    rf"return\s+([0-9]+);",
                    source,
                    flags=re.DOTALL,
                )

                self.assertIsNotNone(function_match)
                self.assertEqual(record["command_mnemonic"], start_name)
                self.assertEqual(record["function"], int(function_match.group(1)))
                self.assertEqual(record["effect_contract"], tile_name)
                self.assertEqual(record["semantic_handler"], tile_name)
                self.assertEqual(record["legality_handler"], f"TileOperandsLegal_{tile_name}")
                self.assertEqual(
                    record["datr_contract"],
                    {
                        "allowed_nonzero_fields": [
                            "DataType",
                            "RMode",
                            "Sat",
                            "PadValueOrByteId",
                        ],
                        "pad_union": "matrix-cctrl",
                    },
                )

    def test_operand_roles_match_the_m_equals_one_tgemv_specialization(self) -> None:
        for tile_name, expected_roles in CUBE_OPERAND_ROLES.items():
            with self.subTest(tile=tile_name):
                tile = self.by_mnemonic[tile_name]
                record = tile.metadata["catalog_records"][0]
                self.assertEqual(
                    tuple(operand["role"] for operand in record["operands"]),
                    expected_roles,
                )
                self.assertEqual(
                    tuple(
                        operand["role"] for operand in tile.metadata["contract"]["operands"]
                    ),
                    expected_roles,
                )

    def test_matrix_cctrl_contract_is_consistent_across_tile_and_start_owners(self) -> None:
        for tile_name, start_name in CUBE_TILE_TO_START.items():
            for mnemonic in (tile_name, start_name):
                with self.subTest(mnemonic=mnemonic):
                    contract = self.by_mnemonic[mnemonic].metadata["contract"]
                    self.assertTrue(
                        any("Omitted CCTRL selects 00" in row for row in contract["defaults"])
                    )
                    self.assertTrue(
                        any(
                            "Every successful form allocates and publishes D" in row
                            for row in contract["legality"]
                        )
                    )
                    self.assertTrue(
                        any("Transparent-cache hints" in row for row in contract["ordering"])
                    )
                    self.assertTrue(
                        any("Always publish D" in row for row in contract["state_effects"])
                    )


if __name__ == "__main__":
    unittest.main()
