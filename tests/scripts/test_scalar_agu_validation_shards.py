from __future__ import annotations

import io
import json
import runpy
import unittest
from contextlib import redirect_stdout
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
GENERATOR = runpy.run_path(
    str(ROOT / "scripts/generate-asl-decoders"),
    run_name="pto_generate_asl_decoders_agu_shards_test",
)
AVS_GENERATOR = runpy.run_path(
    str(ROOT / "scripts/generate-mnemonic-avs.py"),
    run_name="pto_generate_mnemonic_avs_agu_shards_test",
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


class ScalarAguValidationShardTest(unittest.TestCase):
    def test_agu_metadata_is_owned_by_the_catalog_record(self) -> None:
        row = scalar_form("LD")
        expected = {
            "action": "Load",
            "address_kind": "Register",
            "offset_scale": 0,
            "prefetch_returns_address": False,
            "signed_load": False,
            "size_bytes": 8,
            "update_mode": "None",
        }
        row["agu"] = expected
        row["mnemonic"] = "NAME.MUST.NOT.DRIVE.SEMANTICS"

        self.assertEqual(GENERATOR["agu_metadata"](row), expected)

    def test_one_owner_emits_four_independent_validation_entrypoints(self) -> None:
        output = io.StringIO()

        with redirect_stdout(output):
            GENERATOR["emit_scalar_agu_owner_validations"](
                scalar_form("LD"), FAMILY_CONSTRAINTS, 0
            )

        generated = output.getvalue()
        self.assertIn("func ValidateScalarAGUExecute_LD()", generated)
        self.assertIn("func ValidateScalarAGUBounds_LD()", generated)
        self.assertIn("func ValidateScalarAGUFault_LD()", generated)
        self.assertIn("func ValidateScalarAGUAlias_LD()", generated)
        self.assertEqual(generated.count("func ValidateScalarAGU"), 4)

    def test_validation_index_uses_owner_entrypoints_without_agu_aggregates(self) -> None:
        generated = GENERATOR["partition_generated_asl"](
            GENERATOR["_render_monolithic"]()
        )
        names = {function.name for function in generated.validation}

        self.assertIn("ValidateScalarAGUExecute_LD", names)
        self.assertIn("ValidateScalarAGUBounds_LD", names)
        self.assertIn("ValidateScalarAGUFault_LD", names)
        self.assertIn("ValidateScalarAGUAlias_LD", names)
        self.assertNotIn("ValidateCanonicalScalarAGUEffects", names)
        self.assertNotIn("ValidateCanonicalScalarAGUTotality", names)
        self.assertNotIn("ValidateCanonicalScalarAGUAliases", names)

    def test_alias_setup_marks_temporary_queue_sources_available(self) -> None:
        output = io.StringIO()

        with redirect_stdout(output):
            GENERATOR["emit_scalar_agu_owner_validations"](
                scalar_form("LD"), FAMILY_CONSTRAINTS, 0
            )

        generated = output.getvalue()
        alias_validation = generated.split("func ValidateScalarAGUAlias_LD()", 1)[1]
        first_execution = alias_validation.split("ExecuteScalarInstruction", 1)[0]
        for index in range(4):
            self.assertIn(f"_TQueueValid[[{index}]] = TRUE;", first_execution)
            self.assertIn(f"_UQueueValid[[{index}]] = TRUE;", first_execution)

    def test_one_owner_projects_four_short_mnemonic_named_test_points(self) -> None:
        unit = next(
            unit
            for unit in AVS_GENERATOR["load_units"](ROOT / "asl")
            if unit.mnemonic == "LD"
        )

        documents = AVS_GENERATOR["render_scalar_agu_avs"](unit)

        self.assertEqual(len(documents), 4)
        paths = {path.name for path, _ in documents}
        self.assertEqual(
            paths,
            {
                "scalar-exec-ld-direct-001.asl",
                "scalar-bound-ld-address-001.asl",
                "scalar-fault-ld-precise-001.asl",
                "scalar-exec-ld-registers-001.asl",
            },
        )
        for _, document in documents:
            self.assertEqual(document.count("ValidateScalarAGU"), 1)
            self.assertIn("PTO-AVS-AGU-LD-", document)

    def test_prefetch_bounds_execute_assigned_models_and_reject_reserved_models(self) -> None:
        output = io.StringIO()

        with redirect_stdout(output):
            GENERATOR["emit_scalar_agu_bounds_validation"](
                scalar_form("HL.PRF"), FAMILY_CONSTRAINTS
            )

        generated = output.getvalue()
        for model in range(3):
            self.assertIn(f"AGU-PREFETCH-MODEL-LEGAL: {model}/", generated)
        for model in range(3, 32):
            self.assertIn(f"AGU-PREFETCH-MODEL-RESERVED: {model}/", generated)
        self.assertNotIn("AGU-PREFETCH-MODEL-LEGAL: 3/", generated)

    def test_compressed_store_bounds_and_faults_make_implicit_t1_available(self) -> None:
        for emitter in (
            GENERATOR["emit_scalar_agu_bounds_validation"],
            lambda row, constraints: GENERATOR["emit_scalar_agu_fault_validation"](
                row, constraints, 0
            ),
        ):
            output = io.StringIO()
            with redirect_stdout(output):
                emitter(scalar_form("C.SDI"), FAMILY_CONSTRAINTS)
            generated = output.getvalue()
            self.assertIn("_TQueueValid[[0]] = TRUE;", generated)

    def test_register_address_witness_uses_an_assigned_modifier(self) -> None:
        for mnemonic in ("LD", "SD"):
            with self.subTest(mnemonic=mnemonic):
                row = scalar_form(mnemonic)
                witness = GENERATOR["scalar_agu_witness"](
                    row, FAMILY_CONSTRAINTS, 0
                )
                modifier = GENERATOR["decode_field"](
                    row, "SrcRType", witness["instruction"]
                )

                self.assertEqual(modifier, 0)
                shift = (
                    GENERATOR["decode_field"](
                        row, "shamt", witness["instruction"]
                    )
                    if any(field["name"] == "shamt" for field in row["fields"])
                    else row["agu"]["offset_scale"]
                )
                self.assertEqual(
                    witness["offset"], witness["src_r_value"] << shift
                )

    def test_reserved_address_modifier_is_rejected_before_offset_decode(self) -> None:
        output = io.StringIO()

        with redirect_stdout(output):
            GENERATOR["emit_scalar_agu_bounds_validation"](
                scalar_form("LW"), FAMILY_CONSTRAINTS
            )

        reserved = output.getvalue().split(
            "// AGU-SRCRTYPE-RESERVED: 3/", 1
        )[1].split("// AGU-TOTALITY-DECODED: shamt-0/", 1)[0]
        self.assertIn("assert !ScalarFormOperandsLegal(", reserved)
        self.assertIn("ScalarExecution_Rejected", reserved)
        self.assertIn("Fault_IllegalInstruction", reserved)
        self.assertNotIn("ScalarDecodedAGUOffset", reserved)

    def test_register_prefetch_metadata_rejects_reserved_modifiers(self) -> None:
        for mnemonic in ("HL.PRF", "HL.PRF.A"):
            with self.subTest(mnemonic=mnemonic):
                constraints = {
                    constraint["field"]: constraint
                    for constraint in scalar_form(mnemonic)["constraints"]
                }

                self.assertEqual(
                    constraints["SrcRType"],
                    {
                        "field": "SrcRType",
                        "operator": "one-of",
                        "values": [0, 1, 2],
                    },
                )


if __name__ == "__main__":
    unittest.main()
