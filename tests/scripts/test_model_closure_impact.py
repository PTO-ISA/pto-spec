from __future__ import annotations

import unittest

import runpy
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
VALIDATE = runpy.run_path(str(ROOT / "scripts/generate-model-closure-impact"))["validate_envelope"]


class ModelClosureImpactTest(unittest.TestCase):
    def test_preserves_a_clean_machine_readable_ndf_envelope(self) -> None:
        envelope = {
                "schema_version": "0.1",
                "command": "impact pto-release",
                "ok": True,
                "diagnostics": [],
                "data": {
                "schema_version": "1",
                "changes": [
                    {"uri": "ndf://pto-spec/PTO-INST-TILE-TADD", "kind": "modified"},
                ],
                },
            }
        self.assertIs(VALIDATE(envelope), envelope)

    def test_rejects_failed_cli_envelope(self) -> None:
        with self.assertRaisesRegex(ValueError, "did not produce a clean"):
            VALIDATE({"schema_version": "0.1", "command": "impact pto-release", "ok": False})


if __name__ == "__main__":
    unittest.main()
