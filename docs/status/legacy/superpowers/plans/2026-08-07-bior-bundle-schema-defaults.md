# B.IOR Bundle Schema Defaults Implementation Plan

> Historical, non-normative material. This page is excluded from the active PTO architecture and release closure.

> **For Codex:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

**Goal:** Make PTO v0.58 resolve B.IOR operands from the complete bundle schema, allow omission with architectural defaults, constrain encoded selectors to the 24 absolute GPRs, and synchronize the resulting common ISA contract into LinxISA while preserving its separate decoupled-body rules.

**Architecture:** Keep encoded-instruction presence, resolved operand presence, and selector value as distinct concepts. Derive the direct-operation B.IOR shape from catalog operand fields, enforce fail-closed legality before state mutation, and regenerate every checked projection from its authoritative source. PTO is completed first; LinxISA then imports that exact reviewed PTO commit and carries only explicit Linx-only extensions.

**Tech Stack:** ASL, JSON instruction catalogs, Python generators/checkers, Markdown normative documentation, Make-based repository gates, Git worktrees.

---

### Task 1: Lock the PTO behavior with failing tests

**Files:**
- Modify: `tests/asl/bundle-tests.asl`
- Modify: `tests/asl/shards/core-bundle.asl`
- Test: `tests/asl/bundle-tests.asl`

**Step 1: Add focused architectural cases**

Add cases for omitted B.IOR defaults, selector-zero semantics, unused nonzero fields, repeated selectors, a second B.IOR preserving the first binding, selector values 24..31 rejecting before mutation, and zero-mask no effects.

Add direct-memory cases proving that the unchanged TLOAD/TSTORE encoding binds
`RegSrc0` to base and `RegSrc1` to row stride in elements, that an omitted
B.IOR defaults the row stride to `LB2/Col`, and that an explicitly encoded zero
stride remains zero rather than receiving the omission default. Include a
packed four-bit case so nibble selection follows the strided logical index.

**Step 2: Register the new test in the core bundle shard**

Add the new test function to `tests/asl/shards/core-bundle.asl` so the hosted and local shard paths exercise it.

**Step 3: Run the focused shard and confirm RED**

Run: `make test-shard-core-bundle`

Expected: failure on at least one newly asserted rule in the current implementation, proving the test can detect the old behavior.

### Task 2: Implement PTO catalog and ASL legality

**Files:**
- Modify: `spec/catalog/command-forms.json`
- Modify: `asl/bundle/dispatch.asl`
- Modify only if required: `asl/bundle/state.asl`
- Test: `tests/asl/bundle-tests.asl`

**Step 1: Constrain all encoded B.IOR selectors**

Add machine-readable constraints requiring RegDst and RegSrc0..2 to be one of `0..23`, so reserved selector encodings reject before dispatch changes bundle state.

**Step 2: Resolve consumed fields from the operation schema**

Add ASL helpers that derive the current direct-operation register-input order
and validate only schema-consumed fields. Omitted B.IOR is legal and supplies
operation defaults; a present unused field must be zero. TLOAD/TSTORE continue
to use the existing B.IOR RegSrc0/RegSrc1 encoding, with base in RegSrc0 and
row stride in RegSrc1. Their omitted stride default is the resolved LB2/Col
dimension, while an explicitly encoded zero selector reads architectural zero.

**Step 3: Reject a second direct B.IOR without overwrite**

Guard the B.IOR handler before `SetBundleScalarBinding`, raise the appropriate bundle legality fault, and preserve the first binding.

**Step 4: Preserve Shared and zero-mask semantics**

Allow omitted Shared B.IOR defaults while retaining the existing strict
`PE_MASK=0000` no-effect path. Apply the same base/row-stride contract to
Shared TLOAD/TSTORE without adding or changing an encoded field.

**Step 5: Run the focused shard and confirm GREEN**

Run: `make test-shard-core-bundle`

Expected: pass.

### Task 3: Align PTO normative assembly and generated projections

**Files:**
- Modify: `docs/instructions/block/operands/B.IOR.md`
- Modify: `docs/davincioo-arch/assembly-syntax.md`
- Modify relevant current instruction pages under: `docs/instructions/`
- Modify authoritative release/encoding inputs only where required under: `spec/`
- Regenerate checked documentation and release artifacts

**Step 1: Replace absence-by-zero and duplicate prohibitions**

Document bundle-wide schema resolution, omitted defaults, legal repeated/aliased registers, absolute GPR spelling, and encoded-all-zero versus omitted B.IOR.

**Step 2: Canonicalize examples**

Use `zero/sp/a0..a7/ra/s0..s8/x0..x3`; permit `R0..R23` as input aliases; remove numeric-zero and relative-register examples from current normative surfaces.

**Step 3: Normalize B.IOS/B.IOT sizes**

Show semantic per-PE sizes (`128B` through `8KB`) in assembly/disassembly examples instead of raw TSize bits.

**Step 4: Regenerate projections**

Run the repository's canonical instruction-reference, encoding, evidence, and release-manifest generators in write mode as identified by the Makefile/check output.

**Step 5: Verify the complete PTO repository**

Run: `make repo-check`

Expected: pass with no stale generated artifact, catalog, shard, release, link, or publication-hygiene failure.

### Task 4: Commit the exact PTO result

**Files:**
- Review all files changed by Tasks 1-3

**Step 1: Review scope and generated deltas**

Run `git status --short`, `git diff --check`, and inspect the complete diff. Confirm no historical ADR/evidence text was rewritten as if it were current normative behavior.

**Step 2: Commit the verified PTO change**

Commit the implementation and record the exact commit and tree IDs. Keep the existing design commit as its own reviewable predecessor.

### Task 5: Relock LinxISA to the exact PTO result

**Files:**
- Modify the Linx PTO import lock/projection under the paths selected by the repository importer
- Modify current Linx assembly/ISA documentation describing imported direct B.IOR
- Modify current Linx-only decoupled-body documentation/tests where needed to keep the boundary explicit

**Step 1: Discover and run the canonical PTO importer**

Use the repository-provided import/relock tool against the exact PTO implementation commit from Task 4. Do not hand-copy generated common forms.

**Step 2: Preserve the Linx-only extension boundary**

Imported PTO direct bundles allow at most one B.IOR and use complete-bundle defaults. Linx decoupled programmable bodies may contain multiple declarations and repeated input/output registers; no PTO document gains that extension.

**Step 3: Remove active stale forms and synchronize TSize/shared management**

Ensure the current Linx v0.58 projection has no active `C.B.IOS`, no mask-only Shared `B.IOT`, includes the current 32-bit PTO `B.IOS`, and exactly matches PTO common scalar/command constraints and logical-field metadata.

**Step 4: Regenerate Linx projections and evidence**

Run the Linx repository's canonical generators in write mode.

### Task 6: Verify and commit LinxISA synchronization

**Files:**
- Review all files changed by Task 5

**Step 1: Run focused import/parity gates**

Run the repository-provided PTO lock, common-form parity, assembly-documentation, and generated-artifact checks.

**Step 2: Run the broad Linx repository gate appropriate to this documentation/spec-only change**

Use the checked Make/script entrypoint discovered in the repository and record any unavailable external dependency separately from repository failures.

**Step 3: Review and commit**

Run `git diff --check`, inspect the full diff, commit the exact synchronized result, and record commit/tree IDs plus validation evidence for both repositories.
