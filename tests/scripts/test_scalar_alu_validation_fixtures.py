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
    run_name="pto_generate_asl_decoders_alu_test",
)
SCALAR_CATALOG = json.loads(
    (ROOT / "spec/catalog/scalar-forms.json").read_text(encoding="utf-8")
)
SCALAR_FORMS = SCALAR_CATALOG["forms"]
FAMILY_CONSTRAINTS = SCALAR_CATALOG["family_constraints"]


def scalar_form(mnemonic: str) -> dict:
    return next(row for row in SCALAR_FORMS if row["mnemonic"] == mnemonic)


class ScalarALUValidationFixtureTest(unittest.TestCase):
    def test_remainder_pair_expected_publishes_remainder_before_quotient(self) -> None:
        self.assertEqual(
            GENERATOR["scalar_pair_expected"]("HL.REM", 7, 3, 0),
            (1, 2),
        )
        self.assertEqual(
            GENERATOR["scalar_pair_expected"]("HL.REMUW", 0xFFFFFFFF, 2, 0),
            (1, 0x7FFFFFFF),
        )

    def test_divide_pair_expected_keeps_quotient_before_remainder(self) -> None:
        self.assertEqual(
            GENERATOR["scalar_pair_expected"]("HL.DIV", 7, 3, 0),
            (2, 1),
        )
        self.assertEqual(
            GENERATOR["scalar_pair_expected"]("HL.DIVUW", 0xFFFFFFFF, 2, 0),
            (0x7FFFFFFF, 1),
        )

    def test_remainder_pair_handlers_are_classified_as_pair_effects(self) -> None:
        pair_handlers = GENERATOR["SCALAR_ALU_EFFECT_HANDLER_CLASSES"][
            "scalar-pair-value"
        ]
        self.assertIn("ExecuteScalarRemainderPair", pair_handlers)
        self.assertIn("ExecuteScalarRemainderPairW", pair_handlers)

    def test_maddw_pair_expected_publishes_sign_extended_word_halves(self) -> None:
        self.assertEqual(
            GENERATOR["scalar_pair_expected"](
                "HL.MADDW", 0x7FFFFFFF, 0x7FFFFFFF, 0
            ),
            (1, 0x3FFFFFFF),
        )

    def test_command_rejection_inventory_matches_reserved_pto_handlers(self) -> None:
        self.assertEqual(
            GENERATOR["PTO_V0_UNSUPPORTED_COMMAND_HANDLERS"],
            {
                "SaveExecutionContext",
                "RecoverExecutionContext",
                "ExecuteCrossBlockTransfer",
            },
        )

    def test_canonical_frame_command_has_minimum_singleton_frame(self) -> None:
        rows = json.loads(
            (ROOT / "spec/catalog/command-forms.json").read_text(
                encoding="utf-8"
            )
        )["forms"]
        row = next(
            row
            for row in rows
            if row["mnemonic"] == "FENTRY"
        )
        witness = GENERATOR["canonical_command_execution_witness"](row, 0)

        self.assertEqual(GENERATOR["decode_field"](row, "uimm", witness), 8)

        output = io.StringIO()
        with redirect_stdout(output):
            GENERATOR["emit_canonical_command_execution_setup"](
                "ExecuteFrameEntry", row
            )
        self.assertIn("WriteGPR(2, Zeros{PTO_XLEN} + 0x100)", output.getvalue())

        output = io.StringIO()
        with redirect_stdout(output):
            GENERATOR["emit_canonical_command_execution_setup"](
                "ExecuteFrameExit", row
            )
        self.assertIn("_FrameDepth = 1", output.getvalue())

        row = next(row for row in rows if row["mnemonic"] == "FRET.STK")
        witness = GENERATOR["canonical_command_execution_witness"](row, 0)
        self.assertEqual(GENERATOR["decode_field"](row, "DstBegin", witness), 10)
        self.assertEqual(GENERATOR["decode_field"](row, "DstEnd", witness), 10)
        self.assertEqual(GENERATOR["decode_field"](row, "uimm", witness), 8)

    def test_frame_return_tpc_assertions_use_return_target(self) -> None:
        for handler in (
            "ExecuteFrameReturnAddress",
            "ExecuteFrameReturnStack",
        ):
            with self.subTest(handler=handler):
                output = io.StringIO()
                with redirect_stdout(output):
                    GENERATOR["emit_canonical_command_tpc_assertion"](
                        handler, 32
                    )
                self.assertEqual(
                    output.getvalue().strip(),
                    "assert ReadTPC() == Zeros{PTO_XLEN};",
                )

    def test_binary_boundary_expected_uses_binary_modifier_encoding(self) -> None:
        row = scalar_form("ADD")
        left = 0x8000000000000000
        right = 0x0000000080000000

        expected = GENERATOR["scalar_binary_boundary_expected"](
            row, left, right, {"SrcRType": 0, "shamt": 0}
        )

        self.assertEqual(expected, 0x7FFFFFFF80000000)

    def test_compressed_commit_target_fixture_enters_block_and_checks_bpcn(self) -> None:
        row = scalar_form("C.SETC.TGT")
        output = io.StringIO()

        with redirect_stdout(output):
            GENERATOR["emit_scalar_alu_boundary_case"](
                row, FAMILY_CONSTRAINTS, 0, "zero"
            )

        emitted = output.getvalue()
        self.assertIn("BeginBundle(BundleKind_Standard", emitted)
        self.assertIn("assert _BARG.bpcn ==", emitted)
        self.assertNotIn("assert _CommitArgument ==", emitted)

    def test_canonical_system_fixture_enters_system_block(self) -> None:
        output = io.StringIO()

        with redirect_stdout(output):
            GENERATOR["emit_scalar_sys_body_setup"]()

        emitted = output.getvalue()
        self.assertIn("BeginBundle(BundleKind_System", emitted)
        self.assertIn("EnterBundleBody();", emitted)

    def test_commit_target_system_fixture_can_enter_standard_body(self) -> None:
        output = io.StringIO()

        with redirect_stdout(output):
            GENERATOR["emit_scalar_sys_body_setup"]("Standard")

        emitted = output.getvalue()
        self.assertIn("BeginBundle(BundleKind_Standard", emitted)
        self.assertIn("EnterBundleBody();", emitted)

    def test_canonical_amo_fixture_initializes_selected_queue_source(self) -> None:
        row = scalar_form("CASB")
        output = io.StringIO()

        with redirect_stdout(output):
            GENERATOR["emit_canonical_scalar_amo_setup"](row, 24 << 15)

        emitted = output.getvalue()
        self.assertIn("_TQueue[[0]]", emitted)
        self.assertIn("_TQueueValid[[0]] = TRUE", emitted)

    def test_canonical_header_command_fixture_enters_block(self) -> None:
        output = io.StringIO()

        with redirect_stdout(output):
            GENERATOR["emit_canonical_command_execution_setup"](
                "SetBundleDimension"
            )

        self.assertIn("BeginBundle(BundleKind_Standard", output.getvalue())

    def test_canonical_indirect_call_fixture_installs_retiring_barg(self) -> None:
        row = next(
            row
            for row in json.loads(
                (ROOT / "spec/catalog/command-forms.json").read_text(
                    encoding="utf-8"
                )
            )["forms"]
            if row["mnemonic"] == "BSTART.ICALL"
        )
        output = io.StringIO()

        with redirect_stdout(output):
            GENERATOR["emit_canonical_command_execution_setup"](
                "ExecuteBundleStart", row
            )

        emitted = output.getvalue()
        self.assertIn("BundleTransfer_Direct", emitted)
        self.assertIn("Zeros{PTO_XLEN} + 8", emitted)


if __name__ == "__main__":
    unittest.main()
