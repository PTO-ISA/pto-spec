from __future__ import annotations

import os
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
CHECKER = ROOT / "scripts/check-script-entrypoints"


class ScriptEntrypointTest(unittest.TestCase):
    def run_checker(
        self, files: dict[str, tuple[str, int]]
    ) -> subprocess.CompletedProcess[str]:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name, (content, mode) in files.items():
                path = root / name
                path.write_text(content, encoding="utf-8")
                os.chmod(path, mode)
            return subprocess.run(
                [str(CHECKER), "--scripts", str(root)],
                cwd=ROOT,
                text=True,
                capture_output=True,
                check=False,
            )

    def test_declared_python_module_may_be_non_executable(self) -> None:
        result = self.run_checker({"asl_tests.py": ("VALUE = 1\n", 0o644)})
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_adr_records_module_may_be_non_executable(self) -> None:
        result = self.run_checker({"adr_records.py": ("VALUE = 1\n", 0o644)})
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_workflow_contract_modules_may_be_non_executable(self) -> None:
        for name in (
            "architecture_readiness.py",
            "full_validation_workflow.py",
            "management_refactor_closure.py",
            "release_selection.py",
            "workflow_contract.py",
        ):
            with self.subTest(name=name):
                result = self.run_checker({name: ("VALUE = 1\n", 0o644)})
                self.assertEqual(result.returncode, 0, result.stderr)

    def test_python_command_without_executable_bit_is_rejected(self) -> None:
        result = self.run_checker(
            {"instruction_docs.py": ("#!/usr/bin/env python3\nVALUE = 1\n", 0o644)}
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("script is not executable", result.stderr)

    def test_executable_python_command_is_accepted(self) -> None:
        result = self.run_checker(
            {"instruction_docs.py": ("#!/usr/bin/env python3\nVALUE = 1\n", 0o755)}
        )
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_check_adrs_is_an_executable_python_command(self) -> None:
        result = self.run_checker(
            {"check-adrs": ("#!/usr/bin/env python3\nVALUE = 1\n", 0o755)}
        )
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == "__main__":
    unittest.main()
