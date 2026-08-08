from __future__ import annotations

import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "scripts/check-pr"
WORKFLOW = ROOT / ".github/workflows/asl.yml"
REPOSITORY_CHECK = ROOT / "scripts/check-repository"


class PullRequestCheckTest(unittest.TestCase):
    def test_repository_checker_accepts_non_executable_python_modules(self) -> None:
        result = subprocess.run(
            [str(REPOSITORY_CHECK), "--structure-only"],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )

        self.assertEqual(result.returncode, 0, result.stderr)

    def test_publication_hygiene_accepts_the_approved_ndf_reference(self) -> None:
        result = subprocess.run(
            ["python3", "scripts/check-publication-hygiene"],
            cwd=ROOT,
            text=True,
            capture_output=True,
        )

        self.assertEqual(result.returncode, 0, result.stderr)

    def test_command_contract_is_lightweight(self) -> None:
        result = subprocess.run(
            [str(SCRIPT), "--list"],
            cwd=ROOT,
            check=True,
            text=True,
            capture_output=True,
        )

        commands = result.stdout.splitlines()
        self.assertEqual(
            commands,
            [
                "./scripts/check-asl-layout",
                "./scripts/check-ndf",
                "./scripts/check-asl-tests",
                "./scripts/check-release-workflow",
                "python3 -m unittest discover -s tests/scripts -p test_*.py",
                "python3 scripts/project_asl_catalogs.py --root . --check",
                "python3 scripts/instruction_docs.py --check",
                "python3 scripts/generate-mnemonic-avs.py --check",
                "python3 scripts/check-publication-hygiene",
                "git diff --check",
            ],
        )
        lowered = "\n".join(commands).lower()
        for forbidden in (
            "opam",
            "setup-aslref",
            "scripts/aslref",
            "toolchain-check",
            "release-verify",
            "test-" + "shard-",
        ):
            self.assertNotIn(forbidden, lowered)

    def test_pull_request_workflow_has_one_lightweight_job(self) -> None:
        workflow = WORKFLOW.read_text(encoding="utf-8")

        self.assertIn("name: PR", workflow)
        self.assertIn("name: PR / validate", workflow)
        for gate in (
            "./scripts/check-asl-layout",
            "./scripts/check-ndf",
            "./scripts/check-asl-tests",
            "python3 scripts/project_asl_catalogs.py --root . --check",
            "python3 scripts/instruction_docs.py --check",
            "python3 scripts/check-publication-hygiene",
        ):
            self.assertIn(gate, workflow)
        self.assertEqual(workflow.count("runs-on:"), 1)
        for forbidden in (
            "setup-ocaml",
            "opam",
            "asl-shard",
            "strict-model",
            "test-" + "shard-",
        ):
            self.assertNotIn(forbidden, workflow)

    def test_repository_source_membership_avoids_pipefail_broken_pipe(self) -> None:
        checker = REPOSITORY_CHECK.read_text(encoding="utf-8")

        self.assertNotIn('| grep -Fxq "$path"', checker)
        self.assertIn('grep -Fxq -- "$path" <<<"$assembled"', checker)

    def test_repository_checker_rejects_every_obsolete_active_tree(self) -> None:
        checker = REPOSITORY_CHECK.read_text(encoding="utf-8")
        active_checker = (ROOT / "scripts/check-active-paths").read_text(
            encoding="utf-8"
        )
        for relative in (
            "asl/bundle",
            "asl/numeric",
            "asl/profiles",
            "asl/architecture.asl",
            "asl/types.asl",
            "asl/state.asl",
            "asl/concurrency.asl",
            "asl/dispatch.asl",
            "docs/instructions",
            "tests/asl/main.asl",
            "tests/asl/shards",
        ):
            self.assertFalse((ROOT / relative).exists(), relative)
            self.assertIn(relative, active_checker)
        self.assertIn("active Markdown is outside the ASL mirror", active_checker)
        self.assertIn("./scripts/check-active-paths", checker)
        self.assertNotIn("--four-surface", checker)


if __name__ == "__main__":
    unittest.main()
