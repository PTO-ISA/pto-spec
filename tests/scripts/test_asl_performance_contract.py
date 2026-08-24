from __future__ import annotations

import json
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[2]
MATRIX = ROOT / "spec/evidence/bundle-operation-fixture-matrix.json"
MATRIX_DIR = ROOT / "tests/asl/block/model/operands/subview-descriptor"


class AslPerformanceContractTest(unittest.TestCase):
    def test_operation_role_cases_have_independent_result_files(self) -> None:
        evidence = json.loads(MATRIX.read_text(encoding="utf-8"))
        case_count = evidence["operation_role_case_count"]
        self.assertEqual(evidence["shard_count"], case_count)
        self.assertTrue(evidence["closure"]["independent_case_results"])

        paths = sorted(
            MATRIX_DIR.glob("block-exec-range-operation-matrix-*.asl")
        )
        self.assertEqual(len(paths), case_count)
        for path in paths:
            cases = [
                line for line in path.read_text(encoding="utf-8").splitlines()
                if line.startswith("// RANGE-MATRIX-CASE-")
            ]
            self.assertEqual(len(cases), 1, path.name)

    def test_exhaustive_range_tests_use_local_fixture_resets(self) -> None:
        paths = (
            ROOT / "tests/asl/block/operands/B.SUBVIEW/block-exec-b-subview-001.asl",
            ROOT / "tests/asl/block/operands/B.ASSEMBLE/block-exec-b-assemble-001.asl",
            ROOT / "tests/asl/block/model/operands/range-modifiers/block-exec-range-pemode-zero-001.asl",
        )
        for path in paths:
            text = path.read_text(encoding="utf-8")
            self.assertNotIn("ResetProfileState()", text, path.name)
            self.assertRegex(text, r"func Reset[A-Za-z]+Fixture\(\)")
            self.assertIn("ResetBundleControlState();", text)
            self.assertIn("ClearFault();", text)


if __name__ == "__main__":
    unittest.main()
