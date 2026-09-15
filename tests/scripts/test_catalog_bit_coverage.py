from __future__ import annotations

import json
import unittest
from pathlib import Path


REPO = Path(__file__).resolve().parents[2]

CATALOG_PATHS = [
    "spec/catalog/scalar-forms.json",
    "spec/catalog/command-forms.json",
]


class CatalogBitCoverageTest(unittest.TestCase):
    """Every encoding bit is either fixed by the form mask or covered by
    exactly one field piece.

    An unassigned bit silently multiplies the encodings that decode to a
    form; a double-covered bit makes field values inconsistent. Both are
    contract defects (see issue #289).
    """

    def test_every_bit_is_masked_or_uniquely_field_covered(self) -> None:
        for path in CATALOG_PATHS:
            catalog = json.loads((REPO / path).read_text())
            for form in catalog["forms"]:
                for encoding in form.get("encoding", []):
                    width = encoding.get("width_bits") or form.get("length_bits")
                    mask = int(encoding["mask"], 16)
                    coverage = [0] * width
                    for field in form.get("fields", []):
                        for piece in field["pieces"]:
                            for bit in range(
                                piece["instruction_lsb"],
                                piece["instruction_lsb"] + piece["width"],
                            ):
                                coverage[bit] += 1
                    unassigned = [
                        bit
                        for bit in range(width)
                        if coverage[bit] == 0 and not (mask >> bit) & 1
                    ]
                    double_covered = [bit for bit in range(width) if coverage[bit] > 1]
                    with self.subTest(path=path, form=form["form_id"]):
                        self.assertEqual(unassigned, [])
                        self.assertEqual(double_covered, [])


if __name__ == "__main__":
    unittest.main()
