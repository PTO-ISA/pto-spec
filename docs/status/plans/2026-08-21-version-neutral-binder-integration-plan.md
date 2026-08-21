# Version-neutral binder integration implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `executing-plans` to implement this plan task-by-task. The current task requires inline execution; do not dispatch subagents.

**Goal:** Integrate the B.IOT/B.IOS `SizeCode` and `PEMode` architecture without assigning or relabeling a release version.

**Architecture:** ASL, generated documentation, catalogs, and mnemonic-owned tests describe the current development architecture. Published release metadata remains an immutable snapshot until the later consolidated release change. Binary closure therefore has an architecture-only mode for ordinary repository checks and an additional release mode that links the current encoding projection to the release manifest.

**Tech Stack:** ASL1, Python 3, Bash, JSON/TOML projections, Make, GitHub Actions.

## Global constraints

- ASL is the sole formal architecture source.
- `specification.toml` and all published release-owned artifacts remain identical to the PR base.
- Active ADR/NDF text contains no release version, future version, or publication-order rule.
- Tests remain below the existing mirrored `tests/asl/{arch,block,scalar,tile}` taxonomy.
- Every new binder test path, ID, source, and purpose names B.IOT or B.IOS explicitly.
- Ordinary checks never treat stale release evidence as current architecture evidence.
- Release-only checks remain fail-closed and require an exact architecture-to-manifest match.
- Do not start a release workflow, generate a tag, or publish a release.

---

### Task 1: Lock the architecture/release boundary with failing tests

**Files:**
- Create: `tests/scripts/test_architecture_release_boundary.py`
- Modify: `tests/scripts/test_release_closure.py`
- Test: `tests/scripts/test_architecture_release_boundary.py`
- Test: `tests/scripts/test_release_closure.py`

**Interfaces:**
- Consumes: current `Makefile`, `scripts/check-repository`, `scripts/check-binary-closure`, `specification.toml`, and ADR 0069.
- Produces: executable policy checks that later tasks must satisfy.

- [ ] **Step 1: Add a failing version-neutral ADR check**

Create a test that reads `docs/status/decisions/0069-b-iot-b-ios-sizecode-pemode.md` and rejects release-owned language:

```python
FORBIDDEN_ADR_PATTERNS = (
    r"\b0\.\d+(?:\.\d+)?\b",
    r"post-0\.",
    r"encoding_abi",
    r"Merge gate:",
    r"must not merge until",
)

def test_binder_adr_is_version_neutral(self) -> None:
    text = ADR.read_text(encoding="utf-8")
    for pattern in FORBIDDEN_ADR_PATTERNS:
        self.assertNotRegex(text, pattern)
```

- [ ] **Step 2: Add failing release-ownership composition checks**

Require ordinary checks to use architecture-only binary closure and release checks to use release mode:

```python
def test_ordinary_repository_check_excludes_release_manifest(self) -> None:
    checker = REPOSITORY_CHECK.read_text(encoding="utf-8")
    self.assertIn("./scripts/check-binary-closure", checker)
    self.assertNotIn("./scripts/check-release-manifest", checker)
    self.assertNotIn("generate-release-traceability-readiness", checker)

def test_release_gate_requires_manifest_linkage(self) -> None:
    makefile = MAKEFILE.read_text(encoding="utf-8")
    self.assertIn("./scripts/check-binary-closure --release", makefile)
    self.assertIn("./scripts/check-release-manifest", makefile)
```

- [ ] **Step 3: Restore the release-identity test expectation**

Change `test_release_identity_is_0590_and_owns_current_evidence` back to the current published-release expectation from `origin/main`. Do not introduce a future identifier.

- [ ] **Step 4: Run the focused tests and prove they fail for the intended reasons**

Run:

```bash
python3 -m unittest \
  tests.scripts.test_architecture_release_boundary \
  tests.scripts.test_release_closure
```

Expected: failures report the versioned ADR, ordinary release-manifest coupling, missing `--release` linkage, and changed release identity.

- [ ] **Step 5: Commit the red policy tests**

```bash
git add -- \
  tests/scripts/test_architecture_release_boundary.py \
  tests/scripts/test_release_closure.py
git commit -m "test: lock version-neutral architecture integration"
```

---

### Task 2: Separate development binary closure from release closure

**Files:**
- Modify: `scripts/check-binary-closure`
- Modify: `scripts/check-repository`
- Modify: `Makefile`
- Test: `tests/scripts/test_architecture_release_boundary.py`

**Interfaces:**
- Consumes: scalar and command form catalogs plus `spec/release-manifest.json`.
- Produces: `check_architecture_binary()` for current forms and `check_release_linkage()` for release-only identity linkage; CLI flag `--release` selects both checks.

- [ ] **Step 1: Parse an explicit release-only flag**

Add this CLI shape to `scripts/check-binary-closure`:

```python
import argparse

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--release",
        action="store_true",
        help="also require the published release manifest to match current encodings",
    )
    return parser.parse_args()
```

- [ ] **Step 2: Keep current-form closure version-neutral**

Move form loading, unique-ID validation, form-count validation, and fingerprint validation into:

```python
def check_architecture_binary() -> str:
    # Return the validated SHA-256 fingerprint for the current catalogs.
```

Update `EXPECTED_FINGERPRINT` to the reviewed PR encoding fingerprint. Keep the form count exact. Do not read `specification.toml` or release identity in this function.

- [ ] **Step 3: Gate manifest linkage only behind `--release`**

Move manifest identity, catalog counts, and encoding-projection hash checks into:

```python
def check_release_linkage() -> str:
    # Return the release encoding projection hash after exact manifest checks.
```

`main()` always calls `check_architecture_binary()`. It calls `check_release_linkage()` only when `args.release` is true. A mismatch remains a nonzero exit; no warning-only path is permitted.

- [ ] **Step 4: Remove release-only generators from ordinary repository checks**

End `scripts/check-repository` with current-architecture checks only:

```bash
./scripts/check-binary-closure
echo "repository checks passed"
```

Do not call release traceability, release gate, release closure, or release manifest checks there.

- [ ] **Step 5: Strengthen the release-only Make target**

Change `release-evidence-check` to call:

```make
	./scripts/check-binary-closure --release
	./scripts/check-release-manifest
```

Keep release traceability, release gate, release closure, formal semantic audit, and exact-head release workflow checks in release-only targets.

- [ ] **Step 6: Run focused tests**

Run:

```bash
python3 -m unittest \
  tests.scripts.test_architecture_release_boundary \
  tests.scripts.test_release_closure
./scripts/check-binary-closure
```

Expected: policy tests pass and architecture-only binary closure reports the current fingerprint. Do not run `--release` as a success claim before release metadata is updated.

- [ ] **Step 7: Commit the checker split**

```bash
git add -- \
  Makefile \
  scripts/check-binary-closure \
  scripts/check-repository \
  tests/scripts/test_architecture_release_boundary.py \
  tests/scripts/test_release_closure.py
git commit -m "build: separate architecture and release closure"
```

---

### Task 3: Restore release-owned files and make ADR 0069 version-neutral

**Files:**
- Modify: `specification.toml`
- Modify: `scripts/generate-release-manifest`
- Modify: `spec/evidence/pto-isa-0582-hardware-numeric-vectors.json`
- Modify: `docs/status/decisions/0069-b-iot-b-ios-sizecode-pemode.md`
- Test: `tests/scripts/test_architecture_release_boundary.py`
- Test: `tests/scripts/test_release_closure.py`

**Interfaces:**
- Consumes: the approved version-neutral design and the current published release files from `origin/main`.
- Produces: semantic binder ADR with no release identity and byte-identical release-owned files relative to `origin/main`.

- [ ] **Step 1: Restore release-owned file content**

Using `apply_patch`, restore these files to their `origin/main` content:

```text
specification.toml
scripts/generate-release-manifest
spec/evidence/pto-isa-0582-hardware-numeric-vectors.json
```

The release test must assert the same published identity as `origin/main`.

- [ ] **Step 2: Rewrite ADR 0069 as an accepted semantic decision**

Set `Status: accepted`. Remove issue/reviewer provenance, release lines, merge sequencing, future-version language, and ABI-version alternatives. Retain only:

```text
SizeCode = instruction[18:15]
PEMode   = instruction[11:9]
```

plus the complete mode table, size legality, source-only code zero, strict no-effect mode zero, capacity accounting, reserved values, and pre-effect fault ordering.

- [ ] **Step 3: Prove release-owned files are unchanged**

Run:

```bash
git diff --exit-code origin/main -- \
  specification.toml \
  scripts/generate-release-manifest \
  spec/evidence/pto-isa-0582-hardware-numeric-vectors.json
```

Expected: no diff.

- [ ] **Step 4: Run policy tests and text scans**

Run:

```bash
python3 -m unittest \
  tests.scripts.test_architecture_release_boundary \
  tests.scripts.test_release_closure
! rg -n '\b0\.[0-9]+(?:\.[0-9]+)?\b|post-0\.|mode-function-v[0-9]+|must not merge until' \
  docs/status/decisions/0069-b-iot-b-ios-sizecode-pemode.md
```

Expected: tests pass and the scan finds nothing.

- [ ] **Step 5: Commit the version-neutral architecture record**

```bash
git add -- \
  specification.toml \
  scripts/generate-release-manifest \
  spec/evidence/pto-isa-0582-hardware-numeric-vectors.json \
  docs/status/decisions/0069-b-iot-b-ios-sizecode-pemode.md \
  tests/scripts/test_release_closure.py
git commit -m "docs: keep binder architecture version neutral"
```

---

### Task 4: Move binder evidence to mnemonic-owned tests

**Files:**
- Create: `tests/asl/block/operands/B.IOT/block-bound-b-iot-capacity-003.asl`
- Create: `tests/asl/block/operands/B.IOT/block-exec-b-iot-pemode-004.asl`
- Create: `tests/asl/block/operands/B.IOT/block-exec-b-iot-sizecodes-002.asl`
- Create: `tests/asl/block/operands/B.IOT/block-exec-b-iot-consumer-001.asl`
- Create: `tests/asl/block/operands/B.IOS/block-bound-b-ios-capacity-003.asl`
- Create: `tests/asl/block/operands/B.IOS/block-exec-b-ios-pemode-005.asl`
- Create: `tests/asl/block/operands/B.IOS/block-exec-b-ios-sizecodes-003.asl`
- Create: `tests/asl/block/operands/B.IOS/block-exec-b-ios-consumer-001.asl`
- Delete: the six `tests/asl/block/model/dispatch/commands/*binder*.asl` files added by the PR.

**Interfaces:**
- Consumes: normal `ExecuteCommandInstruction` paths and the accepted B.IOT/B.IOS ASL owners.
- Produces: one stable mnemonic-owned test ID per execution, boundary, reserved-value, and consumer obligation.

- [ ] **Step 1: Split combined capacity evidence by mnemonic**

Move Local exact-fit/overflow assertions into `PTO-AVS-BLOCK-B-IOT-CAPACITY-003`. Move Shared single/two-PE success and multi-PE overflow into `PTO-AVS-BLOCK-B-IOS-CAPACITY-003`. Each file names its operand ASL owner in `source`.

- [ ] **Step 2: Move PEMode matrices**

Use IDs:

```text
PTO-AVS-BLOCK-B-IOT-PEMODE-004
PTO-AVS-BLOCK-B-IOS-PEMODE-005
```

Both tests exercise all eight encoded modes through their normal binder command path and prove mode zero has no effects.

- [ ] **Step 3: Move SizeCode matrices**

Use IDs:

```text
PTO-AVS-BLOCK-B-IOT-SIZECODES-002
PTO-AVS-BLOCK-B-IOS-SIZECODES-003
```

B.IOT proves legal codes 1..10 and rejects 11..15. B.IOS proves legal codes 1..12 and rejects 13..15 before effects.

- [ ] **Step 4: Split normal-consumer evidence**

Use IDs:

```text
PTO-AVS-BLOCK-B-IOT-CONSUMER-001
PTO-AVS-BLOCK-B-IOS-CONSUMER-001
```

Each test independently reaches decoded TLOAD consumption and proves successful publication plus atomic rollback for its own capacity boundary.

- [ ] **Step 5: Remove generic binder test files**

Delete only the six newly added `block/model/dispatch/commands/*binder*.asl` files after their assertions have been split. Do not create a new test root or aggregate runner.

- [ ] **Step 6: Run every moved point independently**

Run:

```bash
for id in \
  PTO-AVS-BLOCK-B-IOT-CAPACITY-003 \
  PTO-AVS-BLOCK-B-IOT-PEMODE-004 \
  PTO-AVS-BLOCK-B-IOT-SIZECODES-002 \
  PTO-AVS-BLOCK-B-IOT-CONSUMER-001 \
  PTO-AVS-BLOCK-B-IOS-CAPACITY-003 \
  PTO-AVS-BLOCK-B-IOS-PEMODE-005 \
  PTO-AVS-BLOCK-B-IOS-SIZECODES-003 \
  PTO-AVS-BLOCK-B-IOS-CONSUMER-001
do
  ./scripts/run-asl-test --id "$id"
done
```

Expected: all eight points pass individually.

- [ ] **Step 7: Commit mnemonic-owned evidence**

```bash
git add -- \
  tests/asl/block/operands/B.IOT \
  tests/asl/block/operands/B.IOS \
  tests/asl/block/model/dispatch/commands
git commit -m "test: give binder evidence mnemonic ownership"
```

---

### Task 5: Regenerate architecture projections and validate the candidate

**Files:**
- Modify: architecture-owned generated catalogs, instruction pages, AVS metadata, and instruction-contract closure only when their generators report drift.
- Do not modify: `specification.toml`, release-manifest generator, release manifest, version-specific release evidence, release traceability, or release-gate evidence.

**Interfaces:**
- Consumes: final ASL, docs, checker split, and mnemonic-owned tests.
- Produces: exact candidate head suitable for hosted PR validation and merge review.

- [ ] **Step 1: Regenerate architecture-owned projections**

Run generators only for current architecture surfaces:

```bash
python3 scripts/project_asl_catalogs.py --root .
python3 scripts/instruction_docs.py
python3 scripts/generate-mnemonic-avs.py
./scripts/generate-instruction-contract-closure
```

- [ ] **Step 2: Verify no release-owned file changed**

Run:

```bash
git diff --exit-code origin/main -- \
  specification.toml \
  scripts/generate-release-manifest \
  spec/release-manifest.json \
  spec/evidence/pto-isa-0582-hardware-numeric-vectors.json \
  spec/evidence/release-traceability-readiness.json \
  spec/evidence/release-gate-readiness.json
```

Expected: no diff.

- [ ] **Step 3: Run complete non-release validation**

Run:

```bash
cores=$(sysctl -n hw.logicalcpu)
make -j"$cores" pr-check
make repo-check
git diff --check
```

Expected: all ordinary checks pass. Do not run `release-evidence-check`, `release-check`, `release-prepare`, or a release workflow.

- [ ] **Step 4: Perform the final inline semantic review**

Read B.IOT and B.IOS ASL, their generated pages, every mnemonic-owned test, common PEMode decode, size tables, capacity accounting, zero-mode path, reserved values, and pre-effect rejection ordering. Record any Critical, High, Medium, or architectural blocker before push.

- [ ] **Step 5: Commit regenerated architecture surfaces**

```bash
git add -- \
  spec/catalog \
  spec/evidence/instruction-contract-closure.json \
  docs/arch docs/block docs/scalar docs/tile \
  tests/asl
git commit -m "chore: refresh version-neutral binder projections"
```

Skip the commit if the generators produce no tracked changes.

---

### Task 6: Publish the reviewed PR candidate and update remote context

**Files:**
- Remote issue: architecture decision issue for B.IOT/B.IOS SizeCode/PEMode.
- Remote PR: PR #119 title and body.

**Interfaces:**
- Consumes: clean exact local head and successful non-release validation.
- Produces: version-neutral issue/PR text and a fresh hosted exact-head validation run.

- [ ] **Step 1: Update the issue text**

Rewrite the issue to contain only the accepted field layout, mode table, size table, capacity accounting, reserved values, fault ordering, and required architecture evidence. Remove version numbers, release sequencing, and downstream publication identity. Mark the decision accepted.

- [ ] **Step 2: Update the PR title and body**

Use the title:

```text
Define B.IOT/B.IOS SizeCode and PEMode encoding
```

The body must state `Closes #118`, list ASL/docs/tests and exact non-release validation, declare release metadata unchanged, and say no release action is included. It must not name a future release.

- [ ] **Step 3: Push with an exact lease**

Observe the remote head, then run:

```bash
git push \
  --force-with-lease=refs/heads/codex/issue-118-binder-encoding-v2:<observed-head> \
  origin HEAD:refs/heads/codex/issue-118-binder-encoding-v2
```

- [ ] **Step 4: Require fresh hosted validation**

Verify the hosted PR check is for the pushed exact head. Pending, skipped, cancelled, stale-head, or missing checks are not success.

- [ ] **Step 5: Merge only after final review**

If the exact head remains conflict-free and the review has no blocker, squash with `--match-head-commit`, fetch `main`, and prove the squash tree equals the reviewed exact-head tree before cleaning PR-owned state. Do not start release.
