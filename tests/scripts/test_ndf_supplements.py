from __future__ import annotations

import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
CHECKER = ROOT / "scripts/check-ndf-supplements"


class NdfSupplementsTest(unittest.TestCase):
    def test_repository_has_complete_bilingual_supplements(self) -> None:
        result = subprocess.run(
            [str(CHECKER)], cwd=ROOT, text=True, capture_output=True, check=False
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("405 explicit clauses", result.stdout)


if __name__ == "__main__":
    unittest.main()
