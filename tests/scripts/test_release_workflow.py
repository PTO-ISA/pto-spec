from __future__ import annotations

import unittest

from scripts.release_workflow import validate_pr_workflow, validate_release_workflow


def replace_last(source: str, old: str, new: str) -> str:
    before, separator, after = source.rpartition(old)
    if not separator:
        return source
    return before + new + after


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
          ./scripts/check-release-event-schema
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
  identity:
    timeout-minutes: 10
    steps:
      - env:
          COMMIT: ${{ inputs.commit }}
        run: '[[ "$COMMIT" =~ ^[0-9a-f]{40}$ ]]'
      - uses: actions/checkout@d23441a48e516b6c34aea4fa41551a30e30af803
        with:
          ref: ${{ inputs.commit }}
      - run: test "$(git rev-parse HEAD)" = "$COMMIT"
  pr-contract:
    needs: identity
    timeout-minutes: 45
    steps:
      - uses: actions/checkout@d23441a48e516b6c34aea4fa41551a30e30af803
        with:
          ref: ${{ inputs.commit }}
      - run: |
          test "$(git rev-parse HEAD)" = "$COMMIT"
          make pr-check
  matrix-plan:
    needs: identity
    timeout-minutes: 45
    outputs:
      pages: ${{ steps.matrix.outputs.pages }}
    steps:
      - uses: actions/checkout@d23441a48e516b6c34aea4fa41551a30e30af803
        with:
          ref: ${{ inputs.commit }}
      - id: matrix
        run: |
          test "$(git rev-parse HEAD)" = "$COMMIT"
          ./scripts/print-asl-test-matrix --page-size 100 --output-dir build/planned-asl-test-pages > build/asl-test-plan-index.json
          echo 'pages=[0]' >> "$GITHUB_OUTPUT"
      - uses: actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02
        with:
          name: planned-asl-test-pages
  strict-model:
    needs: identity
    timeout-minutes: 360
    steps:
      - uses: actions/checkout@d23441a48e516b6c34aea4fa41551a30e30af803
        with:
          ref: ${{ inputs.commit }}
      - uses: ocaml/setup-ocaml@15d660006c1d3110d77c34b7faa3bddefe8b82f0
        with:
          ocaml-compiler: "5.2.1"
          dune-cache: true
      - uses: actions/cache@55cc8345863c7cc4c66a329aec7e433d2d1c52a9
        with:
          path: .cache/herdtools7
          key: aslref-${{ runner.os }}-${{ runner.arch }}-ocaml-5.2.1-${{ hashFiles('.aslref-version', 'scripts/setup-aslref', 'scripts/prepare-aslref') }}
      - run: make setup
      - run: make toolchain-check check
  asl-page:
    needs: matrix-plan
    timeout-minutes: 360
    strategy:
      fail-fast: false
      matrix:
        page: ${{ fromJSON(needs.matrix-plan.outputs.pages) }}
    steps:
      - uses: actions/checkout@d23441a48e516b6c34aea4fa41551a30e30af803
        with:
          ref: ${{ inputs.commit }}
      - uses: actions/download-artifact@95815c38cf2ff2164869cbab79da8d1f422bc89e
        with:
          name: planned-asl-test-pages
      - uses: ocaml/setup-ocaml@15d660006c1d3110d77c34b7faa3bddefe8b82f0
        with:
          ocaml-compiler: "5.2.1"
          dune-cache: true
      - uses: actions/cache@55cc8345863c7cc4c66a329aec7e433d2d1c52a9
        with:
          path: .cache/herdtools7
          key: aslref-${{ runner.os }}-${{ runner.arch }}-ocaml-5.2.1-${{ hashFiles('.aslref-version', 'scripts/setup-aslref', 'scripts/prepare-aslref') }}
      - run: make setup
      - name: Execute independent ASL points with machine parallelism
        run: |
          set +e
          ASL_TEST_JOBS="${PTO_ASL_TEST_JOBS:-$(getconf _NPROCESSORS_ONLN)}"
          ./scripts/run-asl-page --matrix "build/planned-asl-test-pages/page-${{ matrix.page }}.json" -j "$ASL_TEST_JOBS"
          execution_status=$?
          set -e
          printf '%s\n' "$execution_status" > build/asl-page-execution.status
      - name: Report per-mnemonic results and enforce the page
        if: always()
        run: |
          set +e
          ./scripts/report-asl-page-results --matrix "build/planned-asl-test-pages/page-${{ matrix.page }}.json" --results build/asl-test-results
          report_status=$?
          set -e
          test -f build/asl-page-execution.status
          read -r execution_status < build/asl-page-execution.status
          test "$execution_status" = 0
          test "$report_status" = 0
      - uses: actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02
        with:
          name: asl-test-results-${{ matrix.page }}
          path: build/asl-test-results/*/result.json
  release-evidence:
    needs: [pr-contract, matrix-plan, strict-model, asl-page]
    timeout-minutes: 45
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
    needs: [identity, pr-contract, matrix-plan, strict-model, asl-page, release-evidence]
    timeout-minutes: 10
    steps:
      - env:
          IDENTITY_RESULT: ${{ needs.identity.result }}
          PR_CONTRACT_RESULT: ${{ needs.pr-contract.result }}
          MATRIX_PLAN_RESULT: ${{ needs.matrix-plan.result }}
          STRICT_MODEL_RESULT: ${{ needs.strict-model.result }}
          ASL_PAGE_RESULT: ${{ needs.asl-page.result }}
          RELEASE_EVIDENCE_RESULT: ${{ needs.release-evidence.result }}
        run: |
          test "$IDENTITY_RESULT" = success
          test "$PR_CONTRACT_RESULT" = success
          test "$MATRIX_PLAN_RESULT" = success
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

    def test_pr_workflow_requires_release_event_schema_gate(self) -> None:
        workflow = VALID_PR_WORKFLOW.replace(
            "          ./scripts/check-release-event-schema\n", ""
        )
        errors = validate_pr_workflow(workflow)
        self.assertTrue(any("check-release-event-schema" in error for error in errors))


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

    def test_page_rediscovery_is_rejected(self) -> None:
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace(
                "      - name: Execute independent ASL points with machine parallelism\n",
                "      - run: ./scripts/print-asl-test-matrix --page-size 100 --page 0\n"
                "      - name: Execute independent ASL points with machine parallelism\n",
            ),
            "without rediscovery",
        )

    def test_independent_runner_is_required(self) -> None:
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace("./scripts/run-asl-page", "true"),
            "run-asl-page",
        )

    def test_each_page_must_prepare_aslref_before_parallel_execution(self) -> None:
        self.assert_rejected(
            replace_last(VALID_RELEASE_WORKFLOW, "      - run: make setup\n", ""),
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
                    replace_last(
                        VALID_RELEASE_WORKFLOW,
                        "      - run: make setup\n",
                        replacement,
                    ),
                    "prepare pinned ASLRef",
                )

    def test_asl_pages_require_explicit_configurable_parallelism(self) -> None:
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace(' -j "$ASL_TEST_JOBS"', ""),
            "-j configurable parallelism",
        )

    def test_parallelism_defaults_to_machine_core_count_with_override(self) -> None:
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace(
                '          ASL_TEST_JOBS="${PTO_ASL_TEST_JOBS:-$(getconf _NPROCESSORS_ONLN)}"\n',
                '          ASL_TEST_JOBS="4"\n',
            ),
            "machine core count",
        )

    def test_page_report_must_run_after_parallel_execution(self) -> None:
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace(
                '          ./scripts/report-asl-page-results --matrix "build/planned-asl-test-pages/page-${{ matrix.page }}.json" --results build/asl-test-results\n',
                "",
            ),
            "report every ASL page",
        )

    def test_execution_and_report_statuses_must_both_fail_closed(self) -> None:
        for line, expected in (
            ('          test "$execution_status" = 0\n', "execution status"),
            ('          test "$report_status" = 0\n', "report status"),
        ):
            with self.subTest(line=line):
                self.assert_rejected(VALID_RELEASE_WORKFLOW.replace(line, ""), expected)

    def test_status_capture_must_be_immediately_after_each_command(self) -> None:
        for command, status in (
            (
                '          ./scripts/run-asl-page --matrix "build/planned-asl-test-pages/page-${{ matrix.page }}.json" -j "$ASL_TEST_JOBS"\n',
                "          execution_status=$?\n",
            ),
            (
                '          ./scripts/report-asl-page-results --matrix "build/planned-asl-test-pages/page-${{ matrix.page }}.json" --results build/asl-test-results\n',
                "          report_status=$?\n",
            ),
        ):
            with self.subTest(command=command):
                self.assert_rejected(
                    VALID_RELEASE_WORKFLOW.replace(
                        command + status, command + "          true\n" + status
                    ),
                    "separate contiguous fail-closed",
                )

    def test_page_report_is_a_distinct_always_run_step(self) -> None:
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace("        if: always()\n", ""),
            "distinct always-run step",
        )

    def test_fail_closed_aggregation_is_required(self) -> None:
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace(" --aggregate-only", ""),
            "aggregate-only",
        )

    def test_asl_pages_upload_only_compact_result_json_artifacts(self) -> None:
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace(
                "          path: build/asl-test-results/*/result.json\n",
                "          path: build/asl-test-results\n",
            ),
            "only per-ID result.json",
        )

    def test_compact_decoy_cannot_hide_broad_real_result_upload(self) -> None:
        real_upload = """      - uses: actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02
        with:
          name: asl-test-results-${{ matrix.page }}
          path: build/asl-test-results/*/result.json
"""
        decoy_and_broad_upload = """      - uses: actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02
        with:
          name: compact-decoy
          path: build/asl-test-results/*/result.json
      - uses: actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02
        with:
          name: asl-test-results-${{ matrix.page }}
          path: build/asl-test-results
"""
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace(real_upload, decoy_and_broad_upload),
            "only per-ID result.json",
        )

    def test_upload_action_comment_decoy_cannot_spoof_real_uses_key(self) -> None:
        real_upload = """      - uses: actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02
        with:
          name: asl-test-results-${{ matrix.page }}
          path: build/asl-test-results/*/result.json
"""
        spoofed_upload = """      - uses: attacker/not-upload-artifact@0123456789abcdef0123456789abcdef01234567
        # actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02
        with:
          name: asl-test-results-${{ matrix.page }}
          path: build/asl-test-results/*/result.json
"""
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace(real_upload, spoofed_upload),
            "only per-ID result.json",
        )

    def test_env_name_decoy_cannot_spoof_upload_with_inputs(self) -> None:
        real_upload = """      - uses: actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02
        with:
          name: asl-test-results-${{ matrix.page }}
          path: build/asl-test-results/*/result.json
"""
        spoofed_upload = """      - uses: actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02
        env:
          name: asl-test-results-${{ matrix.page }}
        with:
          name: ignored-by-release-download-${{ matrix.page }}
          path: build/asl-test-results/*/result.json
"""
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace(real_upload, spoofed_upload),
            "only per-ID result.json",
        )

    def test_extra_broad_result_namespace_upload_is_rejected(self) -> None:
        real_upload = """      - uses: actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02
        with:
          name: asl-test-results-${{ matrix.page }}
          path: build/asl-test-results/*/result.json
"""
        compact_and_broad_uploads = (
            real_upload
            + """      - uses: actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02
        with:
          name: asl-test-results-broad-${{ matrix.page }}
          path: build/asl-test-results
"""
        )
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace(real_upload, compact_and_broad_uploads),
            "only per-ID result.json",
        )

    def test_extra_broad_upload_with_unpinned_action_ref_is_rejected(self) -> None:
        real_upload = """      - uses: actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02
        with:
          name: asl-test-results-${{ matrix.page }}
          path: build/asl-test-results/*/result.json
"""
        compact_and_unpinned_broad_uploads = (
            real_upload
            + """      - uses: actions/upload-artifact@v4
        with:
          name: asl-test-results-broad-${{ matrix.page }}
          path: build/asl-test-results
"""
        )
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace(
                real_upload, compact_and_unpinned_broad_uploads
            ),
            "only per-ID result.json",
        )

    def test_extra_quoted_broad_upload_action_is_rejected(self) -> None:
        real_upload = """      - uses: actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02
        with:
          name: asl-test-results-${{ matrix.page }}
          path: build/asl-test-results/*/result.json
"""
        for quote in ('"', "'"):
            with self.subTest(quote=quote):
                quoted_broad_upload = (
                    real_upload
                    + f"""      - uses: {quote}actions/upload-artifact@v4{quote}
        with:
          name: asl-test-results-broad-${{{{ matrix.page }}}}
          path: build/asl-test-results
"""
                )
                self.assert_rejected(
                    VALID_RELEASE_WORKFLOW.replace(real_upload, quoted_broad_upload),
                    "only per-ID result.json",
                )

    def test_escaped_quoted_upload_action_is_rejected(self) -> None:
        real_upload = """      - uses: actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02
        with:
          name: asl-test-results-${{ matrix.page }}
          path: build/asl-test-results/*/result.json
"""
        for escaped_action in (
            r"actions/upload-artifact\u0040v4",
            r"action\u0073/upload-artifact@v4",
        ):
            with self.subTest(escaped_action=escaped_action):
                escaped_broad_upload = (
                    real_upload
                    + f'''      - uses: "{escaped_action}"
        with:
          name: asl-test-results-broad-${{{{ matrix.page }}}}
          path: build/asl-test-results
'''
                )
                self.assert_rejected(
                    VALID_RELEASE_WORKFLOW.replace(real_upload, escaped_broad_upload),
                    "uses values",
                )

    def test_yaml_alias_cannot_inject_broad_result_upload(self) -> None:
        for anchor in ("broad_result_upload", "1"):
            with self.subTest(anchor=anchor):
                anchored_upload_job = f"""  upload-template:
    steps:
      - &{anchor}
        uses: actions/upload-artifact@v4
        with:
          name: asl-test-results-broad-${{{{ matrix.page }}}}
          path: build/asl-test-results
"""
                workflow = VALID_RELEASE_WORKFLOW.replace(
                    "  asl-page:\n", anchored_upload_job + "  asl-page:\n"
                ).replace(
                    "          path: build/asl-test-results/*/result.json\n",
                    "          path: build/asl-test-results/*/result.json\n"
                    f"      - *{anchor}\n",
                )
                self.assert_rejected(workflow, "anchors or aliases")

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

    def test_independent_release_gates_start_directly_after_identity(self) -> None:
        for job in ("pr-contract", "matrix-plan", "strict-model"):
            workflow = VALID_RELEASE_WORKFLOW.replace(
                f"  {job}:\n    needs: identity\n",
                f"  {job}:\n    needs: matrix-plan\n",
            )
            with self.subTest(job=job):
                self.assert_rejected(workflow, "directly after identity")

    def test_every_release_job_requires_an_explicit_timeout(self) -> None:
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace("    timeout-minutes: 45\n", "", 1),
            "explicit timeout",
        )

    def test_toolchain_cache_action_must_be_commit_pinned(self) -> None:
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace(
                "actions/cache@55cc8345863c7cc4c66a329aec7e433d2d1c52a9",
                "actions/cache@v5",
                1,
            ),
            "commit-pinned verified ASLRef cache",
        )

    def test_cache_key_must_bind_toolchain_inputs(self) -> None:
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace("scripts/prepare-aslref", "prepare", 1),
            "pin, and setup scripts",
        )

    def test_release_evidence_waits_for_pr_contract(self) -> None:
        self.assert_rejected(
            VALID_RELEASE_WORKFLOW.replace(
                "needs: [pr-contract, matrix-plan, strict-model, asl-page]",
                "needs: [matrix-plan, strict-model, asl-page]",
            ),
            "pr-contract dependency",
        )


if __name__ == "__main__":
    unittest.main()
