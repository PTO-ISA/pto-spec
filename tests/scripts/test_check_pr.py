from __future__ import annotations

import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "scripts/check-pr"
WORKFLOW = ROOT / ".github/workflows/asl.yml"
REPOSITORY_CHECK = ROOT / "scripts/check-repository"


class PullRequestCheckTest(unittest.TestCase):
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
                "./scripts/check-adrs",
                "./scripts/check-asl-tests",
                "./scripts/check-release-event-schema",
                "./scripts/check-release-workflow",
                "./scripts/check-repository --structure-only",
                "python3 -m unittest discover -s tests/scripts -p 'test_*.py'",
                "python3 scripts/project_asl_catalogs.py --root . --check",
                "python3 scripts/instruction_docs.py --check",
                "python3 scripts/generate-mnemonic-avs.py --check",
                "python3 scripts/generate-bundle-operation-matrix.py --check",
                "./scripts/generate-bundle-command-totality --check",
                "./scripts/generate-public-source-reconciliation --check",
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

    def test_pull_request_workflow_has_parallel_workers_and_stable_aggregator(self) -> None:
        workflow = WORKFLOW.read_text(encoding="utf-8")

        self.assertIn("name: PR", workflow)
        self.assertIn("name: PR / source-contract", workflow)
        self.assertIn("name: PR / tooling-tests", workflow)
        self.assertIn("name: PR / validate", workflow)
        for gate in (
            "./scripts/check-asl-layout",
            "./scripts/check-ndf",
            "./scripts/check-adrs",
            "./scripts/check-asl-tests",
            "./scripts/check-release-event-schema",
            "python3 scripts/project_asl_catalogs.py --root . --check",
            "python3 scripts/instruction_docs.py --check",
            "./scripts/generate-bundle-command-totality --check",
            "./scripts/generate-public-source-reconciliation --check",
            "python3 scripts/check-publication-hygiene",
        ):
            self.assertIn(gate, workflow)
        self.assertEqual(workflow.count("runs-on:"), 3)
        self.assertIn("needs: [source-contract, tooling-tests]", workflow)
        self.assertIn("if: always()", workflow)
        self.assertIn('test "$SOURCE_CONTRACT_RESULT" = success', workflow)
        self.assertIn('test "$TOOLING_TESTS_RESULT" = success', workflow)
        for forbidden in (
            "setup-ocaml",
            "opam",
            "asl-shard",
            "strict-model",
            "test-" + "shard-",
        ):
            self.assertNotIn(forbidden, workflow)

    def test_pull_request_workflow_executes_each_production_checker_once(self) -> None:
        workflow = WORKFLOW.read_text(encoding="utf-8")

        result = subprocess.run(
            [str(SCRIPT), "--list"],
            cwd=ROOT,
            check=True,
            text=True,
            capture_output=True,
        )
        for command in result.stdout.splitlines():
            self.assertEqual(workflow.count(command), 1, command)

    def test_pull_request_workflow_caches_only_the_ndf_tool_build(self) -> None:
        workflow = WORKFLOW.read_text(encoding="utf-8")

        self.assertIn("path: tools/ndf/target", workflow)
        for term in (
            "runner.os",
            "runner.arch",
            "steps.ndf-revision.outputs.sha",
            "hashFiles('tools/ndf/Cargo.lock')",
        ):
            self.assertIn(term, workflow)
        for forbidden_path in (
            "build/decoders.asl",
            "build/validation-index.json",
            "build/mnemonic-avs",
            "build/asl-test-results",
            "spec/catalog",
            "docs/",
        ):
            self.assertNotIn(f"path: {forbidden_path}", workflow)

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
