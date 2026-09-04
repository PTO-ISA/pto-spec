from __future__ import annotations

import io
from pathlib import Path
import runpy
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
RUNNER = runpy.run_path(
    str(ROOT / "scripts/run-python-tests"),
    run_name="pto_run_python_tests_test",
)
ModuleResult = RUNNER["ModuleResult"]


class PythonTestRunnerTest(unittest.TestCase):
    def test_discovers_modules_in_stable_order(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            tests = root / "tests/scripts"
            tests.mkdir(parents=True)
            (tests / "test_zeta.py").write_text("", encoding="utf-8")
            (tests / "test_alpha.py").write_text("", encoding="utf-8")
            (tests / "helper.py").write_text("", encoding="utf-8")

            modules = RUNNER["discover_modules"](root)

        self.assertEqual(
            modules,
            ("tests.scripts.test_alpha", "tests.scripts.test_zeta"),
        )

    def test_runs_modules_in_isolated_processes(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            tests = root / "tests/scripts"
            tests.mkdir(parents=True)
            (tests / "test_pass.py").write_text(
                "import unittest\n"
                "class PassTest(unittest.TestCase):\n"
                "    def test_pass(self):\n"
                "        self.assertEqual(1 + 1, 2)\n",
                encoding="utf-8",
            )
            (tests / "test_fail.py").write_text(
                "import unittest\n"
                "class FailTest(unittest.TestCase):\n"
                "    def test_fail(self):\n"
                "        self.fail('expected failure')\n",
                encoding="utf-8",
            )

            results = RUNNER["run_modules"](
                root,
                ("tests.scripts.test_pass", "tests.scripts.test_fail"),
                2,
            )

        by_module = {result.module: result for result in results}
        self.assertEqual(by_module["tests.scripts.test_pass"].returncode, 0)
        self.assertEqual(by_module["tests.scripts.test_pass"].test_count, 1)
        self.assertNotEqual(by_module["tests.scripts.test_fail"].returncode, 0)
        self.assertEqual(by_module["tests.scripts.test_fail"].test_count, 1)

    def test_reports_failures_and_slowest_modules(self) -> None:
        results = (
            ModuleResult("tests.scripts.test_slow", 0, 2.0, 3, "", ""),
            ModuleResult("tests.scripts.test_fail", 1, 1.0, 2, "", "boom\n"),
        )

        def fake_run_modules(root, modules, jobs):
            self.assertEqual(modules, ("tests.scripts.test_slow",))
            self.assertEqual(jobs, 2)
            return results

        output = io.StringIO()
        original = RUNNER["main"].__globals__["run_modules"]
        RUNNER["main"].__globals__["run_modules"] = fake_run_modules
        try:
            returncode = RUNNER["main"](
                ["--module", "tests.scripts.test_slow", "-j", "2", "--slowest", "1"],
                output=output,
            )
        finally:
            RUNNER["main"].__globals__["run_modules"] = original

        text = output.getvalue()
        self.assertEqual(returncode, 1)
        self.assertIn("FAIL tests.scripts.test_fail", text)
        self.assertIn("boom", text)
        self.assertIn("2.000s tests.scripts.test_slow", text)
        self.assertIn("Python tests: FAIL · 2 modules · 5 tests · 1 failed", text)

    def test_clean_default_output_is_summary_only(self) -> None:
        results = (
            ModuleResult("tests.scripts.test_alpha", 0, 0.25, 2, "", ""),
            ModuleResult("tests.scripts.test_beta", 0, 0.50, 3, "", ""),
        )

        def fake_run_modules(root, modules, jobs):
            return results

        output = io.StringIO()
        original = RUNNER["main"].__globals__["run_modules"]
        RUNNER["main"].__globals__["run_modules"] = fake_run_modules
        try:
            returncode = RUNNER["main"](
                ["--module", "tests.scripts.test_alpha", "-j", "2"],
                output=output,
            )
        finally:
            RUNNER["main"].__globals__["run_modules"] = original

        text = output.getvalue()
        self.assertEqual(returncode, 0)
        self.assertEqual(text.count("\n"), 1)
        self.assertNotIn("tests.scripts.test_alpha", text)
        self.assertIn("Python tests: PASS · 2 modules · 5 tests", text)

    def test_excludes_release_only_modules_from_a_discovered_lane(self) -> None:
        results = (
            ModuleResult("tests.scripts.test_alpha", 0, 0.25, 1, "", ""),
        )

        def fake_run_modules(root, modules, jobs):
            self.assertEqual(modules, ("tests.scripts.test_alpha",))
            return results

        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            tests = root / "tests/scripts"
            tests.mkdir(parents=True)
            (tests / "test_alpha.py").write_text("", encoding="utf-8")
            (tests / "test_release_only.py").write_text("", encoding="utf-8")
            output = io.StringIO()
            original = RUNNER["main"].__globals__["run_modules"]
            RUNNER["main"].__globals__["run_modules"] = fake_run_modules
            try:
                returncode = RUNNER["main"](
                    [
                        "--root",
                        str(root),
                        "--exclude-module",
                        "tests.scripts.test_release_only",
                    ],
                    output=output,
                )
            finally:
                RUNNER["main"].__globals__["run_modules"] = original

        self.assertEqual(returncode, 0)
        self.assertIn("Python tests: PASS · 1 modules · 1 tests", output.getvalue())


if __name__ == "__main__":
    unittest.main()
