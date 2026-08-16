from __future__ import annotations

import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
README = ROOT / "README.md"
MANIFEST = ROOT / "spec/release-manifest.json"
TRACEABILITY = ROOT / "spec/evidence/release-traceability-readiness.json"
RESERVATIONS = ROOT / "spec/catalog/extension-encoding-reservations.json"
AUDIT_ADR = ROOT / "docs/status/decisions/0062-mnemonic-review-decisions.md"
ARCH_SCOPE_ADR = ROOT / "docs/status/decisions/0001-pto-architecture-scope.md"
HISTORICAL_INVENTORY_ADRS = (
    ROOT / "docs/status/decisions/0032-bundle-command-totality-and-profile-boundaries.md",
    ROOT / "docs/status/decisions/0054-pe-local-tile-size-and-32-bit-shared-io-binding.md",
    ROOT / "docs/status/decisions/0055-complete-bundle-bior-schema-and-defaults.md",
    ROOT / "docs/status/decisions/0056-pto-encoding-ownership-and-gm-access.md",
    ROOT / "docs/status/decisions/0060-l-bstop-common-long-form.md",
    ROOT / "docs/status/decisions/0064-b-fpatr-complete-bundle-postprocess.md",
)


class PublicationInventoryTest(unittest.TestCase):
    @staticmethod
    def normalized(text: str) -> str:
        return " ".join(text.split())

    def test_readme_inventory_matches_release_evidence(self) -> None:
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
        traceability = json.loads(TRACEABILITY.read_text(encoding="utf-8"))
        reservations = json.loads(RESERVATIONS.read_text(encoding="utf-8"))
        readme = self.normalized(README.read_text(encoding="utf-8"))
        counts = manifest["catalog_counts"]
        summary = traceability["summary"]

        self.assertIn(
            f"{counts['scalar_forms']} scalar forms, "
            f"{counts['command_forms']} active block forms, "
            f"{counts['tile_operations_total']} direct Tile operations, and "
            f"{len(reservations['reservations'])} occupied extension reservations",
            readme,
        )
        self.assertIn(
            f"{summary['unit_count']} ASL units, "
            f"{summary['documentation_page_count']} generated pages, "
            f"{summary['test_count']} independently runnable AVS points, and "
            f"{summary['executable_requirement_count']} executable mnemonic requirements",
            readme,
        )

    def test_audit_adr_owns_current_active_reserved_inventory(self) -> None:
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
        reservations = json.loads(RESERVATIONS.read_text(encoding="utf-8"))
        text = self.normalized(AUDIT_ADR.read_text(encoding="utf-8"))
        counts = manifest["catalog_counts"]
        encoded_forms = counts["scalar_forms"] + counts["command_forms"]

        self.assertIn("## Current active and reserved encoding inventory", text)
        self.assertIn(
            f"{counts['scalar_forms']} Scalar forms and "
            f"{counts['command_forms']} active Block forms, for "
            f"{encoded_forms} active encoded forms",
            text,
        )
        self.assertIn(
            f"{len(reservations['reservations'])} occupied extension-reservation entries",
            text,
        )

    def test_architecture_scope_matches_current_catalogs(self) -> None:
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
        reservations = json.loads(RESERVATIONS.read_text(encoding="utf-8"))
        text = self.normalized(ARCH_SCOPE_ADR.read_text(encoding="utf-8"))
        counts = manifest["catalog_counts"]

        self.assertIn(
            f"{counts['scalar_forms']} Scalar forms, "
            f"{counts['command_forms']} active Block forms, "
            f"{counts['tile_operations_total']} direct Tile operations, and "
            f"{len(reservations['reservations'])} occupied extension reservations",
            text,
        )

    def test_earlier_inventory_snapshots_defer_to_the_current_audit_adr(self) -> None:
        marker = (
            "Current release inventory is governed by ADR 0062; numeric inventories "
            "below are acceptance-time history, not the current active decoder set."
        )
        for path in HISTORICAL_INVENTORY_ADRS:
            with self.subTest(path=path.name):
                self.assertIn(
                    marker,
                    self.normalized(path.read_text(encoding="utf-8")),
                )


if __name__ == "__main__":
    unittest.main()
