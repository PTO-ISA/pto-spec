# NDF Governance and Manual Release Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make PTO architecture PRs use a fast structural gate while preserving complete, fail-closed ASL verification and coverage in an exact-head manually dispatched release workflow.

**Architecture:** ASL remains the only current architecture source. A small Python NDF parser validates stable ASL clause regions and their generated Markdown projections; `make pr-check` runs only repository-local lightweight checks, while `make release-verify` and a manual GitHub workflow run pinned ASLRef, all runtime shards, release evidence, and documentation verification. Git history and decision metadata preserve provenance; the current tree contains no legacy specification copies.

**Tech Stack:** ASL1, Python 3 standard library and `unittest`, GNU Make, Bash, GitHub Actions YAML, MkDocs.

## Global Constraints

- Do not add a package or external runtime dependency.
- Do not run OCaml/opam or ASLRef in the pull-request workflow.
- Do not weaken, skip, or reinterpret any release verification or coverage failure.
- Tie release verification to one exact 40-character commit SHA.
- ASL owns current normative semantics; generated Markdown may not diverge.
- Delete legacy specification copies from the current tree; Git is the archive.
- Keep the existing instruction encodings unchanged.

---

### Task 1: Isolate and fix the failed TLOAD default-binding shard

**Files:**
- Modify: `tests/asl/bundle-tests.asl:741-781`
- Modify: `tests/asl/shards/core-bundle.asl:20-30`
- Create: `tests/asl/shards/bundle-scalar-defaults.asl`
- Modify: `Makefile:88-132`

**Interfaces:**
- Consumes: `BundleOperationBindingsComplete(operation)` and `AddBundleTileBinding(...)`.
- Produces: `make test-shard-bundle-scalar-defaults` and a 53-shard matrix.

- [x] **Step 1: Preserve the exact failing reproduction**

Record that hosted run `31189236482` failed at the omitted TLOAD assertion because the fixture called:

```asl
AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, FALSE, 0, 0, TRUE);
```

The fifth argument incorrectly declares a tile source for TLOAD.

- [x] **Step 2: Create a dedicated shard**

```asl
func main() => integer
begin
    ResetProfileState();
    TestBundleScalarBindingSchemaDefaults();
    return 0;
end;
```

Add the shard and its `tests/asl/bundle-tests.asl` library to the Make matrix, then remove the function call from `core-bundle.asl`.

- [x] **Step 3: Implement the minimal fixture correction**

For the omitted, encoded-zero, and explicit-stride TLOAD cases, set both tile source-valid arguments to `FALSE`:

```asl
AddBundleTileBinding(TRUE, 0, 1, '1111', FALSE, FALSE, 0, 0, TRUE);
```

Do not change the TLOAD catalog, encoding, scalar defaults, or execution logic.

- [x] **Step 4: Verify the split and focused target**

Run:

```bash
./scripts/check-asl-test-shards
make build/pto-tests-bundle-scalar-defaults.asl
git diff --check
```

Expected: 53 shards partition all canonical calls; assembly and diff checks pass. The full dynamic target remains a release-lane check if local strict typecheck exceeds the interactive validation window.

- [x] **Step 5: Commit**

```bash
git add Makefile tests/asl/bundle-tests.asl tests/asl/shards/core-bundle.asl tests/asl/shards/bundle-scalar-defaults.asl
git commit -m "test: isolate and correct TLOAD bundle defaults"
```

### Task 2: Add ASL-backed NDF clauses and a fail-closed checker

**Files:**
- Create: `scripts/ndf.py`
- Create: `scripts/check-ndf`
- Create: `tests/scripts/test_ndf.py`
- Modify: `scripts/instruction_docs.py`
- Modify: `tests/scripts/test_instruction_docs.py`
- Modify: `asl/architecture.asl`
- Modify: generated `docs/instructions/**`
- Create: `docs/open/index.md`

**Interfaces:**
- Produces: `parse_ndf_regions(text: str, source: Path) -> tuple[NdfClause, ...]`.
- Produces: `check_repository(root: Path) -> list[str]`.
- Produces: `./scripts/check-ndf` with exit 0 only when IDs, metadata, references, and projections are valid.

- [x] **Step 1: Write parser and repository-check tests first**

Add literal fixtures proving:

```python
VALID = """// NDF-BEGIN: PTO-TILE-CAPACITY
// ndf: kind=contract level=L1 layer=tile status=accepted
// Tile capacity is defined per selected PE.
// NDF-END: PTO-TILE-CAPACITY
"""

def test_rejects_duplicate_clause_ids(self):
    self.write("asl/architecture.asl", VALID)
    self.write("asl/tile/state.asl", VALID)
    self.assertIn("duplicate NDF clause PTO-TILE-CAPACITY", check_repository(self.root))

def test_rejects_unknown_cross_reference(self):
    self.write(
        "asl/architecture.asl",
        VALID.replace("selected PE.", "selected PE; see [[PTO-MISSING]]."),
    )
    self.assertIn("unknown NDF reference PTO-MISSING", check_repository(self.root))

def test_accepts_one_asl_owned_clause(self):
    self.write("asl/architecture.asl", VALID)
    self.assertEqual(check_repository(self.root), [])
```

The same test module includes literal mismatched-end, invalid-metadata,
normative-Markdown, legacy-path, and backup-path fixtures using the shared
`write(relative: str, text: str) -> Path` helper.

Run:

```bash
python3 -m unittest tests.scripts.test_ndf -v
```

Expected: FAIL because `scripts.ndf` does not exist.

- [x] **Step 2: Implement the NDF parser**

Recognize exact ASL regions:

```text
// NDF-BEGIN: PTO-...
// ndf: kind=<intent|contract|mechanism|executable> level=<L0|L1|L2|L3> layer=<architecture|scalar|block|tile|state|memory|concurrency> status=<open|accepted>
// ... clause text with optional [[PTO-...]] references
// NDF-END: PTO-...
```

Require IDs matching `PTO-[A-Z0-9]+(?:-[A-Z0-9]+)*`, unique IDs, matched boundaries, one metadata line, nonempty body, and resolvable references. Reject tracked paths containing `legacy`, `archive`, `.bak`, `.old`, `~`, or version-suffixed backup names below active ASL/docs trees.

- [x] **Step 3: Seed architecture-wide ASL clauses**

Add NDF regions in `asl/architecture.asl` for the source hierarchy, per-PE tile capacity, and manual release boundary. The clauses point to executable L3 functions rather than restating their algorithms.

- [x] **Step 4: Project NDF identity into instruction pages**

Derive each instruction clause ID from surface and mnemonic, for example `PTO-INST-TILE-TLOAD`, and render this generated heading near the ASL source marker:

```markdown
## Normative identity {#PTO-INST-TILE-TLOAD}
<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->
```

The identity must be deterministic and collision-checked by `instruction_docs.py`.

- [x] **Step 5: Verify and commit**

Run:

```bash
python3 -m unittest tests.scripts.test_ndf tests.scripts.test_instruction_docs -v
./scripts/check-ndf
python3 scripts/instruction_docs.py --check
git diff --check
```

Expected: all pass.

```bash
git add scripts/ndf.py scripts/check-ndf tests/scripts/test_ndf.py scripts/instruction_docs.py tests/scripts/test_instruction_docs.py asl/architecture.asl docs/instructions docs/open/index.md docs/mkdocs/generated-nav.yml
git commit -m "feat: enforce ASL-backed NDF clauses"
```

### Task 3: Build the lightweight PR gate

**Files:**
- Create: `scripts/check-pr`
- Create: `tests/scripts/test_check_pr.py`
- Modify: `Makefile:208-260`
- Replace: `.github/workflows/asl.yml`

**Interfaces:**
- Produces: `make pr-check`.
- Produces: one GitHub required check named `PR / validate`.

- [x] **Step 1: Add a subprocess contract test**

Test the observable Make command plan:

```python
result = subprocess.run(
    ["make", "--no-print-directory", "-n", "pr-check"],
    cwd=ROOT,
    check=True,
    text=True,
    capture_output=True,
)
self.assertIn("./scripts/check-pr", result.stdout)
for forbidden in ("opam", "setup-aslref", "aslref", "release-verify"):
    self.assertNotIn(forbidden, result.stdout.lower())
```

Run:

```bash
python3 -m unittest tests.scripts.test_check_pr -v
```

Expected: FAIL before the script exists.

- [x] **Step 2: Implement `scripts/check-pr`**

Use fail-fast Bash to run:

```bash
./scripts/check-ndf
./scripts/check-repository --structure-only
./scripts/check-asl-test-shards
python3 -m unittest discover -s tests/scripts -p 'test_*.py'
python3 scripts/instruction_docs.py --check
python3 scripts/check-publication-hygiene
git diff --check
```

`check-repository --structure-only` is invoked directly so the PR lane validates
tracked repository structure without inheriting the `$(SPEC)` Make prerequisite
or any strict-model checks that execute ASLRef.

- [x] **Step 3: Add Make targets**

```make
pr-check:
	./scripts/check-pr
```

Keep existing compatibility targets, but make `ci` an alias for `pr-check` so ordinary contributors do not accidentally start a release verification.

- [x] **Step 4: Replace the PR workflow**

Make `.github/workflows/asl.yml` run on `pull_request` and pushes to `main`, with one Ubuntu job:

```yaml
jobs:
  validate:
    name: PR / validate
    steps:
      - uses: actions/checkout@d23441a48e516b6c34aea4fa41551a30e30af803
      - run: make pr-check
```

Retain read-only permissions and concurrency cancellation. Do not add OCaml setup or ASL matrix jobs.

- [x] **Step 5: Verify and commit**

Run:

```bash
python3 -m unittest tests.scripts.test_check_pr -v
make pr-check
git diff --check
```

Expected: all pass and no ASLRef process starts.

```bash
git add scripts/check-pr tests/scripts/test_check_pr.py Makefile .github/workflows/asl.yml
git commit -m "ci: keep pull request validation lightweight"
```

### Task 4: Add exact-head manual release verification

**Files:**
- Create: `.github/workflows/release.yml`
- Create: `scripts/check-release-workflow`
- Create: `tests/scripts/test_release_workflow.py`
- Modify: `Makefile:208-260`

**Interfaces:**
- Produces: `make release-verify` for local sequential verification.
- Produces: manual workflow input `commit` containing exactly 40 lowercase hexadecimal characters.
- Produces: final check `Release / validate` that depends on repository, strict-model, and every shard job.

- [ ] **Step 1: Write workflow contract tests**

Implement fixture-based tests for
`validate_release_workflow(text: str) -> list[str]`. A complete literal workflow
fixture must be accepted. Independently remove the exact-SHA check, strict-model
dependency, shard matrix, or explicit equality-to-success expression and assert
the validator returns the matching error. This tests release safety behavior
rather than an exact checked-in YAML spelling.

Run:

```bash
python3 -m unittest tests.scripts.test_release_workflow -v
```

Expected: FAIL because the workflow does not exist.

- [ ] **Step 2: Implement local release orchestration**

Add:

```make
release-verify: pr-check release-check toolchain-check check test-shards

release-prepare:
	./scripts/generate-release-manifest
	./scripts/check-release-manifest
	git diff --exit-code
```

`release-verify` never creates a tag. `release-prepare` proves regenerated release artifacts leave the candidate tree clean.

- [ ] **Step 3: Implement manual GitHub workflow**

Use separate jobs:

- `plan`: validate and checkout exact input SHA, run `make pr-check`, export shard JSON;
- `strict-model`: pinned OCaml and ASLRef, then `make toolchain-check check`;
- `asl-shard`: full matrix with `fail-fast: false` so every shard result is recorded;
- `release-evidence`: regenerate/check manifest and upload evidence artifacts;
- `validate`: `if: always()` and explicit equality-to-success checks for all dependencies.

Do not create the release or tag in this first workflow. A later explicit publication step may consume only a successful exact-head run.

- [ ] **Step 4: Verify and commit**

Run:

```bash
python3 -m unittest tests.scripts.test_release_workflow -v
./scripts/check-release-workflow
make pr-check
git diff --check
```

Expected: all pass.

```bash
git add .github/workflows/release.yml scripts/check-release-workflow tests/scripts/test_release_workflow.py Makefile
git commit -m "ci: add exact-head manual release verification"
```

### Task 5: Replace governance surfaces and remove legacy copies

**Files:**
- Replace: `.github/ISSUE_TEMPLATE/formal-model-change.yml`
- Modify: `.github/PULL_REQUEST_TEMPLATE.md`
- Modify: `CONTRIBUTING.md`
- Modify: `GOVERNANCE.md`
- Modify: `README.md`
- Modify: `AGENTS.md`
- Delete: `docs/legacy/**`
- Modify: `docs/mkdocs/mkdocs.yml`

**Interfaces:**
- Consumes: `make pr-check`, `make release-verify`, and stable NDF IDs.
- Produces: NDF architecture issue and PR review contracts with no reference to the old required hosted ASL gate.

- [ ] **Step 1: Replace the architecture issue template**

Require baseline commit, affected clause IDs, normative delta, defaults and unspecified behavior, compatibility/toolchain impact, open questions, verification evidence, and release impact. Rename the visible template to `NDF architecture change` while preserving the file path to avoid a second obsolete template.

- [ ] **Step 2: Replace the PR checklist**

Require linked issue, changed clause IDs, source owner, regenerated projections, focused tests, `make pr-check`, and explicit declaration that full ASL verification is deferred to manual release.

- [ ] **Step 3: Update repository guidance**

Document the two lanes and source lookup order:

```text
ASL owner -> generated instruction page -> decision/open metadata -> release evidence
```

Remove statements that every PR must pass the full hosted `validate` ASL matrix.

- [ ] **Step 4: Delete legacy content and repair links**

Delete `docs/legacy/` entirely. Regenerate MkDocs navigation and use publication/link checks to find any remaining references. Do not relocate the old prose elsewhere.

- [ ] **Step 5: Verify and commit**

Run:

```bash
make pr-check
python3 -m mkdocs build --strict --config-file docs/mkdocs/mkdocs.yml
git diff --check
```

Expected: all pass and `git ls-files docs/legacy` prints nothing.

```bash
git add -A .github CONTRIBUTING.md GOVERNANCE.md README.md AGENTS.md docs
git commit -m "docs: adopt NDF architecture change governance"
```

### Task 6: Final exact-head review, push, and dispatch

**Files:**
- Verify only; no planned source edits.

**Interfaces:**
- Consumes: clean branch HEAD and GitHub authentication.
- Produces: pushed branch exact SHA and manual Release workflow run URL.

- [ ] **Step 1: Run final lightweight verification**

```bash
make pr-check
python3 -m mkdocs build --strict --config-file docs/mkdocs/mkdocs.yml
git diff --check
git status --short
```

Expected: all checks pass and worktree is clean.

- [ ] **Step 2: Audit the workflow boundary**

```bash
rg -n 'opam|setup-aslref|aslref|test-shard' .github/workflows/asl.yml
rg -n 'workflow_dispatch|setup-ocaml|toolchain-check|test-shard|Release / validate' .github/workflows/release.yml
```

Expected: the first command has no matches; the second shows every heavy release component.

- [ ] **Step 3: Push with exact lease**

Fetch the remote branch, verify its observed head, then push the reviewed local head with `--force-with-lease=<branch>:<observed-head>` only if rebasing the already-reviewed unique delta is required. Otherwise use a normal fast-forward push.

- [ ] **Step 4: Dispatch manual release verification**

After the branch is merged to `main`, fetch the exact main SHA and run:

```bash
release_commit=$(git rev-parse origin/main)
gh workflow run release.yml --repo PTO-ISA/pto-spec -f commit="$release_commit"
```

Return the new run URL and current status without waiting synchronously for long hosted ASL jobs. Do not publish a tag or release until `Release / validate` succeeds for that exact SHA.
