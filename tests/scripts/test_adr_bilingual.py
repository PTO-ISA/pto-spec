from __future__ import annotations

import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
CHECKER = ROOT / "scripts/check-adr-bilingual"


class AdrBilingualTest(unittest.TestCase):
    def test_repository_adrs_have_bilingual_decision_details(self) -> None:
        result = subprocess.run(
            [str(CHECKER)], cwd=ROOT, text=True, capture_output=True, check=False
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("104 records", result.stdout)


if __name__ == "__main__":
    unittest.main()
