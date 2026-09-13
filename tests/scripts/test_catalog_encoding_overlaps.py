from __future__ import annotations

import json
import unittest
from pathlib import Path


REPO = Path(__file__).resolve().parents[2]

CATALOG_PATHS = [
    "spec/catalog/scalar-forms.json",
    "spec/catalog/command-forms.json",
]


def encoding_overlaps(catalog: dict) -> set[tuple[str, str]]:
    """Return every mask/match overlap pair as an unordered form-id pair."""
    forms = catalog["forms"]
    pairs: set[tuple[str, str]] = set()
    for index, first in enumerate(forms):
        for second in forms[index + 1 :]:
            if first.get("length_bits") != second.get("length_bits"):
                continue
            first_encoding = first["encoding"][0]
            second_encoding = second["encoding"][0]
            if first_encoding.get("width_bits") != second_encoding.get("width_bits"):
                continue
            first_mask = int(first_encoding["mask"], 16)
            first_match = int(first_encoding["match"], 16)
            second_mask = int(second_encoding["mask"], 16)
            second_match = int(second_encoding["match"], 16)
            if first_match & second_mask == second_match & first_mask:
                pairs.add(
                    tuple(sorted((first["form_id"], second["form_id"])))
                )
    return pairs


class CatalogEncodingOverlapsTest(unittest.TestCase):
    """Every mask/match overlap must be a recorded, reviewed overlap.

    A scan treats reviewed pairs as expected (the catalog records why the
    overlap is not an ambiguity) and fails on any unreviewed overlap, and on
    any review record that no longer names a real overlapping pair.
    """

    @classmethod
    def setUpClass(cls) -> None:
        cls.catalogs = {
            path: json.loads((REPO / path).read_text()) for path in CATALOG_PATHS
        }

    def test_every_overlap_pair_is_reviewed(self) -> None:
        for path, catalog in self.catalogs.items():
            overlaps = encoding_overlaps(catalog)
            reviewed = {
                (min(item["broad_form_id"], item["narrow_form_id"]),
                 max(item["broad_form_id"], item["narrow_form_id"]))
                for item in catalog.get("reviewed_encoding_overlaps", [])
            }
            with self.subTest(path=path):
                self.assertEqual(overlaps, reviewed)

    def test_review_records_are_not_dangling(self) -> None:
        for path, catalog in self.catalogs.items():
            form_ids = {form["form_id"] for form in catalog["forms"]}
            seen: set[tuple[str, str]] = set()
            for item in catalog.get("reviewed_encoding_overlaps", []):
                key = tuple(sorted((item["broad_form_id"], item["narrow_form_id"])))
                with self.subTest(path=path, broad=item["broad_form_id"], narrow=item["narrow_form_id"]):
                    self.assertIn(item["broad_form_id"], form_ids)
                    self.assertIn(item["narrow_form_id"], form_ids)
                    self.assertNotEqual(item["broad_form_id"], item["narrow_form_id"])
                    self.assertNotIn(key, seen, "duplicate review record")
                    self.assertTrue(item["reason"].strip(), "review record must state a reason")
                    seen.add(key)

    def test_review_records_name_actual_overlaps(self) -> None:
        for path, catalog in self.catalogs.items():
            overlaps = encoding_overlaps(catalog)
            for item in catalog.get("reviewed_encoding_overlaps", []):
                key = tuple(sorted((item["broad_form_id"], item["narrow_form_id"])))
                with self.subTest(path=path, pair=key):
                    self.assertIn(key, overlaps, "reviewed pair no longer overlaps")

    def test_both_catalogs_use_the_same_record_shape(self) -> None:
        for path, catalog in self.catalogs.items():
            for item in catalog.get("reviewed_encoding_overlaps", []):
                with self.subTest(path=path, pair=item["broad_form_id"]):
                    self.assertEqual(
                        set(item), {"broad_form_id", "narrow_form_id", "reason"}
                    )


if __name__ == "__main__":
    unittest.main()
