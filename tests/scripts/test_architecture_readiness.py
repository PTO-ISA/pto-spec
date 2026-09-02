from __future__ import annotations

import json
from pathlib import Path
import subprocess
import tempfile
import unittest

from scripts.architecture_readiness import (
    build_document,
    derive_readiness,
    derive_row,
    render_document,
)


ROOT = Path(__file__).resolve().parents[2]
GENERATOR = ROOT / "scripts/generate-architecture-readiness"


class ArchitectureReadinessTest(unittest.TestCase):
    def row(
        self,
        *,
        adr_status: str = "accepted",
        missing_ndf: tuple[str, ...] = (),
        missing_units: tuple[str, ...] = (),
        missing_tests: tuple[str, ...] = (),
        implementation_issue: str | None = None,
        validation: dict[str, object] | None = None,
        commit: str = "a" * 40,
        released_versions: tuple[str, ...] = (),
    ):
        return derive_row(
            subject_id="ADR-GOV-9999",
            adr_status=adr_status,
            ndf_ids=("PTO-EXAMPLE-001",),
            unit_ids=("PTO-EXAMPLE-UNIT",),
            test_ids=("PTO-AVS-EXAMPLE-001",),
            missing_ndf=missing_ndf,
            missing_units=missing_units,
            missing_tests=missing_tests,
            implementation_issue=implementation_issue,
            validation=validation,
            commit=commit,
            released_versions=released_versions,
        )

    def test_draft_never_promotes_from_repository_facts(self) -> None:
        row = self.row(
            adr_status="draft",
            validation={"commit": "a" * 40, "result": "success"},
            released_versions=("0.58.2",),
        )

        self.assertEqual(row.stage, "draft")
        self.assertIsNone(row.validated_commit)
        self.assertEqual(row.released_versions, ())

    def test_accepted_adr_without_asl_is_architecture_defined(self) -> None:
        row = self.row(
            missing_ndf=("PTO-EXAMPLE-001",),
            missing_units=("PTO-EXAMPLE-UNIT",),
            implementation_issue="https://github.com/PTO-ISA/pto-spec/issues/999",
        )

        self.assertEqual(row.stage, "architecture-defined")
        self.assertIn("missing NDF PTO-EXAMPLE-001", row.blockers)
        self.assertIn("missing ASL unit PTO-EXAMPLE-UNIT", row.blockers)

    def test_accepted_adr_without_model_or_issue_is_rejected(self) -> None:
        with self.assertRaisesRegex(ValueError, "implementation issue"):
            self.row(missing_ndf=("PTO-EXAMPLE-001",))

    def test_executable_requires_ndf_and_avs(self) -> None:
        row = self.row(missing_tests=("NDF PTO-EXAMPLE-001",))

        self.assertEqual(row.stage, "modeled")
        self.assertIn("missing AVS for NDF PTO-EXAMPLE-001", row.blockers)

    def test_complete_model_and_avs_are_executable(self) -> None:
        row = self.row()

        self.assertEqual(row.stage, "executable")
        self.assertIsNone(row.validated_commit)

    def test_validation_is_exact_commit_scoped(self) -> None:
        row = self.row(
            validation={"commit": "a" * 40, "result": "success"},
            commit="b" * 40,
        )

        self.assertEqual(row.stage, "executable")
        self.assertIsNone(row.validated_commit)

    def test_matching_successful_validation_promotes_exact_commit(self) -> None:
        row = self.row(
            validation={"commit": "a" * 40, "result": "success"},
        )

        self.assertEqual(row.stage, "validated")
        self.assertEqual(row.validated_commit, "a" * 40)

    def test_release_requires_matching_validation(self) -> None:
        unvalidated = self.row(released_versions=("0.58.2",))
        validated = self.row(
            validation={"commit": "a" * 40, "result": "success"},
            released_versions=("0.58.2",),
        )

        self.assertEqual(unvalidated.stage, "executable")
        self.assertEqual(unvalidated.released_versions, ())
        self.assertEqual(validated.stage, "released")
        self.assertEqual(validated.released_versions, ("0.58.2",))

    def test_repository_projection_is_active_and_does_not_self_validate(self) -> None:
        rows = derive_readiness(ROOT, "a" * 40)
        by_id = {row.subject_id: row for row in rows}

        self.assertEqual(len(by_id), len(rows))
        self.assertEqual(by_id["ADR-NUM-0013"].stage, "draft")
        self.assertEqual(by_id["ADR-NUM-0022"].stage, "draft")
        self.assertFalse(
            any(row.stage in {"validated", "released"} for row in rows)
        )
        self.assertTrue(
            all(
                row.stage != "architecture-defined"
                for row in rows
                if row.subject_id not in {
                    *{f"ADR-{value:04d}" for value in range(86, 96)},
                    "ADR-CUBE-0010",
                }
            )
        )

    def test_document_is_deterministic_and_has_no_wall_clock_time(self) -> None:
        first = render_document(build_document(ROOT, "a" * 40))
        second = render_document(build_document(ROOT, "b" * 40))

        self.assertEqual(first, second)
        self.assertNotIn("generated_at", first)
        document = json.loads(first)
        self.assertEqual(document["schema"], "pto.architecture-readiness")
        self.assertEqual(
            document["summary"]["subject_count"], len(document["rows"])
        )
        self.assertEqual(document["summary"]["validated_count"], 0)
        self.assertEqual(document["summary"]["released_count"], 0)

    def test_generator_supports_write_and_checked_output(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "readiness.json"
            write = subprocess.run(
                [
                    str(GENERATOR),
                    "--output",
                    str(output),
                    "--commit",
                    "a" * 40,
                ],
                cwd=ROOT,
                text=True,
                capture_output=True,
                check=False,
            )
            check = subprocess.run(
                [
                    str(GENERATOR),
                    "--check",
                    "--output",
                    str(output),
                    "--commit",
                    "b" * 40,
                ],
                cwd=ROOT,
                text=True,
                capture_output=True,
                check=False,
            )

        self.assertEqual(write.returncode, 0, write.stderr)
        self.assertEqual(check.returncode, 0, check.stderr)


if __name__ == "__main__":
    unittest.main()
