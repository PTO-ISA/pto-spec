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
import subprocess
import tempfile
import unittest
from unittest import mock

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


class ReaderBlockIdentityTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tool = load_tool()
        self.unit = self.tool.current_units()["PTO-ARCH-STATE-NUMERIC-STATUS"]
        self.shard = json.loads(self.tool.shard_path(self.unit).read_text())
        self.translation = json.loads(self.tool.translation_path(self.unit).read_text())
        self.parse_page = self.tool.parse_page

    def renamed_page(self, path, logical):
        body, blocks, nodes = self.parse_page(path, logical)
        for block in blocks:
            block["block_id"] = "drift-" + block["block_id"]
        for node in nodes:
            node["block_id"] = "drift-" + node["block_id"]
        return body, blocks, nodes

    def test_rebind_rejects_english_and_synchronized_locale_renames(self) -> None:
        # Renaming both locales previously let --write silently absorb drift.
        with mock.patch.object(self.tool, "parse_page", side_effect=self.renamed_page):
            with self.assertRaisesRegex(self.tool.RebindError, "block IDs and order"):
                self.tool.rebuild_unit_shard(self.unit, self.shard)

    def test_rebind_rejects_locale_only_rename(self) -> None:
        english, body = self.tool.rebuild_unit_shard(self.unit, self.shard)
        with mock.patch.object(self.tool, "parse_page", side_effect=self.renamed_page):
            with self.assertRaisesRegex(self.tool.RebindError, "block IDs and order"):
                self.tool.rebuild_translation(self.unit, english, body, self.translation)

    def test_rebind_rejects_english_block_reordering(self) -> None:
        def reordered_page(path, logical):
            body, blocks, nodes = self.parse_page(path, logical)
            return body, list(reversed(blocks)), nodes
        with mock.patch.object(self.tool, "parse_page", side_effect=reordered_page):
            with self.assertRaisesRegex(self.tool.RebindError, "block IDs and order"):
                self.tool.rebuild_unit_shard(self.unit, self.shard)

    def test_first_bind_accepts_blocks_without_previous_identity(self) -> None:
        self.shard["status"] = "pending"
        self.shard["presentation_blocks"] = []
        with mock.patch.object(self.tool, "parse_page", side_effect=self.renamed_page):
            rebuilt, _ = self.tool.rebuild_unit_shard(self.unit, self.shard)
        self.assertTrue(all(b["block_id"].startswith("drift-")
                            for b in rebuilt["presentation_blocks"]))


class AttestationSafetyTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tool = load_tool()
        self.contexts = {
            "writer": "/codex/writer",
            "reviewer": "/codex/reviewer",
            "verifier": "/codex/verifier",
        }
        self.source_commit = subprocess.run(
            ["git", "rev-parse", "HEAD"], cwd=ROOT, check=True,
            capture_output=True, text=True,
        ).stdout.strip()

    def assert_rejected_without_mutation(self, unit_ids, batch_id, contexts=None,
                                         source_commit=None) -> None:
        with mock.patch.object(pathlib.Path, "write_bytes") as write_bytes, \
                mock.patch.object(pathlib.Path, "unlink") as unlink:
            with self.assertRaises(self.tool.RebindError):
                self.tool.attest(
                    unit_ids,
                    batch_id,
                    contexts if contexts is not None else self.contexts,
                    source_commit if source_commit is not None else self.source_commit,
                )
        write_bytes.assert_not_called()
        unlink.assert_not_called()

    def test_attest_validates_all_external_identifiers_before_mutation(self) -> None:
        unit_id = "PTO-ARCH-GQM"
        invalid_requests = (
            ([unit_id], "PTO-READER-../../escape", self.contexts, self.source_commit),
            ([unit_id, unit_id], "PTO-READER-SAFE-001", self.contexts,
             self.source_commit),
            (["PTO-NOT-A-UNIT"], "PTO-READER-SAFE-001", self.contexts,
             self.source_commit),
            ([unit_id], "PTO-READER-SAFE-001",
             {"writer": "same", "reviewer": "same", "verifier": "other"},
             self.source_commit),
            ([unit_id], "PTO-READER-SAFE-001",
             {"writer": "writer", "reviewer": "reviewer", "verifier": "   "},
             self.source_commit),
            ([unit_id], "PTO-READER-SAFE-001", self.contexts, "not-a-commit"),
            ([unit_id], "PTO-READER-SAFE-001", self.contexts, "f" * 40),
        )
        for request in invalid_requests:
            with self.subTest(request=request):
                self.assert_rejected_without_mutation(*request)

    def test_attest_rejects_existing_destinations_before_mutation(self) -> None:
        self.assert_rejected_without_mutation(
            ["PTO-ARCH-GQM"], "PTO-READER-READABILITY-ARCH-001"
        )

    def test_attest_rejects_a_well_formed_but_unknown_source_commit(self) -> None:
        with self.assertRaisesRegex(self.tool.RebindError, "Git commit"):
            self.tool._validate_attestation_request(
                ["PTO-TILE-TADD"], "PTO-READER-SAFE-SOURCE-001",
                self.contexts, "f" * 40, self.tool.current_units(),
            )

    def test_attest_rejects_a_dangling_destination_symlink(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            evidence = pathlib.Path(directory) / "evidence"
            review_root = evidence / "reviews"
            translation_root = evidence / "translation-reviews/zh-CN"
            review_root.mkdir(parents=True)
            translation_root.mkdir(parents=True)
            destination = review_root / "safe-link-001.json"
            destination.symlink_to(pathlib.Path(directory) / "outside.json")
            with mock.patch.object(self.tool, "EVIDENCE", evidence):
                with self.assertRaisesRegex(self.tool.RebindError, "destination"):
                    self.tool._attestation_destinations("PTO-READER-SAFE-LINK-001")

    def test_partial_english_split_rejects_changed_unselected_shard(self) -> None:
        path = (ROOT / "spec/evidence/mnemonic-descriptions/reviews/"
                "readability-arch-001.json")
        batch = json.loads(path.read_text())
        selected, unselected = list(batch["unit_risks"])[:2]
        units = self.tool.current_units()
        original_shard_path = self.tool.shard_path
        with tempfile.TemporaryDirectory() as directory:
            tampered = pathlib.Path(directory) / "tampered.json"
            tampered.write_bytes(original_shard_path(units[unselected]).read_bytes() + b" ")

            def shard_path(unit):
                return tampered if unit["id"] == unselected else original_shard_path(unit)

            with mock.patch.object(self.tool, "shard_path", side_effect=shard_path):
                with self.assertRaisesRegex(self.tool.RebindError, "accepted writer digest"):
                    self.tool._prove_english_batch(batch, units, {selected})

    def test_partial_translation_split_rejects_changed_unselected_artifact(self) -> None:
        path = (ROOT / "spec/evidence/mnemonic-descriptions/translation-reviews/zh-CN/"
                "readability-arch-001.json")
        batch = json.loads(path.read_text())
        selected, unselected = batch["unit_ids"][:2]
        units = self.tool.current_units()
        original_translation_path = self.tool.translation_path
        with tempfile.TemporaryDirectory() as directory:
            tampered = pathlib.Path(directory) / "tampered.json"
            tampered.write_bytes(
                original_translation_path(units[unselected]).read_bytes() + b" "
            )

            def translation_path(unit):
                return (tampered if unit["id"] == unselected
                        else original_translation_path(unit))

            with mock.patch.object(self.tool, "translation_path", side_effect=translation_path):
                with self.assertRaisesRegex(self.tool.RebindError,
                                             "accepted translation digest"):
                    self.tool._prove_translation_batch(batch, units, {selected})

    def test_digest_preflight_failure_never_mutates_review_files(self) -> None:
        with mock.patch.object(
                self.tool, "_prove_english_batch",
                side_effect=self.tool.RebindError("accepted writer digest mismatch")), \
                mock.patch.object(pathlib.Path, "write_bytes") as write_bytes, \
                mock.patch.object(pathlib.Path, "unlink") as unlink:
            with self.assertRaisesRegex(self.tool.RebindError, "accepted writer digest"):
                self.tool.attest(
                    ["PTO-ARCH-GQM"], "PTO-READER-SAFE-NEW-001",
                    self.contexts, self.source_commit,
                )
        write_bytes.assert_not_called()
        unlink.assert_not_called()

    def test_attest_requires_selected_shards_to_bind_current_guides(self) -> None:
        unit_id = "PTO-TILE-TADD"
        unit = self.tool.current_units()[unit_id]
        rebuild_unit_shard = self.tool.rebuild_unit_shard

        def stale_rebuild(*args):
            rebuilt, body = rebuild_unit_shard(*args)
            stale = dict(rebuilt)
            stale["risk_tier"] = "stale"
            return stale, body

        with mock.patch.object(
                self.tool, "rebuild_unit_shard", side_effect=stale_rebuild), \
                mock.patch.object(pathlib.Path, "write_bytes") as write_bytes, \
                mock.patch.object(pathlib.Path, "unlink") as unlink:
            with self.assertRaisesRegex(self.tool.RebindError, "run --write first"):
                self.tool.attest(
                    [unit_id], "PTO-READER-SAFE-BINDING-001",
                    self.contexts, self.source_commit,
                )
        write_bytes.assert_not_called()
        unlink.assert_not_called()


if __name__ == "__main__":
    unittest.main()
