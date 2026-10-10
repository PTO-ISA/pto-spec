from __future__ import annotations

import json
import tomllib
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


def catalog_counts() -> dict[str, int]:
    scalar = json.loads(
        (ROOT / "spec/catalog/scalar-forms.json").read_text(encoding="utf-8")
    )
    command = json.loads(
        (ROOT / "spec/catalog/command-forms.json").read_text(encoding="utf-8")
    )
    tile = json.loads(
        (ROOT / "spec/catalog/tile-operations.json").read_text(encoding="utf-8")
    )
    return {
        "scalar_forms": scalar["form_count"],
        "command_forms": command["form_count"],
        "pto_operations": tile["operation_count"],
    }


class SpecificationCountsTest(unittest.TestCase):
    def test_architecture_counts_match_the_authoritative_catalogs(self) -> None:
        specification = tomllib.loads(
            (ROOT / "specification.toml").read_text(encoding="utf-8")
        )
        architecture = specification["architecture"]
        expected = catalog_counts()
        for field, count in expected.items():
            self.assertEqual(
                architecture[field],
                count,
                f"specification.toml [architecture].{field} drifted from the "
                "catalog projection; catalogs are authoritative",
            )

    def test_release_manifest_counts_remain_pinned_to_its_release_identity(self) -> None:
        manifest = json.loads(
            (ROOT / "spec/release-manifest.json").read_text(encoding="utf-8")
        )
        specification = tomllib.loads(
            (ROOT / "specification.toml").read_text(encoding="utf-8")
        )
        release = specification["release"]
        self.assertEqual(manifest["release"], release["architecture_version"])
        self.assertEqual(manifest["publication_version"], release["publication_version"])
        self.assertEqual(manifest["encoding_abi"], release["encoding_abi"])
        counts = manifest["catalog_counts"]
        # This manifest is the immutable 0.58.7 release artifact. New draft
        # catalog forms are checked against specification.toml above and must
        # not silently rewrite the already-published release identity.
        self.assertEqual(counts["scalar_forms"], 466)
        self.assertEqual(counts["command_forms"], 96)
        self.assertEqual(counts["tile_operations_total"], 118)


if __name__ == "__main__":
    unittest.main()
