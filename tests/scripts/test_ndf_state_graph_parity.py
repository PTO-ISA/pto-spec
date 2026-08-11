from __future__ import annotations

import json
import subprocess
import tempfile
import unittest
from pathlib import Path


REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
NDF_ROOT = REPOSITORY_ROOT / "tools" / "ndf"
NDF_REVISION = "ed356980ce7ecb2e8482902988d5012fb54058b3"
EXPECTED_COUNTS = {
    "unit": 788,
    "instruction": 651,
    "synthetic-unit": 1,
    "state": 12,
}


def command(*arguments: str, cwd: Path = REPOSITORY_ROOT) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        arguments,
        cwd=cwd,
        check=False,
        capture_output=True,
        text=True,
    )


class NdfStateGraphParityTest(unittest.TestCase):
    def test_compiler_is_an_exact_locked_tool_dependency(self) -> None:
        self.assertTrue(NDF_ROOT.is_dir(), "tools/ndf submodule is missing")
        self.assertEqual(
            command("git", "rev-parse", "HEAD", cwd=NDF_ROOT).stdout.strip(),
            NDF_REVISION,
        )
        self.assertEqual(
            command(
                "git",
                "config",
                "-f",
                ".gitmodules",
                "--get",
                "submodule.tools/ndf.url",
            ).stdout.strip(),
            "https://github.com/PTO-ISA/normative_language.git",
        )
        manifest = (REPOSITORY_ROOT / "ndf.yaml").read_text(encoding="utf-8")
        lock = (REPOSITORY_ROOT / "ndf.lock").read_text(encoding="utf-8")
        self.assertIn("  ndf:\n    path: tools/ndf\n    graph: false\n", manifest)
        self.assertIn(f"    revision: {NDF_REVISION}\n", lock)
        self.assertIn("    path: tools/ndf\n", lock)

    def test_compiler_graph_matches_the_pto_metadata_inventory(self) -> None:
        build = command(
            "cargo",
            "build",
            "--manifest-path",
            str(NDF_ROOT / "Cargo.toml"),
            "--locked",
            "--release",
            "-p",
            "ndf-cli",
        )
        self.assertEqual(build.returncode, 0, build.stderr)
        binary = NDF_ROOT / "target" / "release" / "ndf"
        with tempfile.TemporaryDirectory() as temporary:
            index = Path(temporary) / "pto.sqlite"
            built = command(
                str(binary),
                "build",
                "--root",
                str(REPOSITORY_ROOT),
                "--output",
                str(index),
                "--format",
                "json",
            )
            self.assertEqual(built.returncode, 0, built.stderr)
            envelope = json.loads(built.stdout)
            self.assertTrue(envelope["ok"], envelope)

            actual: dict[str, int] = {}
            for entity in EXPECTED_COUNTS:
                queried = command(
                    str(binary),
                    "query",
                    "--index",
                    str(index),
                    "--expression",
                    f"attributes.pto_entity={entity}",
                    "--format",
                    "json",
                )
                self.assertEqual(queried.returncode, 0, queried.stderr)
                result = json.loads(queried.stdout)
                self.assertTrue(result["ok"], result)
                actual[entity] = len(result["data"])

        self.assertEqual(actual, EXPECTED_COUNTS)


if __name__ == "__main__":
    unittest.main()
