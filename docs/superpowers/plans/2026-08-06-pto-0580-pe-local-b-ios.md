# PTO ISA 0.58 PE-Local Tile and B.IOS Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reissue PTO ISA 0.58 with PE-local Tile sizes and dimensions and replace active `C.B.IOS` with an unambiguous 32-bit `B.IOS` Shared operand binder.

**Architecture:** Keep release identity `0.58.0` and the existing ABI string, but regenerate the release manifest from a new normative tree. `B.IOS` uses opcode `0x13`, funct3 `001`, carries absolute `SharedTID`, per-PE `TSize`, and `PE_MASK`, and owns all Shared operand metadata. Local Tile binding remains in `B.IOT`; scalar/address binding remains in `B.IOR`.

**Tech Stack:** JSON catalogs, Python generators and validators, ASL formal model and executable tests, Markdown documentation, generated HTML and XLSX release projections, GitHub Actions release checks.

## Global Constraints

- The release remains PTO ISA `0.58.0`; do not create 0.59 or an ABI-v2 suffix.
- `TSize=001..111` means 128 B, 256 B, 512 B, 1 KiB, 2 KiB, 4 KiB, and 8 KiB per selected PE.
- `PE_MASK=0000` is a strict no-op with no allocation, rename, read, write, fault, consume, or lifetime effect.
- Active `C.B.IOS` is removed; active command-form count remains 99.
- `B.IOS` encoding is width 32, match `0x00001013`, mask `0xf00871ff`, semantic group `Bundle Input & Output`.
- `B.IOR.RegDst` is not a Shared size carrier, and mask-only `B.IOT` is not an architectural form.
- All legality failures occur before architectural effects and before binder consumption.
- Preserve unrelated work and do not include PR 2.

---

### Task 1: Lock the architecture decisions and command encoding

**Files:**
- Create: `docs/architecture-decisions/0054-pe-local-tile-size-and-32-bit-shared-io-binding.md`
- Modify: `spec/catalog/command-forms.json`
- Modify: `spec/encoding/PTO-ISA-Encoding.sync.json`
- Modify: `specification.toml`
- Test: `scripts/check-catalogs`

**Interfaces:**
- Consumes: approved design in `docs/superpowers/specs/2026-08-06-pe-local-tile-size-design.md`.
- Produces: catalog form `B.IOS` with fields `SharedTID`, `PE_MASK`, and `TSize`, plus a stable generated `form_id` and no active `C.B.IOS` form.

- [ ] Replace the active `C.B.IOS` catalog row with `B.IOS`, preserving total form count 99 and removing the old reviewed compressed overlap exception.
- [ ] Add catalog canaries that require bits `[31:28]`, bit `[19]`, and bits `[8:7]` to be zero and prove no raw-word overlap with scalar, `B.IOR`, or `B.IOT` forms.
- [ ] Update the encoding sync source to the same mask, match, fields, syntax, and semantic handler.
- [ ] Add ADR 0054 recording the clean break, per-PE size table, Shared allocation-mask rules, zero-mask no-op, and in-place 0.58 reissue.
- [ ] Run `python3 scripts/check-catalogs` and require success.
- [ ] Commit the normative encoding decision.

### Task 2: Add failing ASL tests for PE-local sizes and Shared binding state

**Files:**
- Modify: `tests/asl/state-tests.asl`
- Modify: `tests/asl/bundle-tests.asl`
- Modify: `tests/asl/tlsu-totality-tests.asl`
- Modify: `tests/asl/cube-totality-tests.asl`
- Modify: `tests/asl/main.asl`
- Modify: `tests/asl/shards/core-bundle.asl`
- Modify: `tests/asl/shards/tlsu-totality.asl`
- Modify: `tests/asl/shards/cube-totality.asl`

**Interfaces:**
- Consumes: catalog field names `SharedTID`, `PE_MASK`, and `TSize`.
- Produces: executable requirements for `TileSizeCodeBytes(1)==128`, `TileSizeCodeBytes(7)==8192`, `B.IOS` decode boundaries, complete binding snapshots, and Shared TLSU/TMOV/CUBE role legality.

- [ ] Add decode vectors for `S0`, `S255`, masks 0/1/15, sizes 0/1/7, every reserved-bit rejection, wrong funct3 rejection, and retired `C.B.IOS` reinterpretation as the overlapping active `C.B.DIMI` form.
- [ ] Add state tests proving reset, append, duplicate rejection, fifth-binding rejection, consume, fault preservation, and trap restore for `size_code` and `pe_mask`.
- [ ] Add TLSU tests proving GM-to-Shared uses `B.IOS` size/mask, Shared-to-GM requires source size zero, Local-to-Shared takes destination size from `B.IOS`, Shared-to-Local takes Local capacity from `B.IOT`, and mask mismatch faults before effects.
- [ ] Add zero-mask tests proving no descriptor, payload, GM event, allocation, rename, consume, or fault effect.
- [ ] Add CUBE tests that check every Shared binder has `TSize=0` and mask `1111`, plus TGEMV rejection.
- [ ] Register every new test in full and shard entrypoints.
- [ ] Run the smallest ASL test target and confirm the new tests fail before implementation.
- [ ] Commit the executable requirements.

### Task 3: Implement PE-local size and complete Shared binding state

**Files:**
- Modify: `asl/types.asl`
- Modify: `asl/tile/state.asl`
- Modify: `asl/bundle/state.asl`
- Modify: `asl/state.asl`
- Modify: `asl/profiles/pto-v0.asl`

**Interfaces:**
- Produces: `BundleSharedBinding` fields `valid`, `shared_id`, `size_code`, `pe_mask`, and `consumed`; accessors `BundleSharedBindingSize`, `BundleSharedBindingMask`, and `BundleSharedBindingIsDestination`; per-PE `TileSizeCodeBytes`.

- [ ] Change `TileSizeCodeBytes` to return `128 * 2^(size_code-1)` for legal codes 1 through 7.
- [ ] Extend `BundleSharedBinding`, every reset/clear path, and trap snapshots with `size_code` and `pe_mask`.
- [ ] Change `BindBundleSharedIO` to accept and store `(shared_id, size_code, pe_mask)`.
- [ ] Add accessors that assert valid and unconsumed bindings.
- [ ] Preserve complete binding records through trap save and restore.
- [ ] Run state and bundle tests and require success for this task's cases.
- [ ] Commit the state-model implementation.

### Task 4: Move Shared operand ownership into B.IOS

**Files:**
- Modify: `asl/bundle/dispatch.asl`
- Modify: `asl/tile/memory.asl`
- Modify: `asl/tile/cube.asl`
- Modify: `asl/tile/legality.asl`

**Interfaces:**
- Consumes: complete Shared binding accessors from Task 3.
- Produces: `B.IOS` decoder dispatch, role/mask schema checks, and Shared TLOAD/TSTORE/TMOV/CUBE execution without a `B.IOR` size carrier or mask-only `B.IOT`.

- [ ] Decode `SharedTID`, `TSize`, and `PE_MASK` into `BindBundleSharedIO`.
- [ ] Remove `BundleSharedMaskCompanionLegal`, `EffectiveSharedPEMask`, `destination MOD 4`, and `destination DIVRM 4` from active Shared execution.
- [ ] Make Shared scalar schema require zero `RegDst`, `RegSrc1`, and `RegSrc2` where the operation does not use them.
- [ ] Make GM-to-Shared use destination `B.IOS.TSize` and `B.IOS.PE_MASK`; make Shared-to-GM require source `TSize=0`.
- [ ] Make Local-to-Shared use a source-only `B.IOT`, destination `B.IOS`, and equal masks; make Shared-to-Local use source `B.IOS`, destination `B.IOT`, and equal masks.
- [ ] Check every Shared CUBE binder for source role and full mask; keep TGEMV rejection.
- [ ] Ensure all schema checks precede memory events, descriptor/payload changes, destination finalization, and binder consumption.
- [ ] Run bundle, TLSU, CUBE, state, dispatch, and shard tests and require success.
- [ ] Commit the execution-model change.

### Task 5: Implement PE-local allocation, dimensions, and Shared mask rules

**Files:**
- Modify: `asl/tile/state.asl`
- Modify: `asl/tile/memory.asl`
- Modify: `asl/tile/cube.asl`
- Modify: `asl/bundle/state.asl`
- Modify: `tests/asl/state-tests.asl`
- Modify: `tests/asl/bundle-tests.asl`
- Modify: `tests/asl/tlsu-totality-tests.asl`
- Modify: `tests/asl/cube-totality-tests.asl`

**Interfaces:**
- Produces: core allocation accounting `popcount(PE_MASK) * per_pe_bytes`, fixed PE identity mapping, immutable Shared allocation mask with subset updates, and per-PE CUBE dimensions.

- [ ] Add or update allocation accounting helpers so destination capacity charges selected PE count times per-PE capacity.
- [ ] Preserve fixed mapping `1000=PE0`, `0100=PE1`, `0010=PE2`, `0001=PE3` without packing selected lanes.
- [ ] Record the first nonzero Shared destination mask as immutable `allocation_mask`; allow subset updates and reject expansion.
- [ ] Keep undefined Shared reads non-trapping and side-effect free while preserving atomic selected-lane destination updates.
- [ ] Interpret `B.DIM M/N/K` and descriptor shape as per-PE; derive `MShard4 group_M=4*pe_M` only in the cooperative group view.
- [ ] Add tests for popcounts 1 through 4, fixed bit order, subset update, expansion rejection, and `M128N32K64` using two `K=32` rounds.
- [ ] Run targeted ASL tests and require success.
- [ ] Commit the allocation and dimension semantics.

### Task 6: Update normative documentation and traceability

**Files:**
- Create: `docs/instructions/block/operands/B.IOS.md`
- Delete: `docs/instructions/block/operands/C.B.IOS.md`
- Modify: `docs/instructions/block/operands/B.IOR.md`
- Modify: `docs/instructions/block/operands/B.IOT.md`
- Modify: `docs/instructions/block/operands/B.DIM.md`
- Modify: `docs/instructions/tile/TLOAD.md`
- Modify: `docs/instructions/tile/TSTORE.md`
- Modify: `docs/instructions/tile/TMOV.md`
- Modify: `docs/instructions/tile/GMOV.md`
- Modify: `docs/instructions/tile/TMATMUL.md`
- Modify: `docs/instructions/tile/TMATMUL_ACC.md`
- Modify: `docs/instructions/tile/TMATMUL_BIAS.md`
- Modify: `docs/instructions/tile/TMATMUL_MX.md`
- Modify: `docs/instructions/tile/TMATMUL_MX_ACC.md`
- Modify: `docs/instructions/tile/TMATMUL_MX_BIAS.md`
- Modify: `docs/architecture.md`
- Modify: `docs/davincioo-arch/assembly-syntax.md`
- Modify: `docs/davincioo-arch/encoding-conventions.md`
- Modify: `docs/davincioo-arch/isa-overview.md`
- Modify: `docs/davincioo-arch/programming-model.md`
- Modify: `docs/davincioo-arch/state-and-data-types.md`
- Modify: `docs/davincioo-arch/memory-ordering-and-exceptions.md`
- Modify: `spec/requirements.json`

**Interfaces:**
- Produces: one consistent normative explanation of PE-local size/dimensions and Shared binder ownership.

- [ ] Document `B.IOS` syntax, bit layout, mask/match, role rule, absolute IDs, ordered stream, consume timing, fault behavior, trap preservation, and examples.
- [ ] Remove active `C.B.IOS`, Shared-size-in-`B.IOR`, and mask-only-`B.IOT` claims from all current documentation while preserving historical ADR text.
- [ ] Update TLOAD/TSTORE/TMOV/GMOV and cooperative matrix examples to per-PE sizes and fixed PE masks.
- [ ] Add the normative `M128N32K64` two-round example and distinguish per-PE encoded values from derived group totals.
- [ ] Update requirement model/test links to the new ADR, `B.IOS`, ASL state, and totality evidence.
- [ ] Run documentation and repository checks and require success.
- [ ] Commit the human-authored specification changes.

### Task 7: Regenerate release projections and evidence

**Files:**
- Regenerate: `spec/encoding/PTO-ISA-Encoding.xlsx`
- Regenerate: generated instruction reference pages under `docs/instructions/`
- Regenerate: `docs/html/`
- Regenerate: `docs/DavinciOO_PTO_Intrinsic_Complete.html`
- Regenerate: evidence under `spec/evidence/`
- Regenerate: `spec/release-manifest.json`

**Interfaces:**
- Consumes: stable catalog, ASL, tests, docs, and requirements.
- Produces: one self-consistent reissued 0.58 release tree and canonical manifest hash.

- [ ] Run the repository-owned decoder, instruction-reference, evidence, HTML, XLSX, and release-manifest generators in dependency order.
- [ ] Regenerate 0.58 ABI and encoding vectors in the existing 0.58 artifact names because this is an approved in-place reissue.
- [ ] Verify generated artifacts contain active `B.IOS`, contain no active `C.B.IOS`, and use the 128B–8KB per-PE table.
- [ ] Run `git diff --check` and generated-artifact `--check` modes.
- [ ] Commit generated projections and release closure.

### Task 8: Verify, publish, merge, and re-tag PTO ISA 0.58

**Files:**
- No new source files; this task validates and publishes the reviewed exact tree.

**Interfaces:**
- Produces: merged PTO-SPEC commit and reissued `v0.58` tag that both point to the reviewed tree.

- [ ] Run targeted ASL tests, full local repository checks, release-manifest check, release gate, and every enabled CI-equivalent local target.
- [ ] Push the branch, open a PR against `main`, and record the exact head commit and tree.
- [ ] Require all enabled GitHub checks to complete successfully and require GitHub to report no conflicts.
- [ ] Squash merge with `--match-head-commit`; use `--admin` only if the merge privilege itself requires it and never to bypass a pending or failing check.
- [ ] Fetch merged `main` and prove the squash commit tree equals the reviewed exact-head tree.
- [ ] Move the existing `v0.58` tag to the proved merged commit only after the tree proof, push the updated tag, and verify the remote tag target.
- [ ] Reply to Issues 48 and 49 with the accepted ADR, merged commit, release manifest identity, and tag target; close both issues.
