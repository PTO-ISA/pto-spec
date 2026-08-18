from __future__ import annotations

import json
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
GENERATOR = ROOT / "scripts/generate-instruction-contract-closure"
OUTPUT = ROOT / "spec/evidence/instruction-contract-closure.json"
TRACEABILITY = ROOT / "spec/evidence/release-traceability-readiness.json"


class InstructionContractClosureTest(unittest.TestCase):
    def test_generated_projection_has_exact_global_counts(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "closure.json"
            result = subprocess.run(
                [str(GENERATOR), "--output", str(output)],
                cwd=ROOT,
                text=True,
                capture_output=True,
                check=False,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            document = json.loads(output.read_text(encoding="utf-8"))

        self.assertEqual(document["schema"], "pto.instruction-contract-closure.v1")
        self.assertEqual(document["summary"]["mnemonic_count"], 634)
        self.assertEqual(document["summary"]["encoded_form_count"], 540)
        self.assertEqual(document["summary"]["selector_operation_count"], 109)
        self.assertEqual(document["summary"]["unresolved_field_count"], 0)
        self.assertEqual(document["summary"]["placeholder_count"], 0)

    def test_datatype_and_deleted_name_dispositions_are_exported(self) -> None:
        document = json.loads(OUTPUT.read_text(encoding="utf-8"))
        by_name = {row["mnemonic"]: row for row in document["instructions"]}
        datatype = next(
            row
            for row in by_name["B.DATR"]["contract"]["encoded_fields"]
            if row["field"] == "DataType"
        )

        self.assertEqual(
            datatype["assigned_ranges"],
            [[0, 14], [16, 20], [24, 28], [31, 31]],
        )
        self.assertEqual(
            datatype["reserved_ranges"],
            [[15, 15], [21, 23], [29, 30]],
        )
        self.assertEqual(document["deleted_names"], ["B.IOD", "BSTART.PAR", "C.B.IOS"])

    def test_checked_in_projection_is_current(self) -> None:
        result = subprocess.run(
            [str(GENERATOR), "--check"],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )

        self.assertEqual(result.returncode, 0, result.stderr)

    def test_traceability_links_every_mnemonic_to_the_contract_projection(self) -> None:
        traceability = json.loads(TRACEABILITY.read_text(encoding="utf-8"))
        mnemonic_rows = [row for row in traceability["units"] if row["mnemonic"]]

        self.assertEqual(len(mnemonic_rows), 634)
        self.assertTrue(
            all(
                row["instruction_contract"]["artifact"]
                == "spec/evidence/instruction-contract-closure.json"
                and row["instruction_contract"]["mnemonic"] == row["mnemonic"]
                for row in mnemonic_rows
            )
        )
        self.assertIn(
            "spec/evidence/instruction-contract-closure.json",
            traceability["sources"],
        )

    def test_every_mnemonic_has_owner_local_semantic_evidence(self) -> None:
        traceability = json.loads(TRACEABILITY.read_text(encoding="utf-8"))
        mnemonic_rows = [row for row in traceability["units"] if row["mnemonic"]]

        self.assertEqual(
            traceability["summary"]["mnemonic_semantic_gap_count"],
            0,
        )
        self.assertEqual(
            traceability["summary"]["mnemonics_without_semantic_tests"],
            [],
        )
        self.assertTrue(all(row["semantic_tests"] for row in mnemonic_rows))


if __name__ == "__main__":
    unittest.main()
