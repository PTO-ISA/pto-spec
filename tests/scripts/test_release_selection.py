from __future__ import annotations

import json
from pathlib import Path
import unittest

from scripts.release_selection import evaluate_release_selection, validate_selection


ROOT = Path(__file__).resolve().parents[2]
SELECTION = ROOT / "spec/release-selection.json"
SCHEMA = ROOT / "spec/schemas/pto-release-selection.schema.json"


class ReleaseSelectionTest(unittest.TestCase):
    def selection(self) -> dict[str, object]:
        return {
            "$schema": "spec/schemas/pto-release-selection.schema.json",
            "architecture_version": "0.58.2",
            "baseline_commit": "b" * 40,
            "included_ndf_statuses": ["accepted"],
            "excluded_draft_adrs": ["ADR-0002"],
            "required_readiness_floor": "executable",
        }

    def facts(self):
        adrs = (
            {
                "id": "ADR-0001",
                "status": "accepted",
                "target_releases": ["0.58.2"],
                "affected_ndf": ["PTO-EXAMPLE-001"],
            },
            {
                "id": "ADR-0002",
                "status": "draft",
                "target_releases": ["unassigned"],
                "affected_ndf": [],
            },
        )
        readiness = (
            {"subject_id": "ADR-0001", "stage": "executable"},
            {"subject_id": "ADR-0002", "stage": "draft"},
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
    ):
        default_adrs, default_readiness, default_ndf = self.facts()
        return validate_selection(
            selection or self.selection(),
            architecture_version="0.58.2",
            adr_records=adrs or default_adrs,
            readiness_rows=readiness or default_readiness,
            ndf_rows=ndf or default_ndf,
            previous_manifest=previous_manifest,
        )

    def test_valid_selection_expands_exact_active_surface(self) -> None:
        result = self.validate()

        self.assertEqual(result.selected_adr_ids, ("ADR-0001",))
        self.assertEqual(result.selected_ndf_ids, ("PTO-EXAMPLE-001",))
        self.assertEqual(result.excluded_draft_adrs, ("ADR-0002",))
        self.assertEqual(result.blockers, ())

    def test_unknown_adr_in_draft_exclusion_is_rejected(self) -> None:
        selection = self.selection()
        selection["excluded_draft_adrs"] = ["ADR-9999"]

        with self.assertRaisesRegex(ValueError, "unknown ADR"):
            self.validate(selection)

    def test_every_draft_must_be_excluded_and_accepted_must_not_be(self) -> None:
        missing = self.selection()
        missing["excluded_draft_adrs"] = []
        accepted = self.selection()
        accepted["excluded_draft_adrs"] = ["ADR-0001", "ADR-0002"]

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
            {**row, "stage": "modeled"} if row["subject_id"] == "ADR-0001" else row
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
            "release_selection": {
                "expanded_ndf": [
                    {"id": "PTO-EXAMPLE-001", "sha256": "0" * 64}
                ]
            },
        }

        result = self.validate(previous_manifest=previous)

        self.assertTrue(
            any("published NDF PTO-EXAMPLE-001 changed" in row for row in result.blockers)
        )

    def test_new_accepted_ndf_becomes_release_blocker(self) -> None:
        _, _, ndf = self.facts()
        previous = {
            "release": "0.58.2",
            "release_selection": {
                "expanded_ndf": [
                    {"id": "PTO-EXAMPLE-001", "sha256": "1" * 64}
                ]
            },
        }
        expanded = (
            *ndf,
            {"id": "PTO-NEW-001", "status": "accepted", "sha256": "3" * 64},
        )

        result = self.validate(ndf=expanded, previous_manifest=previous)

        self.assertTrue(
            any("selected NDF set changed" in row for row in result.blockers)
        )

    def test_repository_policy_freezes_selection_and_reports_main_drift(self) -> None:
        self.assertTrue(SELECTION.is_file())
        self.assertTrue(SCHEMA.is_file())
        schema = json.loads(SCHEMA.read_text(encoding="utf-8"))
        self.assertEqual(schema["$schema"], "https://json-schema.org/draft/2020-12/schema")

        result = evaluate_release_selection(ROOT)
        policy = json.loads(SELECTION.read_text(encoding="utf-8"))
        readiness = json.loads(
            (ROOT / "spec/evidence/architecture-readiness.json").read_text(
                encoding="utf-8"
            )
        )
        drafts = sorted(
            row["subject_id"]
            for row in readiness["rows"]
            if row["stage"] == "draft"
        )

        self.assertEqual(policy["excluded_draft_adrs"], drafts)
        self.assertTrue(result.blockers)
        self.assertTrue(any("published NDF" in row for row in result.blockers))
        self.assertGreater(len(result.selected_ndf_ids), 100)
        self.assertEqual(len(result.selected_adr_ids), 76)

    def test_repository_manifest_records_exact_selection_expansion(self) -> None:
        manifest = json.loads(
            (ROOT / "spec/release-manifest.json").read_text(encoding="utf-8")
        )
        selection = manifest["release_selection"]
        result = evaluate_release_selection(ROOT)

        self.assertEqual(selection["architecture_version"], "0.58.2")
        self.assertEqual(selection["required_readiness_floor"], "executable")
        self.assertEqual(
            [row["id"] for row in selection["expanded_ndf"]],
            list(result.selected_ndf_ids),
        )
        self.assertEqual(selection["selected_adr_ids"], list(result.selected_adr_ids))
        self.assertEqual(selection["blockers"], list(result.blockers))


if __name__ == "__main__":
    unittest.main()
