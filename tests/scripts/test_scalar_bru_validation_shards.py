from __future__ import annotations

import json
import runpy
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
GENERATOR = runpy.run_path(
    str(ROOT / "scripts/generate-asl-decoders"),
    run_name="pto_generate_asl_decoders_bru_shards_test",
)
AVS_GENERATOR = runpy.run_path(
    str(ROOT / "scripts/generate-mnemonic-avs.py"),
    run_name="pto_generate_mnemonic_avs_bru_shards_test",
)
SCALAR_CATALOG = json.loads(
    (ROOT / "spec/catalog/scalar-forms.json").read_text(encoding="utf-8")
)
FAMILY_CONSTRAINTS = SCALAR_CATALOG["family_constraints"]


def scalar_form(mnemonic: str) -> dict:
    for index, row in enumerate(SCALAR_CATALOG["forms"]):
        if row["mnemonic"] == mnemonic:
            return {**row, "_form_index": index}
    raise AssertionError(f"missing scalar form {mnemonic}")


class ScalarBruValidationShardTest(unittest.TestCase):
    def test_one_owner_emits_two_independent_semantic_entrypoints(self) -> None:
        generated = GENERATOR["partition_generated_asl"](
            GENERATOR["_render_monolithic"]()
        )
        functions = {
            function.name: function.text for function in generated.validation
        }

        execution = functions["ValidateScalarBRUExecute_CMP_EQ"]
        boundary = functions["ValidateScalarBRUBounds_CMP_EQ"]
        self.assertIn("ExecuteScalarInstruction", execution)
        self.assertIn("scalar-compare-value", execution)
        self.assertIn("bru-totality-zero", boundary)
        self.assertIn("bru-totality-upper", boundary)

    def test_validation_index_contains_only_owner_bru_entrypoints(self) -> None:
        generated = GENERATOR["partition_generated_asl"](
            GENERATOR["_render_monolithic"]()
        )
        functions = {
            function.name: function.text for function in generated.validation
        }
        names = set(functions)

        self.assertIn("ValidateScalarBRUExecute_CMP_EQ", names)
        self.assertIn("ValidateScalarBRUBounds_CMP_EQ", names)
        self.assertIn("ValidateScalarBRUAlias_CMP_EQ", names)
        self.assertNotIn("ValidateCanonicalScalarBRUEffects", names)
        self.assertNotIn("ValidateCanonicalScalarBRUTotality", names)
        self.assertNotIn("ValidateCanonicalScalarBRUAliasAndFaults", names)
        self.assertNotIn("ValidateScalarBRUExecute_B_Z", names)
        self.assertNotIn("ValidateScalarBRUExecute_B_NZ", names)
        self.assertNotIn("ValidateScalarBRUAlias_B_Z", names)
        self.assertIn("Zeros{PTO_XLEN} + 0x104", functions["ValidateScalarBRUAlias_JR"])

    def test_one_owner_projects_two_short_mnemonic_named_points(self) -> None:
        unit = next(
            unit
            for unit in AVS_GENERATOR["load_units"](ROOT / "asl")
            if unit.mnemonic == "CMP.EQ"
        )

        documents = AVS_GENERATOR["render_scalar_bru_avs"](unit)

        self.assertEqual(len(documents), 3)
        paths = {path.name for path, _ in documents}
        self.assertEqual(
            paths,
            {
                "scalar-exec-cmp-eq-direct-001.asl",
                "scalar-bound-cmp-eq-fields-001.asl",
                "scalar-exec-cmp-eq-alias-001.asl",
            },
        )
        for _, document in documents:
            self.assertEqual(document.count("ValidateScalarBRU"), 1)
            self.assertIn("PTO-AVS-BRU-CMP-EQ-", document)

    def test_addtpc_page_scale_is_independent_from_halfword_control(self) -> None:
        generated = GENERATOR["partition_generated_asl"](
            GENERATOR["_render_monolithic"]()
        )
        functions = {
            function.name: function.text for function in generated.validation
        }

        self.assertIn(
            GENERATOR["bit_literal"](0x3100, 64),
            functions["ValidateScalarBRUExecute_ADDTPC"],
        )
        self.assertIn(
            GENERATOR["bit_literal"](0x3100, 64),
            functions["ValidateScalarBRUExecute_HL_ADDTPC"],
        )
        self.assertIn(
            "Zeros{PTO_XLEN} + 0x106",
            functions["ValidateScalarBRUExecute_SETRET"],
        )
        self.assertIn(
            "Zeros{PTO_XLEN} + 0x106",
            functions["ValidateScalarBRUExecute_HL_SETRET"],
        )


if __name__ == "__main__":
    unittest.main()
