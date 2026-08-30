from __future__ import annotations

import json
from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from scripts.ndf import parse_ndf_regions, state_index  # noqa: E402


STATE_OWNER = ROOT / "asl/arch/state/functional-model.asl"
PROFILE_OWNER = ROOT / "asl/arch/profile/functional-model.asl"
ADR = (
    ROOT
    / "docs/status/decisions/0116-pto-architecture-and-functional-model-boundary.md"
)


class FunctionalModelLayeringTest(unittest.TestCase):
    def clause(self, path: Path, clause_id: str):
        source = path.relative_to(ROOT)
        clauses = {
            clause.clause_id: clause
            for clause in parse_ndf_regions(path.read_text(encoding="utf-8"), source)
        }
        return clauses[clause_id]

    def test_snapshot_and_identity_are_architecture_boundaries(self) -> None:
        snapshot = self.clause(
            STATE_OWNER, "PTO-REQ-FUNCTIONAL-STATE-SNAPSHOT-001"
        )
        identity = self.clause(
            PROFILE_OWNER, "PTO-REQ-FUNCTIONAL-PROFILE-IDENTITY-001"
        )
        for clause in (snapshot, identity):
            self.assertEqual(clause.layer, "architecture")
            self.assertEqual(clause.status, "accepted")

    def test_c_abi_and_descriptor_names_do_not_leak_into_asl(self) -> None:
        asl = "\n".join(
            path.read_text(encoding="utf-8")
            for path in sorted((ROOT / "asl").rglob("*.asl"))
        )
        for implementation_name in (
            "PTO_ASL_MODEL_EXPERIMENTAL_ABI_VERSION",
            "pto_model_snapshot",
            "pto_model_restore",
            "descriptor_sha256",
            "snapshot_schema",
        ):
            self.assertNotIn(implementation_name, asl)

    def test_model_ndf_is_not_owned_by_pto_spec(self) -> None:
        clauses = {
            clause.clause_id
            for path in sorted((ROOT / "asl").rglob("*.asl"))
            for clause in parse_ndf_regions(
                path.read_text(encoding="utf-8"), path.relative_to(ROOT)
            )
        }
        for model_requirement in (
            "PTO-REQ-FUNCTIONAL-STEP-001",
            "PTO-REQ-FUNCTIONAL-HOST-REQUEST-001",
            "PTO-REQ-FUNCTIONAL-RESET-001",
            "PTO-REQ-FUNCTIONAL-EXIT-GROUP-001",
        ):
            self.assertNotIn(model_requirement, clauses)

        states = set(state_index(ROOT))
        self.assertNotIn("PTO-STATE-ARCH-FUNCTIONAL-MODEL-PROFILE", states)
        self.assertIn("PTO-STATE-MODEL-FUNCTIONAL-CONTROL", states)

    def test_model_overlay_implements_an_architecture_owned_hook(self) -> None:
        hook = ROOT / "asl/arch/profile/service-request-intercept.asl"
        profile = PROFILE_OWNER.read_text(encoding="utf-8")
        semantics = (
            ROOT / "asl/scalar/model/sys/semantics.asl"
        ).read_text(encoding="utf-8")
        clause = self.clause(hook, "PTO-REQ-SERVICE-REQUEST-INTERCEPT-001")
        self.assertEqual(clause.layer, "architecture")
        self.assertIn("impdef func InterceptArchitectureCloseRequest", hook.read_text())
        self.assertIn(
            "implementation func InterceptArchitectureCloseRequest", profile
        )
        self.assertIn("InterceptArchitectureCloseRequest(request_type)", semantics)

    def test_accepted_adr_records_the_layering_decision(self) -> None:
        text = ADR.read_text(encoding="utf-8")
        metadata = json.loads(text.split("---", 2)[1])
        self.assertEqual(metadata["id"], "ADR-0116")
        self.assertEqual(metadata["status"], "accepted")
        self.assertEqual(metadata["approvers"], ["zhoubot"])
        self.assertEqual(
            set(metadata["affected_ndf"]),
            {
                "PTO-REQ-FUNCTIONAL-PROFILE-IDENTITY-001",
                "PTO-REQ-FUNCTIONAL-STATE-SNAPSHOT-001",
            },
        )


if __name__ == "__main__":
    unittest.main()
