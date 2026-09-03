# Validation

This page owns the human description of repository validation. Executable
authority remains in the Make targets, scripts, and pinned workflows.

## Lane meanings

| Lane | Trigger and commit binding | Contract |
| --- | --- | --- |
| Pull request | Push or pull request head | `PR / validate` requires both lightweight correctness workers; it checks source structure, projections, script tests, documentation, workflow policy, and diff hygiene without claiming full-model or release readiness |
| Nightly | Schedule or dispatch, after proving the workflow commit equals latest `origin/main` | Reuses full validation as non-authoritative health; `Nightly / health` requires exact latest-`main` identity and the complete model |
| Release | Dispatch with one full lowercase commit SHA | Reuses full validation with release authority, aggregates the exact AVS result set, regenerates evidence, and requires `Release / validate` for that same commit |

Nightly results are diagnostic. Pull-request results establish merge readiness
only. Release results can support release eligibility but do not create a tag,
release, or publication.

## Local commands

Fast pull-request feedback needs Git, GNU Make, and Python 3.11+:

```bash
make pr-check
make repo-check
git diff --check
```

`make pr-check` runs two fail-closed lanes concurrently: source/projection
contracts and isolated Python test modules. Each command reports elapsed time,
and the Python runner prints the slowest modules. Use
`PTO_PYTHON_TEST_JOBS=<N>` to set its bounded module-level parallelism. The
default is at most four workers. To diagnose one lane independently, run:

```bash
./scripts/check-pr --source
./scripts/check-pr --tooling
```

For a focused ASL rerun, list exact stable IDs and execute the resulting page
with host-sized parallelism:

```bash
printf '%s\n' \
  PTO-AVS-BLOCK-B-SUBVIEW-ENCODING-001 \
  PTO-AVS-BLOCK-B-ASSEMBLE-ENCODING-001 \
  > build/asl-focused-ids.txt
./scripts/print-asl-test-matrix \
  --ids-file build/asl-focused-ids.txt \
  > build/asl-focused-page.json
./scripts/run-asl-page \
  --matrix build/asl-focused-page.json \
  -j "$(getconf _NPROCESSORS_ONLN)"
```

Focused selection defaults to one complete page, ignores blank and comment
lines, rejects duplicate or unknown IDs, and lazily generates only the
validation shards required by the selected points. Full release planning still
discovers and validates the complete repository matrix. Generated exhaustive
coverage keeps one case per result file; multi-case runtime shards are not an
accepted optimization.

Full verification additionally needs OCaml, opam, network access for the pinned
ASLRef checkout, and enough time to execute every AVS point:

```bash
make setup
make release-verify
make release-prepare
```

`make setup` verifies the `.aslref-origin` repository and prepares the exact
`.aslref-version` commit. The
release commands validate the strict assembled model, execute the complete test
matrix, and reproduce registered evidence.

## Fail-closed rules

- A pending, skipped, cancelled, failed, stale, or different-commit result is
  not success.
- Missing commands, artifacts, matrix pages, or per-ID results fail the lane.
- A generator check reports drift; it never silently accepts hand-edited output.
- A canary that is expected to fail is proof that rejection works. Do not weaken
  it to make a lane pass.
- Generated `build/` and `.cache/` output remains untracked.
- Commands that write the same shared `build/` artifact must run sequentially.
  Independent PR lanes, isolated Python test modules, and ASL point execution
  may use bounded parallelism.

Use `scripts/generate-review-summary --base REF --head REF` to enumerate the
merge-base semantic delta. The report is a deterministic review aid, not a
replacement for the owning sources or exact-head validation.
