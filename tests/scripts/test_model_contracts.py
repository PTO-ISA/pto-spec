from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from scripts.model_contracts import (
    ModelContractValidationError,
    check_repository,
    parse_model_contracts,
)


VALID_CONTRACT = """// PTO-MODEL-CONTRACT-BEGIN: PTO-REQ-MODEL-STEP-001
// contract: layer=model status=accepted
// The model step observes one architecture transition.
// PTO-MODEL-CONTRACT-END: PTO-REQ-MODEL-STEP-001
"""


class ModelContractTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def write(self, relative: str, text: str) -> Path:
        path = self.root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")
        return path

    def test_parse_model_contract(self) -> None:
        contracts = parse_model_contracts(VALID_CONTRACT, Path("asl/model.asl"))
        self.assertEqual(len(contracts), 1)
        self.assertEqual(contracts[0].contract_id, "PTO-REQ-MODEL-STEP-001")
        self.assertEqual(contracts[0].layer, "model")

    def test_parse_hosted_abi_contract(self) -> None:
        contracts = parse_model_contracts(
            VALID_CONTRACT.replace("layer=model", "layer=abi"),
            Path("asl/model.asl"),
        )
        self.assertEqual(contracts[0].layer, "abi")

    def test_rejects_architecture_layer(self) -> None:
        with self.assertRaises(ModelContractValidationError) as raised:
            parse_model_contracts(
                VALID_CONTRACT.replace("layer=model", "layer=architecture"),
                Path("asl/model.asl"),
            )
        self.assertIn("unknown model-contract layer architecture", str(raised.exception))

    def test_rejects_duplicate_owners(self) -> None:
        self.write("asl/first.asl", VALID_CONTRACT)
        self.write("asl/second.asl", VALID_CONTRACT)
        self.assertTrue(
            any(
                error.startswith("duplicate model contract PTO-REQ-MODEL-STEP-001")
                for error in check_repository(self.root)
            )
        )


if __name__ == "__main__":
    unittest.main()
