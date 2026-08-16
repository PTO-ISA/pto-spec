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
    run_name="pto_generate_asl_decoders_test",
)
SCALAR_CATALOG = json.loads(
    (ROOT / "spec/catalog/scalar-forms.json").read_text(encoding="utf-8")
)
SCALAR_FORMS = SCALAR_CATALOG["forms"]
FAMILY_CONSTRAINTS = SCALAR_CATALOG["family_constraints"]


def scalar_form(mnemonic: str) -> dict:
    return next(row for row in SCALAR_FORMS if row["mnemonic"] == mnemonic)


class ScalarMemoryAgentFixtureTest(unittest.TestCase):
    def assert_agent_selected_before_gpr_setup(
        self, output: str, *, agent: int
    ) -> None:
        selection = f"SelectMemoryEventAgent({agent});"
        capture = f"StartMemoryEventCapture({agent});"

        self.assertIn(selection, output)
        self.assertIn("WriteGPR(", output)
        self.assertIn(capture, output)
        self.assertLess(output.index(selection), output.index("WriteGPR("))
        self.assertLess(output.index("WriteGPR("), output.index(capture))

    def test_agu_fault_selects_execution_agent_before_private_gpr_setup(self) -> None:
        output = io.StringIO()

        with redirect_stdout(output):
            GENERATOR["emit_scalar_agu_fault"](
                scalar_form("C.LDI"), FAMILY_CONSTRAINTS, 0
            )

        self.assert_agent_selected_before_gpr_setup(output.getvalue(), agent=1)

    def test_amo_case_selects_execution_agent_before_private_gpr_setup(self) -> None:
        output = io.StringIO()

        with redirect_stdout(output):
            GENERATOR["emit_scalar_amo_decoded_success"](
                scalar_form("CASB"),
                FAMILY_CONSTRAINTS,
                1,
                "fixture-agent-order",
                old_value=0x22,
                operand=0x22,
                desired=0x44,
            )

        self.assert_agent_selected_before_gpr_setup(output.getvalue(), agent=1)

    def test_amo_temporary_sources_are_marked_available(self) -> None:
        output = io.StringIO()

        with redirect_stdout(output):
            GENERATOR["emit_scalar_amo_decoded_success"](
                scalar_form("CASB"),
                FAMILY_CONSTRAINTS,
                0,
                "fixture-temporary-source",
                old_value=0x22,
                operand=0x22,
                desired=0x44,
                selectors={"SrcD": 24},
            )

        emitted = output.getvalue()
        self.assertIn("_TQueue[[0]] =", emitted)
        self.assertIn("_TQueueValid[[0]] = TRUE;", emitted)


if __name__ == "__main__":
    unittest.main()
