from __future__ import annotations

import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "scripts/check-aslref-diagnostics"


class ASLRefDiagnosticsTest(unittest.TestCase):
    def run_fixture(self, shell_body: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [str(SCRIPT), "bash", "-c", shell_body],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )

    def test_accepts_clean_success(self) -> None:
        result = self.run_fixture("exit 0")

        self.assertEqual(result.returncode, 0)
        self.assertIn("0 warnings", result.stdout)

    def test_rejects_warning_even_when_aslref_succeeds(self) -> None:
        result = self.run_fixture("printf 'ASL Warning: fixture\\n' >&2")

        self.assertEqual(result.returncode, 1)
        self.assertIn("ASL Warning: fixture", result.stderr)
        self.assertIn("completed with warnings", result.stderr)

    def test_preserves_failing_exit_status_and_diagnostics(self) -> None:
        result = self.run_fixture("printf 'type error\\n' >&2; exit 7")

        self.assertEqual(result.returncode, 7)
        self.assertIn("type error", result.stderr)


if __name__ == "__main__":
    unittest.main()
