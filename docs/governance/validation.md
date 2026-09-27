# Validation

This page owns the operator guide to repository validation. Executable
authority remains in the Make targets, scripts, and pinned workflows.

## Lane meanings

| Lane | Trigger and commit binding | Contract |
| --- | --- | --- |
| Pull request | Push or pull request head | `PR / validate` requires both lightweight correctness workers; it checks source structure, projections, formal review field completeness, live README inventory, script tests, workflow policy, and diff hygiene without claiming full-model or release readiness |
| Nightly | Schedule or dispatch, after proving the workflow commit equals latest `origin/main` | Reuses full validation as non-authoritative health; `Nightly / health` requires exact latest-`main` identity and the complete model |
| Release | Dispatch with one full lowercase PTO-SPEC commit SHA | Reuses full validation with release authority, aggregates the exact ASL AVS result set, certifies same-run PTO-SPEC artifacts, and requires `Release / validate` for that exact commit |

Nightly results are diagnostic. Pull-request results establish merge readiness
only. Release results can support release eligibility but do not create a tag,
release, or publication.

## Release execution order

The release workflow starts with candidate preflight: the exact clean PTO-SPEC
checkout, workflow commit, manifest identity, and pinned PTO NDF and ASLRef
dependencies must agree before ASLRef validation starts.

After preflight succeeds, full ASL validation uses 16 balanced pages; nightly
health retains 8 pages. Release evidence aggregation waits for the complete
ASL result set. LLVM-to-ASL acceptance runs in ASL-MODEL's own checks, and the
site has its own workflow. Neither is a PTO-SPEC release prerequisite.

The workflow downloads its preflight and ASL evidence, certifies their exact
commit and complete result set, and requires the certification digest in
`Release / validate`. A green workflow is directly consumable by
`scripts/prepare-release-publication`. Validation results are produced afresh
for each candidate.

Preflight and artifact certification write diagnostics when their runners reach
those steps; full validation records per-page results and health when available.
An evidence job can be skipped after a failed prerequisite, so diagnostics may
be partial or absent. Read the complete terminal failure set before preparing
a repair. Diagnostic artifacts cannot substitute for passing evidence. The
[release guide](../releases/index.md)
owns the read-only `scripts/prepare-release-publication` handoff after hosted
verification succeeds.

The independent Site workflow checks source, build, and browser paths. A
separate site publication pipeline must enforce Lighthouse quality budgets
before deployment; the current Site workflow does not produce a deployable
preview. Neither result certifies PTO-SPEC ASL semantics.

The older integrated 0.58.6 release run `33946824280` took 73.7 minutes,
including LLVM/model and site work. Its timing is historical and is not a
performance target for the PTO-only release lane.

## Local commands

Fast pull-request feedback needs Git, GNU Make, and Python 3.11+:

```bash
make pr-check
git diff --check
```

Hosted PR validation runs two fail-closed workers concurrently. Locally,
`make pr-check` runs source/projection contracts followed by isolated Python
test modules, which run in bounded parallelism. Each command reports elapsed time,
and the Python runner prints the slowest modules. Use
`PTO_PYTHON_TEST_JOBS=<N>` to set its bounded module-level parallelism. The
default is at most four workers. To diagnose one lane independently, run:

```bash
./scripts/check-pr --source
./scripts/check-pr --tooling
```

Use `scripts/prepare-pr --base origin/main --head HEAD` to prepare the agent
review handoff and impact-specific checks. This is an alternative entry to the
raw commands above: execute each check once per candidate, reusing a fresh passing
result for the exact same inputs. Formal review metadata is checked
without ASLRef; it does not prove that an independent reviewer executed. The
[contribution guide](../../CONTRIBUTING.md#agent-handoff) owns that operation.
`make repo-check` additionally checks binary closure and is appropriate when
that contract changes. Release-only projection tests stay in the release lane.

README inventory is generated from live catalogs and ASL owners by
`scripts/generate-readme-inventory`. Regenerate it when those inputs change.
Its check performs no network access or exhaustive AVS matrix discovery.

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
`.aslref-version` commit. The release commands validate the strict assembled
model, execute the complete test matrix, and reproduce registered evidence.
Hosted PTO-SPEC release verification requires only the exact PTO-SPEC candidate.
It rejects missing, failed, skipped, timed-out, stale, or unknown ASL cases and
incomplete same-run evidence. Downstream ELF identity and model closure are
validated by their owning repositories.

[`spec/model-closure-selection.json`](../../spec/model-closure-selection.json)
records the downstream compiler/model adoption baseline and mandatory family
canaries. ASL-MODEL owns execution cases for changed instruction identities;
LLVM owns negative MC/LLD obligations. These records do not substitute for
PTO-SPEC release evidence and do not block its hosted release lane.

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
