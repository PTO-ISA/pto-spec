# Validation

This page owns the operator guide to repository validation. Executable
authority remains in the Make targets, scripts, and pinned workflows.

## Lane meanings

| Lane | Trigger and commit binding | Contract |
| --- | --- | --- |
| Pull request | Push or pull request head | `PR / validate` requires both lightweight correctness workers; it checks source structure, projections, formal review field completeness, live README inventory, script tests, workflow policy, and diff hygiene without claiming full-model or release readiness |
| Nightly | Schedule or dispatch, after proving the workflow commit equals latest `origin/main` | Reuses full validation as non-authoritative health; `Nightly / health` requires exact latest-`main` identity and the complete model |
| Release | Dispatch with full lowercase PTO-SPEC, LLVM, and ASL-MODEL commit SHAs | Reuses full validation with release authority, aggregates the exact ASL AVS result set, builds NDF release impact, compiles the ASL-MODEL corpus with the exact LLVM candidate, runs every selected ELF twice through the exact ASLRef model, and requires `Release / validate` for the complete version tuple |

Nightly results are diagnostic. Pull-request results establish merge readiness
only. Release results can support release eligibility but do not create a tag,
release, or publication.

## Release execution order

The release workflow starts with candidate preflight: exact clean checkouts,
manifest freshness, LLVM identity, pinned dependencies and downstream AVS
obligations must agree before LLVM or ASLRef builds start. The imported
ASL-MODEL PTO graph remains an explicit baseline, distinct from the runtime
candidate.

After preflight succeeds, full ASL validation, LLVM-to-ASL closure and site
validation run in parallel. Release evidence aggregation waits for the complete
ASL result set; the final gate requires all workers and artifact digests.
LLVM build caches follow the LLVM commit and host tool/configuration fingerprint;
the other build caches follow their own dependency pins. Validation results are
produced afresh for each candidate.

Each release worker writes a diagnostic status summary even after an earlier
step fails, while the runner is still available. Read those summaries and the
complete terminal failure set before preparing a repair. Diagnostic artifacts
cannot substitute for passing evidence. The [release guide](../releases/index.md)
owns the read-only `scripts/prepare-release-publication` handoff after hosted
verification succeeds.

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
`.aslref-version` commit. The
release commands validate the strict assembled model, execute the complete test
matrix, and reproduce registered evidence. Hosted release verification also
needs the exact LLVM and ASL-MODEL candidates. It rejects mismatched ELF
`.note.pto.isa` identities, incomplete impact coverage, differing semantic
payload digests, and failed, skipped, timed-out, stale, or unknown cases.

[`spec/model-closure-selection.json`](../../spec/model-closure-selection.json)
fixes the 0.58.5 compiler/model adoption baseline and mandatory family
canaries. Pre-adoption changes remain historical backlog rather than being
misrepresented as per-instruction runtime coverage. Every instruction identity
added, changed, or moved after that immutable baseline is selected by NDF impact
and requires an explicit ASL-MODEL execution case before release. Removed and
superseded encodings remain compiler-owned negative MC/LLD obligations and may
not be represented as successful model execution.

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
