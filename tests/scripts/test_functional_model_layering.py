from __future__ import annotations

import json
from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from scripts.ndf import parse_ndf_regions  # noqa: E402
from scripts.model_contracts import parse_model_contracts  # noqa: E402


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

    def model_contract(self, path: Path, contract_id: str):
        source = path.relative_to(ROOT)
        contracts = {
            contract.contract_id: contract
            for contract in parse_model_contracts(
                path.read_text(encoding="utf-8"), source
            )
        }
        return contracts[contract_id]

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

    def test_model_control_and_hosted_abi_are_not_architecture(self) -> None:
        step = self.model_contract(
            ROOT / "asl/arch/dispatch/functional-step.asl",
            "PTO-REQ-FUNCTIONAL-STEP-001",
        )
        host = self.model_contract(
            PROFILE_OWNER, "PTO-REQ-FUNCTIONAL-HOST-REQUEST-001"
        )
        reset = self.model_contract(
            PROFILE_OWNER, "PTO-REQ-FUNCTIONAL-RESET-001"
        )
        exit_group = self.model_contract(
            PROFILE_OWNER, "PTO-REQ-FUNCTIONAL-EXIT-GROUP-001"
        )
        self.assertEqual({step.layer, host.layer, reset.layer}, {"model"})
        self.assertEqual(exit_group.layer, "abi")

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

    def test_model_contract_pages_are_not_labeled_as_architecture(self) -> None:
        for relative in (
            "docs/arch/data-types/functional-model.md",
            "docs/arch/dispatch/functional-step.md",
            "docs/arch/profile/functional-model.md",
            "docs/arch/state/functional-model.md",
        ):
            text = (ROOT / relative).read_text(encoding="utf-8")
            self.assertIn("non-architectural functional-model contract", text)
            self.assertIn("## Model-contract ASL", text)
            self.assertNotIn("**Normative ASL source:**", text)

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
        self.assertEqual(
            set(metadata["affected_model_contracts"]),
            {
                "PTO-REQ-FUNCTIONAL-EXIT-GROUP-001",
                "PTO-REQ-FUNCTIONAL-HOST-REQUEST-001",
                "PTO-REQ-FUNCTIONAL-RESET-001",
                "PTO-REQ-FUNCTIONAL-STEP-001",
            },
        )


if __name__ == "__main__":
    unittest.main()
