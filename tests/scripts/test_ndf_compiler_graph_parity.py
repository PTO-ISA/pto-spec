"""Cargo-dependent NDF compiler graph parity check.

This module builds the locked NDF compiler with cargo and compares its graph
against the PTO metadata inventory. It is valuable release evidence, but it
requires the Rust toolchain (tools/ndf pins rust 1.94.0, edition 2024), so it
runs in the full-validation lane (make release-verify) instead of the
lightweight pull-request lane, which only assumes Git, GNU Make, and Python.
"""

from __future__ import annotations

import json
import subprocess
import tempfile
import unittest
from pathlib import Path

from tests.scripts.test_ndf_state_graph_parity import (
    NDF_ROOT,
    REPOSITORY_ROOT,
    command,
    expected_counts,
)


class NdfCompilerGraphParityTest(unittest.TestCase):
    def test_compiler_graph_matches_the_pto_metadata_inventory(self) -> None:
        expected = expected_counts()
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
            for entity in expected:
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

        self.assertEqual(actual, expected)


if __name__ == "__main__":
    unittest.main()
