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


if __name__ == "__main__":
    unittest.main()
