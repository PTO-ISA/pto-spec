from __future__ import annotations

import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
MAKEFILE = ROOT / "Makefile"


class AslBuildDependenciesTest(unittest.TestCase):
    def test_decoder_target_depends_on_shared_witness_generator(self) -> None:
        makefile = MAKEFILE.read_text(encoding="utf-8")
        rule = re.search(
            r"^\$\(DECODER_SPEC\):(?P<prerequisites>(?:[^\n]*\\\n)*[^\n]*)\n\t",
            makefile,
            flags=re.MULTILINE,
        )

        self.assertIsNotNone(rule, "DECODER_SPEC rule is absent or malformed")
        self.assertIn("scripts/encoding_witness.py", rule.group("prerequisites"))


if __name__ == "__main__":
    unittest.main()
