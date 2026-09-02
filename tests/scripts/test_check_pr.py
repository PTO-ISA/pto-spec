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
                "./scripts/check-adrs",
                "make --no-print-directory check-decoder-partition",
                "./scripts/check-release-event-schema",
                "./scripts/check-model-closure-schema",
                "./scripts/check-release-workflow",
                "./scripts/check-repository --structure-only",
                "git diff --check",
                "./scripts/run-python-tests",
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
        self.assertEqual(workflow.count("./scripts/check-pr --source"), 1)
        self.assertEqual(workflow.count("./scripts/check-pr --tooling"), 1)
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
            self.assertNotIn(command, workflow, command)

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

    def test_local_runner_parallelizes_the_two_fail_closed_lanes(self) -> None:
        checker = SCRIPT.read_text(encoding="utf-8")

        self.assertIn('run_commands source "${source_commands[@]}" &', checker)
        self.assertIn('run_commands tooling "${tooling_commands[@]}" &', checker)
        self.assertIn('wait "$source_pid"', checker)
        self.assertIn('wait "$tooling_pid"', checker)
        self.assertIn("PR check failed: source=%s tooling=%s", checker)
        self.assertIn("date +%s", checker)

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
