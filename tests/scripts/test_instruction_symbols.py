from __future__ import annotations

import unittest
from pathlib import Path

from scripts.instruction_symbols import contract_symbol


ROOT = Path(__file__).resolve().parents[2]
class InstructionSymbolTest(unittest.TestCase):
    def test_representative_roles_use_readable_arm_style_names(self) -> None:
        self.assertEqual(contract_symbol("Operation", "ADD"), "ADDOperation")
        self.assertEqual(contract_symbol("Handler", "B_IOT"), "BIOTHandler")
        self.assertEqual(contract_symbol("Execute", "TADD"), "ExecuteTADD")
        self.assertEqual(contract_symbol("Result", "ADD"), "ADDResult")
        self.assertEqual(
            contract_symbol("GMAddress", "TLOAD"), "TLOADGMAddress"
        )
        self.assertEqual(
            contract_symbol("OperandsLegal", "TMATMUL"), "TMATMULOperandsLegal"
        )

    def test_active_asl_has_no_retired_contract_prefix(self) -> None:
        for source in sorted((ROOT / "asl").rglob("*.asl")):
            text = source.read_text(encoding="utf-8")
            self.assertNotIn("InstructionContract", text, str(source))


if __name__ == "__main__":
    unittest.main()
