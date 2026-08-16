from __future__ import annotations

import hashlib
import io
import json
import tempfile
import threading
import unittest
from pathlib import Path
from subprocess import CompletedProcess
from types import SimpleNamespace
from unittest.mock import patch

import scripts.asl_release_suite as asl_release_suite
from scripts.asl_release_suite import (
    _write_evidence,
    aggregate_results,
    execute_matrix,
    require_exact_head,
)


MATRIX = [
    {
        "id": "PTO-AVS-ARCH-ONE-001",
        "display_name": "ARCH one | execution | one",
        "path": "tests/asl/arch/one/PTO-AVS-ARCH-ONE-001.asl",
        "source": "asl/arch/one.asl",
        "requirements": ["PTO-ARCH-ONE-001"],
        "kind": "execution",
        "sha256": "a" * 64,
        "validation_entrypoint": None,
        "validation_sha256": "v" * 64,
    }
]


def result(
    *, status: str = "passed", test_id: str | None = None, sha256: str | None = None
) -> dict[str, object]:
    return {
        "id": test_id or MATRIX[0]["id"],
        "path": MATRIX[0]["path"],
        "display_name": MATRIX[0]["display_name"],
        "source": MATRIX[0]["source"],
        "kind": MATRIX[0]["kind"],
        "sha256": sha256 or MATRIX[0]["sha256"],
        "validation_entrypoint": MATRIX[0]["validation_entrypoint"],
        "validation_sha256": MATRIX[0]["validation_sha256"],
        "status": status,
        "returncode": 0 if status == "passed" else 1,
        "duration_seconds": 0.1,
        "command": ["fake-aslref"],
        "error": None if status == "passed" else status,
        "log_excerpt": "" if status == "passed" else status,
    }


class ReleaseSuiteAggregationTest(unittest.TestCase):
    def test_pretty_page_summary_reports_counts_and_slowest_points(self) -> None:
        pretty_page_summary = getattr(asl_release_suite, "pretty_page_summary", None)
        self.assertIsNotNone(pretty_page_summary)
        values = [
            {
                **result(),
                "id": "PTO-AVS-ARCH-FAST-001",
                "display_name": "ARCH fast",
                "duration_seconds": 1.0,
            },
            {
                **result(status="failed"),
                "id": "PTO-AVS-ARCH-SLOW-001",
                "display_name": "ARCH slow",
                "duration_seconds": 3.0,
            },
            {
                **result(status="timeout"),
                "id": "PTO-AVS-ARCH-MID-001",
                "display_name": "ARCH mid",
                "duration_seconds": 2.0,
            },
        ]
        output = io.StringIO()

        pretty_page_summary(values, elapsed_seconds=12.5, output=output)

        text = output.getvalue()
        self.assertIn("SUMMARY 1 passed, 2 failed, 12.500s elapsed", text)
        self.assertLess(text.index("ARCH slow"), text.index("ARCH mid"))
        self.assertLess(text.index("ARCH mid"), text.index("ARCH fast"))

    def test_exact_head_mismatch_is_rejected(self) -> None:
        with self.assertRaisesRegex(ValueError, "exact HEAD"):
            require_exact_head("a" * 40, "b" * 40, "")

    def test_exact_head_rejects_tracked_staged_and_untracked_dirt(self) -> None:
        for status in (" M tracked.asl\n", "M  staged.asl\n", "?? untracked.asl\n"):
            with self.subTest(status=status):
                with self.assertRaisesRegex(ValueError, "clean committed tree"):
                    require_exact_head("a" * 40, "a" * 40, status)

    def test_one_complete_pass_is_accepted(self) -> None:
        coverage = aggregate_results("c" * 40, MATRIX, [result()])
        self.assertEqual(coverage["test_count"], 1)
        self.assertEqual(coverage["passed_count"], 1)
        self.assertEqual(coverage["status"], "passed")

    def test_failure_is_rejected(self) -> None:
        with self.assertRaisesRegex(ValueError, "did not pass"):
            aggregate_results("c" * 40, MATRIX, [result(status="failed")])

    def test_timeout_is_rejected(self) -> None:
        with self.assertRaisesRegex(ValueError, "did not pass"):
            aggregate_results("c" * 40, MATRIX, [result(status="timeout")])

    def test_missing_result_is_rejected(self) -> None:
        with self.assertRaisesRegex(ValueError, "missing result"):
            aggregate_results("c" * 40, MATRIX, [])

    def test_duplicate_result_is_rejected(self) -> None:
        with self.assertRaisesRegex(ValueError, "duplicate result"):
            aggregate_results("c" * 40, MATRIX, [result(), result()])

    def test_unplanned_result_is_rejected(self) -> None:
        with self.assertRaisesRegex(ValueError, "unplanned result"):
            aggregate_results(
                "c" * 40, MATRIX, [result(test_id="PTO-AVS-ARCH-TWO-001")]
            )

    def test_hash_mismatch_is_rejected(self) -> None:
        with self.assertRaisesRegex(ValueError, "hash mismatch"):
            aggregate_results("c" * 40, MATRIX, [result(sha256="b" * 64)])

    def test_display_name_mismatch_is_rejected(self) -> None:
        observed = result()
        observed["display_name"] = "wrong"

        with self.assertRaisesRegex(ValueError, "display_name mismatch"):
            aggregate_results("c" * 40, MATRIX, [observed])

    def test_page_preparation_runs_once_and_entries_execute_directly(self) -> None:
        self.assertTrue(hasattr(asl_release_suite, "prepare_page_inputs"))
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            second = {**MATRIX[0], "id": "PTO-AVS-ARCH-TWO-001"}
            entries = [MATRIX[0], second]
            prepared = SimpleNamespace(name="prepared")
            observed: list[tuple[str, object]] = []

            def fake_point_runner(point: object, inputs: object) -> int:
                test_id = str(getattr(point, "test_id"))
                observed.append((test_id, inputs))
                entry = next(item for item in entries if item["id"] == test_id)
                result_path = root / "build/asl-test-results" / test_id / "result.json"
                result_path.parent.mkdir(parents=True)
                payload = {
                    **result(test_id=test_id),
                    "display_name": entry["display_name"],
                }
                result_path.write_text(json.dumps(payload), encoding="utf-8")
                return 0

            with patch(
                "scripts.asl_release_suite.prepare_page_inputs",
                return_value=prepared,
            ) as prepare:
                results = execute_matrix(
                    root,
                    entries,
                    jobs=2,
                    point_runner=fake_point_runner,
                    output=io.StringIO(),
                )

            prepare.assert_called_once()
            self.assertEqual(
                sorted(observed),
                sorted((str(entry["id"]), prepared) for entry in entries),
            )
            self.assertEqual(
                [item["id"] for item in results],
                sorted(str(entry["id"]) for entry in entries),
            )

    def test_matrix_timeout_covers_page_preparation_and_each_point(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            prepared = SimpleNamespace(name="prepared")

            def fake_execute(
                observed_root: Path,
                point: object,
                *,
                timeout_seconds: int,
                prepared: object,
            ) -> int:
                self.assertEqual(observed_root, root)
                self.assertEqual(timeout_seconds, 17)
                self.assertEqual(prepared, prepared_inputs)
                test_id = str(getattr(point, "test_id"))
                result_path = root / "build/asl-test-results" / test_id / "result.json"
                result_path.parent.mkdir(parents=True)
                result_path.write_text(json.dumps(result(test_id=test_id)), encoding="utf-8")
                return 0

            prepared_inputs = prepared
            with (
                patch(
                    "scripts.asl_release_suite.prepare_page_inputs",
                    return_value=prepared_inputs,
                ) as prepare,
                patch(
                    "scripts.asl_release_suite.execute_test_point",
                    side_effect=fake_execute,
                ),
            ):
                results = execute_matrix(
                    root,
                    MATRIX,
                    jobs=1,
                    timeout_seconds=17,
                    output=io.StringIO(),
                )

            prepare.assert_called_once_with(root, MATRIX, timeout_seconds=17)
            self.assertEqual([item["id"] for item in results], [MATRIX[0]["id"]])

    def test_parallel_results_are_reported_in_completion_order(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            first = dict(MATRIX[0])
            first["id"] = "PTO-AVS-ARCH-FIRST-001"
            first["display_name"] = "ARCH first | execution | first"
            second = dict(MATRIX[0])
            second["id"] = "PTO-AVS-ARCH-SECOND-001"
            second["display_name"] = "ARCH second | execution | second"
            entries = [first, second]
            second_done = threading.Event()
            output = io.StringIO()

            def fake_point_runner(point: object, _: object) -> int:
                test_id = str(getattr(point, "test_id"))
                if test_id == first["id"]:
                    self.assertTrue(second_done.wait(timeout=2))
                    entry = first
                else:
                    entry = second
                payload = {
                    **result(test_id=str(entry["id"])),
                    "display_name": entry["display_name"],
                }
                path = root / "build/asl-test-results" / test_id / "result.json"
                path.parent.mkdir(parents=True)
                path.write_text(json.dumps(payload), encoding="utf-8")
                if test_id == second["id"]:
                    second_done.set()
                return 0

            with patch(
                "scripts.asl_release_suite.prepare_page_inputs",
                return_value=SimpleNamespace(name="prepared"),
            ):
                results = execute_matrix(
                    root,
                    entries,
                    jobs=2,
                    point_runner=fake_point_runner,
                    output=output,
                )

            lines = output.getvalue().splitlines()
            self.assertIn(str(second["id"]), lines[0])
            self.assertIn(str(first["id"]), lines[1])
            self.assertEqual(
                [item["id"] for item in results],
                sorted((first["id"], second["id"])),
            )

    def test_page_preparation_rejects_a_test_file_hash_mismatch_before_building(
        self,
    ) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / str(MATRIX[0]["path"])
            path.parent.mkdir(parents=True)
            path.write_text("// exact test\n", encoding="utf-8")
            entry = {
                **MATRIX[0],
                "sha256": "0" * 64,
                "validation_sha256": hashlib.sha256(
                    asl_release_suite.EMPTY_VALIDATION_SHARD.encode()
                ).hexdigest(),
            }

            with (
                patch(
                    "scripts.asl_release_suite.generate_source_order",
                    return_value=("asl/arch/one.asl",),
                ),
                patch(
                    "scripts.asl_release_suite._run_checked",
                    return_value=CompletedProcess(
                        ["fake"], 0, stdout="// decoder\n", stderr=""
                    ),
                ) as run_checked,
            ):
                with self.assertRaisesRegex(ValueError, "test file hash mismatch"):
                    asl_release_suite.prepare_page_inputs(root, [entry])

            run_checked.assert_not_called()

    def test_release_evidence_hashes_the_exact_monolithic_matrix_document(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            coverage = aggregate_results("c" * 40, MATRIX, [result()])

            _write_evidence(root, MATRIX, coverage)

            matrix_path = root / "build/asl-test-matrix.json"
            matrix_bytes = matrix_path.read_bytes()
            self.assertEqual(
                json.loads(matrix_bytes),
                {
                    "commit": "c" * 40,
                    "page": 0,
                    "page_count": 1,
                    "test_count": 1,
                    "include": MATRIX,
                },
            )
            self.assertEqual(
                (root / "spec/evidence/asl-test-matrix.sha256").read_text(
                    encoding="utf-8"
                ),
                f"{hashlib.sha256(matrix_bytes).hexdigest()}  "
                "build/asl-test-matrix.json\n",
            )


if __name__ == "__main__":
    unittest.main()
