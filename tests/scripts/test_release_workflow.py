from __future__ import annotations

import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

from scripts.full_validation_workflow import (
    validate_full_validation_workflow,
    validate_nightly_workflow,
)
from scripts.release_workflow import validate_pr_workflow, validate_release_workflow


ROOT = Path(__file__).resolve().parents[2]
WORKFLOW_CHECKER = ROOT / "scripts/check-release-workflow"


def replace_last(source: str, old: str, new: str) -> str:
    before, separator, after = source.rpartition(old)
    if not separator:
        return source
    return before + new + after


VALID_PR_WORKFLOW = r"""
name: PR
on:
  push:
    branches: [main]
  pull_request:
permissions:
  contents: read
concurrency:
  group: pr-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
jobs:
  source-contract:
    name: PR / source-contract
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - name: Check out repository
        uses: actions/checkout@d23441a48e516b6c34aea4fa41551a30e30af803
        with:
          fetch-depth: 0
          submodules: recursive
      - name: Validate source, projection, and publication contracts
        run: |
          ./scripts/check-asl-layout
          ./scripts/check-ndf
          ./scripts/check-adrs
          ./scripts/check-asl-tests
          ./scripts/check-release-event-schema
          python3 scripts/project_asl_catalogs.py --root . --check
          python3 scripts/instruction_docs.py --check
          python3 scripts/generate-mnemonic-avs.py --check
          python3 scripts/generate-bundle-operation-matrix.py --check
          ./scripts/generate-bundle-command-totality --check
          ./scripts/generate-public-source-reconciliation --check
          python3 scripts/check-publication-hygiene
          ./scripts/check-release-workflow
          ./scripts/check-repository --structure-only
          git diff --check
  tooling-tests:
    name: PR / tooling-tests
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - name: Check out repository
        uses: actions/checkout@d23441a48e516b6c34aea4fa41551a30e30af803
        with:
          fetch-depth: 0
          submodules: recursive
      - name: Resolve the exact NDF revision
        id: ndf-revision
        run: echo "sha=$(git -C tools/ndf rev-parse HEAD)" >> "$GITHUB_OUTPUT"
      - name: Restore the NDF tool build
        id: ndf-cache
        uses: actions/cache@55cc8345863c7cc4c66a329aec7e433d2d1c52a9
        with:
          path: tools/ndf/target
          key: ndf-${{ runner.os }}-${{ runner.arch }}-${{ steps.ndf-revision.outputs.sha }}-${{ hashFiles('tools/ndf/Cargo.lock') }}
      - name: Run script and NDF parity tests
        run: python3 -m unittest discover -s tests/scripts -p 'test_*.py'
  validate:
    name: PR / validate
    if: always()
    needs: [source-contract, tooling-tests]
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - name: Require both correctness workers
        env:
          SOURCE_CONTRACT_RESULT: ${{ needs.source-contract.result }}
          TOOLING_TESTS_RESULT: ${{ needs.tooling-tests.result }}
        run: |
          test "$SOURCE_CONTRACT_RESULT" = success
          test "$TOOLING_TESTS_RESULT" = success
"""


WORKFLOW_SHA_NIGHTLY = r"""name: Nightly main health

on:
  schedule:
    - cron: "17 2 * * *"
  workflow_dispatch:

permissions:
  contents: read

concurrency:
  group: nightly-main-health
  cancel-in-progress: false

jobs:
  resolve-main:
    name: Nightly / prove workflow commit is latest main
    runs-on: ubuntu-latest
    timeout-minutes: 10
    outputs:
      commit: ${{ steps.resolve.outputs.commit }}
    steps:
      - name: Check out caller workflow commit
        uses: actions/checkout@d23441a48e516b6c34aea4fa41551a30e30af803
        with:
          ref: ${{ github.sha }}
          fetch-depth: 0
          persist-credentials: false
          submodules: recursive

      - name: Prove caller workflow commit is latest origin main
        id: resolve
        shell: bash
        env:
          GITHUB_WORKFLOW_SHA: ${{ github.sha }}
        run: |
          test "$GITHUB_REF" = refs/heads/main
          [[ "$GITHUB_WORKFLOW_SHA" =~ ^[0-9a-f]{40}$ ]]
          test "$GITHUB_SHA" = "$GITHUB_WORKFLOW_SHA"
          test "$(git rev-parse HEAD)" = "$GITHUB_WORKFLOW_SHA"
          git fetch --no-tags origin main:refs/remotes/origin/main
          test "$(git rev-parse origin/main)" = "$GITHUB_WORKFLOW_SHA"
          echo "commit=$GITHUB_WORKFLOW_SHA" >> "$GITHUB_OUTPUT"

  full-validation:
    name: Nightly / full validation
    needs: resolve-main
    uses: ./.github/workflows/full-validation.yml
    with:
      commit: ${{ needs.resolve-main.outputs.commit }}
      authority: nightly
    permissions:
      contents: read

  validate:
    name: Nightly / health
    if: always()
    needs: [resolve-main, full-validation]
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - name: Require exact latest-main health
        shell: bash
        env:
          RESOLVE_MAIN_RESULT: ${{ needs.resolve-main.result }}
          FULL_VALIDATION_RESULT: ${{ needs.full-validation.result }}
        run: |
          test "$RESOLVE_MAIN_RESULT" = success
          test "$FULL_VALIDATION_RESULT" = success
"""


class PullRequestWorkflowContractTest(unittest.TestCase):
    def test_complete_lightweight_workflow_is_accepted(self) -> None:
        self.assertEqual(validate_pr_workflow(VALID_PR_WORKFLOW), [])

    def assert_root_rejected(self, workflow: str) -> None:
        errors = validate_pr_workflow(workflow)
        self.assertTrue(
            any("exact top-level mapping" in error for error in errors), errors
        )

    def test_pr_workflow_rejects_top_level_default_shells(self) -> None:
        for shell in ("echo {0}", "bash -n {0}"):
            with self.subTest(shell=shell):
                workflow = VALID_PR_WORKFLOW.replace(
                    "jobs:\n",
                    f"defaults:\n  run:\n    shell: {shell}\njobs:\n",
                    1,
                )
                self.assert_root_rejected(workflow)

    def test_pr_workflow_rejects_top_level_bash_env(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "jobs:\n",
            "env:\n  BASH_ENV: .github/bypass.sh\njobs:\n",
            1,
        )
        self.assert_root_rejected(workflow)

    def test_pr_workflow_rejects_widened_permissions(self) -> None:
        self.assert_root_rejected(
            VALID_PR_WORKFLOW.replace(
                "  contents: read\n", "  contents: write\n", 1
            )
        )

    def test_pr_workflow_rejects_pull_request_target(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "  pull_request:\n",
            "  pull_request:\n  pull_request_target:\n",
            1,
        )
        self.assert_root_rejected(workflow)

    def test_pr_workflow_rejects_extra_event_and_root_key(self) -> None:
        workflows = (
            VALID_PR_WORKFLOW.replace(
                "  pull_request:\n", "  pull_request:\n  workflow_dispatch:\n", 1
            ),
            VALID_PR_WORKFLOW.replace("jobs:\n", "timeout-minutes: 1\njobs:\n", 1),
        )
        for workflow in workflows:
            with self.subTest(workflow=workflow):
                self.assert_root_rejected(workflow)

    def test_pr_workflow_rejects_missing_root_key(self) -> None:
        self.assert_root_rejected(
            VALID_PR_WORKFLOW.replace(
                "concurrency:\n"
                "  group: pr-${{ github.workflow }}-${{ github.ref }}\n"
                "  cancel-in-progress: true\n",
                "",
                1,
            )
        )

    def test_pr_workflow_rejects_altered_name_events_and_concurrency(self) -> None:
        workflows = (
            VALID_PR_WORKFLOW.replace("name: PR\n", "name: Pull request\n", 1),
            VALID_PR_WORKFLOW.replace(
                "    branches: [main]\n", "    branches: [release]\n", 1
            ),
            VALID_PR_WORKFLOW.replace(
                "    branches: [main]\n", "    branches: main\n", 1
            ),
            VALID_PR_WORKFLOW.replace(
                "  group: pr-${{ github.workflow }}-${{ github.ref }}\n",
                "  group: pr-${{ github.ref }}\n",
                1,
            ),
            VALID_PR_WORKFLOW.replace(
                "  cancel-in-progress: true\n", "  cancel-in-progress: false\n", 1
            ),
        )
        for workflow in workflows:
            with self.subTest(workflow=workflow):
                self.assert_root_rejected(workflow)

    def test_pr_workflow_rejects_top_level_duplicate_and_anchor_bypasses(self) -> None:
        workflows = (
            VALID_PR_WORKFLOW.replace("name: PR\n", "name: decoy\nname: PR\n", 1),
            VALID_PR_WORKFLOW.replace(
                "permissions:\n",
                "defaults: &bypass\n  run:\n    shell: echo {0}\npermissions:\n",
                1,
            ),
        )
        for workflow in workflows:
            with self.subTest(workflow=workflow):
                errors = validate_pr_workflow(workflow)
                self.assertTrue(
                    any(
                        marker in error
                        for error in errors
                        for marker in ("duplicate mapping key", "anchors or aliases")
                    ),
                    errors,
                )

    def test_pr_workflow_rejects_aslref(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "      - name: Validate source, projection, and publication contracts\n",
            "      - name: forbidden ASLRef setup\n"
            "        run: make setup-aslref\n"
            "      - name: Validate source, projection, and publication contracts\n",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("unexpected" in error for error in errors))

    def test_pr_workflow_rejects_opam(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "      - name: Validate source, projection, and publication contracts\n",
            "      - name: forbidden opam setup\n"
            "        run: opam install anything\n"
            "      - name: Validate source, projection, and publication contracts\n",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("unexpected" in error for error in errors))

    def test_pr_workflow_requires_every_lightweight_gate(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "          ./scripts/check-ndf\n",
            "",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("check-ndf" in error for error in errors))

    def test_pr_workflow_requires_adr_gate(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "          ./scripts/check-adrs\n",
            "",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("check-adrs" in error for error in errors))

    def test_pr_workflow_requires_release_event_schema_gate(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "          ./scripts/check-release-event-schema\n",
            "",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("check-release-event-schema" in error for error in errors))

    def test_pr_workflow_requires_exact_parallel_job_shape(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace("  tooling-tests:\n", "  extra:\n", 1)
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("exactly source-contract, tooling-tests, and validate" in error for error in errors))

    def test_pr_workflow_requires_fail_closed_aggregator(self) -> None:
        for removed, expected in (
            (
                "  validate:\n    name: PR / validate\n    if: always()\n",
                "always run",
            ),
            ("          test \"$SOURCE_CONTRACT_RESULT\" = success\n", "SOURCE_CONTRACT_RESULT"),
            ("          test \"$TOOLING_TESTS_RESULT\" = success\n", "TOOLING_TESTS_RESULT"),
        ):
            with self.subTest(removed=removed):
                replacement = (
                    "  validate:\n    name: PR / validate\n"
                    if removed.startswith("  validate:")
                    else ""
                )
                errors = validate_pr_workflow(
                    VALID_PR_WORKFLOW.replace(removed, replacement, 1)
                )
                self.assertTrue(any(expected in error for error in errors), errors)

    def test_pr_workflow_rejects_duplicate_production_gate(self) -> None:
        duplicated = VALID_PR_WORKFLOW.replace(
            "          ./scripts/check-adrs\n",
            "          ./scripts/check-adrs\n"
            "          ./scripts/check-adrs\n",
        )
        errors = validate_pr_workflow(duplicated)
        self.assertTrue(any("exactly once" in error and "check-adrs" in error for error in errors), errors)

    def test_pr_workflow_requires_narrow_ndf_cache(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "          path: tools/ndf/target\n",
            "          path: build\n",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("NDF cache" in error for error in errors), errors)

    def test_pr_workflow_rejects_an_additional_cache(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "      - name: Validate source, projection, and publication contracts\n",
            "      - uses: actions/cache@55cc8345863c7cc4c66a329aec7e433d2d1c52a9\n"
            "        with:\n"
            "          path: build\n"
            "          key: generated-output\n"
            "      - name: Validate source, projection, and publication contracts\n",
            1,
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("only cache" in error for error in errors), errors)

    def test_pr_workflow_requires_every_action_to_use_the_exact_pin(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "actions/cache@55cc8345863c7cc4c66a329aec7e433d2d1c52a9",
            "actions/cache@v4",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("commit-pinned" in error for error in errors), errors)

    def test_pr_workflow_rejects_duplicate_mapping_keys(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "    name: PR / source-contract\n",
            "    name: decoy\n    name: PR / source-contract\n",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("duplicate mapping key" in error for error in errors), errors)

    def test_pr_workflow_rejects_duplicate_jobs(self) -> None:
        duplicate = VALID_PR_WORKFLOW[VALID_PR_WORKFLOW.index("  source-contract:\n") : VALID_PR_WORKFLOW.index("  tooling-tests:\n")]
        workflow = VALID_PR_WORKFLOW.replace("  tooling-tests:\n", duplicate + "  tooling-tests:\n")
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("duplicate mapping key" in error for error in errors), errors)

    def test_pr_workflow_rejects_anchors_and_aliases(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "    name: PR / source-contract\n",
            "    name: &worker PR / source-contract\n    inherited: *worker\n",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("anchors or aliases" in error for error in errors), errors)

    def test_commented_checker_does_not_count_as_execution(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "          ./scripts/check-adrs\n",
            "          # ./scripts/check-adrs\n",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("check-adrs" in error for error in errors), errors)

    def test_folded_run_block_is_outside_the_supported_subset(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace("        run: |\n", "        run: >\n", 1)
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("invalid structure" in error for error in errors), errors)

    def test_commented_if_does_not_make_aggregator_always_run(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "    if: always()\n",
            "    # if: always()\n",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("always run" in error for error in errors), errors)

    def test_pr_workflow_rejects_unknown_job(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "  validate:\n",
            "  surprise:\n    name: surprise\n    steps: []\n  validate:\n",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("exactly source-contract" in error for error in errors), errors)

    def test_pr_workflow_rejects_duplicate_uses_keys(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "        uses: actions/cache@55cc8345863c7cc4c66a329aec7e433d2d1c52a9\n",
            "        uses: actions/cache@55cc8345863c7cc4c66a329aec7e433d2d1c52a9\n"
            "        uses: actions/cache@v4\n",
            1,
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("duplicate mapping key" in error for error in errors), errors)

    def test_pr_workflow_rejects_malformed_uses(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "actions/cache@55cc8345863c7cc4c66a329aec7e433d2d1c52a9",
            "[actions/cache@v4]",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(
            any(
                "malformed or unrecognized uses" in error
                or "invalid structure" in error
                for error in errors
            ),
            errors,
        )

    def test_pr_workflow_rejects_unrecognized_action(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "actions/cache@55cc8345863c7cc4c66a329aec7e433d2d1c52a9",
            "attacker/cache@55cc8345863c7cc4c66a329aec7e433d2d1c52a9",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("malformed or unrecognized uses" in error for error in errors), errors)

    def test_pr_workflow_rejects_wrong_aggregator_needs(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "    needs: [source-contract, tooling-tests]\n",
            "    needs: source-contract\n",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("both worker jobs" in error for error in errors), errors)

    def test_pr_workflow_rejects_an_extra_checker(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "          ./scripts/check-adrs\n",
            "          ./scripts/check-adrs\n"
            "          ./scripts/check-adrs\n",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("exactly once" in error for error in errors), errors)

    def test_pr_workflow_rejects_env_prefixed_duplicate_checker(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "          ./scripts/check-adrs\n",
            "          ./scripts/check-adrs\n"
            "          CHECK_MODE=duplicate ./scripts/check-adrs\n",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("unexpected active line" in error for error in errors), errors)

    def test_pr_workflow_rejects_alternate_checker_invocation(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "          ./scripts/check-adrs\n",
            "          ./scripts/check-adrs\n"
            "          python3 scripts/check-adrs\n",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("unexpected active line" in error for error in errors), errors)

    def test_pr_workflow_rejects_obfuscated_forbidden_tool(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "          ./scripts/check-adrs\n",
            "          ./scripts/check-adrs\n"
            "          o'p'am --version\n",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("unexpected active line" in error for error in errors), errors)

    def test_source_checker_cannot_move_to_tooling_worker(self) -> None:
        command = "          ./scripts/check-adrs\n"
        workflow = VALID_PR_WORKFLOW.replace(command, "", 1).replace(
            "        run: python3 -m unittest discover -s tests/scripts -p 'test_*.py'",
            "        run: |\n"
            + command
            + "          python3 -m unittest discover -s tests/scripts -p 'test_*.py'",
            1,
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("source-contract" in error and "check-adrs" in error for error in errors), errors)

    def test_source_correctness_step_rejects_false_condition(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "      - name: Validate source, projection, and publication contracts\n"
            "        run: |\n",
            "      - name: Validate source, projection, and publication contracts\n"
            "        if: false\n"
            "        run: |\n",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("exact ordered step mappings" in error for error in errors), errors)

    def test_tooling_correctness_step_rejects_false_condition(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "      - name: Run script and NDF parity tests\n",
            "      - name: Run script and NDF parity tests\n"
            "        if: false\n",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("exact ordered step mappings" in error for error in errors), errors)

    def test_source_correctness_step_rejects_continue_on_error(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "      - name: Validate source, projection, and publication contracts\n"
            "        run: |\n",
            "      - name: Validate source, projection, and publication contracts\n"
            "        continue-on-error: true\n"
            "        run: |\n",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("exact ordered step mappings" in error for error in errors), errors)

    def test_tooling_correctness_step_rejects_continue_on_error(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "      - name: Run script and NDF parity tests\n",
            "      - name: Run script and NDF parity tests\n"
            "        continue-on-error: true\n",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("exact ordered step mappings" in error for error in errors), errors)

    def test_source_correctness_step_rejects_nonexecuting_shell(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "      - name: Validate source, projection, and publication contracts\n"
            "        run: |\n",
            "      - name: Validate source, projection, and publication contracts\n"
            "        shell: echo {0}\n"
            "        run: |\n",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("exact ordered step mappings" in error for error in errors), errors)

    def test_tooling_correctness_step_rejects_nonexecuting_shell(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "      - name: Run script and NDF parity tests\n",
            "      - name: Run script and NDF parity tests\n"
            "        shell: echo {0}\n",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("exact ordered step mappings" in error for error in errors), errors)

    def test_correctness_step_rejects_other_execution_overrides(self) -> None:
        for override in (
            "        working-directory: scripts\n",
            "        timeout-minutes: 1\n",
            "        env:\n          BYPASS: true\n",
        ):
            with self.subTest(override=override):
                workflow = VALID_PR_WORKFLOW.replace(
                    "      - name: Validate source, projection, and publication contracts\n"
                    "        run: |\n",
                    "      - name: Validate source, projection, and publication contracts\n"
                    + override
                    + "        run: |\n",
                )
                errors = validate_pr_workflow(workflow)
                self.assertTrue(any("exact ordered step mappings" in error for error in errors), errors)

    def test_worker_job_rejects_continue_on_error(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "    timeout-minutes: 15\n    steps:\n",
            "    timeout-minutes: 15\n    continue-on-error: true\n    steps:\n",
            1,
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("exact job mapping" in error for error in errors), errors)

    def test_tooling_cache_cannot_precede_revision(self) -> None:
        revision = (
            "      - name: Resolve the exact NDF revision\n"
            "        id: ndf-revision\n"
            "        run: echo \"sha=$(git -C tools/ndf rev-parse HEAD)\" >> \"$GITHUB_OUTPUT\"\n"
        )
        cache = (
            "      - name: Restore the NDF tool build\n"
            "        id: ndf-cache\n"
            "        uses: actions/cache@55cc8345863c7cc4c66a329aec7e433d2d1c52a9\n"
            "        with:\n"
            "          path: tools/ndf/target\n"
            "          key: ndf-${{ runner.os }}-${{ runner.arch }}-${{ steps.ndf-revision.outputs.sha }}-${{ hashFiles('tools/ndf/Cargo.lock') }}\n"
        )
        workflow = VALID_PR_WORKFLOW.replace(revision + cache, cache + revision)
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("exact ordered step mappings" in error for error in errors), errors)

    def test_tooling_cache_cannot_follow_tests(self) -> None:
        cache_start = VALID_PR_WORKFLOW.index("      - name: Restore the NDF tool build\n")
        tests_start = VALID_PR_WORKFLOW.index("      - name: Run script and NDF parity tests\n")
        finish_start = VALID_PR_WORKFLOW.index("  validate:\n")
        cache = VALID_PR_WORKFLOW[cache_start:tests_start]
        workflow = (
            VALID_PR_WORKFLOW[:cache_start]
            + VALID_PR_WORKFLOW[tests_start:finish_start]
            + cache
            + VALID_PR_WORKFLOW[finish_start:]
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("exact ordered step mappings" in error for error in errors), errors)

    def test_checkout_and_correctness_step_cannot_be_reordered(self) -> None:
        checkout_start = VALID_PR_WORKFLOW.index("      - name: Check out repository\n")
        correctness_start = VALID_PR_WORKFLOW.index(
            "      - name: Validate source, projection, and publication contracts\n"
        )
        tooling_start = VALID_PR_WORKFLOW.index("  tooling-tests:\n")
        checkout = VALID_PR_WORKFLOW[checkout_start:correctness_start]
        correctness = VALID_PR_WORKFLOW[correctness_start:tooling_start]
        workflow = (
            VALID_PR_WORKFLOW[:checkout_start]
            + correctness
            + checkout
            + VALID_PR_WORKFLOW[tooling_start:]
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("exact ordered step mappings" in error for error in errors), errors)

    def test_aggregator_job_rejects_false_condition(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "  validate:\n    name: PR / validate\n    if: always()\n",
            "  validate:\n    name: PR / validate\n    if: false\n",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("validate must use its exact job mapping" in error for error in errors), errors)

    def test_aggregator_job_rejects_continue_on_error(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "    timeout-minutes: 5\n    steps:\n",
            "    timeout-minutes: 5\n    continue-on-error: true\n    steps:\n",
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("validate must use its exact job mapping" in error for error in errors), errors)

    def test_aggregator_job_rejects_runner_or_timeout_changes(self) -> None:
        for old, new in (
            ("    runs-on: ubuntu-latest\n", "    runs-on: ubuntu-24.04\n"),
            ("    timeout-minutes: 5\n", "    timeout-minutes: 10\n"),
        ):
            with self.subTest(new=new):
                workflow = replace_last(VALID_PR_WORKFLOW, old, new)
                errors = validate_pr_workflow(workflow)
                self.assertTrue(any("validate must use its exact job mapping" in error for error in errors), errors)

    def test_aggregator_steps_reject_execution_overrides(self) -> None:
        for override in (
            "        if: false\n",
            "        continue-on-error: true\n",
            "        shell: echo {0}\n",
        ):
            with self.subTest(override=override):
                marker = "      - name: Require both correctness workers\n"
                workflow = VALID_PR_WORKFLOW.replace(marker, marker + override, 1)
                errors = validate_pr_workflow(workflow)
                self.assertTrue(any("validate must use its exact ordered step mappings" in error for error in errors), errors)

    def test_aggregator_result_env_rejects_literal_success_spoof(self) -> None:
        for expression in (
            "${{ needs.source-contract.result }}",
            "${{ needs.tooling-tests.result }}",
        ):
            with self.subTest(expression=expression):
                workflow = VALID_PR_WORKFLOW.replace(expression, "success", 1)
                errors = validate_pr_workflow(workflow)
                self.assertTrue(any("validate must use its exact ordered step mappings" in error for error in errors), errors)

    def test_aggregator_result_step_is_required(self) -> None:
        result = (
            "      - name: Require both correctness workers\n"
            "        env:\n"
            "          SOURCE_CONTRACT_RESULT: ${{ needs.source-contract.result }}\n"
            "          TOOLING_TESTS_RESULT: ${{ needs.tooling-tests.result }}\n"
            "        run: |\n"
            "          test \"$SOURCE_CONTRACT_RESULT\" = success\n"
            "          test \"$TOOLING_TESTS_RESULT\" = success\n"
        )
        errors = validate_pr_workflow(VALID_PR_WORKFLOW.replace(result, ""))
        self.assertTrue(
            any("validate must use its exact ordered step mappings" in error for error in errors),
            errors,
        )


class HostedFullValidationContractTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.full = (ROOT / ".github/workflows/full-validation.yml").read_text(
            encoding="utf-8"
        )
        cls.nightly = (ROOT / ".github/workflows/nightly.yml").read_text(
            encoding="utf-8"
        )
        cls.release = (ROOT / ".github/workflows/release.yml").read_text(
            encoding="utf-8"
        )

    def assert_full_rejected(self, old: str, new: str) -> None:
        self.assertIn(old, self.full)
        self.assertTrue(validate_full_validation_workflow(self.full.replace(old, new, 1)))

    def assert_nightly_rejected(self, old: str, new: str) -> None:
        self.assertIn(old, self.nightly)
        self.assertTrue(validate_nightly_workflow(self.nightly.replace(old, new, 1)))

    def assert_release_rejected(self, old: str, new: str) -> None:
        self.assertIn(old, self.release)
        self.assertTrue(validate_release_workflow(self.release.replace(old, new, 1)))

    def test_repository_workflows_are_accepted(self) -> None:
        self.assertEqual(validate_full_validation_workflow(self.full), [])
        self.assertEqual(validate_nightly_workflow(self.nightly), [])
        self.assertEqual(validate_release_workflow(self.release), [])

    def test_shared_contract_requires_workflow_call_only(self) -> None:
        self.assert_full_rejected("  workflow_call:\n", "  workflow_dispatch:\n")

    def test_shared_contract_requires_both_typed_inputs(self) -> None:
        self.assert_full_rejected("        required: true\n", "        required: false\n")
        self.assert_full_rejected(
            "      authority:\n        required: true\n        type: string\n",
            "",
        )

    def test_shared_contract_rejects_authority_bypass(self) -> None:
        self.assert_full_rejected(
            '          if [[ "$AUTHORITY" != nightly && "$AUTHORITY" != release ]]; then\n',
            '          if [[ "$AUTHORITY" != nightly && "$AUTHORITY" != debug ]]; then\n',
        )
        self.assert_full_rejected("            exit 1\n", "            true\n")

    def test_shared_contract_rejects_permission_and_action_bypasses(self) -> None:
        self.assert_full_rejected("  contents: read\n", "  contents: write\n")
        self.assert_full_rejected(
            "actions/checkout@d23441a48e516b6c34aea4fa41551a30e30af803",
            "actions/checkout@v6",
        )

    def test_shared_contract_binds_every_checkout_to_the_exact_commit(self) -> None:
        self.assert_full_rejected("          ref: ${{ inputs.commit }}\n", "          ref: ${{ github.sha }}\n")

    def test_shared_contract_freezes_eight_page_matrix_and_parallelism(self) -> None:
        self.assert_full_rejected('  ASL_TEST_PAGE_COUNT: "8"\n', '  ASL_TEST_PAGE_COUNT: "7"\n')
        self.assert_full_rejected("      max-parallel: 8\n", "      max-parallel: 7\n")

    def test_shared_contract_binds_cache_to_all_toolchain_inputs(self) -> None:
        self.assert_full_rejected("scripts/prepare-aslref", "scripts/prepare-toolchain")

    def test_shared_contract_uploads_only_per_id_results(self) -> None:
        self.assert_full_rejected(
            "          path: build/asl-test-results/*/result.json\n",
            "          path: build/asl-test-results\n",
        )

    def test_shared_health_aggregation_is_exact_and_fail_closed(self) -> None:
        self.assert_full_rejected(
            '          test "$ASL_PAGE_RESULT" = success\n',
            '          test -n "$ASL_PAGE_RESULT"\n',
        )
        self.assert_full_rejected(
            "from scripts.asl_release_suite import aggregate_results, load_matrix_pages, load_results\n",
            "coverage = {'status': 'passed'}\n",
        )

    def test_shared_contract_rejects_extra_steps_and_jobs(self) -> None:
        self.assert_full_rejected(
            "      - name: Prove exact checked-out head\n",
            "      - run: true\n      - name: Prove exact checked-out head\n",
        )
        self.assert_full_rejected("  health:\n", "  bypass:\n    steps:\n      - run: true\n  health:\n")

    def test_release_is_manual_and_retains_exact_commit_input(self) -> None:
        self.assert_release_rejected("  workflow_dispatch:\n", "  schedule:\n")
        self.assert_release_rejected("        required: true\n", "        required: false\n")

    def test_release_calls_shared_validation_with_release_authority(self) -> None:
        self.assert_release_rejected("      authority: release\n", "      authority: nightly\n")
        self.assert_release_rejected(
            "    uses: ./.github/workflows/full-validation.yml\n",
            "    uses: attacker/repo/.github/workflows/full-validation.yml@main\n",
        )

    def test_release_alone_aggregates_and_prepares_canonical_evidence(self) -> None:
        self.assert_release_rejected("          make release-prepare\n", "")
        self.assert_release_rejected("          git diff --exit-code\n", "          true\n")
        self.assert_release_rejected("            spec/evidence/asl-test-matrix.sha256\n", "")

    def test_release_final_gate_is_fail_closed(self) -> None:
        self.assert_release_rejected(
            '          test "$FULL_VALIDATION_RESULT" = success\n',
            '          test -n "$FULL_VALIDATION_RESULT"\n',
        )

    def test_nightly_requires_schedule_and_manual_dispatch(self) -> None:
        self.assert_nightly_rejected('    - cron: "17 2 * * *"\n', "")
        self.assert_nightly_rejected("  workflow_dispatch:\n", "")

    def test_nightly_validates_the_exact_caller_workflow_commit(self) -> None:
        self.assertEqual(validate_nightly_workflow(WORKFLOW_SHA_NIGHTLY), [])

    def test_nightly_rejects_runtime_selected_origin_main_as_the_commit(self) -> None:
        runtime_selected = WORKFLOW_SHA_NIGHTLY.replace(
            '          echo "commit=$GITHUB_WORKFLOW_SHA" >> "$GITHUB_OUTPUT"\n',
            '          echo "commit=$(git rev-parse origin/main)" >> "$GITHUB_OUTPUT"\n',
        )
        self.assertTrue(validate_nightly_workflow(runtime_selected))

    def test_nightly_rejects_missing_origin_main_workflow_sha_equality(self) -> None:
        without_equality = WORKFLOW_SHA_NIGHTLY.replace(
            '          test "$(git rev-parse origin/main)" = "$GITHUB_WORKFLOW_SHA"\n',
            "",
        )
        self.assertTrue(validate_nightly_workflow(without_equality))

    def test_nightly_calls_shared_validation_without_release_authority(self) -> None:
        self.assert_nightly_rejected("      authority: nightly\n", "      authority: release\n")

    def test_nightly_has_read_only_permissions_and_no_release_mutation(self) -> None:
        self.assert_nightly_rejected("  contents: read\n", "  contents: write\n")
        for forbidden in (
            "make release-prepare",
            "spec/evidence/",
            "gh release",
            "git push",
        ):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, self.nightly)

    def test_nightly_final_health_gate_is_fail_closed(self) -> None:
        self.assert_nightly_rejected(
            '          test "$FULL_VALIDATION_RESULT" = success\n',
            '          test -n "$FULL_VALIDATION_RESULT"\n',
        )

    def test_readiness_keeps_nightly_non_authoritative(self) -> None:
        readiness = (ROOT / "spec/evidence/release-gate-readiness.json").read_text(
            encoding="utf-8"
        )
        self.assertIn('"publication_authority": false', readiness)
        self.assertIn('"publication_authority": true', readiness)
        self.assertIn(
            '"commit_selection": "caller-workflow-sha-equal-latest-origin-main"',
            readiness,
        )
        self.assertIn('"status": "ready-for-exact-head-verification"', readiness)
        self.assertNotIn('"candidate_evidence"', readiness)


class WorkflowInventoryAuthorityTest(unittest.TestCase):
    def run_checker_with_extra(
        self, name: str, workflow: str
    ) -> subprocess.CompletedProcess[str]:
        with tempfile.TemporaryDirectory() as directory:
            workflows = Path(directory)
            for source in sorted((ROOT / ".github/workflows").glob("*.y*ml")):
                shutil.copyfile(source, workflows / source.name)
            (workflows / name).write_text(workflow, encoding="utf-8")
            return subprocess.run(
                [str(WORKFLOW_CHECKER), "--workflows-dir", str(workflows)],
                cwd=ROOT,
                text=True,
                capture_output=True,
                check=False,
            )

    def assert_extra_rejected(self, name: str, body: str) -> None:
        workflow = f"""name: Unauthorized fixture
on:
  workflow_dispatch:
permissions:
  contents: read
jobs:
  fixture:
    runs-on: ubuntu-latest
    steps:
      - name: Exercise unauthorized capability
{body}
"""
        result = self.run_checker_with_extra(name, workflow)
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn(name, result.stderr)

    def test_canonical_workflow_inventory_is_accepted(self) -> None:
        result = subprocess.run(
            [str(WORKFLOW_CHECKER)],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_extra_yml_cannot_call_release_authority(self) -> None:
        workflow = """name: Unauthorized release caller
on:
  workflow_dispatch:
permissions:
  contents: read
jobs:
  fixture:
    uses: ./.github/workflows/full-validation.yml
    with:
      commit: ${{ github.sha }}
      authority: release
"""
        result = self.run_checker_with_extra("rogue-release.yml", workflow)
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("rogue-release.yml", result.stderr)

    def test_quoted_release_authority_cannot_bypass_inventory(self) -> None:
        for authority in ('"release"', "'release'", '"\\u0072elease"'):
            with self.subTest(authority=authority):
                workflow = f"""name: Unauthorized quoted release caller
on:
  workflow_dispatch:
permissions:
  contents: read
jobs:
  fixture:
    uses: ./.github/workflows/full-validation.yml
    with:
      commit: ${{{{ github.sha }}}}
      authority: {authority}
"""
                result = self.run_checker_with_extra("rogue-quoted.yml", workflow)
                self.assertNotEqual(result.returncode, 0, result.stdout)
                self.assertIn("rogue-quoted.yml", result.stderr)

    def test_inline_release_authority_cannot_bypass_inventory(self) -> None:
        workflow = """name: Unauthorized inline release caller
on:
  workflow_dispatch:
permissions:
  contents: read
jobs:
  fixture:
    uses: ./.github/workflows/full-validation.yml
    with: {commit: ${{ github.sha }}, authority: release}
"""
        result = self.run_checker_with_extra("rogue-inline.yml", workflow)
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("rogue-inline.yml", result.stderr)

    def test_json_flow_release_authority_cannot_bypass_inventory(self) -> None:
        workflow = r"""name: Unauthorized JSON flow release caller
on:
  workflow_dispatch:
permissions:
  contents: read
jobs:
  fixture:
    uses: ./.github/workflows/full-validation.yml
    with: {"commit":"${{ github.sha }}","authority":"release"}
"""
        result = self.run_checker_with_extra("rogue-json-authority.yml", workflow)
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("rogue-json-authority.yml", result.stderr)

    def test_json_list_with_value_is_rejected_fail_closed(self) -> None:
        workflow = r"""name: Invalid JSON list caller inputs
on:
  workflow_dispatch:
permissions:
  contents: read
jobs:
  fixture:
    uses: ./.github/workflows/full-validation.yml
    with: ["authority","release"]
"""
        result = self.run_checker_with_extra("rogue-list-with.yml", workflow)
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("rogue-list-with.yml", result.stderr)

    def test_single_quoted_flow_authority_fails_closed(self) -> None:
        workflow = r"""name: Unauthorized single-quoted flow caller
on:
  workflow_dispatch:
permissions:
  contents: read
jobs:
  fixture:
    uses: ./.github/workflows/full-validation.yml
    with: {'commit':'${{ github.sha }}','authority':'release'}
"""
        result = self.run_checker_with_extra("rogue-single-flow.yml", workflow)
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("rogue-single-flow.yml", result.stderr)

    def test_extra_yaml_cannot_prepare_release_evidence(self) -> None:
        self.assert_extra_rejected(
            "rogue-prepare.yaml",
            "        run: make release-prepare",
        )

    def test_escaped_quoted_run_command_cannot_bypass_inventory(self) -> None:
        self.assert_extra_rejected(
            "rogue-escaped-run.yml",
            r'        run: "make release-\u0070repare"',
        )

    def test_escaped_release_publication_command_cannot_bypass_inventory(self) -> None:
        self.assert_extra_rejected(
            "rogue-escaped-publish.yml",
            r'        run: "gh \u0072elease create v1 artifact.tar"',
        )

    def test_single_quoted_run_command_cannot_bypass_inventory(self) -> None:
        self.assert_extra_rejected(
            "rogue-single-run.yml",
            "        run: 'make release-prepare'",
        )

    def test_literal_run_block_cannot_bypass_inventory(self) -> None:
        self.assert_extra_rejected(
            "rogue-literal-run.yml",
            "        run: |\n"
            "          make release-prepare",
        )

    def test_json_list_run_value_is_rejected_fail_closed(self) -> None:
        self.assert_extra_rejected(
            "rogue-list-run.yml",
            '        run: ["make release-prepare"]',
        )

    def test_folded_run_block_is_rejected_fail_closed(self) -> None:
        self.assert_extra_rejected(
            "rogue-folded-run.yml",
            "        run: >\n"
            "          make release-prepare",
        )

    def test_extra_workflow_cannot_upload_canonical_release_evidence(self) -> None:
        self.assert_extra_rejected(
            "rogue-evidence.yml",
            "        uses: actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02\n"
            "        with:\n"
            "          name: pto-release-evidence-${{ github.sha }}\n"
            "          path: spec/evidence/asl-test-matrix.sha256",
        )

    def test_escaped_evidence_path_cannot_bypass_inventory(self) -> None:
        self.assert_extra_rejected(
            "rogue-escaped-evidence-path.yml",
            "        uses: actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02\n"
            "        with:\n"
            "          name: health-only\n"
            r'          path: "spec/\u0065vidence/asl-test-matrix.sha256"',
        )

    def test_escaped_evidence_name_cannot_bypass_inventory(self) -> None:
        self.assert_extra_rejected(
            "rogue-escaped-evidence-name.yml",
            "        uses: actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02\n"
            "        with:\n"
            r'          name: "pto-release-\u0065vidence-${{ github.sha }}"'
            "\n          path: build/health.json",
        )

    def test_extra_workflow_cannot_define_release_validate(self) -> None:
        workflow = """name: Unauthorized release check
on:
  workflow_dispatch:
permissions:
  contents: read
jobs:
  validate:
    name: Release / validate
    runs-on: ubuntu-latest
    steps:
      - run: true
"""
        result = self.run_checker_with_extra("rogue-validate.yml", workflow)
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("rogue-validate.yml", result.stderr)

    def test_escaped_release_validate_name_cannot_bypass_inventory(self) -> None:
        workflow = r"""name: Unauthorized escaped release check
on:
  workflow_dispatch:
permissions:
  contents: read
jobs:
  validate:
    name: "\u0052elease / validate"
    runs-on: ubuntu-latest
    steps:
      - run: true
"""
        result = self.run_checker_with_extra("rogue-escaped-validate.yml", workflow)
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("rogue-escaped-validate.yml", result.stderr)

    def test_extra_workflow_cannot_publish_release_or_tags(self) -> None:
        self.assert_extra_rejected(
            "rogue-publish.yml",
            "        run: gh release create v1 artifact.tar",
        )

    def test_extra_workflow_cannot_request_write_permissions(self) -> None:
        workflow = """name: Unauthorized write token
on:
  workflow_dispatch:
permissions:
  contents: write
jobs:
  fixture:
    runs-on: ubuntu-latest
    steps:
      - run: true
"""
        result = self.run_checker_with_extra("rogue-write.yml", workflow)
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("rogue-write.yml", result.stderr)

    def test_quoted_write_permission_cannot_bypass_inventory(self) -> None:
        workflow = """name: Unauthorized quoted write token
on:
  workflow_dispatch:
permissions:
  contents: "write"
jobs:
  fixture:
    runs-on: ubuntu-latest
    steps:
      - run: true
"""
        result = self.run_checker_with_extra("rogue-quoted-write.yml", workflow)
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("rogue-quoted-write.yml", result.stderr)

    def test_inline_write_permission_cannot_bypass_inventory(self) -> None:
        workflow = """name: Unauthorized inline write token
on:
  workflow_dispatch:
permissions: {contents: write}
jobs:
  fixture:
    runs-on: ubuntu-latest
    steps:
      - run: true
"""
        result = self.run_checker_with_extra("rogue-inline-write.yml", workflow)
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("rogue-inline-write.yml", result.stderr)

    def test_json_flow_escaped_write_permission_cannot_bypass_inventory(self) -> None:
        workflow = r"""name: Unauthorized JSON flow write token
on:
  workflow_dispatch:
permissions: {"contents":"\u0077rite"}
jobs:
  fixture:
    runs-on: ubuntu-latest
    steps:
      - run: true
"""
        result = self.run_checker_with_extra("rogue-json-write.yml", workflow)
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("rogue-json-write.yml", result.stderr)

    def test_json_list_permissions_are_rejected_fail_closed(self) -> None:
        workflow = r"""name: Invalid JSON list permissions
on:
  workflow_dispatch:
permissions: ["read","write"]
jobs:
  fixture:
    runs-on: ubuntu-latest
    steps:
      - run: true
"""
        result = self.run_checker_with_extra("rogue-list-permissions.yml", workflow)
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("rogue-list-permissions.yml", result.stderr)

    def test_combined_quoted_escaped_release_surface_is_rejected(self) -> None:
        workflow = r"""name: Unauthorized combined release surface
on:
  workflow_dispatch:
permissions: {"contents":"\u0077rite"}
jobs:
  fixture:
    name: "\u0052elease / validate"
    runs-on: ubuntu-latest
    steps:
      - uses: "actions/\u0063reate-release@0123456789abcdef0123456789abcdef01234567"
        with:
          name: "pto-release-\u0065vidence-${{ github.sha }}"
          path: "spec/\u0065vidence/asl-test-matrix.sha256"
      - run: "gh \u0072elease create v1 artifact.tar"
"""
        result = self.run_checker_with_extra("rogue-combined.yml", workflow)
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("rogue-combined.yml", result.stderr)

    def test_malformed_flow_collections_are_rejected_fail_closed(self) -> None:
        for name, mapping in (
            ("rogue-malformed-map.yml", '{"contents":"write"'),
            ("rogue-malformed-list.yml", '["read","write"'),
        ):
            with self.subTest(name=name):
                workflow = f"""name: Malformed flow collection
on:
  workflow_dispatch:
permissions: {mapping}
jobs:
  fixture:
    runs-on: ubuntu-latest
    steps:
      - run: true
"""
                result = self.run_checker_with_extra(name, workflow)
                self.assertNotEqual(result.returncode, 0, result.stdout)
                self.assertIn(name, result.stderr)
                self.assertIn("invalid structure", result.stderr)

    def test_duplicate_json_flow_keys_are_rejected_fail_closed(self) -> None:
        workflow = r"""name: Duplicate flow authority
on:
  workflow_dispatch:
permissions:
  contents: read
jobs:
  fixture:
    uses: ./.github/workflows/full-validation.yml
    with: {"commit":"${{ github.sha }}","authority":"release","authority":"nightly"}
"""
        result = self.run_checker_with_extra("rogue-duplicate-flow.yml", workflow)
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("rogue-duplicate-flow.yml", result.stderr)
        self.assertIn("invalid structure", result.stderr)


if __name__ == "__main__":
    unittest.main()
