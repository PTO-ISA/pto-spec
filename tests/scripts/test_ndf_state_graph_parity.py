from __future__ import annotations

import subprocess
import unittest
from pathlib import Path

from scripts.asl_units import load_units
from scripts.ndf import state_index


REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
NDF_ROOT = REPOSITORY_ROOT / "tools" / "ndf"
NDF_REVISION = "ed356980ce7ecb2e8482902988d5012fb54058b3"


def expected_counts() -> dict[str, int]:
    """Derive the independent PTO inventory compared with the NDF graph."""

    units = load_units(REPOSITORY_ROOT / "asl")
    return {
        "unit": len(units),
        "instruction": sum(unit.mnemonic is not None for unit in units),
        "synthetic-unit": 1,
        "state": len(state_index(REPOSITORY_ROOT)),
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


if __name__ == "__main__":
    unittest.main()
