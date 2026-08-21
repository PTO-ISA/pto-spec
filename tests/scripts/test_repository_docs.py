from __future__ import annotations

import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
CHANGELOG_GENERATOR = ROOT / "scripts/generate-changelog"
REVIEW_GENERATOR = ROOT / "scripts/generate-review-summary"

GUIDANCE_PATHS = (
    ROOT / "README.md",
    ROOT / "CONTRIBUTING.md",
    ROOT / "GOVERNANCE.md",
    ROOT / "AGENTS.md",
    ROOT / ".codex/skills/pto-asl/SKILL.md",
    ROOT / ".codex/skills/pto-asl/references/source-map.md",
    ROOT / "docs/governance/adr-process.md",
    ROOT / "docs/governance/validation.md",
    ROOT / "docs/development/getting-started.md",
    ROOT / "docs/development/repository-layout.md",
    ROOT / "docs/releases/index.md",
)

README_LINKS = (
    "docs/arch/overview/architecture.md",
    "docs/arch/overview/instruction-classification.md",
    "docs/development/getting-started.md",
    "docs/development/repository-layout.md",
    "docs/governance/adr-process.md",
    "docs/governance/validation.md",
    "docs/releases/index.md",
    "docs/status/decisions/",
    "docs/status/open/",
)


class RepositoryDocumentationTest(unittest.TestCase):
    def test_focused_guidance_hubs_exist(self) -> None:
        for path in GUIDANCE_PATHS:
            self.assertTrue(path.is_file(), path.relative_to(ROOT))

    def test_readme_is_concise_and_routes_each_topic_once(self) -> None:
        readme = (ROOT / "README.md").read_text(encoding="utf-8")
        self.assertLessEqual(len(readme.splitlines()), 220)
        for target in README_LINKS:
            self.assertEqual(readme.count(f"]({target})"), 1, target)
        for phrase in (
            "PTO ISA at a glance",
            "Architecture scope",
            "Instruction families",
            "Start reading",
            "Quick start",
            "Project policy",
        ):
            self.assertIn(phrase, readme)

    def test_readme_focuses_on_the_isa_not_repository_governance(self) -> None:
        readme = (ROOT / "README.md").read_text(encoding="utf-8")
        self.assertLess(
            readme.index("## Architecture scope"),
            readme.index("## Quick start"),
        )
        self.assertLess(
            readme.index("## Instruction families"),
            readme.index("## Project policy"),
        )
        for phrase in (
            "Management-system migration",
            "management-system-refactor-closure",
            "## Normative authority",
            "## Validation lanes",
        ):
            self.assertNotIn(phrase, readme)

    def test_steady_state_tree_has_no_refactor_timing_infrastructure(self) -> None:
        removed_paths = (
            ROOT / "scripts/pr_timing.py",
            ROOT / "scripts/generate-management-system-refactor-closure",
            ROOT / "scripts/management_refactor_closure.py",
            ROOT / "spec/evidence/management-system-refactor-closure.json",
            ROOT / "docs/status/plans/2026-08-21-management-system-refactor.md",
            ROOT / "docs/status/plans/2026-08-21-management-system-refactor-design.md",
        )
        for path in removed_paths:
            self.assertFalse(path.exists(), path.relative_to(ROOT))

        active_contracts = (
            ROOT / "Makefile",
            ROOT / ".github/workflows/asl.yml",
            ROOT / "spec/release-inputs.json",
            ROOT / "scripts/generate-release-gate-readiness",
        )
        for path in active_contracts:
            text = path.read_text(encoding="utf-8")
            self.assertNotIn("pr_timing", text, path.relative_to(ROOT))
            self.assertNotIn(
                "management-system-refactor-closure",
                text,
                path.relative_to(ROOT),
            )

    def test_active_guidance_has_no_stale_routes_or_release_only_wording(self) -> None:
        forbidden = (
            "spec/requirements.json",
            "PRD-",
            "PD-",
            "manual exact-head release lane",
            "manually dispatched",
        )
        for path in GUIDANCE_PATHS:
            text = path.read_text(encoding="utf-8")
            for phrase in forbidden:
                self.assertNotIn(phrase, text, f"{path.relative_to(ROOT)}: {phrase}")

    def test_authority_order_is_explicit_and_singular(self) -> None:
        readme = (ROOT / "README.md").read_text(encoding="utf-8")
        self.assertIn(
            "ASL/NDF owner -> generated Markdown mirror -> AVS -> commit-scoped evidence",
            readme,
        )
        source_map = (
            ROOT / ".codex/skills/pto-asl/references/source-map.md"
        ).read_text(encoding="utf-8")
        self.assertIn("spec/evidence/adr-index.json", source_map)
        self.assertIn("spec/evidence/release-traceability-readiness.json", source_map)
        self.assertIn("spec/evidence/architecture-readiness.json", source_map)

    def test_readiness_documentation_uses_the_current_generated_view(self) -> None:
        releases = (ROOT / "docs/releases/index.md").read_text(encoding="utf-8")
        governance = (ROOT / "GOVERNANCE.md").read_text(encoding="utf-8")

        self.assertIn("spec/evidence/architecture-readiness.json", releases)
        self.assertIn("spec/evidence/architecture-readiness.json", governance)
        self.assertIn("spec/release-selection.json", releases)
        self.assertIn("spec/release-selection.json", governance)
        self.assertNotIn("externally blocked", releases)
        self.assertNotIn("documented fallback", releases)
        self.assertNotIn("documented fallback", governance)

    def test_current_semantics_and_decision_history_have_distinct_entrypoints(self) -> None:
        agents = (ROOT / "AGENTS.md").read_text(encoding="utf-8")
        source_map = (
            ROOT / ".codex/skills/pto-asl/references/source-map.md"
        ).read_text(encoding="utf-8")
        skill = (ROOT / ".codex/skills/pto-asl/SKILL.md").read_text(
            encoding="utf-8"
        )

        for text in (agents, source_map, skill):
            self.assertIn(
                "Current semantics: owning ASL/NDF -> generated mirror -> AVS -> commit-scoped evidence",
                text,
            )
            self.assertIn(
                "Decision history: ADR index -> affected ASL/NDF",
                text,
            )

    def test_codeowners_has_one_repository_wide_owner(self) -> None:
        self.assertEqual(
            (ROOT / ".github/CODEOWNERS").read_text(encoding="utf-8"),
            "* @zhoubot\n",
        )

    def test_guidance_uses_current_ndf_and_traceability_names(self) -> None:
        governance = (ROOT / "GOVERNANCE.md").read_text(encoding="utf-8")
        skill = (ROOT / ".codex/skills/pto-asl/SKILL.md").read_text(
            encoding="utf-8"
        )
        self.assertIn("github.com/PTO-ISA/normative_language", governance)
        self.assertIn("NDF traceability and coverage", skill)
        self.assertNotIn("documentation, requirements, coverage", skill)

    def test_repository_has_no_checked_in_legacy_documentation_tree(self) -> None:
        self.assertFalse((ROOT / "docs/status/legacy").exists())

    def test_generators_are_executable_and_changelog_is_current(self) -> None:
        for path in (CHANGELOG_GENERATOR, REVIEW_GENERATOR):
            self.assertTrue(path.is_file(), path.relative_to(ROOT))
            self.assertTrue(path.stat().st_mode & 0o111, path.relative_to(ROOT))
        result = subprocess.run(
            [str(CHANGELOG_GENERATOR), "--check"],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_review_summary_is_deterministic_and_non_authoritative(self) -> None:
        command = [str(REVIEW_GENERATOR), "--base", "HEAD^", "--head", "HEAD"]
        first = subprocess.run(
            command, cwd=ROOT, text=True, capture_output=True, check=False
        )
        second = subprocess.run(
            command, cwd=ROOT, text=True, capture_output=True, check=False
        )
        self.assertEqual(first.returncode, 0, first.stderr)
        self.assertEqual(first.stdout, second.stdout)
        for heading in (
            "## Changed ADRs",
            "## Changed NDF clauses",
            "## Changed ASL units",
            "## Binary fingerprint",
            "## Generated projections",
            "## AVS points",
            "## Compatibility",
            "## Blockers",
        ):
            self.assertIn(heading, first.stdout)
        self.assertIn("merge base", first.stdout.lower())
        self.assertIn("review aid", first.stdout.lower())
        self.assertIn("not authority", first.stdout.lower())

    def test_generated_changelog_is_deterministic_and_non_authoritative(self) -> None:
        first = subprocess.run(
            [str(CHANGELOG_GENERATOR), "--stdout"],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )
        second = subprocess.run(
            [str(CHANGELOG_GENERATOR), "--stdout"],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(first.returncode, 0, first.stderr)
        self.assertEqual(first.stdout, second.stdout)
        self.assertEqual(first.stdout, (ROOT / "CHANGELOG.md").read_text(encoding="utf-8"))
        self.assertIn("not architecture authority", first.stdout.lower())


if __name__ == "__main__":
    unittest.main()
