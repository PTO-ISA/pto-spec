from __future__ import annotations

import runpy
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[2] / "scripts/generate-system-register-witness-closure"


class SystemRegisterWitnessClosureTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.module = runpy.run_path(str(SCRIPT), run_name="witness_module")

    def test_unit_inventory_ignores_symbols_and_numbers_in_comments(self) -> None:
        sources = {
            "asl/example.asl": (
                "// ReadSystemRegisterAddress and trap numbers 33, 49, 51 are metadata.\n"
                "func Clean() => integer\n"
                "begin\n"
                "    // SetFault(Fault_Example);\n"
                "    return 0;\n"
                "end;\n"
            )
        }

        inventory = self.module["unit_inventory"](
            sources,
            {"ReadSystemRegisterAddress", "SetFault"},
            {33, 49, 51},
        )

        self.assertEqual(inventory, [])


if __name__ == "__main__":
    unittest.main()
