# Release Workflow Performance Design

## Objective

Reduce exact-head release verification latency while preserving the existing
normative guarantees:

- the requested 40-hex commit is the checked-out commit;
- the repository-derived ASL matrix is complete and deterministic;
- every independent test point produces one exact result;
- missing, duplicate, mismatched, skipped, timed-out, or failed results reject;
- strict-model and release-evidence gates remain mandatory;
- page execution keeps machine-sized `-j` parallelism;
- verification never creates a tag or GitHub Release.

## Considered approaches

### A. Remove repeated work and improve the DAG (selected)

Generate every matrix page in one repository scan, start independent release
gates concurrently, load each page plan once, and prepare immutable model inputs
once per page. Preserve one result per test ID and the final exact-set aggregate.

This gives the largest speedup without weakening the evidence model.

### B. Increase `max-parallel` only

This is simple, but it multiplies repeated repository scans, decoder generation,
model assembly, and toolchain setup. It can increase runner cost and contention
without reducing the serial planning path. It is not sufficient by itself.

### C. Replace independent points with coarse aggregate tests

This would be faster, but it would remove per-ID isolation, diagnostics, and
exact result equality. It is rejected because release evidence quality is more
important than raw throughput.

## Selected architecture

### One-pass exact matrix export

`print-asl-test-matrix` gains an all-pages output mode. It performs repository
discovery and coverage validation once, then writes every deterministic page,
an index containing the page numbers, and a complete matrix checksum. The
single-page mode remains available for local inspection.

Each page contains the exact commit, page number, page count, total test count,
and exact matrix entries. Aggregation continues to require complete page
numbering and exact test/result set equality.

### Parallel release DAG

The workflow is split into these jobs:

1. `identity`: validate and check out the requested exact commit.
2. `pr-contract`: run the lightweight repository contract.
3. `matrix-plan`: export all deterministic pages in one pass.
4. `strict-model`: prepare the pinned toolchain and validate the normative model.
5. `asl-page`: execute matrix pages with `-j` machine parallelism.
6. `release-evidence`: wait for all required gates and aggregate exact results.
7. `validate`: always run and require every gate to report success.

`pr-contract`, `matrix-plan`, and `strict-model` may run concurrently after the
identity gate. `asl-page` depends on the matrix plan. Evidence generation waits
for the PR contract, strict model, and every ASL page.

### Page-local immutable preparation

`run-asl-page` consumes the exact page entries directly. It does not launch a
child that re-discovers the entire repository for every ID.

Before parallel point execution, it prepares once per page:

- ASL source order;
- normative decoder;
- assembled base PTO model;
- each distinct validation shard used by the page.

Every shard hash is checked against the exact page entry before execution. Each
test still receives its own assembled test file, ASLRef process, result directory,
result JSON, timeout, and pass/fail status.

### Pretty output and diagnostics

Console output uses stable, readable records with:

- page progress and total count;
- `PASS`, `FAIL`, `TIMEOUT`, or `ERROR` status;
- mnemonic-derived display name and independent ID;
- elapsed time;
- a final page summary with passed/failed counts and slowest points.

GitHub step summaries present the same information as a compact Markdown table.
Failures remain visible even when page execution returns nonzero.

### Cache boundary

Pinned OCaml/opam/ASLRef dependencies may be cached using a key derived from the
runner platform, OCaml version, `.aslref-version`, and setup scripts. Restored
cache content is never accepted as evidence by itself: exact ASLRef commit,
clean state, executable presence, and toolchain canaries are rechecked.

### Timeouts and load balancing

Every workflow job has an explicit timeout. Each point has a bounded timeout
that can be overridden for diagnostics. Stable round-robin page assignment is
preferred over contiguous ID slices to reduce mnemonic/category clustering.
Historical durations may be emitted as non-normative performance evidence, but
must never change matrix membership or release correctness.

Within each fixed page, the runner may submit likely expensive points first
using a deterministic estimate derived from that page's exact test and
validation text, including full-reset and loop markers. This ordering hint does
not change page membership, matrix bytes, per-ID isolation, result ordering, or
the final exact-set aggregate. Prior PASS results and machine-specific timing
history are not scheduling authority.

## Testing strategy

Regression tests must prove:

- all-pages export performs one repository discovery and writes complete pages;
- page numbering, commit binding, matrix membership, and hashes remain exact;
- page execution does not perform per-ID repository discovery;
- base decoder/model and each validation shard are prepared once per page;
- parallel execution still honors `-j` and emits one result per ID;
- pretty output reports status, identity, duration, counts, and failures;
- workflow DAG starts PR contract, matrix planning, and strict model independently;
- final validation still rejects any missing or unsuccessful job;
- timeout, cache verification, and action pinning remain fail-closed.

Short unit and workflow-contract tests are used during implementation. The full
hosted ASL release suite is not run synchronously during development; it is
dispatched only after the optimized exact head is committed and reviewed.
