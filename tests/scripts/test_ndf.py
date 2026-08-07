from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from scripts.ndf import check_repository, instruction_clause_id, parse_ndf_regions


VALID_CLAUSE = """// NDF-BEGIN: PTO-TILE-CAPACITY
// ndf: kind=contract level=L1 layer=tile status=accepted
// Tile capacity is defined per selected PE.
// NDF-END: PTO-TILE-CAPACITY
"""


class NdfTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def write(self, relative: str, text: str) -> Path:
        path = self.root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")
        return path

    def test_parse_valid_clause(self) -> None:
        clauses = parse_ndf_regions(VALID_CLAUSE, Path("asl/architecture.asl"))

        self.assertEqual(len(clauses), 1)
        self.assertEqual(clauses[0].clause_id, "PTO-TILE-CAPACITY")
        self.assertEqual(clauses[0].level, "L1")
        self.assertEqual(clauses[0].body, "Tile capacity is defined per selected PE.")

    def test_rejects_duplicate_clause_ids(self) -> None:
        self.write("asl/architecture.asl", VALID_CLAUSE)
        self.write("asl/tile/state.asl", VALID_CLAUSE)

        self.assertIn(
            "duplicate NDF clause PTO-TILE-CAPACITY",
            check_repository(self.root),
        )

    def test_rejects_mismatched_end_id(self) -> None:
        self.write(
            "asl/architecture.asl",
            VALID_CLAUSE.replace(
                "NDF-END: PTO-TILE-CAPACITY",
                "NDF-END: PTO-OTHER",
            ),
        )

        self.assertTrue(
            any("mismatched NDF end PTO-OTHER" in error for error in check_repository(self.root))
        )

    def test_rejects_invalid_metadata(self) -> None:
        self.write(
            "asl/architecture.asl",
            VALID_CLAUSE.replace(
                "kind=contract level=L1 layer=tile status=accepted",
                "kind=contract level=L3 layer=unknown status=final",
            ),
        )

        errors = check_repository(self.root)
        self.assertTrue(any("kind contract requires level L1" in error for error in errors))
        self.assertTrue(any("unknown NDF layer unknown" in error for error in errors))
        self.assertTrue(any("unknown NDF status final" in error for error in errors))

    def test_rejects_unknown_cross_reference(self) -> None:
        self.write(
            "asl/architecture.asl",
            VALID_CLAUSE.replace(
                "selected PE.",
                "selected PE; see [[PTO-MISSING]].",
            ),
        )

        self.assertIn(
            "asl/architecture.asl: unknown NDF reference PTO-MISSING",
            check_repository(self.root),
        )

    def test_rejects_normative_clause_outside_asl(self) -> None:
        self.write(
            "docs/architecture.md",
            "## Contract {#PTO-TILE-CAPACITY}\n"
            "<!-- ndf: kind=contract level=L1 layer=tile status=accepted -->\n",
        )

        self.assertIn(
            "docs/architecture.md: active NDF clause must be owned by ASL",
            check_repository(self.root),
        )

    def test_rejects_legacy_archive_and_backup_paths(self) -> None:
        self.write("docs/legacy/old.md", "old\n")
        self.write("docs/archive/old.md", "old\n")
        self.write("asl/tile/state.asl.bak", "old\n")

        errors = check_repository(self.root)
        self.assertIn("forbidden legacy specification path: docs/legacy/old.md", errors)
        self.assertIn("forbidden legacy specification path: docs/archive/old.md", errors)
        self.assertIn("forbidden backup specification path: asl/tile/state.asl.bak", errors)

    def test_accepts_asl_owned_clause(self) -> None:
        self.write("asl/architecture.asl", VALID_CLAUSE)

        self.assertEqual(check_repository(self.root), [])

    def test_instruction_clause_id_is_stable_and_surface_scoped(self) -> None:
        self.assertEqual(instruction_clause_id("tile", "TLOAD"), "PTO-INST-TILE-TLOAD")
        self.assertEqual(
            instruction_clause_id("block", "BSTART.TLOAD"),
            "PTO-INST-BLOCK-BSTART-TLOAD",
        )


if __name__ == "__main__":
    unittest.main()
