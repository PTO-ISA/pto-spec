from __future__ import annotations

import hashlib
import json
import tempfile
import unittest
from pathlib import Path

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
        "status": status,
        "returncode": 0 if status == "passed" else 1,
        "duration_seconds": 0.1,
        "command": ["fake-aslref"],
        "error": None if status == "passed" else status,
        "log_excerpt": "" if status == "passed" else status,
    }


class ReleaseSuiteAggregationTest(unittest.TestCase):
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

    def test_fake_runner_pass_failure_and_timeout_are_observed(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            result_path = (
                root / "build/asl-test-results" / str(MATRIX[0]["id"]) / "result.json"
            )

            def fake_runner(command: list[str], cwd: Path) -> int:
                self.assertEqual(cwd, root)
                self.assertEqual(command[-2:], ["--id", MATRIX[0]["id"]])
                result_path.parent.mkdir(parents=True)
                result_path.write_text(json.dumps(result()), encoding="utf-8")
                return 0

            results = execute_matrix(root, MATRIX, jobs=1, runner=fake_runner)
            self.assertEqual(results, [result()])

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
