from __future__ import annotations

import os
import resource
import stat
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
LAUNCHER = ROOT / "scripts" / "aslref"
PREPARER = ROOT / "scripts" / "prepare-aslref"
UPSTREAM = (ROOT / ".aslref-origin").read_text(encoding="utf-8").strip()
PIN = (ROOT / ".aslref-version").read_text(encoding="utf-8").strip()


class AslrefLauncherTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory(prefix="pto-aslref-launcher-")
        self.addCleanup(self.temp_dir.cleanup)
        self.temp = Path(self.temp_dir.name)
        self.fake_bin = self.temp / "bin"
        self.fake_bin.mkdir()
        self._write_executable(self.fake_bin / "opam", "#!/usr/bin/env bash\nexit 0\n")
        self._write_executable(
            self.fake_bin / "git",
            """#!/usr/bin/env bash
case "$*" in
  *"remote get-url origin"*) printf '%s\\n' "$PTO_TEST_UPSTREAM" ;;
  *"rev-parse HEAD"*) printf '%s\\n' "$PTO_TEST_PIN" ;;
  *"status --porcelain=v1 --untracked-files=all"*)
    if [[ ${PTO_TEST_DIRTY:-0} = 1 ]]; then printf ' M asllib/fixture.ml\\n'; fi ;;
  *) printf 'unexpected git mutation: %s\\n' "$*" >&2; exit 90 ;;
esac
""",
        )
        self.env = {
            **os.environ,
            "PATH": f"{self.fake_bin}{os.pathsep}{os.environ['PATH']}",
            "PTO_TEST_PIN": PIN,
            "PTO_TEST_UPSTREAM": UPSTREAM,
        }

    @staticmethod
    def _write_executable(path: Path, text: str) -> None:
        path.write_text(text, encoding="utf-8")
        path.chmod(path.stat().st_mode | stat.S_IXUSR)

    def test_unprepared_launcher_fails_without_creating_shared_cache(self) -> None:
        cache = self.temp / "missing-cache"
        result = subprocess.run(
            [str(LAUNCHER), "--type-check-strict", "fixture.asl"],
            cwd=ROOT,
            env={**self.env, "PTO_ASLREF_ROOT": str(cache)},
            text=True,
            capture_output=True,
            check=False,
        )

        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(cache.exists())
        self.assertIn("make setup", result.stderr)

    def test_prepared_launcher_executes_exact_pinned_binary(self) -> None:
        cache = self.temp / "prepared-cache"
        (cache / ".git").mkdir(parents=True)
        binary = cache / "_build" / "default" / "asllib" / "aslref.exe"
        binary.parent.mkdir(parents=True)
        self._write_executable(binary, "#!/usr/bin/env bash\nprintf 'aslref:%s\\n' \"$*\"\n")

        result = subprocess.run(
            [str(LAUNCHER), "--type-check-strict", "fixture.asl"],
            cwd=ROOT,
            env={**self.env, "PTO_ASLREF_ROOT": str(cache)},
            text=True,
            capture_output=True,
            check=False,
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "aslref:--type-check-strict fixture.asl\n")

    def test_launcher_rejects_a_different_origin(self) -> None:
        cache = self.temp / "wrong-origin-cache"
        (cache / ".git").mkdir(parents=True)
        binary = cache / "_build" / "default" / "asllib" / "aslref.exe"
        binary.parent.mkdir(parents=True)
        self._write_executable(binary, "#!/usr/bin/env bash\nprintf 'must-not-run\\n'\n")

        result = subprocess.run(
            [str(LAUNCHER), "--version"],
            cwd=ROOT,
            env={
                **self.env,
                "PTO_ASLREF_ROOT": str(cache),
                "PTO_TEST_UPSTREAM": "https://github.com/herd/herdtools7.git",
            },
            text=True,
            capture_output=True,
            check=False,
        )

        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("must-not-run", result.stdout)
        self.assertIn("cached ASLRef origin", result.stderr)

    def test_prepared_launcher_raises_soft_stack_to_hard_limit(self) -> None:
        cache = self.temp / "stack-cache"
        (cache / ".git").mkdir(parents=True)
        binary = cache / "_build" / "default" / "asllib" / "aslref.exe"
        binary.parent.mkdir(parents=True)
        self._write_executable(
            binary,
            "#!/usr/bin/env bash\nprintf 'stack:%s\\n' \"$(ulimit -s)\"\n",
        )

        result = subprocess.run(
            [str(LAUNCHER), "--type-check-strict", "fixture.asl"],
            cwd=ROOT,
            env={**self.env, "PTO_ASLREF_ROOT": str(cache)},
            text=True,
            capture_output=True,
            check=False,
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        hard_limit = resource.getrlimit(resource.RLIMIT_STACK)[1]
        expected = (
            "unlimited"
            if hard_limit == resource.RLIM_INFINITY
            else str(hard_limit // 1024)
        )
        self.assertEqual(result.stdout, f"stack:{expected}\n")

    def test_launcher_rejects_a_dirty_pinned_checkout(self) -> None:
        cache = self.temp / "dirty-cache"
        (cache / ".git").mkdir(parents=True)
        binary = cache / "_build" / "default" / "asllib" / "aslref.exe"
        binary.parent.mkdir(parents=True)
        self._write_executable(binary, "#!/usr/bin/env bash\nprintf 'must-not-run\\n'\n")

        result = subprocess.run(
            [str(LAUNCHER), "--version"],
            cwd=ROOT,
            env={
                **self.env,
                "PTO_ASLREF_ROOT": str(cache),
                "PTO_TEST_DIRTY": "1",
            },
            text=True,
            capture_output=True,
            check=False,
        )

        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("must-not-run", result.stdout)
        self.assertIn("not clean", result.stderr)

    def test_prepare_rebuilds_a_preexisting_stale_binary(self) -> None:
        cache = self.temp / "prepared-cache"
        (cache / ".git").mkdir(parents=True)
        binary = cache / "_build" / "default" / "asllib" / "aslref.exe"
        binary.parent.mkdir(parents=True)
        self._write_executable(binary, "#!/usr/bin/env bash\nprintf 'stale\\n'\n")
        self._write_executable(
            self.fake_bin / "opam",
            """#!/usr/bin/env bash
set -euo pipefail
test "$*" = "exec -- dune build --root=$PTO_ASLREF_ROOT asllib/aslref.exe"
cat > "$PTO_ASLREF_ROOT/_build/default/asllib/aslref.exe" <<'EOF'
#!/usr/bin/env bash
printf 'fresh\\n'
EOF
chmod +x "$PTO_ASLREF_ROOT/_build/default/asllib/aslref.exe"
""",
        )

        result = subprocess.run(
            [str(PREPARER)],
            cwd=ROOT,
            env={**self.env, "PTO_ASLREF_ROOT": str(cache)},
            text=True,
            capture_output=True,
            check=False,
        )
        executed = subprocess.run(
            [str(binary)],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(executed.returncode, 0, executed.stderr)
        self.assertEqual(executed.stdout, "fresh\n")


if __name__ == "__main__":
    unittest.main()
