from __future__ import annotations

import hashlib
import importlib.util
from importlib.machinery import SourceFileLoader
import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
GENERATOR = ROOT / "scripts/generate-executable-model-comparison"


def load_generator():
    loader = SourceFileLoader("generate_executable_model_comparison", str(GENERATOR))
    spec = importlib.util.spec_from_loader(
        "generate_executable_model_comparison", loader
    )
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot import {GENERATOR}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class ExecutableModelComparisonTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.generator = load_generator()

    def test_tlsu_adapter_accepts_current_snapshot_schema(self) -> None:
        aliases = [{"mnemonic": "TLOAD", "function": 0}]
        self.assertEqual(
            self.generator.independent_tlsu_aliases(
                {"tlsu": {"legal_aliases": aliases}}
            ),
            aliases,
        )

    def test_tlsu_adapter_accepts_historical_snapshot_schema(self) -> None:
        aliases = [{"mnemonic": "TSTORE", "function": 1}]
        self.assertEqual(
            self.generator.independent_tlsu_aliases(
                {"tma": {"legal_aliases": aliases}}
            ),
            aliases,
        )

    def test_tlsu_adapter_rejects_ambiguous_snapshot_schema(self) -> None:
        with self.assertRaisesRegex(ValueError, "conflicting TLSU manifests"):
            self.generator.independent_tlsu_aliases(
                {
                    "tlsu": {"legal_aliases": [{"mnemonic": "TLOAD"}]},
                    "tma": {"legal_aliases": [{"mnemonic": "TSTORE"}]},
                }
            )

    def test_reviewed_l_bstop_can_be_recorded_as_missing_without_fake_coverage(
        self,
    ) -> None:
        row = self.generator.reviewed_missing_command_row(
            {
                "form_id": "l_bstop_64_94c7f0a5e8b3",
                "mnemonic": "L.BSTOP",
                "semantic_handler": "ExecuteBundleStop",
            },
            index=99,
            pto_effect="executed",
        )

        self.assertEqual(row["classification"], "divergence")
        self.assertEqual(row["independent_status"], "missing")
        self.assertFalse(row["encoding_match"])
        self.assertIsNone(row["abi_change_acceptance"])
        self.assertIn("no independent comparison row", row["pto_disposition"])

    def test_pto_evidence_paths_are_stable_and_deduplicated(self) -> None:
        self.assertEqual(
            self.generator.normalize_pto_evidence_paths(
                [
                    "spec/evidence/release-traceability-readiness.json",
                    "spec/catalog/scalar-forms.json",
                    "spec/evidence/release-traceability-readiness.json",
                ]
            ),
            [
                "spec/catalog/scalar-forms.json",
                "spec/evidence/release-traceability-readiness.json",
            ],
        )

    def test_addtpc_semantic_drift_is_not_hidden_by_matching_encodings(self) -> None:
        classification, disposition = self.generator.scalar_comparison_disposition(
            {"mnemonic": "ADDTPC"},
            independent_present=True,
            encoding_match=True,
            independent_status="executable-subset",
        )

        self.assertEqual(classification, "divergence")
        self.assertIn("4 KiB page displacement", disposition)
        self.assertIn("halfword scaling", disposition)

    def test_published_addtpc_rows_report_semantic_divergence(self) -> None:
        evidence = json.loads(
            (ROOT / "spec/evidence/executable-model-comparison.json").read_text(
                encoding="utf-8"
            )
        )
        rows = {row.get("mnemonic"): row for row in evidence["rows"]}

        for mnemonic in ("ADDTPC", "HL.ADDTPC"):
            row = rows[mnemonic]
            self.assertEqual(row["classification"], "divergence")
            self.assertTrue(row["encoding_match"])
            self.assertIn("4 KiB page displacement", row["pto_disposition"])
            self.assertIn(
                "docs/status/decisions/ADR-SCALAR-0005-addtpc-page-scaled-immediate.md",
                row["evidence"],
            )
        self.assertEqual(
            evidence["summary"]["classification_counts"],
            {"comparable-match": 517, "divergence": 114, "non-comparable": 37},
        )

    def test_published_missing_b_fpatr_is_an_explicit_divergence(self) -> None:
        evidence = json.loads(
            (ROOT / "spec/evidence/executable-model-comparison.json").read_text(
                encoding="utf-8"
            )
        )
        row = next(row for row in evidence["rows"] if row["mnemonic"] == "B.FPATR")
        catalog = json.loads(
            (ROOT / "spec/catalog/command-forms.json").read_text(encoding="utf-8")
        )
        form = next(row for row in catalog["forms"] if row["mnemonic"] == "B.FPATR")

        self.assertEqual(row["classification"], "divergence")
        self.assertEqual(row["independent_status"], "missing")
        self.assertEqual(row["stable_id"], form["form_id"])
        self.assertIn("no independent comparison row", row["pto_disposition"])

    def test_published_snapshot_has_fetchable_public_provenance(self) -> None:
        evidence = json.loads(
            (ROOT / "spec/evidence/executable-model-comparison.json").read_text(
                encoding="utf-8"
            )
        )
        publication = evidence["snapshot"]["publication"]

        self.assertEqual(
            publication,
            {
                "commit": "3fc63e5fc1d1913b7c4754944df983d7bd8416c5",
                "commit_url": (
                    "https://github.com/LinxISA/linx-isa/commit/"
                    "3fc63e5fc1d1913b7c4754944df983d7bd8416c5"
                ),
                "ref": "refs/pull/160/head",
                "repository": "https://github.com/LinxISA/linx-isa.git",
                "review_url": "https://github.com/LinxISA/linx-isa/pull/160",
                "role": "historical-independent-comparison-only",
            },
        )
        self.assertEqual(
            evidence["snapshot"]["revision_sha256"],
            hashlib.sha256(publication["commit"].encode("utf-8")).hexdigest(),
        )
        self.assertTrue(evidence["closure_judgment"]["can_close_s5_t3"])

    def test_published_hl_qpop_keeps_reviewed_encoding_divergence(self) -> None:
        evidence = json.loads(
            (ROOT / "spec/evidence/executable-model-comparison.json").read_text(
                encoding="utf-8"
            )
        )
        row = next(row for row in evidence["rows"] if row["mnemonic"] == "HL.QPOP")

        self.assertEqual(row["classification"], "divergence")
        self.assertIsNotNone(row["abi_change_acceptance"])
        self.assertIn("superseded command encoding", row["pto_disposition"])


if __name__ == "__main__":
    unittest.main()
