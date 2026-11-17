from __future__ import annotations

import re
import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
GENERATOR = ROOT / "scripts/generate-asl-decoders"


class MessageBufferGeneratorTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        completed = subprocess.run(
            [str(GENERATOR), "--kind", "monolithic"],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )
        if completed.returncode != 0:
            raise AssertionError(completed.stdout[-4000:] + completed.stderr[-4000:])
        cls.generated = completed.stdout

    def test_catalog_expansion_has_complete_transfer_tail(self) -> None:
        self.assertIn(
            "func ValidateCanonicalScalarSYSRegisterTransfers1792To2011()",
            self.generated,
        )
        self.assertIn("/MSGBCR/0x000830", self.generated)
        self.assertIn("/MSGBDOMAIN/0x00084b", self.generated)

    def test_reset_and_access_witnesses_use_message_semantics(self) -> None:
        self.assertIn("assert MessageBufferStateIsReset();", self.generated)
        self.assertIn(".staging_words[[0]] ==", self.generated)
        self.assertIn("msgb_ack_state_", self.generated)
        self.assertIn("Zeros{PTO_XLEN} + 0x101", self.generated)

    def test_swap_witness_rejects_message_registers(self) -> None:
        marker = re.search(
            r"transfer/ssrswap_32_[a-z0-9]+/MSGBD1/0x000831",
            self.generated,
        )
        self.assertIsNotNone(marker)
        assert marker is not None
        start = marker.start()
        case = self.generated[start : start + 1800]
        self.assertIn("ScalarExecution_Rejected", case)
        self.assertIn("Fault_IllegalInstruction", case)
        self.assertNotIn("scalar_sys_transfer_after_", case)


if __name__ == "__main__":
    unittest.main()
