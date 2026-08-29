from __future__ import annotations

import os
import stat
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
CHECKER = ROOT / "scripts" / "check-aslref-strict"


class CheckAslrefStrictTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory(prefix="pto-check-aslref-strict-")
        self.addCleanup(self.temp_dir.cleanup)
        self.temp = Path(self.temp_dir.name)
        self.fixture = self.temp / "fixture.asl"
        self.fixture.write_text("func main() => integer begin return 0; end;\n")

    def _run(self, body: str) -> subprocess.CompletedProcess[str]:
        aslref = self.temp / "fake-aslref"
        aslref.write_text(f"#!/usr/bin/env bash\n{body}\n", encoding="utf-8")
        aslref.chmod(aslref.stat().st_mode | stat.S_IXUSR)
        return subprocess.run(
            [str(CHECKER), str(self.fixture)],
            cwd=ROOT,
            env={**os.environ, "ASLREF": str(aslref)},
            text=True,
            capture_output=True,
            check=False,
        )

    def test_accepts_warning_free_strict_typecheck(self) -> None:
        result = self._run(
            'test "$1" = "--type-check-strict"\n'
            'test "$2" = "--no-exec"\n'
            'test "$3" = "' + str(self.fixture) + '"\n'
            "printf 'strict typecheck passed\\n'"
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "strict typecheck passed\n")

    def test_rejects_successful_typecheck_with_warning(self) -> None:
        result = self._run(
            "printf 'ASL Warning: narrowed a constraint set\\n' >&2\nexit 0"
        )

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("ASL Warning: narrowed a constraint set", result.stderr)
        self.assertIn("strict typecheck emitted an ASL warning", result.stderr)

    def test_preserves_aslref_failure(self) -> None:
        result = self._run("printf 'ASL Type error: fixture failed\\n' >&2\nexit 17")

        self.assertEqual(result.returncode, 17)
        self.assertIn("ASL Type error: fixture failed", result.stderr)
        self.assertNotIn("ASL warning", result.stderr)


if __name__ == "__main__":
    unittest.main()
