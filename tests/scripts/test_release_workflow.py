from __future__ import annotations

import unittest

from scripts.release_workflow import validate_pr_workflow, validate_release_workflow


VALID_PR_WORKFLOW = r"""
name: PR
on:
  pull_request:
permissions:
  contents: read
jobs:
  validate:
    name: PR / validate
    steps:
      - run: |
          ./scripts/check-asl-layout
          ./scripts/check-ndf
          ./scripts/check-asl-tests
          python3 scripts/project_asl_catalogs.py --root . --check
          python3 scripts/instruction_docs.py --check
          python3 scripts/check-publication-hygiene
"""


VALID_RELEASE_WORKFLOW = r"""
name: Release verification
on:
  workflow_dispatch:
    inputs:
      commit:
        required: true
        type: string
permissions:
  contents: read
jobs:
  plan:
    outputs:
      pages: ${{ steps.matrix.outputs.pages }}
    steps:
      - env:
          COMMIT: ${{ inputs.commit }}
        run: '[[ "$COMMIT" =~ ^[0-9a-f]{40}$ ]]'
      - uses: actions/checkout@d23441a48e516b6c34aea4fa41551a30e30af803
        with:
          ref: ${{ inputs.commit }}
      - id: matrix
        run: |
          test "$(git rev-parse HEAD)" = "$COMMIT"
          make pr-check
          ./scripts/print-asl-test-matrix --page-size 100 --page 0
          echo 'pages=[0]' >> "$GITHUB_OUTPUT"
      - uses: actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02
        with:
          name: planned-asl-test-pages
  strict-model:
    needs: plan
    steps:
      - uses: ocaml/setup-ocaml@15d660006c1d3110d77c34b7faa3bddefe8b82f0
      - run: make setup
      - run: make toolchain-check check
  asl-page:
    needs: plan
    strategy:
      fail-fast: false
      matrix:
        page: ${{ fromJSON(needs.plan.outputs.pages) }}
    steps:
      - uses: actions/download-artifact@95815c38cf2ff2164869cbab79da8d1f422bc89e
        with:
          name: planned-asl-test-pages
      - run: make setup
      - run: |
          ./scripts/print-asl-test-matrix --page-size 100 --page "${{ matrix.page }}"
          cmp "build/planned-asl-test-pages/page-${{ matrix.page }}.json" "build/actual-page.json"
          printf '%s\\n' fixture \
            | xargs -P 8 -n 1 ./scripts/run-asl-test --id
      - uses: actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02
        with:
          name: asl-test-results-${{ matrix.page }}
          path: build/asl-test-results/*/result.json
  release-evidence:
    needs: [plan, strict-model, asl-page]
    steps:
      - uses: actions/download-artifact@95815c38cf2ff2164869cbab79da8d1f422bc89e
        with:
          pattern: asl-test-results-*
          merge-multiple: true
      - run: |
          ./scripts/run-asl-release-suite --commit "$COMMIT" --aggregate-only --matrix-pages build/planned-asl-test-pages --results build/asl-test-results
          git diff --exit-code
      - uses: actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02
        with:
          name: release-evidence
          path: |
            build/asl-test-matrix.json
            spec/evidence/asl-test-matrix.sha256
  validate:
    name: Release / validate
    if: always()
    needs: [plan, strict-model, asl-page, release-evidence]
    steps:
      - env:
          PLAN_RESULT: ${{ needs.plan.result }}
          STRICT_MODEL_RESULT: ${{ needs.strict-model.result }}
          ASL_PAGE_RESULT: ${{ needs.asl-page.result }}
          RELEASE_EVIDENCE_RESULT: ${{ needs.release-evidence.result }}
        run: |
          test "$PLAN_RESULT" = success
          test "$STRICT_MODEL_RESULT" = success
          test "$ASL_PAGE_RESULT" = success
          test "$RELEASE_EVIDENCE_RESULT" = success
"""


class PullRequestWorkflowContractTest(unittest.TestCase):
    def test_complete_lightweight_workflow_is_accepted(self) -> None:
        self.assertEqual(validate_pr_workflow(VALID_PR_WORKFLOW), [])

    def test_pr_workflow_rejects_aslref(self) -> None:
        errors = validate_pr_workflow(VALID_PR_WORKFLOW + "\n# make setup-aslref\n")
        self.assertTrue(any("ASLRef" in error for error in errors))

    def test_pr_workflow_requires_every_lightweight_gate(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace("          ./scripts/check-ndf\n", "")
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("check-ndf" in error for error in errors))


class ReleaseWorkflowContractTest(unittest.TestCase):
    def assert_rejected(self, workflow: str, expected: str) -> None:
        errors = validate_release_workflow(workflow)
        self.assertTrue(errors)
        self.assertTrue(any(expected in error for error in errors), errors)

    def test_complete_manual_workflow_is_accepted(self) -> None:
        self.assertEqual(validate_release_workflow(VALID_RELEASE_WORKFLOW), [])

    def test_exact_sha_validation_is_required(self) -> None:
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace(
                '[[ "$COMMIT" =~ ^[0-9a-f]{40}$ ]]', 'test -n "$COMMIT"'
            ),
            "40 lowercase hexadecimal",
        )

    def test_repository_derived_pages_are_required(self) -> None:
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace("./scripts/print-asl-test-matrix", "printf"),
            "print-asl-test-matrix",
        )

    def test_exact_page_comparison_is_required(self) -> None:
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace("          cmp ", "          true # cmp "),
            "compare",
        )

    def test_independent_runner_is_required(self) -> None:
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace("./scripts/run-asl-test --id", "true"),
            "run-asl-test --id",
        )

    def test_each_page_must_prepare_aslref_before_parallel_execution(self) -> None:
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace(
                "          name: planned-asl-test-pages\n      - run: make setup\n",
                "          name: planned-asl-test-pages\n",
            ),
            "prepare pinned ASLRef",
        )

    def test_aslref_preparation_must_be_a_standalone_run_step(self) -> None:
        for replacement in (
            "      # run: make setup\n",
            "      - run: echo make setup\n",
            "      - run: make setup || true\n",
            "      - run: false && make setup\n",
        ):
            with self.subTest(replacement=replacement):
                self.assert_rejected(
                    VALID_RELEASE_WORKFLOW.replace(
                        "      - run: make setup\n      - run: |\n",
                        replacement + "      - run: |\n",
                        1,
                    ),
                    "prepare pinned ASLRef",
                )

    def test_asl_pages_must_keep_eight_way_test_parallelism(self) -> None:
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace("xargs -P 8", "xargs -P 1"),
            "eight-way parallelism",
        )

    def test_parallel_pipeline_rejects_decoys_and_best_effort_execution(self) -> None:
        required = "            | xargs -P 8 -n 1 ./scripts/run-asl-test --id\n"
        for replacement in (
            "          # | xargs -P 8 -n 1 ./scripts/run-asl-test --id\n"
            "            | xargs -P 1 -n 1 ./scripts/run-asl-test --id\n",
            "          echo '| xargs -P 8 -n 1 ./scripts/run-asl-test --id'\n"
            "            | xargs -P 1 -n 1 ./scripts/run-asl-test --id\n",
            "            | xargs -P 8 -n 1 ./scripts/run-asl-test --id || true\n",
        ):
            with self.subTest(replacement=replacement):
                self.assert_rejected(
                    VALID_RELEASE_WORKFLOW.replace(required, replacement),
                    "eight-way parallelism",
                )

    def test_skipped_p8_pipeline_cannot_hide_real_serial_execution(self) -> None:
        required = (
            "          printf '%s\\\\n' fixture \\\n"
            "            | xargs -P 8 -n 1 ./scripts/run-asl-test --id\n"
        )
        replacement = (
            "          false && printf '%s\\\\n' fixture \\\n"
            "            | xargs -P 8 -n 1 ./scripts/run-asl-test --id\n"
            "          printf '%s\\\\n' fixture \\\n"
            "            | xargs -P 1 -n 1 ./scripts/run-asl-test --id\n"
        )
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace(required, replacement),
            "exactly one",
        )

    def test_fail_closed_aggregation_is_required(self) -> None:
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace(" --aggregate-only", ""),
            "aggregate-only",
        )

    def test_uploaded_evidence_must_include_matrix_and_checksum(self) -> None:
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace(
                "            build/asl-test-matrix.json\n", ""
            ),
            "matrix and its checksum",
        )

    def test_final_gate_must_require_every_job_success(self) -> None:
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace(
                'test "$ASL_PAGE_RESULT" = success', 'test -n "$ASL_PAGE_RESULT"'
            ),
            "ASL_PAGE_RESULT",
        )


if __name__ == "__main__":
    unittest.main()
