from __future__ import annotations

import json
import subprocess
import tempfile
import unittest
from pathlib import Path

from scripts.pr_timing import percentile, summarize, summarize_records


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "scripts/pr_timing.py"


class PullRequestTimingTest(unittest.TestCase):
    def test_percentile_uses_nearest_rank(self) -> None:
        self.assertEqual(percentile([1, 2, 3, 4, 5], 95), 5)

    def test_summary_marks_p95_budget_failure(self) -> None:
        summary = summarize([590, 601], budget_seconds=600)

        self.assertEqual(
            summary,
            {
                "budget_seconds": 600,
                "p50_seconds": 590,
                "p95_seconds": 601,
                "sample_count": 2,
                "within_budget": False,
            },
        )

    def test_run_writes_exact_success_record(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "timing.json"
            result = subprocess.run(
                [
                    str(SCRIPT),
                    "run",
                    "--output",
                    str(output),
                    "--",
                    "python3",
                    "-c",
                    "pass",
                ],
                cwd=ROOT,
                text=True,
                capture_output=True,
                check=False,
            )

            self.assertEqual(result.returncode, 0, result.stderr)
            record = json.loads(output.read_text(encoding="utf-8"))
            self.assertEqual(
                set(record),
                {
                    "command",
                    "duration_seconds",
                    "exit_code",
                    "failure_category",
                    "record_type",
                },
            )
            self.assertEqual(record["record_type"], "command")
            self.assertEqual(record["command"], ["python3", "-c", "pass"])
            self.assertIsInstance(record["duration_seconds"], float)
            self.assertGreaterEqual(record["duration_seconds"], 0.0)
            self.assertEqual(record["exit_code"], 0)
            self.assertEqual(record["failure_category"], "none")

    def test_run_preserves_failure_and_records_command_failure(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "timing.json"
            result = subprocess.run(
                [
                    str(SCRIPT),
                    "run",
                    "--output",
                    str(output),
                    "--",
                    "python3",
                    "-c",
                    "raise SystemExit(7)",
                ],
                cwd=ROOT,
                text=True,
                capture_output=True,
                check=False,
            )

            self.assertEqual(result.returncode, 7)
            record = json.loads(output.read_text(encoding="utf-8"))
            self.assertEqual(record["exit_code"], 7)
            self.assertEqual(record["failure_category"], "command")

    def test_run_summary_uses_the_parallel_worker_critical_path(self) -> None:
        records = [
            {
                "record_type": "run",
                "run_id": "hosted-1",
                "worker": "source-contract",
                "duration_seconds": sum([60] * 12),
            },
            {
                "record_type": "run",
                "run_id": "hosted-1",
                "worker": "tooling-tests",
                "duration_seconds": 60,
            },
        ]

        summary = summarize_records(records, budget_seconds=600)

        self.assertEqual(summary["p50_seconds"], 720)
        self.assertEqual(summary["p95_seconds"], 720)
        self.assertEqual(summary["sample_count"], 1)
        self.assertFalse(summary["within_budget"])

    def test_historical_summary_rejects_mixed_command_and_run_records(self) -> None:
        records = [
            {
                "record_type": "run",
                "run_id": "hosted-1",
                "worker": "source-contract",
                "duration_seconds": 1,
            },
            {
                "record_type": "command",
                "command": ["true"],
                "duration_seconds": 1,
                "exit_code": 0,
                "failure_category": "none",
            },
        ]

        with self.assertRaisesRegex(ValueError, "only run records"):
            summarize_records(records, budget_seconds=600)

    def test_worker_finish_writes_exact_run_record(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            start = Path(directory) / "worker.started"
            output = Path(directory) / "worker.json"
            subprocess.run(
                [str(SCRIPT), "start", "--output", str(start)],
                cwd=ROOT,
                check=True,
            )
            result = subprocess.run(
                [
                    str(SCRIPT),
                    "finish",
                    "--start",
                    str(start),
                    "--output",
                    str(output),
                    "--run-id",
                    "hosted-1",
                    "--worker",
                    "source-contract",
                ],
                cwd=ROOT,
                text=True,
                capture_output=True,
                check=False,
            )

            self.assertEqual(result.returncode, 0, result.stderr)
            record = json.loads(output.read_text(encoding="utf-8"))
            self.assertEqual(
                set(record),
                {"duration_seconds", "record_type", "run_id", "worker"},
            )
            self.assertEqual(record["record_type"], "run")
            self.assertEqual(record["run_id"], "hosted-1")
            self.assertEqual(record["worker"], "source-contract")
            self.assertGreaterEqual(record["duration_seconds"], 0.0)


if __name__ == "__main__":
    unittest.main()
