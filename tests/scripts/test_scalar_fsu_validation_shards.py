from __future__ import annotations

import json
import runpy
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
GENERATOR = runpy.run_path(
    str(ROOT / "scripts/generate-asl-decoders"),
    run_name="pto_generate_asl_decoders_fsu_shards_test",
)
AVS_GENERATOR = runpy.run_path(
    str(ROOT / "scripts/generate-mnemonic-avs.py"),
    run_name="pto_generate_mnemonic_avs_fsu_shards_test",
)
SCALAR_CATALOG = json.loads(
    (ROOT / "spec/catalog/scalar-forms.json").read_text(encoding="utf-8")
)


class ScalarFsuValidationShardTest(unittest.TestCase):
    def test_conversion_rejects_reserved_types_before_source_read(self) -> None:
        dispatch = (ROOT / "asl/scalar/model/dispatch/fsu.asl").read_text(
            encoding="utf-8"
        )
        start = dispatch.index("func ExecuteDecodedFPConvert(")
        end = dispatch.index("func ExecuteDecodedFSUForm(", start)
        conversion = dispatch[start:end]

        source_read = conversion.index("let value = ReadDecodedScalarRegister(")
        legality_fault = conversion.index(
            "SetFault(Fault_IllegalInstruction, ReadPC());"
        )
        self.assertLess(legality_fault, source_read)

    def test_fadd_owns_short_semantic_entrypoints(self) -> None:
        generated = GENERATOR["partition_generated_asl"](
            GENERATOR["_render_monolithic"]()
        )
        functions = {
            function.name: function.text for function in generated.validation
        }

        expected = {
            "ValidateScalarFSUExecute_FADD",
            "ValidateScalarFSUTypesLegal_FADD",
            "ValidateScalarFSUTypesReserved_FADD",
            "ValidateScalarFSUBounds_FADD",
            "ValidateScalarFSURounding_FADD",
            "ValidateScalarFSUFlags_FADD",
            "ValidateScalarFSUAliasDestination_FADD",
            "ValidateScalarFSUAliasSources_FADD",
            "ValidateScalarFSUAliasSnapshot_FADD",
        }
        self.assertLessEqual(expected, set(functions))
        self.assertIn("ExecuteScalarInstruction", functions["ValidateScalarFSUExecute_FADD"])
        self.assertIn(
            "InstructionContractBinaryOperation_FADD() == FloatingBinary_ADD",
            functions["ValidateScalarFSUExecute_FADD"],
        )
        self.assertIn(
            "InstructionContractSourceArity_FADD() == 2",
            functions["ValidateScalarFSUExecute_FADD"],
        )
        self.assertIn("FSU-TYPE-LEGAL", functions["ValidateScalarFSUTypesLegal_FADD"])
        self.assertIn(
            "InstructionContractSourceTypeLegal_FADD('00')",
            functions["ValidateScalarFSUTypesLegal_FADD"],
        )
        self.assertIn("FSU-TYPE-RESERVED", functions["ValidateScalarFSUTypesReserved_FADD"])
        self.assertIn(
            "!InstructionContractSourceTypeLegal_FADD('10')",
            functions["ValidateScalarFSUTypesReserved_FADD"],
        )
        self.assertIn("FSU-BOUNDARY", functions["ValidateScalarFSUBounds_FADD"])
        self.assertIn("FSU-ROUNDING", functions["ValidateScalarFSURounding_FADD"])
        self.assertIn(
            "InstructionContractUsesActiveRounding_FADD()",
            functions["ValidateScalarFSURounding_FADD"],
        )
        self.assertIn("FSU-FLAGS", functions["ValidateScalarFSUFlags_FADD"])
        self.assertIn(
            "InstructionContractUsesProfileFlags_FADD()",
            functions["ValidateScalarFSUFlags_FADD"],
        )
        self.assertIn(
            "_TQueueValid[[0]] = TRUE;",
            functions["ValidateScalarFSUAliasSources_FADD"],
        )
        self.assertIn(
            "_UQueueValid[[0]] = TRUE;",
            functions["ValidateScalarFSUAliasSnapshot_FADD"],
        )

    def test_aggregate_fsu_entrypoints_are_removed(self) -> None:
        generated = GENERATOR["partition_generated_asl"](
            GENERATOR["_render_monolithic"]()
        )
        names = {function.name for function in generated.validation}

        self.assertNotIn("ValidateCanonicalScalarFSUEffects", names)
        self.assertNotIn("ValidateCanonicalScalarFSUTotality", names)
        self.assertNotIn("ValidateCanonicalScalarFSUAliases", names)
        self.assertNotIn("ValidateCanonicalScalarFSUFlagAndRoundingHelpers", names)
        self.assertIn("ValidateScalarFPFlagHelpers", names)
        self.assertIn("ValidateScalarFPRoundingHelpers", names)

    def test_fadd_projects_short_mnemonic_named_points(self) -> None:
        unit = next(
            unit
            for unit in AVS_GENERATOR["load_units"](ROOT / "asl")
            if unit.mnemonic == "FADD"
        )

        documents = AVS_GENERATOR["render_scalar_fsu_avs"](unit)

        self.assertEqual(len(documents), 9)
        names = {path.name for path, _ in documents}
        self.assertIn("scalar-exec-fadd-direct-001.asl", names)
        self.assertIn("scalar-bound-fadd-types-001.asl", names)
        self.assertIn("scalar-fault-fadd-types-001.asl", names)
        self.assertIn("scalar-bound-fadd-values-001.asl", names)
        self.assertIn("scalar-bound-fadd-round-001.asl", names)
        self.assertIn("scalar-state-fadd-flags-001.asl", names)
        self.assertIn("scalar-exec-fadd-dst-001.asl", names)
        self.assertIn("scalar-exec-fadd-src-001.asl", names)
        self.assertIn("scalar-exec-fadd-snap-001.asl", names)
        for _, document in documents:
            self.assertEqual(document.count("ValidateScalarFSU"), 1)
            self.assertIn("PTO-AVS-FSU-FADD-", document)


if __name__ == "__main__":
    unittest.main()
