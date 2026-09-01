from __future__ import annotations

import unittest

from scripts.asl_units import load_units
from scripts.instruction_contracts import (
    ROOT,
    check_instruction_contracts,
    load_field_domains,
    resolve_instruction_contract,
)


class BlockInstructionContractsTest(unittest.TestCase):
    def test_every_block_mnemonic_has_a_complete_contract(self) -> None:
        errors = check_instruction_contracts(surface="block", require_complete=True)

        self.assertEqual(errors, [])

    def test_block_inventory_and_encoded_fields_are_closed(self) -> None:
        units = load_units(ROOT / "asl")
        domains = load_field_domains(units)
        block_units = [
            unit for unit in units if unit.surface == "block" and unit.mnemonic is not None
        ]

        self.assertEqual(len(block_units), 80)
        for unit in block_units:
            contract = resolve_instruction_contract(unit, domains)
            self.assertIsNotNone(contract)
            if unit.metadata.get("alias_of") is None:
                expected_fields = sum(
                    len(record.get("fields", []))
                    for record in unit.metadata["catalog_records"]
                )
                self.assertEqual(len(contract.encoded_fields), expected_fields)

    def test_deleted_block_names_do_not_reenter_the_active_surface(self) -> None:
        active = {
            unit.mnemonic
            for unit in load_units(ROOT / "asl")
            if unit.surface == "block" and unit.mnemonic is not None
        }

        self.assertNotIn("B.IOD", active)
        self.assertNotIn("BSTART.PAR", active)

    def test_xb_is_inventoried_as_reserved_in_pto(self) -> None:
        xb = next(
            unit
            for unit in load_units(ROOT / "asl")
            if unit.surface == "block" and unit.mnemonic == "XB"
        )

        self.assertEqual(len(xb.metadata["catalog_records"]), 1)
        record = xb.metadata["catalog_records"][0]
        self.assertEqual(record["status"], "reserved-in-pto")
        self.assertEqual(
            record["semantic_handler"],
            "ExecuteCrossBlockTransfer",
        )

    def test_extension_context_forms_are_reserved_in_pto(self) -> None:
        by_mnemonic = {
            unit.mnemonic: unit
            for unit in load_units(ROOT / "asl")
            if unit.surface == "block" and unit.mnemonic is not None
        }

        for mnemonic, handler in (
            ("ERCOV", "RecoverExecutionContext"),
            ("ESAVE", "SaveExecutionContext"),
        ):
            with self.subTest(mnemonic=mnemonic):
                record = by_mnemonic[mnemonic].metadata["catalog_records"][0]
                self.assertEqual(record["status"], "reserved-in-pto")
                self.assertEqual(record["semantic_handler"], handler)

    def test_mset_uses_only_absolute_gpr_sources(self) -> None:
        mset = next(
            unit
            for unit in load_units(ROOT / "asl")
            if unit.surface == "block" and unit.mnemonic == "MSET"
        )
        record = mset.metadata["catalog_records"][0]
        constraints = {
            item["field"]: item
            for item in record["constraints"]
        }

        for field in ("RegSrc0", "RegSrc1", "RegSrc2"):
            self.assertEqual(constraints[field]["operator"], "one-of")
            self.assertEqual(constraints[field]["values"], list(range(24)))

    def test_mcopy_uses_only_absolute_gpr_sources(self) -> None:
        mcopy = next(
            unit
            for unit in load_units(ROOT / "asl")
            if unit.surface == "block" and unit.mnemonic == "MCOPY"
        )
        record = mcopy.metadata["catalog_records"][0]
        constraints = {
            item["field"]: item
            for item in record["constraints"]
        }

        for field in ("RegSrc0", "RegSrc1", "RegSrc2"):
            self.assertEqual(constraints[field]["operator"], "one-of")
            self.assertEqual(constraints[field]["values"], list(range(24)))


if __name__ == "__main__":
    unittest.main()
