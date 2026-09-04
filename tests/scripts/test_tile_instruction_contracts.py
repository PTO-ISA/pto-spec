from __future__ import annotations

import unittest
from collections import Counter

from scripts.asl_units import load_units
from scripts.instruction_contracts import (
    ROOT,
    check_instruction_contracts,
    load_field_domains,
    resolve_instruction_contract,
)


class TileInstructionContractsTest(unittest.TestCase):
    def test_every_tile_mnemonic_has_a_complete_contract(self) -> None:
        self.assertEqual(
            check_instruction_contracts(surface="tile", require_complete=True), []
        )

    def test_tile_taxonomy_inventory_and_selector_contracts_are_closed(self) -> None:
        units = load_units(ROOT / "asl")
        domains = load_field_domains(units)
        tile_units = [
            unit for unit in units if unit.surface == "tile" and unit.mnemonic is not None
        ]

        self.assertEqual(len(tile_units), 118)
        self.assertEqual(
            Counter(unit.classification[0] for unit in tile_units),
            Counter(
                {
                    "reduce-and-expand": 28,
                    "elementwise-tile-tile": 25,
                    "tile-scalar-and-immediate": 15,
                    "irregular-and-complex": 4,
                    "matrix-and-matrix-vector": 12,
                    "memory-and-data-movement": 27,
                    "layout-and-rearrangement": 7,
                }
            ),
        )
        for unit in tile_units:
            contract = resolve_instruction_contract(unit, domains)
            self.assertEqual(contract.encoding_class, "selector-encoded-block-operation")
            self.assertFalse(contract.standalone_opcode)
            self.assertEqual(contract.encoded_fields, ())
            self.assertNotEqual(contract.block_composition, ("none",))
            self.assertIn(unit.metadata["engine"], {"VEC", "TLSU", "CUBE", "SFU"})

    def test_tfma_remains_an_active_vec_operation(self) -> None:
        tfma = next(
            unit
            for unit in load_units(ROOT / "asl")
            if unit.mnemonic == "TFMA"
        )

        self.assertEqual(tfma.metadata["engine"], "VEC")
        self.assertEqual(tfma.metadata["catalog_records"][0]["function"], 28)

    def test_mscatter_popc_uses_the_index_only_body_schema(self) -> None:
        by_mnemonic = {
            unit.mnemonic: unit
            for unit in load_units(ROOT / "asl")
            if unit.mnemonic is not None
        }
        start = by_mnemonic["BSTART.MSCATTER.POPC"]
        tile = by_mnemonic["MSCATTER_POPC"]
        expected_body = (
            "BSTART.MSCATTER.POPC DataType",
            "B.DIM LB0=ValidCol",
            "B.IOT IndexTile, mask=PE_MASK, <last>",
            "B.IOR BaseGPR, zero, zero, ->zero",
            "BSTOP",
        )

        self.assertEqual(tuple(start.metadata["block"]), expected_body)
        self.assertEqual(
            tuple(start.metadata["contract"]["block_composition"]), expected_body
        )
        self.assertEqual(tuple(tile.metadata["block"]), expected_body)
        self.assertEqual(
            tuple(tile.metadata["contract"]["block_composition"]), expected_body
        )
        self.assertEqual(
            tile.metadata["operands"],
            [
                {"field": "address", "role": "base-address"},
                {"field": "source0", "role": "indices"},
            ],
        )

    def test_assigned_tepl_selectors_do_not_overlap_reserved_ranges(self) -> None:
        units = load_units(ROOT / "asl")
        top_level = next(
            unit
            for unit in units
            if unit.unit_id == "PTO-TILE-MODEL-DISPATCH-TOP-LEVEL"
        )
        assigned = {
            int(record["selector"], 0)
            for unit in units
            if unit.surface == "tile" and unit.mnemonic is not None
            for record in unit.metadata["catalog_records"]
            if record["family"] == "TEPL"
        }
        reserved = {
            selector
            for start, end in top_level.metadata["catalog_projection"]["reserved"][
                "tepl_selector_ranges"
            ]
            for selector in range(int(start, 0), int(end, 0) + 1)
        }

        self.assertTrue(assigned.isdisjoint(reserved))
        self.assertEqual(len(assigned), 78)
        self.assertEqual(len(reserved), 42)


if __name__ == "__main__":
    unittest.main()
