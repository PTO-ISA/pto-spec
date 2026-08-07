from __future__ import annotations

import unittest

from scripts.release_workflow import validate_release_workflow


VALID_WORKFLOW = r"""
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
      shards: ${{ steps.shards.outputs.matrix }}
    steps:
      - name: Validate exact commit
        env:
          COMMIT: ${{ inputs.commit }}
        run: '[[ "$COMMIT" =~ ^[0-9a-f]{40}$ ]]'
      - uses: actions/checkout@d23441a48e516b6c34aea4fa41551a30e30af803
        with:
          ref: ${{ inputs.commit }}
      - run: |
          test "$(git rev-parse HEAD)" = "$COMMIT"
          make pr-check
      - id: shards
        run: make print-asl-test-shard-names && echo "matrix=[]" >> "$GITHUB_OUTPUT"
  strict-model:
    needs: plan
    steps:
      - uses: ocaml/setup-ocaml@15d660006c1d3110d77c34b7faa3bddefe8b82f0
      - run: make setup
      - run: make toolchain-check check
  asl-shard:
    needs: plan
    strategy:
      fail-fast: false
      matrix:
        shard: ${{ fromJSON(needs.plan.outputs.shards) }}
    steps:
      - run: make "test-shard-${{ matrix.shard }}"
  release-evidence:
    needs: [plan, strict-model, asl-shard]
    steps:
      - run: make release-prepare
      - uses: actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02
  validate:
    name: Release / validate
    if: always()
    needs: [plan, strict-model, asl-shard, release-evidence]
    steps:
      - env:
          PLAN_RESULT: ${{ needs.plan.result }}
          STRICT_MODEL_RESULT: ${{ needs.strict-model.result }}
          ASL_SHARD_RESULT: ${{ needs.asl-shard.result }}
          RELEASE_EVIDENCE_RESULT: ${{ needs.release-evidence.result }}
        run: |
          test "$PLAN_RESULT" = success
          test "$STRICT_MODEL_RESULT" = success
          test "$ASL_SHARD_RESULT" = success
          test "$RELEASE_EVIDENCE_RESULT" = success
"""


class ReleaseWorkflowContractTest(unittest.TestCase):
    def assert_rejected(self, workflow: str, expected: str) -> None:
        errors = validate_release_workflow(workflow)
        self.assertTrue(errors)
        self.assertTrue(
            any(expected in error for error in errors),
            f"expected {expected!r} in {errors!r}",
        )

    def test_complete_manual_workflow_is_accepted(self) -> None:
        self.assertEqual(validate_release_workflow(VALID_WORKFLOW), [])

    def test_exact_sha_validation_is_required(self) -> None:
        self.assert_rejected(
            VALID_WORKFLOW.replace('[[ "$COMMIT" =~ ^[0-9a-f]{40}$ ]]', "test -n \"$COMMIT\""),
            "40 lowercase hexadecimal",
        )

    def test_final_gate_must_depend_on_strict_model(self) -> None:
        self.assert_rejected(
            VALID_WORKFLOW.replace(
                "needs: [plan, strict-model, asl-shard, release-evidence]",
                "needs: [plan, asl-shard, release-evidence]",
                1,
            ),
            "strict-model dependency",
        )

    def test_shard_matrix_is_required(self) -> None:
        self.assert_rejected(
            VALID_WORKFLOW.replace("shard: ${{ fromJSON(needs.plan.outputs.shards) }}", "shard: core"),
            "exact shard matrix",
        )

    def test_explicit_success_comparison_is_required(self) -> None:
        self.assert_rejected(
            VALID_WORKFLOW.replace(
                'test "$STRICT_MODEL_RESULT" = success',
                'test -n "$STRICT_MODEL_RESULT"',
            ),
            "STRICT_MODEL_RESULT",
        )


if __name__ == "__main__":
    unittest.main()
