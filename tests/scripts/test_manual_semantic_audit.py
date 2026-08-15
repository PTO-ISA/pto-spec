from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from scripts.asl_units import load_units
from scripts.manual_semantic_audit import (
    REQUIRED_REVIEWED_FIELDS,
    audit_repository,
    format_summary,
)


class ManualSemanticAuditTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        (self.root / "asl/block/operands").mkdir(parents=True)

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def review(self, **overrides: object) -> dict[str, object]:
        review: dict[str, object] = {
            "review_method": "formal-definition-read",
            "outcome": "FORMAL-COMPLETE",
            "reviewed_fields": list(REQUIRED_REVIEWED_FIELDS),
        }
        review.update(overrides)
        return review

    def write_instruction(self, review: dict[str, object] | None) -> Path:
        metadata: dict[str, object] = {
            "id": "PTO-BLOCK-B-IOR",
            "surface": "block",
            "classification": ["operands"],
            "depends_on": [],
            "mnemonic": "B.IOR",
        }
        path = self.root / "asl/block/operands/B.IOR.asl"
        review_line = (
            "// PTO-REVIEW: " + json.dumps(review, separators=(",", ":")) + "\n"
            if review is not None
            else ""
        )
        path.write_text(
            "// PTO-INSTRUCTION: "
            + json.dumps(metadata, separators=(",", ":"))
            + "\n"
            + review_line
            + "func B_IOR()\nbegin\n    return;\nend;\n",
            encoding="utf-8",
        )
        return path

    def audit(
        self, *, allow_incomplete: bool = False
    ) -> tuple[list[str], dict[str, int]]:
        return audit_repository(
            self.root,
            allow_incomplete=allow_incomplete,
            surface="block",
        )

    def test_valid_review_is_source_free(self) -> None:
        self.write_instruction(self.review())

        errors, summary = self.audit()

        self.assertEqual(errors, [])
        self.assertEqual(summary["reviewed"], 1)
        self.assertEqual(summary["missing"], 0)

    def test_summary_distinguishes_implementation_closure_from_frozen_audit(self) -> None:
        summary = {
            "reviewed": 190,
            "missing": 452,
            "reservation_reviewed": 32,
            "reservation_missing": 0,
        }

        self.assertEqual(
            format_summary(summary),
            "formal implementation closure: 190 complete, 452 incomplete; "
            "reservation closure: 32 complete, 0 incomplete",
        )

    def test_external_provenance_keys_are_rejected(self) -> None:
        self.write_instruction(
            self.review(
                linx_commit="0" * 40,
                linx_sources=[],
                linx_executable_record="external/catalog.json",
            )
        )

        errors, _ = self.audit()

        self.assertTrue(any("unknown" in error and "linx_commit" in error for error in errors))

    def test_missing_review_is_only_allowed_during_explicit_incomplete_phase(self) -> None:
        self.write_instruction(None)

        strict_errors, _ = self.audit()
        incomplete_errors, summary = self.audit(allow_incomplete=True)

        self.assertIn("asl/block/operands/B.IOR.asl: missing formal semantic review", strict_errors)
        self.assertEqual(incomplete_errors, [])
        self.assertEqual(summary["reviewed"], 0)
        self.assertEqual(summary["missing"], 1)

    def test_unknown_outcome_and_missing_subject_are_rejected(self) -> None:
        fields = list(REQUIRED_REVIEWED_FIELDS)
        fields.remove("ordering")
        self.write_instruction(
            self.review(outcome="ALIGNED", reviewed_fields=fields)
        )

        errors, _ = self.audit()

        self.assertTrue(any("unknown review outcome ALIGNED" in error for error in errors))
        self.assertTrue(any("reviewed_fields must acknowledge exactly" in error for error in errors))

    def test_approved_formal_outcomes_are_accepted(self) -> None:
        for outcome in ("FORMAL-COMPLETE", "FORMAL-INCOMPLETE", "AMBIGUOUS"):
            with self.subTest(outcome=outcome):
                self.write_instruction(self.review(outcome=outcome))
                errors, _ = self.audit(allow_incomplete=True)
                self.assertEqual(errors, [])

    def test_only_formal_complete_counts_as_implementation_closure(self) -> None:
        for outcome in ("FORMAL-INCOMPLETE", "AMBIGUOUS"):
            with self.subTest(outcome=outcome):
                self.write_instruction(self.review(outcome=outcome))

                errors, summary = self.audit(allow_incomplete=True)

                self.assertEqual(errors, [])
                self.assertEqual(summary["reviewed"], 0)
                self.assertEqual(summary["missing"], 1)

    def test_duplicate_review_records_are_rejected(self) -> None:
        path = self.write_instruction(self.review())
        text = path.read_text(encoding="utf-8")
        review_line = next(
            line for line in text.splitlines() if line.startswith("// PTO-REVIEW: ")
        )
        path.write_text(
            text.replace(review_line, f"{review_line}\n{review_line}"),
            encoding="utf-8",
        )

        with self.assertRaisesRegex(ValueError, "expected at most one PTO review record"):
            load_units(self.root / "asl")

    def test_extension_reservations_require_source_free_reserved_outcome(self) -> None:
        path = self.root / "asl/arch/overview/encoding-ownership.asl"
        path.parent.mkdir(parents=True)
        metadata = {
            "id": "PTO-ARCH-OVERVIEW-ENCODING-OWNERSHIP",
            "surface": "arch",
            "classification": ["overview", "encoding-ownership"],
            "depends_on": [],
            "catalog_projection": {
                "catalog": "extension-encoding-reservations",
                "reservations": [{"mnemonic": "V.*"}],
            },
            "manual_reservation_reviews": [
                {"mnemonic": "V.*", "review": self.review(outcome="RESERVED")}
            ],
        }
        path.write_text(
            "// PTO-UNIT: " + json.dumps(metadata, separators=(",", ":")) + "\n",
            encoding="utf-8",
        )

        errors, summary = audit_repository(
            self.root,
            allow_incomplete=False,
            surface="arch",
        )

        self.assertEqual(errors, [])
        self.assertEqual(summary["reservation_reviewed"], 1)
        self.assertEqual(summary["reservation_missing"], 0)


if __name__ == "__main__":
    unittest.main()
