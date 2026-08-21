# GM Byte Addressing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make every PTO GM address displacement byte-based on the current branch: TLOAD/TSTORE use a byte row stride, and indexed TLSU operations use signed or unsigned byte displacements.

**Architecture:** Keep the current monolithic Tile memory model, but split address formation into two explicit contracts. Regular two-dimensional transfers compute a byte row base and then a typed column displacement; indexed transfers add the normalized index value directly to the base without transfer-type scaling. Packed four-bit regular transfers retain column-derived nibble selection, while packed four-bit indexed transfer data is rejected because the encoding has no nibble selector.

**Tech Stack:** ASL1 accepted by the repository-pinned ASLRef, JSON catalogs/evidence, Markdown ADR and instruction references, Make validation targets.

## Global Constraints

- Preserve the one-level PTO architecture and existing precise preflight/restart behavior.
- Preserve `B.IOR` encoding, absolute selector ranges, omitted-instruction versus encoded-zero distinction, and PE-private GPR resolution.
- `B.IOR.RegSrc1` is an XLEN byte count between adjacent TLOAD/TSTORE GM row starts.
- Omitted TLOAD/TSTORE `B.IOR` uses base zero and `ceil(physical_columns * element_bits / 8)` bytes; an encoded zero stride remains zero.
- MGATHER, MSCATTER, masked variants, and MGATHER_CAS interpret every IndexTile element as a byte displacement and never multiply it by the transfer element width.
- Packed four-bit transfer data is legal for regular TLOAD/TSTORE and illegal for indexed TLSU transfers until a separate nibble selector is architected.
- Do not modify unrelated existing worktree changes, weaken validation, or commit generated `build/` or `.cache/` output.

---

### Task 1: Lock byte-address behavior with failing executable tests

**Files:**
- Modify: `tests/asl/tlsu-totality-tests.asl`

**Interfaces:**
- Consumes: existing `ConfigureTile`, memory load/store helpers, memory-event capture, `TLOAD`, `TSTORE`, `MGATHER`, and `MSCATTER`.
- Produces: `TestTlsuRegularByteRowStride`, `TestTlsuIndexedByteDisplacements`, and `TestTlsuPackedIndexedTransferRejected`, called exactly once by `TestTlsuTotality`.

- [ ] **Step 1: Add a failing FP32 two-dimensional row-stride test**

  Configure a `2 x 2` FP32 Tile, place four literal values at byte offsets `0`, `4`, `64`, and `68`, call `TLOAD(tile, base, 64)`, and assert the second row comes from `base+64` rather than `base+16` or `base+256`. Mirror the address assertions through `TSTORE(base, 64, tile)`.

- [ ] **Step 2: Run the TLSU shard and verify RED**

  Run: `make test-shard-tlsu-totality`

  Expected: FAIL because the three-argument TLOAD/TSTORE byte-stride interface or its byte behavior is absent.

- [ ] **Step 3: Add a failing U32 indexed byte-displacement test**

  Use index values `0` and `12`, place U32 literals at `base+0` and `base+12`, and assert MGATHER/MSCATTER access those exact addresses. The old element-index implementation would incorrectly scale `12` to `48`.

- [ ] **Step 4: Add a failing packed indexed-transfer legality test**

  Assert that indexed transfer legality rejects E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 as transfer data while retaining signed/unsigned integer IndexTile types.

- [ ] **Step 5: Re-run the TLSU shard and record the expected failures**

  Run: `make test-shard-tlsu-totality`

  Expected: FAIL only on missing byte-row-stride, byte-displacement, or packed-indexed legality behavior.

### Task 2: Implement regular and indexed byte-address primitives

**Files:**
- Modify: `asl/tile/memory.asl`
- Modify: `asl/tile/legality.asl`
- Modify: `asl/tile/state.asl`

**Interfaces:**
- Consumes: `TileElementBits`, `TileElementBytes`, `TileDataTypeIsFourBit`, `MultiplyWord`, and existing memory probes.
- Produces: `TileDenseRowStrideBytes`, `TileMemoryStridedByteAddress`, `TileMemoryStridedHighNibble`, `TileIndexByteDisplacement`, `TileMemoryByteDisplacementAddress`, `IndexedTLSUIndexDataTypeLegal`, and `IndexedTLSUTransferDataTypeLegal`.

- [ ] **Step 1: Add dense-row and regular byte-address helpers**

  Define the dense byte stride as ceiling division of physical-column bits by eight. Define `row_base = base + row * row_stride_bytes`; byte-sized-or-larger columns add `column * element_bytes`; packed four-bit columns add `column DIV 2` and select the nibble from `column MOD 2`.

- [ ] **Step 2: Add explicit three-argument TLOAD/TSTORE behavior**

  Change both preflight and effect loops to use the row/column byte helper. Preserve two-argument overloads as dense convenience entrypoints for existing direct tests, deriving the default from the Tile descriptor.

- [ ] **Step 3: Thread byte stride through Shared TLOAD/TSTORE**

  Add `row_stride_bytes` to Shared helpers and use the same address/nibble functions for each selected PE quarter. Preserve preflight, Shared atomic update, definedness, and source snapshot behavior.

- [ ] **Step 4: Add byte-displacement index normalization**

  Sign-extend S4X2/S8/S16/S32/S64 index elements, zero-extend U4X2/U8/U16/U32/U64 index elements, and add the normalized Word directly to the GM base.

- [ ] **Step 5: Convert every indexed TLSU implementation**

  Update MGATHER, MSCATTER, MGATHER_MASK, MSCATTER_MASK, and MGATHER_CAS to use byte-displacement addresses. Remove transfer-type-derived indexed nibble selection and pass `high_nibble=FALSE` after packed transfer legality has rejected four-bit data.

- [ ] **Step 6: Define indexed type legality independently**

  Accept integer IndexTile types and reject all packed four-bit transfer data types for indexed TLSU. Apply the predicates in direct helper assertions and `TileOperandsLegal_*` functions.

- [ ] **Step 7: Run the TLSU shard and verify GREEN**

  Run: `make test-shard-tlsu-totality`

  Expected: PASS with exact byte addresses, packed regular transfer behavior, and packed indexed rejection.

### Task 3: Repair complete-bundle B.IOR resolution

**Files:**
- Modify: `asl/bundle/dispatch.asl`
- Modify: `tests/asl/bundle-tests.asl`

**Interfaces:**
- Consumes: `TileOperationOfIndex`, `_BundleScalarBindings`, `_BundleDimensions`, effective Tile DataType, and Task 2 dense-stride helper.
- Produces: operation-ordered B.IOR resolution where address uses RegSrc0 and TLOAD/TSTORE byte stride uses RegSrc1.

- [ ] **Step 1: Add a failing decoded bundle test**

  Execute FP32 TLOAD/TSTORE bundles with base in RegSrc0 and byte stride 64 in RegSrc1; assert the second row uses `base+64`. Add omitted-B.IOR dense-byte default and encoded-zero-stride alias cases.

- [ ] **Step 2: Run the bundle shard and verify RED**

  Run: `make test-shard-core-bundle`

  Expected: FAIL because current dispatch copies RegSrc0 into both `address` and `scalar0`, requires B.IOR for every address consumer, and never forwards Shared RegSrc1.

- [ ] **Step 3: Implement operation-aware B.IOR slot resolution**

  Resolve `address` from RegSrc0 and the following scalar operand from RegSrc1. Permit omitted B.IOR only for regular TLOAD/TSTORE, resolving base zero and the typed dense byte stride; preserve required B.IOR for indexed TLSU operations.

- [ ] **Step 4: Pass RegSrc1 through Shared execution**

  Read each selected PE's private RegSrc1 value and forward it to Shared TLOAD/TSTORE. Preserve zero-mask no-effect behavior before GPR reads.

- [ ] **Step 5: Run bundle and TLSU shards and verify GREEN**

  Run: `make test-shard-core-bundle`

  Run: `make test-shard-tlsu-totality`

  Expected: both PASS.

### Task 4: Synchronize normative and generated-facing surfaces

**Files:**
- Create: `docs/architecture-decisions/0058-gm-byte-addressing.md`
- Modify: `spec/catalog/command-forms.json`
- Modify: `spec/catalog/tile-operations.json`
- Modify: `docs/instructions/bundle/operands/B.IOR.md`
- Modify: `docs/instructions/tile/TLOAD.md`
- Modify: `docs/instructions/tile/TSTORE.md`
- Modify: indexed TLSU instruction pages under `docs/instructions/tile/`
- Modify: `spec/evidence/tlsu-totality.json`
- Modify: `spec/evidence/bundle-command-totality.json`
- Modify: `spec/requirements.json`
- Modify: `docs/coverage.md`
- Modify: `docs/normative-sources.md`
- Modify as required by generators: `scripts/generate-asl-decoders`, `scripts/generate-bundle-command-totality`, `scripts/generate-instruction-reference`, and `scripts/check-catalogs`

**Interfaces:**
- Consumes: accepted byte-address behavior from Tasks 2 and 3.
- Produces: one traceable ADR and matching catalog roles, generated descriptions, evidence ledgers, and validation assertions.

- [ ] **Step 1: Record the superseding decision**

  State that TLOAD/TSTORE row stride and indexed TLSU indices are bytes, that indexed byte displacement already matches the intended common rule, that packed regular rows restart nibble selection at each byte-addressed row base, and that indexed packed transfer data rejects for lack of a nibble selector. Explicitly supersede the element-unit portions of the earlier B.IOR/TLSU decisions without changing encodings.

- [ ] **Step 2: Update catalog operand roles and summaries**

  Replace `row-stride-elements` with `row-stride-bytes`; replace indexed logical-element descriptions with `byte-displacement-indices`; preserve BaseGPR and source/destination roles.

- [ ] **Step 3: Update instruction references and evidence ledgers**

  Document exact equations, dense omission, encoded zero, signed/unsigned index extension, packed rejection, faults, and ordering. Add the new executable test scenarios and paths to the TLSU and bundle evidence.

- [ ] **Step 4: Update traceability and closure checks**

  Attach the ADR and changed ASL/test paths to `PTO-REQ-TLSU-001`, memory completion, memory ordering, and bundle dispatch requirements. Make catalog checks reject stale element-unit roles and require the new byte-address scenarios.

- [ ] **Step 5: Regenerate tracked projections using repository scripts**

  Run the existing generators through the Make targets they own; do not hand-edit `build/` output.

### Task 5: Validate the complete current-branch change

**Files:**
- Verify only; do not add unrelated changes.

**Interfaces:**
- Consumes: all previous tasks.
- Produces: fresh evidence for the final completion report.

- [ ] **Step 1: Run targeted executable shards**

  Run: `make test-shard-tlsu-totality`

  Run: `make test-shard-core-bundle`

- [ ] **Step 2: Run catalog and repository closure**

  Run: `make repo-check`

  Run: `git diff --check`

- [ ] **Step 3: Run the broader voluntary CI gate**

  Run: `make ci`

  Expected: all commands pass; if the dirty branch contains pre-existing failures, separate them from regressions with exact output.

- [ ] **Step 4: Review the final diff against worktree ownership**

  Confirm every changed hunk belongs to GM byte addressing or was already present before this task. Do not stage or commit without separate authorization.
