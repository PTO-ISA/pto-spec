"""Rebinding a rewritten reader guide must not drop another unit's review evidence.

Unit identifiers extend each other: ``PTO-BLOCK-BSTART`` is a prefix of
``PTO-BLOCK-BSTART-FP``, ``PTO-BLOCK-BSTART-STD`` and eighteen other Block units.
The claim and node identifiers are built from the unit suffix, so a plain text
prefix test treats every one of those units' identifiers as owned by the shorter
unit and deletes their reviewed claims when only the shorter unit is attested.
"""

from __future__ import annotations

import importlib.machinery
import importlib.util
import json
import pathlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[2]


def load_tool():
    loader = importlib.machinery.SourceFileLoader(
        "pto_rebind_reader_guides", str(ROOT / "scripts/rebind-reader-guides"))
    spec = importlib.util.spec_from_loader(loader.name, loader)
    assert spec is not None
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


class IdentifierOwnerTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tool = load_tool()

    def test_owner_matches_its_own_identifiers(self) -> None:
        owner = self.tool.identifier_owner("CLAIM", "BLOCK-BSTART")
        self.assertIsNotNone(owner.match("PTO-READER-CLAIM-BLOCK-BSTART-001"))
        self.assertIsNotNone(owner.match("PTO-READER-CLAIM-BLOCK-BSTART-0001"))

    def test_owner_rejects_a_longer_unit_identifier(self) -> None:
        owner = self.tool.identifier_owner("CLAIM", "BLOCK-BSTART")
        for identifier in (
            "PTO-READER-CLAIM-BLOCK-BSTART-FP-001",
            "PTO-READER-CLAIM-BLOCK-BSTART-STD-001",
            "PTO-READER-CLAIM-BLOCK-BSTART-TLOAD-001",
        ):
            self.assertIsNone(owner.match(identifier), identifier)

    def test_owner_rejects_a_shorter_unit_identifier(self) -> None:
        owner = self.tool.identifier_owner("NODE", "BLOCK-BSTART-FP")
        self.assertIsNone(owner.match("PTO-READER-NODE-BLOCK-BSTART-001"))

    def test_every_attested_unit_owns_disjoint_identifiers(self) -> None:
        evidence = ROOT / "spec/evidence/mnemonic-descriptions/reviews"
        owners: dict[str, list[str]] = {}
        for path in sorted(evidence.glob("*.json")):
            item = json.loads(path.read_text(encoding="utf-8"))
            for identifier in item["reviewed_claim_ids"]:
                owners.setdefault(identifier, []).append(path.name)
        self.assertTrue(owners)
        duplicated = {key: value for key, value in owners.items() if len(value) > 1}
        self.assertEqual(duplicated, {})


if __name__ == "__main__":
    unittest.main()
