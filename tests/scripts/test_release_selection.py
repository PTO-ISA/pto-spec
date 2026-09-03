from __future__ import annotations

import json
from pathlib import Path

import unittest

from scripts.release_selection import (
    _baseline_inputs,
    evaluate_release_selection,
    validate_selection,
)


ROOT = Path(__file__).resolve().parents[2]
SELECTION = ROOT / "spec/release-selection.json"
SCHEMA = ROOT / "spec/schemas/pto-release-selection.schema.json"


class ReleaseSelectionTest(unittest.TestCase):
    def selection(self) -> dict[str, object]:
        return {
            "$schema": "spec/schemas/pto-release-selection.schema.json",
            "architecture_version": "0.58.2",
            "publication_version": "0.58.2.0",
            "baseline_commit": "b" * 40,
            "included_ndf_statuses": ["accepted"],
            "excluded_draft_adrs": ["ADR-NUM-0001"],
            "required_readiness_floor": "executable",
        }

    def facts(self):
        adrs = (
            {
                "id": "ADR-GOV-0001",
                "status": "accepted",
                "target_releases": ["0.58.2"],
                "affected_ndf": ["PTO-EXAMPLE-001"],
                "affected_units": ["PTO-UNIT-001"],
                "release_boundary": True,
            },
            {
                "id": "ADR-NUM-0001",
                "status": "draft",
                "target_releases": ["unassigned"],
                "affected_ndf": [],
            },
        )
        readiness = (
            {"subject_id": "ADR-GOV-0001", "stage": "executable"},
            {"subject_id": "ADR-NUM-0001", "stage": "draft"},
        )
        ndf = (
            {
                "id": "PTO-EXAMPLE-001",
                "status": "accepted",
                "sha256": "1" * 64,
            },
            {
                "id": "PTO-OPEN-001",
                "status": "open",
                "sha256": "2" * 64,
            },
        )
        return adrs, readiness, ndf

    def validate(
        self,
        selection: dict[str, object] | None = None,
        *,
        adrs=None,
        readiness=None,
        ndf=None,
        previous_manifest: dict[str, object] | None = None,
        units=(),
        baseline_units=(),
    ):
        default_adrs, default_readiness, default_ndf = self.facts()
        candidate = selection or self.selection()
        return validate_selection(
            candidate,
            architecture_version="0.58.2",
            publication_version=str(candidate["publication_version"]),
            adr_records=adrs or default_adrs,
            readiness_rows=readiness or default_readiness,
            ndf_rows=ndf or default_ndf,
            previous_manifest=previous_manifest,
            unit_rows=units,
            baseline_unit_rows=baseline_units,
        )

    def test_valid_selection_expands_exact_active_surface(self) -> None:
        result = self.validate()

        self.assertEqual(result.selected_adr_ids, ("ADR-GOV-0001",))
        self.assertEqual(result.selected_ndf_ids, ("PTO-EXAMPLE-001",))
        self.assertEqual(result.excluded_draft_adrs, ("ADR-NUM-0001",))
        self.assertEqual(result.blockers, ())

    def test_unknown_adr_in_draft_exclusion_is_rejected(self) -> None:
        selection = self.selection()
        selection["excluded_draft_adrs"] = ["ADR-GOV-9999"]

        with self.assertRaisesRegex(ValueError, "unknown ADR"):
            self.validate(selection)

    def test_draft_exclusion_uses_explicit_type_order(self) -> None:
        selection = self.selection()
        selection["excluded_draft_adrs"] = ["ADR-STATE-0001", "ADR-BLOCK-0001"]
        adrs, readiness, ndf = self.facts()
        adrs = (
            adrs[0],
            {**adrs[1], "id": "ADR-STATE-0001"},
            {**adrs[1], "id": "ADR-BLOCK-0001"},
        )
        readiness = (
            readiness[0],
            {"subject_id": "ADR-STATE-0001", "stage": "draft"},
            {"subject_id": "ADR-BLOCK-0001", "stage": "draft"},
        )

        result = self.validate(selection, adrs=adrs, readiness=readiness, ndf=ndf)

        self.assertEqual(
            result.excluded_draft_adrs,
            ("ADR-STATE-0001", "ADR-BLOCK-0001"),
        )

    def test_release_selection_schema_uses_typed_adr_grammar(self) -> None:
        schema = json.loads(SCHEMA.read_text(encoding="utf-8"))
        self.assertEqual(
            schema["properties"]["excluded_draft_adrs"]["items"]["pattern"],
            "^ADR-(GOV|STATE|MEM|BLOCK|SCALAR|TILE|CUBE|NUM)-[0-9]{4}$",
        )

    def test_every_draft_must_be_excluded_and_accepted_must_not_be(self) -> None:
        missing = self.selection()
        missing["excluded_draft_adrs"] = []
        accepted = self.selection()
        accepted["excluded_draft_adrs"] = ["ADR-GOV-0001", "ADR-NUM-0001"]

        with self.assertRaisesRegex(ValueError, "draft exclusion"):
            self.validate(missing)
        with self.assertRaisesRegex(ValueError, "accepted ADR"):
            self.validate(accepted)

    def test_missing_accepted_ndf_status_is_rejected(self) -> None:
        selection = self.selection()
        selection["included_ndf_statuses"] = []

        with self.assertRaisesRegex(ValueError, "accepted NDF"):
            self.validate(selection)

    def test_target_release_requires_the_configured_readiness_floor(self) -> None:
        _, readiness, _ = self.facts()
        below_floor = tuple(
            {**row, "stage": "modeled"} if row["subject_id"] == "ADR-GOV-0001" else row
            for row in readiness
        )

        with self.assertRaisesRegex(ValueError, "target.*readiness"):
            self.validate(readiness=below_floor)

    def test_duplicate_readiness_subject_is_rejected(self) -> None:
        _, readiness, _ = self.facts()

        with self.assertRaisesRegex(ValueError, "duplicate readiness subject"):
            self.validate(readiness=(*readiness, readiness[0]))

    def test_hidden_change_to_released_ndf_becomes_release_blocker(self) -> None:
        previous = {
            "release": "0.58.2",
            "publication_version": "0.58.2.0",
            "release_selection": {
                "expanded_ndf": [{"id": "PTO-EXAMPLE-001", "sha256": "0" * 64}]
            },
        }

        result = self.validate(previous_manifest=previous)

        self.assertTrue(any("PTO-EXAMPLE-001" in row for row in result.blockers))

    def test_new_accepted_ndf_becomes_release_blocker(self) -> None:
        _, _, ndf = self.facts()
        previous = {
            "release": "0.58.2",
            "publication_version": "0.58.2.0",
            "release_selection": {
                "expanded_ndf": [{"id": "PTO-EXAMPLE-001", "sha256": "1" * 64}]
            },
        }
        expanded = (
            *ndf,
            {"id": "PTO-NEW-001", "status": "accepted", "sha256": "3" * 64},
        )

        result = self.validate(ndf=expanded, previous_manifest=previous)

        self.assertTrue(any("PTO-NEW-001" in row for row in result.blockers))

    def test_new_publication_revision_gets_a_fresh_ndf_selection(self) -> None:
        selection = self.selection()
        selection["publication_version"] = "0.58.2.1"
        adrs, readiness, ndf = self.facts()
        adrs = tuple(
            {**row, "target_releases": ["0.58.2.1"]}
            if row["id"] == "ADR-GOV-0001"
            else row
            for row in adrs
        )
        previous = {
            "release": "0.58.2",
            "publication_version": "0.58.2.0",
            "release_selection": {
                "expanded_ndf": [{"id": "PTO-EXAMPLE-001", "sha256": "0" * 64}]
            },
        }
        result = validate_selection(
            selection,
            architecture_version="0.58.2",
            publication_version="0.58.2.1",
            adr_records=adrs,
            readiness_rows=readiness,
            ndf_rows=ndf,
            previous_manifest=previous,
        )
        self.assertEqual(result.blockers, ())

    def test_architecture_target_cannot_mask_later_publication_drift(self) -> None:
        selection = self.selection()
        selection["publication_version"] = "0.58.2.1"
        adrs, readiness, ndf = self.facts()
        adrs = (
            *adrs,
            {
                "id": "ADR-GOV-0002",
                "status": "accepted",
                "target_releases": ["0.58.2.1"],
                "affected_ndf": ["PTO-STABLE-001"],
                "affected_units": [],
                "release_boundary": True,
            },
        )
        readiness = (
            *readiness,
            {"subject_id": "ADR-GOV-0002", "stage": "executable"},
        )
        ndf = (
            *ndf,
            {"id": "PTO-STABLE-001", "status": "accepted", "sha256": "3" * 64},
        )
        baseline = {
            "publication_version": "0.58.2.0",
            "release_selection": {
                "expanded_ndf": [
                    {"id": "PTO-EXAMPLE-001", "sha256": "0" * 64},
                    {"id": "PTO-STABLE-001", "sha256": "3" * 64},
                ]
            },
        }

        result = self.validate(
            selection,
            adrs=adrs,
            readiness=readiness,
            ndf=ndf,
            previous_manifest=baseline,
        )

        self.assertTrue(any("PTO-EXAMPLE-001" in row for row in result.blockers))

    def test_unresolvable_baseline_commit_is_rejected(self) -> None:
        with self.assertRaisesRegex(ValueError, "cannot be resolved"):
            _baseline_inputs(ROOT, "0" * 40)

    def test_publication_bump_requires_release_boundary_adr(self) -> None:
        selection = self.selection()
        selection["publication_version"] = "0.58.2.1"
        adrs, _, _ = self.facts()
        adrs = tuple(
            {k: v for k, v in row.items() if k != "release_boundary"} for row in adrs
        )
        baseline = {
            "publication_version": "0.58.2.0",
            "release_selection": {
                "expanded_ndf": [{"id": "PTO-EXAMPLE-001", "sha256": "1" * 64}]
            },
        }

        result = self.validate(selection, adrs=adrs, previous_manifest=baseline)

        self.assertTrue(any("release_boundary=true" in row for row in result.blockers))

    def test_uncovered_ndf_and_unit_drift_are_blockers(self) -> None:
        selection = self.selection()
        selection["publication_version"] = "0.58.2.1"
        _, _, ndf = self.facts()
        current_ndf = (
            *ndf,
            {"id": "PTO-UNCOVERED-001", "status": "accepted", "sha256": "4" * 64},
        )
        baseline = {
            "publication_version": "0.58.2.0",
            "release_selection": {
                "expanded_ndf": [
                    {"id": "PTO-EXAMPLE-001", "sha256": "1" * 64},
                    {"id": "PTO-UNCOVERED-001", "sha256": "3" * 64},
                ]
            },
        }

        result = self.validate(
            selection,
            ndf=current_ndf,
            previous_manifest=baseline,
            units=(
                {"id": "PTO-UNIT-001", "sha256": "5" * 64},
                {"id": "PTO-UNIT-UNCOVERED", "sha256": "7" * 64},
            ),
            baseline_units=(
                {"id": "PTO-UNIT-001", "sha256": "5" * 64},
                {"id": "PTO-UNIT-UNCOVERED", "sha256": "6" * 64},
            ),
        )

        self.assertTrue(any("PTO-UNCOVERED-001" in row for row in result.blockers))
        self.assertTrue(any("PTO-UNIT-UNCOVERED" in row for row in result.blockers))

    def test_covered_publication_bump_accepts_ndf_and_unit_drift(self) -> None:
        selection = self.selection()
        selection["publication_version"] = "0.58.2.1"
        adrs, readiness, ndf = self.facts()
        adrs = tuple(
            {
                **row,
                "target_releases": ["0.58.2.1"],
                "affected_ndf": ["PTO-EXAMPLE-001"],
                "affected_units": ["PTO-UNIT-001"],
            }
            if row["id"] == "ADR-GOV-0001"
            else row
            for row in adrs
        )
        baseline = {
            "publication_version": "0.58.2.0",
            "release_selection": {
                "expanded_ndf": [{"id": "PTO-EXAMPLE-001", "sha256": "0" * 64}]
            },
        }

        result = validate_selection(
            selection,
            architecture_version="0.58.2",
            publication_version="0.58.2.1",
            adr_records=adrs,
            readiness_rows=readiness,
            ndf_rows=ndf,
            unit_rows=({"id": "PTO-UNIT-001", "sha256": "2" * 64},),
            baseline_manifest=baseline,
            baseline_unit_rows=({"id": "PTO-UNIT-001", "sha256": "1" * 64},),
        )

        self.assertEqual(result.blockers, ())

    def test_repository_policy_covers_targeted_architecture_drift(self) -> None:
        self.assertTrue(SELECTION.is_file())
        self.assertTrue(SCHEMA.is_file())
        schema = json.loads(SCHEMA.read_text(encoding="utf-8"))
        self.assertEqual(
            schema["$schema"], "https://json-schema.org/draft/2020-12/schema"
        )

        result = evaluate_release_selection(ROOT)
        policy = json.loads(SELECTION.read_text(encoding="utf-8"))
        readiness = json.loads(
            (ROOT / "spec/evidence/architecture-readiness.json").read_text(
                encoding="utf-8"
            )
        )
        drafts = sorted(
            row["subject_id"] for row in readiness["rows"] if row["stage"] == "draft"
        )

        self.assertEqual(policy["excluded_draft_adrs"], drafts)
        self.assertEqual(result.blockers, ())
        self.assertIn("ADR-TILE-0012", result.selected_adr_ids)
        self.assertIn("ADR-CUBE-0018", result.selected_adr_ids)
        self.assertGreater(len(result.selected_ndf_ids), 100)
        self.assertEqual(
            set(result.selected_adr_ids),
            {row["subject_id"] for row in readiness["rows"] if row["stage"] != "draft"},
        )

    def test_repository_manifest_matches_current_release_selection(self) -> None:
        manifest = json.loads(
            (ROOT / "spec/release-manifest.json").read_text(encoding="utf-8")
        )
        selection = manifest["release_selection"]
        result = evaluate_release_selection(ROOT)
        policy = json.loads(SELECTION.read_text(encoding="utf-8"))

        self.assertEqual(selection["architecture_version"], "0.58.5")
        self.assertEqual(selection["publication_version"], "0.58.5.1")
        self.assertEqual(selection["required_readiness_floor"], "executable")
        self.assertEqual(manifest["release"], selection["architecture_version"])
        self.assertEqual(
            manifest["publication_version"], selection["publication_version"]
        )
        self.assertEqual(selection["blockers"], [])
        self.assertEqual(policy["architecture_version"], "0.58.5")
        self.assertEqual(policy["publication_version"], "0.58.5.1")
        self.assertIn("ADR-TILE-0012", selection["selected_adr_ids"])
        self.assertIn("ADR-CUBE-0018", selection["selected_adr_ids"])
        self.assertIn("ADR-TILE-0012", result.selected_adr_ids)
        frozen_ndf = {row["id"]: row["sha256"] for row in selection["expanded_ndf"]}
        current_ndf = dict(result.ndf_digests)
        self.assertEqual(frozen_ndf, current_ndf)
        self.assertEqual(result.blockers, ())


if __name__ == "__main__":
    unittest.main()
