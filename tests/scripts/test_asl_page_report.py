from __future__ import annotations

import io
import json
import tempfile
import unittest
from pathlib import Path

from scripts.asl_tests import report_page_results


TEST_ID = "PTO-AVS-TILE-TEPL-TADD-EXECUTION-001"
ENTRY = {
    "id": TEST_ID,
    "display_name": "TADD | execution | adds two tiles",
    "path": f"tests/asl/tile/tepl/TADD/{TEST_ID}.asl",
    "source": "asl/tile/tepl/TADD.asl",
    "requirements": [],
    "kind": "execution",
    "sha256": "a" * 64,
}


class AslPageReportTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        self.matrix = self.root / "page.json"
        self.results = self.root / "results"
        self.summary = self.root / "summary.md"
        self.matrix.write_text(
            json.dumps(
                {
                    "commit": "1" * 40,
                    "page": 6,
                    "page_count": 10,
                    "test_count": 905,
                    "include": [ENTRY],
                }
            ),
            encoding="utf-8",
        )

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def write_result(self, **overrides: object) -> None:
        payload = {
            "id": TEST_ID,
            "display_name": ENTRY["display_name"],
            "path": ENTRY["path"],
            "source": ENTRY["source"],
            "kind": ENTRY["kind"],
            "sha256": ENTRY["sha256"],
            "status": "passed",
            "returncode": 0,
            "duration_seconds": 1.25,
            "command": ["./scripts/aslref", "test.asl"],
            "error": None,
            "log_excerpt": "",
        }
        payload.update(overrides)
        path = self.results / TEST_ID / "result.json"
        path.parent.mkdir(parents=True)
        path.write_text(json.dumps(payload), encoding="utf-8")

    def test_passed_page_writes_mnemonic_summary_and_console_line(self) -> None:
        self.write_result()
        output = io.StringIO()

        status = report_page_results(
            self.matrix, self.results, summary_path=self.summary, output=output
        )

        self.assertEqual(status, 0)
        self.assertIn("PASS TADD | execution | adds two tiles", output.getvalue())
        summary = self.summary.read_text(encoding="utf-8")
        self.assertIn("## ASL page 6", summary)
        self.assertIn("| PASS | TADD \\| execution \\| adds two tiles |", summary)
        self.assertIn(TEST_ID, summary)

    def test_failed_page_emits_annotation_and_log_excerpt(self) -> None:
        self.write_result(
            status="failed",
            returncode=1,
            error="ASLRef execution failed",
            log_excerpt="assertion failed at line 42",
        )
        output = io.StringIO()

        status = report_page_results(
            self.matrix, self.results, summary_path=self.summary, output=output
        )

        self.assertEqual(status, 1)
        text = output.getvalue()
        self.assertIn("FAIL TADD | execution | adds two tiles", text)
        self.assertIn(f"::error file={ENTRY['path']}", text)
        self.assertIn("ASLRef execution failed", text)
        self.assertIn("return code 1", text)
        summary = self.summary.read_text(encoding="utf-8")
        self.assertIn("assertion failed at line 42", summary)

    def test_missing_result_is_annotated_and_fails_closed(self) -> None:
        output = io.StringIO()

        status = report_page_results(
            self.matrix, self.results, summary_path=self.summary, output=output
        )

        self.assertEqual(status, 1)
        self.assertIn("missing result", output.getvalue())
        self.assertIn(TEST_ID, self.summary.read_text(encoding="utf-8"))

    def test_metadata_mismatch_is_annotated_and_fails_closed(self) -> None:
        self.write_result(display_name="wrong name")
        output = io.StringIO()

        status = report_page_results(
            self.matrix, self.results, summary_path=self.summary, output=output
        )

        self.assertEqual(status, 1)
        self.assertIn("display_name mismatch", output.getvalue())


if __name__ == "__main__":
    unittest.main()
