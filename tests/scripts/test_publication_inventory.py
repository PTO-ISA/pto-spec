from __future__ import annotations

import json
import tempfile
import unittest
from unittest.mock import patch
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
README = ROOT / "README.md"
MANIFEST = ROOT / "spec/release-manifest.json"
TRACEABILITY = ROOT / "spec/evidence/release-traceability-readiness.json"
RESERVATIONS = ROOT / "spec/catalog/extension-encoding-reservations.json"
AUDIT_ADR = ROOT / "docs/status/decisions/ADR-GOV-0006-mnemonic-review-decisions.md"
ARCH_SCOPE_ADR = ROOT / "docs/status/decisions/ADR-GOV-0001-pto-architecture-scope.md"
HISTORICAL_INVENTORY_ADRS = (
    ROOT / "docs/status/decisions/ADR-TILE-0004-bundle-command-totality-and-profile-boundaries.md",
    ROOT / "docs/status/decisions/ADR-BLOCK-0004-pe-local-tile-size-and-32-bit-shared-io-binding.md",
    ROOT / "docs/status/decisions/ADR-BLOCK-0005-complete-bundle-bior-schema-and-defaults.md",
    ROOT / "docs/status/decisions/ADR-MEM-0007-pto-encoding-ownership-and-gm-access.md",
    ROOT / "docs/status/decisions/ADR-BLOCK-0008-l-bstop-common-long-form.md",
    ROOT / "docs/status/decisions/ADR-CUBE-0002-b-fpatr-complete-bundle-postprocess.md",
)
AUDIT_FREEZE_SCALAR_FORMS = 466
AUDIT_FREEZE_BLOCK_FORMS = 74
AUDIT_FREEZE_ENCODED_FORMS = 540
AUDIT_FREEZE_RESERVATIONS = 40


class PublicationInventoryTest(unittest.TestCase):
    @staticmethod
    def normalized(text: str) -> str:
        return " ".join(text.split())

    def test_readme_routes_detailed_inventory_to_generated_evidence(self) -> None:
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
        traceability = json.loads(TRACEABILITY.read_text(encoding="utf-8"))
        reservations = json.loads(RESERVATIONS.read_text(encoding="utf-8"))
        readme = self.normalized(README.read_text(encoding="utf-8"))
        counts = manifest["catalog_counts"]
        summary = traceability["summary"]

        self.assertNotIn(
            f"{counts['scalar_forms']} scalar forms, "
            f"{counts['command_forms']} active block forms, "
            f"{counts['tile_operations_total']} direct Tile operations, and "
            f"{len(reservations['reservations'])} occupied extension reservations",
            readme,
        )
        self.assertNotIn(
            f"{summary['unit_count']} ASL units, "
            f"{summary['documentation_page_count']} generated pages, "
            f"{summary['test_count']} independently runnable AVS points, and "
            f"{summary['executable_requirement_count']} executable mnemonic requirements",
            readme,
        )
        self.assertIn(
            "[release-traceability view]"
            "(spec/evidence/release-traceability-readiness.json)",
            readme,
        )
        self.assertIn("[release hub](docs/releases/index.md)", readme)

    def test_audit_adr_preserves_historical_active_reserved_inventory(self) -> None:
        text = self.normalized(AUDIT_ADR.read_text(encoding="utf-8"))

        self.assertIn("## Historical audit provenance", text)
        self.assertIn(
            f"{AUDIT_FREEZE_SCALAR_FORMS} Scalar forms and "
            f"{AUDIT_FREEZE_BLOCK_FORMS} active Block forms, for "
            f"{AUDIT_FREEZE_ENCODED_FORMS} active encoded forms",
            text,
        )
        self.assertIn(
            f"{AUDIT_FREEZE_RESERVATIONS} occupied extension reservations",
            text,
        )
        self.assertIn(
            "These totals are historical evidence, not the current release inventory; "
            "generated catalogs and release evidence remain authoritative.",
            text,
        )

    def test_historical_audit_freeze_ignores_future_inventory_fixtures(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            manifest = root / "release-manifest.json"
            manifest.write_text(
                json.dumps(
                    {
                        "catalog_counts": {
                            "scalar_forms": 999,
                            "command_forms": 1,
                        }
                    }
                ),
                encoding="utf-8",
            )
            reservations = root / "extension-encoding-reservations.json"
            reservations.write_text(
                json.dumps({"reservations": [{}, {}]}), encoding="utf-8"
            )
            with (
                patch(f"{__name__}.MANIFEST", manifest),
                patch(f"{__name__}.RESERVATIONS", reservations),
            ):
                self.test_audit_adr_preserves_historical_active_reserved_inventory()

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

    def test_earlier_inventory_snapshots_defer_to_generated_inventory(self) -> None:
        marker = (
            "Current release inventory is governed by ASL and generated projections; "
            "numeric inventories below are acceptance-time history, not the current "
            "active decoder set."
        )
        for path in HISTORICAL_INVENTORY_ADRS:
            with self.subTest(path=path.name):
                self.assertIn(
                    marker,
                    self.normalized(path.read_text(encoding="utf-8")),
                )


if __name__ == "__main__":
    unittest.main()
