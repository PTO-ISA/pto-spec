from __future__ import annotations

import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
FRAME_MNEMONICS = ("FENTRY", "FEXIT", "FRET.RA", "FRET.STK")


class FrameTemplateContractTest(unittest.TestCase):
    def test_frame_owners_expose_inclusive_not_half_open_ranges(self) -> None:
        for mnemonic in FRAME_MNEMONICS:
            with self.subTest(mnemonic=mnemonic):
                text = (
                    ROOT / "asl/block/lifecycle" / f"{mnemonic}.asl"
                ).read_text(encoding="utf-8")
                identifier = mnemonic.replace(".", "_")
                self.assertIn(
                    f"InstructionContractUsesInclusiveRegisterRange_{identifier}",
                    text,
                )
                self.assertNotIn("UsesHalfOpenRegisterRange", text)


if __name__ == "__main__":
    unittest.main()
