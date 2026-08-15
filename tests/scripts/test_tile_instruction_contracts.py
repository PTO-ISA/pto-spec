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

        self.assertEqual(len(tile_units), 109)
        self.assertEqual(
            Counter(unit.classification[0] for unit in tile_units),
            Counter(
                {
                    "reduce-and-expand": 28,
                    "elementwise-tile-tile": 25,
                    "tile-scalar-and-immediate": 15,
                    "irregular-and-complex": 13,
                    "matrix-and-matrix-vector": 12,
                    "memory-and-data-movement": 9,
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


if __name__ == "__main__":
    unittest.main()
