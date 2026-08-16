# Release Workflow Performance Implementation Plan

> **For agentic workers:** Execute this plan inline with the repository's normal
> edit-test-verify loop. The user explicitly prohibited subagent execution for
> this work. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make exact-head release verification faster and easier to diagnose without weakening matrix completeness, per-ID isolation, strict ASL execution, or fail-closed aggregation.

**Architecture:** Export every deterministic matrix page from one repository discovery, execute each page from its exact artifact, and prepare immutable decoder/model/validation inputs once per page. Reshape the GitHub Actions DAG so independent gates overlap, retain machine-sized `-j`, and add stable console and step-summary reporting.

**Tech Stack:** Python 3 standard library, Bash, GNU Make, GitHub Actions YAML, ASLRef.

## Global Constraints

- Preserve exact 40-hex commit checkout and clean exact-set/hash aggregation.
- Preserve one independent result JSON per ASL test ID.
- Preserve `fail-fast: false`, `if: always()` reporting, and final explicit job-result checks.
- Preserve machine-sized `-j` with `PTO_ASL_TEST_JOBS` override.
- Do not add dependencies or create a tag/GitHub Release.
- Use only short unit/workflow checks during implementation; do not synchronously run the hosted ASL release suite.

---

### Task 1: One-pass deterministic matrix page export

**Files:**
- Modify: `scripts/asl_tests.py`
- Modify: `scripts/print-asl-test-matrix`
- Modify: `tests/scripts/test_asl_tests.py`

**Interfaces:**
- Produces: `matrix_pages(entries, commit, page_size) -> list[dict[str, object]]`
- Produces: `export_matrix_pages(root, output_dir, page_size) -> dict[str, object]`
- CLI: `print-asl-test-matrix --page-size N --output-dir DIR` writes all pages and prints a compact index containing `pages`, `page_count`, `test_count`, and `commit`.

- [ ] **Step 1: Write failing tests for one discovery and complete page export**

```python
def test_all_pages_export_discovers_repository_once(self) -> None:
    with mock.patch("scripts.asl_tests._repository", return_value=fixture_repository()) as discover:
        index = export_matrix_pages(self.root, self.root / "pages", page_size=2)
    self.assertEqual(discover.call_count, 1)
    self.assertEqual(index["pages"], [0, 1])
    self.assertEqual(load_matrix_pages(self.root / "pages", self.commit), expected_entries)
```

- [ ] **Step 2: Run the focused test and verify RED**

Run: `python3 -m unittest tests.scripts.test_asl_tests.AslTestsTest.test_all_pages_export_discovers_repository_once -v`

Expected: FAIL because `export_matrix_pages` is absent.

- [ ] **Step 3: Implement one-pass export and stable round-robin assignment**

```python
def matrix_pages(entries, commit, page_size):
    page_count = max(1, math.ceil(len(entries) / page_size))
    return [
        matrix_page_document(commit, page, page_count, entries[page::page_count])
        for page in range(page_count)
    ]
```

Write each document atomically below the requested directory and print only the compact index to stdout.

- [ ] **Step 4: Run focused matrix tests and verify GREEN**

Run: `python3 -m unittest tests.scripts.test_asl_tests -v`

- [ ] **Step 5: Commit the self-contained matrix export change**

```bash
git add scripts/asl_tests.py scripts/print-asl-test-matrix tests/scripts/test_asl_tests.py
git commit -m "perf: export release matrix pages in one pass"
```

### Task 2: Page execution without per-ID repository discovery

**Files:**
- Modify: `scripts/asl_tests.py`
- Modify: `scripts/asl_release_suite.py`
- Modify: `tests/scripts/test_run_asl_release_suite.py`
- Modify: `tests/scripts/test_run_asl_page.py`

**Interfaces:**
- Produces: `execution_point(entry: Mapping[str, object]) -> AslExecutionPoint`
- Produces: `prepare_page_inputs(root, entries, timeout_seconds) -> PreparedPageInputs`
- Extends: `execute_test_point(..., model_path=None, validation_path=None)` so prepared immutable inputs skip decoder/model/shard regeneration.

- [ ] **Step 1: Write failing tests proving page-level preparation happens once**

```python
def test_execute_matrix_prepares_model_once_and_runs_entries_directly(self) -> None:
    entries = [MATRIX[0], {**MATRIX[0], "id": MATRIX[0]["id"] + "-2"}]
    with mock.patch("scripts.asl_release_suite.prepare_page_inputs") as prepare:
        execute_matrix(self.root, entries, jobs=2, point_runner=record_point)
    prepare.assert_called_once()
    self.assertEqual(recorded_ids, [MATRIX[0]["id"], MATRIX[0]["id"] + "-2"])
```

Also assert that no command contains `scripts/run-asl-test --id`.

- [ ] **Step 2: Run focused tests and verify RED**

Run: `python3 -m unittest tests.scripts.test_run_asl_release_suite tests.scripts.test_run_asl_page -v`

Expected: FAIL because page preparation/direct point execution is absent.

- [ ] **Step 3: Implement exact matrix-entry validation and page-local preparation**

Validate every required entry field and file SHA. Generate source order, decoder, and base model once. Generate each unique validation shard once, verify its closure hash, and store read-only paths in `PreparedPageInputs`.

- [ ] **Step 4: Execute points in the existing thread pool using prepared inputs**

```python
def run_one(test_id: str) -> int:
    point = execution_point(planned[test_id])
    return execute_test_point(
        root,
        point,
        model_path=prepared.model_path,
        validation_path=prepared.validation_paths[point.validation_entrypoint],
    )
```

Each invocation keeps its own final `test.asl`, ASLRef process, log, timeout, and result JSON.

- [ ] **Step 5: Run focused execution tests and verify GREEN**

Run: `python3 -m unittest tests.scripts.test_run_asl_release_suite tests.scripts.test_run_asl_page tests.scripts.test_asl_tests -v`

- [ ] **Step 6: Commit the page-local preparation change**

```bash
git add scripts/asl_tests.py scripts/asl_release_suite.py tests/scripts/test_run_asl_release_suite.py tests/scripts/test_run_asl_page.py
git commit -m "perf: reuse model inputs across ASL page tests"
```

### Task 3: Pretty console and GitHub summaries

**Files:**
- Modify: `scripts/asl_release_suite.py`
- Modify: `scripts/asl_tests.py`
- Modify: `scripts/report-asl-page-results`
- Modify: `tests/scripts/test_run_asl_release_suite.py`
- Modify: `tests/scripts/test_asl_tests.py`

**Interfaces:**
- Produces stable console records: `PASS|FAIL|TIMEOUT|ERROR display-name [id] duration`.
- Produces a page summary with total, passed, failed, elapsed time, and slowest five points.
- Writes the corresponding compact Markdown table to `GITHUB_STEP_SUMMARY`.

- [ ] **Step 1: Write failing output tests**

```python
def test_pretty_page_summary_reports_counts_and_slowest_points(self) -> None:
    output = io.StringIO()
    pretty_page_summary(results, elapsed_seconds=12.5, output=output)
    self.assertIn("2 passed, 1 failed", output.getvalue())
    self.assertIn("Slowest", output.getvalue())
```

- [ ] **Step 2: Run focused tests and verify RED**

Run: `python3 -m unittest tests.scripts.test_run_asl_release_suite tests.scripts.test_asl_tests -v`

- [ ] **Step 3: Implement deterministic pretty output**

Sort the slowest table by descending duration then ID. Do not use terminal color when `NO_COLOR` is set or output is not a TTY. Never truncate test identity or failure status.

- [ ] **Step 4: Run focused reporter tests and verify GREEN**

Run: `python3 -m unittest tests.scripts.test_run_asl_release_suite tests.scripts.test_asl_tests -v`

- [ ] **Step 5: Commit pretty reporting**

```bash
git add scripts/asl_release_suite.py scripts/asl_tests.py scripts/report-asl-page-results tests/scripts/test_run_asl_release_suite.py tests/scripts/test_asl_tests.py
git commit -m "feat: improve ASL release progress reporting"
```

### Task 4: Parallel GitHub release DAG and verified cache

**Files:**
- Modify: `.github/workflows/release.yml`
- Modify: `scripts/release_workflow.py`
- Modify: `tests/scripts/test_release_workflow.py`

**Interfaces:**
- Workflow jobs: `identity`, `pr-contract`, `matrix-plan`, `strict-model`, `asl-page`, `release-evidence`, `validate`.
- Matrix output: `needs.matrix-plan.outputs.pages`.
- Cache key binds runner OS/architecture, OCaml `5.2.1`, `.aslref-version`, `setup-aslref`, and `prepare-aslref`.

- [ ] **Step 1: Write failing workflow-contract tests**

```python
def test_release_gates_start_after_identity_instead_of_serial_plan(self) -> None:
    self.assertEqual(validate_release_workflow(VALID_RELEASE_WORKFLOW), [])
    self.assertIn("needs: identity", job_block("pr-contract"))
    self.assertIn("needs: identity", job_block("matrix-plan"))
    self.assertIn("needs: identity", job_block("strict-model"))
```

Add negative fixtures for missing timeouts, unpinned cache action, missing cache validation, missing final dependency, and returning to serial per-page matrix generation.

- [ ] **Step 2: Run workflow tests and verify RED**

Run: `python3 -m unittest tests.scripts.test_release_workflow -v`

- [ ] **Step 3: Implement the parallel DAG and one-pass matrix command**

Keep all action references pinned to full SHAs. Give every nontrivial job an explicit timeout. Keep `fail-fast: false`, machine-sized `-j`, always-run reporting, compact result upload, and final explicit status checks.

- [ ] **Step 4: Add verified dependency caching**

Restore/save only toolchain dependency/build paths. After restoration, always run `make setup` or an exact pin/clean verification target plus `make toolchain-check`; a cache hit never bypasses a release gate.

- [ ] **Step 5: Run workflow tests and verify GREEN**

Run: `python3 -m unittest tests.scripts.test_release_workflow -v`

- [ ] **Step 6: Commit workflow optimization**

```bash
git add .github/workflows/release.yml scripts/release_workflow.py tests/scripts/test_release_workflow.py
git commit -m "ci: parallelize exact-head release verification"
```

### Task 5: Close release provenance and run short verification

**Files:**
- Regenerate: `spec/evidence/release-gate-readiness.json`
- Regenerate: `spec/release-manifest.json`
- Modify only if required by ownership checks: `scripts/generate-release-gate-readiness`

**Interfaces:**
- Existing `make pr-check` and `make release-evidence-check` remain the short authoritative gates.

- [ ] **Step 1: Regenerate workflow-owned release evidence**

Run:

```bash
./scripts/generate-release-gate-readiness
./scripts/generate-release-manifest
```

- [ ] **Step 2: Run focused syntax and unit checks**

Run:

```bash
python3 -m unittest \
  tests.scripts.test_asl_tests \
  tests.scripts.test_run_asl_release_suite \
  tests.scripts.test_run_asl_page \
  tests.scripts.test_release_workflow -v
python3 -m py_compile \
  scripts/asl_tests.py \
  scripts/asl_release_suite.py \
  scripts/release_workflow.py \
  scripts/print-asl-test-matrix \
  scripts/run-asl-page \
  scripts/report-asl-page-results
ruff check scripts/asl_tests.py scripts/asl_release_suite.py scripts/release_workflow.py tests/scripts
```

- [ ] **Step 3: Run repository-level short gates**

Run:

```bash
make pr-check
make release-evidence-check
git diff --check
git status --short
```

- [ ] **Step 4: Verify performance structure without running the full suite**

Generate all pages once, confirm 3178 exact entries are recovered by `load_matrix_pages`, inspect that the command performs one repository discovery, and run a small fixture page with `-j 2` to prove direct prepared execution and pretty reporting.

- [ ] **Step 5: Commit regenerated evidence and final integration changes**

```bash
git add spec/evidence/release-gate-readiness.json spec/release-manifest.json
git commit -m "chore: refresh optimized release evidence"
```
