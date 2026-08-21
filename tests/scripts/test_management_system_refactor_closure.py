from __future__ import annotations

import json
from pathlib import Path
import tempfile
import unittest

from scripts.management_refactor_closure import (
    REQUIRED_VERIFICATION_COMMANDS,
    active_semantic_identity_count,
    build_document,
    collect_timing_records,
    semantic_surface_changed,
    summarize_timing,
)


ROOT = Path(__file__).resolve().parents[2]
BASELINE = "1e91bf98ad2f918c24ddbb394c3be73fa9d5de9f"
CLOSURE = ROOT / "spec/evidence/management-system-refactor-closure.json"


class ManagementSystemRefactorClosureTest(unittest.TestCase):
    def write_run(
        self,
        root: Path,
        run: int,
        source: float,
        tooling: float,
    ) -> None:
        directory = root / str(run)
        directory.mkdir(parents=True, exist_ok=True)
        for worker, duration in (
            ("source-contract", source),
            ("tooling-tests", tooling),
        ):
            (directory / f"worker-{worker}.json").write_text(
                json.dumps(
                    {
                        "duration_seconds": duration,
                        "record_type": "run",
                        "run_id": f"{run}-1",
                        "worker": worker,
                    }
                ),
                encoding="utf-8",
            )

    def timing_root(self, root: Path, *, count: int = 10) -> Path:
        for run in range(1, count + 1):
            self.write_run(root, run, 250 + run, 300 + run)
        return root

    def test_timing_requires_complete_worker_pairs(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.write_run(root, 1, 200, 300)
            (root / "1/worker-tooling-tests.json").unlink()

            with self.assertRaisesRegex(ValueError, "both worker timings"):
                summarize_timing(collect_timing_records(root))

    def test_timing_requires_ten_samples(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            records = collect_timing_records(self.timing_root(Path(directory), count=9))

            with self.assertRaisesRegex(ValueError, "at least 10"):
                summarize_timing(records)

    def test_timing_requires_p95_within_ten_minutes(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = self.timing_root(Path(directory))
            self.write_run(root, 9, 250, 601)
            self.write_run(root, 10, 250, 601)

            with self.assertRaisesRegex(ValueError, "P95.*600"):
                summarize_timing(collect_timing_records(root))

    def test_timing_summary_is_nearest_rank_and_deterministic(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            summary = summarize_timing(
                collect_timing_records(self.timing_root(Path(directory)))
            )

        self.assertEqual(summary["sample_count"], 10)
        self.assertEqual(summary["workflow_run_count"], 10)
        self.assertEqual(summary["p50_seconds"], 305.0)
        self.assertEqual(summary["p95_seconds"], 310.0)
        self.assertTrue(summary["within_budget"])

    def test_active_semantic_identity_counts_are_zero(self) -> None:
        for identity in ("PRD", "PDR", "PD"):
            with self.subTest(identity=identity):
                self.assertEqual(active_semantic_identity_count(ROOT, identity), 0)

    def test_management_refactor_does_not_change_semantic_surface(self) -> None:
        self.assertFalse(semantic_surface_changed(ROOT, BASELINE, "HEAD"))

    def test_document_requires_exact_successful_local_verification(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            timing_root = self.timing_root(Path(directory) / "timings")
            invalid = Path(directory) / "verification.json"
            invalid.write_text(
                json.dumps({"head_commit": "0" * 40, "status": "passed"}),
                encoding="utf-8",
            )

            with self.assertRaisesRegex(ValueError, "verification.*head"):
                build_document(
                    ROOT,
                    baseline_commit=BASELINE,
                    implementation_head="HEAD",
                    timing_root=timing_root,
                    verification_path=invalid,
                    nightly_event=None,
                )

    def test_awaiting_document_has_no_nightly_authority(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            timing_root = self.timing_root(Path(directory) / "timings")
            verification = Path(directory) / "verification.json"
            head = __import__("subprocess").check_output(
                ["git", "rev-parse", "HEAD"], cwd=ROOT, text=True
            ).strip()
            verification.write_text(
                json.dumps(
                    {
                        "head_commit": head,
                        "status": "passed",
                        "commands": list(REQUIRED_VERIFICATION_COMMANDS),
                    }
                ),
                encoding="utf-8",
            )
            document = build_document(
                ROOT,
                baseline_commit=BASELINE,
                implementation_head=head,
                timing_root=timing_root,
                verification_path=verification,
                nightly_event=None,
            )

        self.assertEqual(document["status"], "awaiting-upstream")
        self.assertIsNone(document["nightly_health_commit"])
        self.assertFalse(document["semantic_surface_changed"])
        self.assertEqual(document["active_prd_count"], 0)
        self.assertEqual(document["active_pdr_count"], 0)
        self.assertEqual(document["active_pd_count"], 0)
        self.assertEqual(document["pr_timing"]["sample_count"], 10)
        self.assertEqual(document["legacy_mapping"]["prd"], 183)
        self.assertEqual(document["legacy_mapping"]["pd"], 12)
        self.assertFalse(document["container_management_present"])

    def test_checked_in_premerge_closure_is_current(self) -> None:
        self.assertTrue(CLOSURE.is_file())
        document = json.loads(CLOSURE.read_text(encoding="utf-8"))

        self.assertEqual(document["schema"], "pto.management-refactor-closure")
        self.assertEqual(document["status"], "awaiting-upstream")
        self.assertGreaterEqual(document["pr_timing"]["sample_count"], 10)
        self.assertLessEqual(document["pr_timing"]["p95_seconds"], 600)
        self.assertFalse(document["semantic_surface_changed"])
        self.assertEqual(document["release_identity"]["architecture_version"], "0.58.2")
        self.assertEqual(document["codeowners"], ["zhoubot"])


if __name__ == "__main__":
    unittest.main()
