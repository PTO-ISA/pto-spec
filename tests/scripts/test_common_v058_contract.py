from __future__ import annotations

import json
import re
import unittest
from pathlib import Path

from scripts.instruction_docs import load_instruction_index


ROOT = Path(__file__).resolve().parents[2]


class CommonV058ContractTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.command = json.loads(
            (ROOT / "spec/catalog/command-forms.json").read_text(encoding="utf-8")
        )
        cls.tile = json.loads(
            (ROOT / "spec/catalog/tile-operations.json").read_text(encoding="utf-8")
        )
        cls.reservations = json.loads(
            (ROOT / "spec/catalog/linx-vector-reservations.json").read_text(
                encoding="utf-8"
            )
        )

    def test_deleted_names_are_not_active_or_reserved(self) -> None:
        active_names = {form["mnemonic"] for form in self.command["forms"]}
        reserved_names = {
            reservation["mnemonic"]
            for reservation in self.reservations["reservations"]
        }

        for deleted in ("B.IOD", "BSTART.PAR", "C.B.IOS"):
            self.assertNotIn(deleted, active_names)
            self.assertNotIn(deleted, reserved_names)

    def test_b_ios_reuses_the_former_b_iod_slot(self) -> None:
        forms = [form for form in self.command["forms"] if form["mnemonic"] == "B.IOS"]

        self.assertEqual(len(forms), 1)
        self.assertEqual(
            forms[0]["encoding"],
            [
                {
                    "index": 0,
                    "mask": "0xf00871ff",
                    "match": "0x00001013",
                    "width_bits": 32,
                }
            ],
        )

    def test_b_iot_has_no_mask_only_shared_form(self) -> None:
        forms = [form for form in self.command["forms"] if form["mnemonic"] == "B.IOT"]

        self.assertTrue(forms)
        for form in forms:
            fields = {field["name"] for field in form["fields"]}
            self.assertTrue(
                {"SrcTile0", "SrcTile1", "DstTile"}.intersection(fields),
                form["asm"],
            )

    def test_tload_tstore_keep_encoded_base_and_stride_schema(self) -> None:
        by_name = {operation["name"]: operation for operation in self.tile["operations"]}

        for name in ("TLOAD", "TSTORE"):
            operands = {
                operand["field"]: operand["role"]
                for operand in by_name[name]["operands"]
            }
            self.assertEqual(operands["address"], "base-address")
            self.assertEqual(operands["scalar0"], "row-stride-elements")

    def test_tfma_remains_active_at_selector_01c(self) -> None:
        tfma = next(
            operation
            for operation in self.tile["operations"]
            if operation["name"] == "TFMA"
        )

        self.assertEqual(tfma["selector"], "0x01C")
        self.assertEqual((tfma["mode"], tfma["function"]), (0, 28))

    def test_every_instruction_has_a_specific_summary(self) -> None:
        generic = re.compile(
            r"Execute the .+ (?:scalar instruction|instruction|Tile operation|operation) contract\."
        )
        missing = [
            record.mnemonic
            for record in load_instruction_index(ROOT)
            if record.surface in {"scalar", "block", "tile"}
            and generic.fullmatch(record.summary)
        ]

        self.assertEqual(missing, [])


if __name__ == "__main__":
    unittest.main()
