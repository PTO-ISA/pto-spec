from __future__ import annotations

import unittest

from scripts.encoding_witness import (
    encoded_catalog_witnesses,
    encoded_form_witness,
    form_constraints_hold,
    form_encoding_matches,
)


def encoded_row(
    form_id: str,
    *,
    mask: str,
    match: str,
    constraints: list[dict] | None = None,
) -> dict:
    return {
        "constraints": constraints or [],
        "encoding": [{"index": 0, "mask": mask, "match": match, "width_bits": 8}],
        "fields": [
            {
                "name": "Selector",
                "width": 4,
                "pieces": [{"instruction_lsb": 4, "value_lsb": 0, "width": 4}],
            }
        ],
        "form_id": form_id,
        "length_bits": 16,
    }


class EncodingWitnessTest(unittest.TestCase):
    def test_form_witness_satisfies_one_of_and_not_equal_constraints(self) -> None:
        row = encoded_row(
            "constrained",
            mask="0x0f",
            match="0x00",
            constraints=[
                {"field": "Selector", "operator": "one-of", "values": [3, 1]},
                {"field": "Selector", "operator": "not-equal", "value": 3},
            ],
        )

        witness = encoded_form_witness(row)

        self.assertEqual(witness, 0x10)
        self.assertTrue(form_encoding_matches(row, witness))
        self.assertTrue(form_constraints_hold(row, witness))

    def test_catalog_witness_avoids_higher_priority_overlap(self) -> None:
        exact = encoded_row("exact", mask="0xff", match="0x00")
        broad = encoded_row("broad", mask="0x0f", match="0x00")

        exact_witness, broad_witness = encoded_catalog_witnesses([exact, broad])

        self.assertEqual(exact_witness, 0)
        self.assertNotEqual(broad_witness, 0)
        self.assertTrue(form_encoding_matches(broad, broad_witness))
        self.assertFalse(form_encoding_matches(exact, broad_witness))

    def test_form_witness_rejects_unsatisfiable_constraints(self) -> None:
        row = encoded_row(
            "unsatisfiable",
            mask="0x0f",
            match="0x00",
            constraints=[
                {"field": "Selector", "operator": "one-of", "values": [3]},
                {"field": "Selector", "operator": "not-equal", "value": 3},
            ],
        )

        with self.assertRaisesRegex(
            ValueError,
            "encoded form has unsatisfiable constraints for Selector: unsatisfiable",
        ):
            encoded_form_witness(row)

    def test_catalog_witness_rejects_form_shadowed_for_all_legal_values(self) -> None:
        exact = encoded_row("exact", mask="0xff", match="0x00")
        shadowed = encoded_row(
            "shadowed",
            mask="0x0f",
            match="0x00",
            constraints=[{"field": "Selector", "operator": "one-of", "values": [0]}],
        )

        with self.assertRaisesRegex(
            ValueError,
            "encoded form has no legal priority-decode witness: shadowed",
        ):
            encoded_catalog_witnesses([exact, shadowed])


if __name__ == "__main__":
    unittest.main()
