from __future__ import annotations

import importlib.util
from importlib.machinery import SourceFileLoader
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


if __name__ == "__main__":
    unittest.main()
