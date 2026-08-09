from __future__ import annotations

import io
import json
import tempfile
import unittest
from contextlib import redirect_stderr, redirect_stdout
from pathlib import Path
from subprocess import CompletedProcess
from unittest.mock import patch

from scripts.asl_release_suite import page_main
from tests.scripts.test_run_asl_release_suite import MATRIX, result


class RunAslPageTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        self.matrix = self.root / "page.json"
        self.commit = "c" * 40
        self.matrix.write_text(
            json.dumps(
                {
                    "commit": self.commit,
                    "page": 3,
                    "page_count": 10,
                    "test_count": 905,
                    "include": MATRIX,
                }
            ),
            encoding="utf-8",
        )

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def git_result(self) -> CompletedProcess[str]:
        return CompletedProcess(
            ["git", "rev-parse", "HEAD"], 0, stdout=self.commit + "\n", stderr=""
        )

    def test_page_runner_passes_explicit_jobs_to_parallel_executor(self) -> None:
        output = io.StringIO()
        with (
            patch("scripts.asl_release_suite.subprocess.run", return_value=self.git_result()),
            patch(
                "scripts.asl_release_suite.execute_matrix", return_value=[result()]
            ) as execute,
            redirect_stdout(output),
        ):
            status = page_main(
                [
                    "--root",
                    str(self.root),
                    "--matrix",
                    str(self.matrix),
                    "-j",
                    "7",
                ]
            )

        self.assertEqual(status, 0)
        execute.assert_called_once_with(self.root.resolve(), MATRIX, jobs=7)
        self.assertIn("page 3 passed", output.getvalue())

    def test_page_runner_defaults_to_machine_core_count(self) -> None:
        output = io.StringIO()
        with (
            patch.dict("scripts.asl_release_suite.os.environ", {}, clear=True),
            patch("scripts.asl_release_suite.os.cpu_count", return_value=6),
            patch("scripts.asl_release_suite.subprocess.run", return_value=self.git_result()),
            patch(
                "scripts.asl_release_suite.execute_matrix", return_value=[result()]
            ) as execute,
            redirect_stdout(output),
        ):
            status = page_main(
                ["--root", str(self.root), "--matrix", str(self.matrix)]
            )

        self.assertEqual(status, 0)
        execute.assert_called_once_with(self.root.resolve(), MATRIX, jobs=6)

    def test_page_runner_rejects_failed_result(self) -> None:
        error = io.StringIO()
        with (
            patch("scripts.asl_release_suite.subprocess.run", return_value=self.git_result()),
            patch(
                "scripts.asl_release_suite.execute_matrix",
                return_value=[result(status="failed")],
            ),
            redirect_stderr(error),
        ):
            status = page_main(
                ["--root", str(self.root), "--matrix", str(self.matrix), "-j", "2"]
            )

        self.assertEqual(status, 1)
        self.assertIn("did not pass", error.getvalue())

    def test_page_runner_rejects_matrix_for_different_commit(self) -> None:
        self.matrix.write_text(
            self.matrix.read_text(encoding="utf-8").replace(self.commit, "d" * 40),
            encoding="utf-8",
        )
        error = io.StringIO()
        with (
            patch("scripts.asl_release_suite.subprocess.run", return_value=self.git_result()),
            redirect_stderr(error),
        ):
            status = page_main(
                ["--root", str(self.root), "--matrix", str(self.matrix), "-j", "2"]
            )

        self.assertEqual(status, 1)
        self.assertIn("wrong commit", error.getvalue())


if __name__ == "__main__":
    unittest.main()
