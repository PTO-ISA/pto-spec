# FPATR Extended Stages PR2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add PTO-owned pre, elementwise/anti-quant, and post extension attributes whose combined D-result behavior completes the accepted FPATR pipeline while leaving transport, layout, synchronization, and memory atomicity out of scope.

**Architecture:** Begin only from merged PR1 and retain the existing required `B.FPATR` anchor. Add three independent command/state units—`B.FPATR.PRE`, `B.FPATR.ELT`, and `B.FPATR.POST`—with separate ASL files, same-basename generated docs, and exact-mirror test directories; resolve their ordered scalar/Local/Shared roles into one preflighted descriptor snapshot and evaluate one deterministic pipeline before atomic publication.

**Tech Stack:** ASL1 at `.aslref-version`, PTO command catalog and generated decoders, NDF clauses, generated Markdown/catalog/evidence projections, Python 3 generators, GNU Make, pinned ASLRef.

## Global Constraints

- Start only after PR1 is merged; branch from the exact merged `origin/main` commit and open a separate linked NDF architecture-change issue.
- Keep `B.FPATR` required exactly once for Matrix blocks; every extension is optional, unique, placed after the anchor and before bindings/body instructions, and omission selects PR1 behavior.
- Allocate only PTO-owned encodings; do not reuse or cite an external encoding namespace.
- Use separate owners `asl/block/attributes/B.FPATR.PRE.asl`, `B.FPATR.ELT.asl`, and `B.FPATR.POST.asl`; generated docs and mirrored test directories must use the same basenames.
- Add no memory movement, OUT/L1/UB destination, NZ2ND/NZ2DN/channel/layout transform, LoopEnhance, depth/space transform, Winograd transform, cache control, unit flag, physical pipeline state, or memory atomic read-modify-write.
- Model scalar parameters through dense `B.IOR`; model vector parameters and elementwise source 2 through explicit Local or Shared bindings; add no hidden parameter storage.
- Snapshot every source and parameter before D evaluation; complete schema, legality, definedness, alias, capacity, and allocation checks before effects.
- RowMax and GroupMax continue to consume the raw accumulator and never observe PRE/ELT/POST results.
- Publish D, enabled raw auxiliaries, descriptors, representation state, and numeric flags atomically.
- Regenerate catalogs, decoders, docs, navigation, traceability, AVS, and release evidence from ASL.
- Stop only after all new command forms close decode, reserved values, state lifecycle, semantics, tests, binary closure, and hosted `PR / validate` at the exact head.

## Locked PTO command interfaces

The implementation uses three collision-free L32 discriminators in the current B.FPATR command class. Before editing, Task 1 re-runs the catalog partition check against merged PR1; any newly occupied discriminator blocks the PR and requires a new NDF encoding amendment rather than silent reassignment.

| Mnemonic | Mask | Match | High-field payload |
| --- | --- | --- | --- |
| `B.FPATR.PRE` | `0x00007fff` | `0x00003023` | bits 31:15 |
| `B.FPATR.ELT` | `0x00007fff` | `0x00004023` | bits 31:15 |
| `B.FPATR.POST` | `0x00007fff` | `0x00005023` | bits 31:15 |

`B.FPATR.PRE OutputOverride, HiF8Hybrid, NaNPreserve, ActivationExt`:

```text
bits 31:30 OutputOverride: 0 Inherit, 1 U8, 2 E5M2, 3 reserved
bit  29    HiF8Hybrid: 0 assigned PR1 rounding, 1 hybrid threshold rounding
bit  28    NaNPreserve: 0 saturating NaN-to-zero, 1 preserve canonical NaN
bits 27:26 ActivationExt: 0 None, 1 ClipReLU, 2 PWL, 3 reserved
bits 25:15 Reserved: zero
```

`B.FPATR.ELT EltOp, SourceType, AntiQuantMode, PerColumn, MBroadcast`:

```text
bits 31:29 EltOp: 0 None, 1 Add, 2 Subtract, 3 Multiply, 4 Maximum, 5..7 reserved
bits 28:24 SourceType: PTO TileDataType encoding
bits 23:20 AntiQuantMode: 0 None; 1/2 S8 scalar/vector; 3/4 S4 scalar/vector;
                              5/6 U8 scalar/vector; 7/8 S16 scalar/vector;
                              9..15 reserved
bit  19    PerColumn: source 2 has one row and N valid columns
bit  18    MBroadcast: broadcast one-row source 2 across M
bits 17:15 Reserved: zero
```

`B.FPATR.POST PostQuantMode, PostReluMode, ClipReLU, BitMask, NaNPreserve, UnsignedOutput`:

```text
bits 31:27 PostQuantMode: 0 None;
    1/2 S16-to-B8 vector/scalar; 3/4 F16-to-B8 vector/scalar;
    5/6 S16-to-S4 vector/scalar; 7/8 F16-to-S4 vector/scalar;
    9/10 S16-to-S16 vector/scalar; 11/12 F16-to-S16 vector/scalar;
    13/14 shift-S33-to-S4 vector/scalar;
    15/16 shift-S33-to-B8 vector/scalar;
    17/18 shift-S33-to-S16 vector/scalar; 19..31 reserved
bits 26:24 PostReluMode: 0 None, 1 ReLU, 2 scalar LReLU, 3 vector PReLU,
                             4 PWL, 5..7 reserved
bit  23    ClipReLU: scalar clip after PostReluMode; legal only when PostReluMode=0
bits 22:20 BitMask: 0 none, 1..4 clear that many destination LSBs, 5..7 reserved
bit  19    NaNPreserve: same policy polarity as PRE
bit  18    UnsignedOutput: B8 modes select U8 instead of S8
bits 17:15 Reserved: zero
```

---

### Task 1: Open the PR2 issue and prove the encoding allocation is free

**Files:**
- Reference: `docs/status/plans/2026-08-19-fpatr-functional-parity-design.md`
- Reference: `spec/catalog/command-forms.json`
- No repository file changes in this task.

**Interfaces:**
- Consumes: merged PR1 main SHA.
- Produces: one NDF issue URL and evidence that matches `0x3023`, `0x4023`, and `0x5023` do not overlap the merged catalog.

- [ ] **Step 1: Create the PR2 branch from merged PR1**

Run:

```bash
git fetch origin main
git switch -c codex/fpatr-extended-stages origin/main
git rev-parse HEAD
git status --short
```

Expected: clean exact-main branch containing PR1.

- [ ] **Step 2: Prove all three discriminators are absent and partition-safe**

Run:

```bash
rg -n '0x00003023|0x00004023|0x00005023' asl spec/catalog/command-forms.json
make check-decoder-partition
```

Expected: `rg` has no match and decoder partition passes. If `rg` finds an assigned form, stop PR2 and amend the NDF issue with a new PTO-owned allocation before code changes.

- [ ] **Step 3: Open the NDF architecture-change issue**

Use title `NDF: add explicit FPATR pre elementwise and post stages` and this exact body:

```text
Baseline: the full 40-character merged-PR1 commit printed by git rev-parse HEAD.

New clauses:
- PTO-B-FPATR-PRE-001
- PTO-B-FPATR-ELT-001
- PTO-B-FPATR-POST-001
- PTO-MATRIX-PRE-STAGE-001
- PTO-MATRIX-ELEMENTWISE-STAGE-001
- PTO-MATRIX-POST-STAGE-001

Affected clauses:
- PTO-B-FPATR-MATRIX-POSTPROCESS-001
- PTO-MATRIX-POSTPROCESS-BITEXACT-001
- PTO-REQ-CUBE-POSTPROCESS-001

Decision:
- Add optional unique B.FPATR.PRE, B.FPATR.ELT, and B.FPATR.POST after the required B.FPATR anchor and before bindings/body instructions.
- Use PTO L32 masks/matches 0x00007fff/0x00003023, /0x00004023, and /0x00005023 after exact-baseline partition confirmation.
- PRE owns U8/E5M2 output override, HiF8 hybrid rounding, independent NaN preservation, Clip-ReLU, and PWL.
- ELT owns Add/Subtract/Multiply/Maximum, explicit source-2 type and Local/Shared binding, assigned scalar/vector anti-quant modes, per-column selection, and M broadcast.
- POST owns the assigned 18 post conversion modes, post activation, Clip-ReLU/PWL, S4/B8/S16 shift modes, bit mask, NaN policy, and signed/unsigned B8 selection.
- Scalar parameters use B.IOR; vector parameters and source 2 use explicit Local or Shared bindings.
- Raw reductions precede every extension stage; all results and flags publish atomically.
- Clip-ReLU computes the typed minimum of its input and one scalar U16, S16, or FP16 ceiling according to the stage type; it does not imply a separate lower clamp.
- PWL uses one explicit 11xN U64 Local or Shared table: row 0 is a shift distance, rows 1..5 are five FP19 rescale values, and rows 6..10 are five signed S17 offsets. Negative shifted inputs select offset 0 with zero rescale; nonnegative shifted inputs select bin min(shifted, 4).

Defaults: omission of each extension selects merged PR1 behavior; every encoded zero field selects None/Inherit.
Compatibility: inapplicable nonzero controls reject with Fault_TileLegality; reserved encoded values do not decode and raise Fault_IllegalInstruction; missing/duplicate/misplaced extension forms raise Fault_BundleControl.
Encoding impact: three new standalone L32 command forms; existing forms unchanged.
Toolchain impact: generated command catalog, decoder, docs, AVS, traceability, and binary-closure updates.
Release impact: additive architecture surface requiring exact-head release evidence.
Open questions: none.
```

Expected: one issue URL retained for the PR.

- [ ] **Step 4: Run the merged-PR1 baseline gates**

```bash
make pr-check
make repo-check
git diff --check
```

Expected: all pass.

### Task 2: Add three separately owned command forms and placement state

**Files:**
- Create: `asl/block/attributes/B.FPATR.PRE.asl`
- Create: `asl/block/attributes/B.FPATR.ELT.asl`
- Create: `asl/block/attributes/B.FPATR.POST.asl`
- Modify: `asl/block/model/state/types.asl`
- Modify: `asl/block/model/state/control-state.asl`
- Modify: `asl/block/model/state/descriptor-state.asl`
- Modify: `asl/block/model/schema/attributes.asl`
- Modify: `asl/block/model/dispatch/commands.asl`
- Test: `tests/asl/block/attributes/B.FPATR.PRE/block-decode-b-fpatr-pre-canonical-001.asl`
- Test: `tests/asl/block/attributes/B.FPATR.ELT/block-decode-b-fpatr-elt-canonical-001.asl`
- Test: `tests/asl/block/attributes/B.FPATR.POST/block-decode-b-fpatr-post-canonical-001.asl`
- Generated: `docs/block/attributes/B.FPATR.PRE.md`
- Generated: `docs/block/attributes/B.FPATR.ELT.md`
- Generated: `docs/block/attributes/B.FPATR.POST.md`

**Interfaces:**
- Produces: `BundleFixedPointPreAttributes`, `BundleFixedPointElementwiseAttributes`, and `BundleFixedPointPostAttributes` records.
- Produces: handlers `SetBundleFixedPointPreAttributes`, `SetBundleFixedPointElementwiseAttributes`, and `SetBundleFixedPointPostAttributes`.
- Requires: the existing `_BundleFixedPointAttributes.valid` anchor before any extension can be placed.

- [ ] **Step 1: Write canonical decode tests for each separate owner**

Each test must assert its exact mask/match, every operand field, semantic handler, positive decode witness, and canonical assembly. For PRE, include:

```asl
assert InstructionContractMatches_B_FPATR_PRE(operation);
assert CommandHandlerOfForm(form) ==
    CommandHandler_SetBundleFixedPointPreAttributes;
assert DecodeCommandOperandRaw(instruction, form,
    CommandField_OutputOverride)[1:0] == '10';
```

Use equivalent ELT and POST assertions for every locked field above.

- [ ] **Step 2: Run catalog/test topology checks and verify RED**

Run:

```bash
./scripts/check-asl-layout
./scripts/check-asl-tests
python3 scripts/project_asl_catalogs.py --root . --check
```

Expected: failure because the three ASL owners and catalog records do not exist.

- [ ] **Step 3: Add the three normative instruction owners**

Each file must contain one `PTO-INSTRUCTION` record, one NDF clause, the exact assembly and encoding table above, closed decode constraints, zero meanings, placement, fault, state, and no-memory-effect contracts. Use independent helpers:

```asl
pure func BundleFPATRPreFieldsLegal(...) => boolean;
pure func BundleFPATRElementwiseFieldsLegal(...) => boolean;
pure func BundleFPATRPostFieldsLegal(...) => boolean;
```

Do not place three command definitions in `B.FPATR.asl`.

- [ ] **Step 4: Add explicit descriptor records and command dispatch**

Add three records with `valid` plus exactly their encoded fields. `BundleFixedPointExtensionCanBePlaced()` must require active Matrix block, no body, anchor already valid, no scalar/Local/Shared binding yet, and the selected extension's `valid == FALSE`.

Dispatch decode-reserved encodings as `Fault_IllegalInstruction`; placement/duplicate violations as `Fault_BundleControl`; accepted incompatible field combinations as `Fault_TileLegality`.

- [ ] **Step 5: Regenerate decoders/docs and verify GREEN**

Run:

```bash
python3 scripts/project_asl_catalogs.py --root . --write
python3 scripts/instruction_docs.py generate
python3 scripts/generate-mnemonic-avs.py --write
make check-decoder-partition
./scripts/check-asl-tests
```

Then run the three new IDs with `./scripts/run-asl-test --id`. Expected: all pass and docs exist at the exact same basenames.

- [ ] **Step 6: Commit the command/state surface**

```bash
git add asl/block/attributes/B.FPATR.PRE.asl \
  asl/block/attributes/B.FPATR.ELT.asl \
  asl/block/attributes/B.FPATR.POST.asl \
  asl/block/model/state/types.asl \
  asl/block/model/state/control-state.asl \
  asl/block/model/state/descriptor-state.asl \
  asl/block/model/schema/attributes.asl \
  asl/block/model/dispatch/commands.asl \
  docs/block/attributes/B.FPATR.PRE.md \
  docs/block/attributes/B.FPATR.ELT.md \
  docs/block/attributes/B.FPATR.POST.md \
  tests/asl/block/attributes/B.FPATR.PRE \
  tests/asl/block/attributes/B.FPATR.ELT \
  tests/asl/block/attributes/B.FPATR.POST \
  spec/catalog
git commit -m "feat: add FPATR extension command forms"
```

### Task 3: Close reset, trap, completion, and ordering lifecycle

**Files:**
- Modify: `asl/block/model/lifecycle/reset.asl`
- Modify: `asl/arch/state/trap-context.asl`
- Modify: `asl/block/model/state/descriptor-state.asl`
- Modify: `asl/block/model/dispatch/commands.asl`
- Test: `tests/asl/block/attributes/B.FPATR.PRE/block-state-b-fpatr-pre-lifecycle-002.asl`
- Test: `tests/asl/block/attributes/B.FPATR.ELT/block-state-b-fpatr-elt-lifecycle-002.asl`
- Test: `tests/asl/block/attributes/B.FPATR.POST/block-state-b-fpatr-post-lifecycle-002.asl`

**Interfaces:**
- Produces: trap-context fields for all three records.
- Preserves: bundle reset and successful completion clear anchor plus all extensions together.

- [ ] **Step 1: Add lifecycle tests before implementation**

For each mnemonic, prove:

```text
omission leaves valid false and PR1 behavior active
placement before B.FPATR -> Fault_BundleControl
duplicate -> Fault_BundleControl
placement after B.IOR/B.IOT/B.IOS or body start -> Fault_BundleControl
trap save/restore preserves every valid bit and field
reset clears every valid bit and field
successful completion clears extension state for the next bundle
```

- [ ] **Step 2: Run the three tests and verify RED**

Use `./scripts/run-asl-test --id` for `PTO-AVS-BLOCK-B-FPATR-PRE-LIFECYCLE-002`, `...ELT...`, and `...POST...`.

Expected: trap/reset/next-bundle assertions fail until the new records are wired through every lifecycle path.

- [ ] **Step 3: Extend trap and reset state symmetrically**

Add fields adjacent to `bundle_fixed_point_attributes` in the trap context. Save, restore, initialization, explicit reset, successful completion, and rollback must copy or clear all three records as a group.

- [ ] **Step 4: Run lifecycle and existing anchor reset tests and verify GREEN**

Run the three new IDs plus:

```bash
./scripts/run-asl-test --id PTO-AVS-BLOCK-B-FPATR-RESET-CLEAR-001
```

Expected: all pass.

- [ ] **Step 5: Commit lifecycle closure**

```bash
git add asl/block/model/lifecycle/reset.asl \
  asl/arch/state/trap-context.asl \
  asl/block/model/state/descriptor-state.asl \
  asl/block/model/dispatch/commands.asl \
  tests/asl/block/attributes/B.FPATR.PRE/block-state-b-fpatr-pre-lifecycle-002.asl \
  tests/asl/block/attributes/B.FPATR.ELT/block-state-b-fpatr-elt-lifecycle-002.asl \
  tests/asl/block/attributes/B.FPATR.POST/block-state-b-fpatr-post-lifecycle-002.asl
git commit -m "feat: preserve FPATR extension lifecycle"
```

### Task 4: Implement PRE output overrides, hybrid HiF8, NaN policy, Clip-ReLU, and PWL

**Files:**
- Create: `asl/arch/profile/matrix-pre-stage.asl`
- Modify: `asl/arch/profile/matrix-quantization.asl`
- Modify: `asl/arch/profile/matrix-postprocess.asl`
- Test: `tests/asl/arch/profile/matrix-pre-stage/arch-exec-matrix-pre-formats-001.asl`
- Test: `tests/asl/arch/profile/matrix-pre-stage/arch-exec-matrix-pre-activation-002.asl`
- Test: `tests/asl/block/attributes/B.FPATR.PRE/block-exec-b-fpatr-pre-compat-003.asl`
- Generated: `docs/arch/profile/matrix-pre-stage.md`

**Interfaces:**
- Produces: `MatrixPreOutputType(anchor_mode: bits(6), override: bits(2)) => TileDataType`.
- Produces: `ReferenceE5M2Encoding(value: real, control: NumericExecutionControl, nan_preserve: boolean) => (Word, bits(5))`.
- Produces: `ReferenceHiF8HybridEncoding(value: real, threshold: bits(14), control: NumericExecutionControl) => (Word, bits(5))`.
- Produces: `MatrixExtendedPreStageWithFlags(value: Word, anchor: BundleFixedPointAttributes, extension: BundleFixedPointPreAttributes, quant_param: Word, activation_param: Word, threshold_param: Word, control: NumericExecutionControl) => (Word, TileDataType, bits(5))`.

- [ ] **Step 1: Add U8, E5M2, HiF8, and NaN-policy RED vectors**

Cover normal, minimum/maximum, halfway, one-ULP-below/above, overflow, qNaN, sNaN, both infinities, and both zeros. Compatibility assertions are exact:

```text
OutputOverride=U8   only with anchor modes whose assigned result is S8
OutputOverride=E5M2 only with anchor E4M3 modes
HiF8Hybrid=1        only with anchor HiF8 modes and a legal 14-bit threshold scalar role
NaNPreserve=1       only with floating destination
ActivationExt!=0    requires anchor ReluMode=None
```

- [ ] **Step 2: Run new PRE points and verify RED**

Run all three new IDs with `./scripts/run-asl-test --id`.

Expected: failure because extended output selection and algorithms are absent.

- [ ] **Step 3: Implement E5M2 and hybrid HiF8 as focused profile helpers**

Reuse `E5M2NumericFormatDescriptor`, `E5M2FiniteDecomposition`, and canonical format helpers. Hybrid HiF8 must compare the discarded threshold field at every exponent boundary and choose the assigned half-away result when the retained/discarded comparison meets the encoded threshold; include both signs and D2/D3/D4 boundaries.

- [ ] **Step 4: Implement Clip-ReLU and PWL with explicit roles**

Clip-ReLU consumes one scalar `B.IOR` word and computes `min(value, ceiling)`. Interpret the low 16 bits as U16 for U8, S16 for S4/S8/S16, and FP16 for FP16; reject Clip-ReLU for every other stage type.

PWL consumes one explicit 11xN U64 Local or Shared Tile. Row 0 supplies a shift distance in `0..31`; rows 1..5 supply five legal FP19 rescale carriers; rows 6..10 supply five sign-extended S17 offsets. For signed integer source `x`, compute `shifted = ASR(x, distance)`. If `shifted < 0`, select zero rescale and offset entry 0; otherwise select entry `min(shifted, 4)`. Feed `x * selected_rescale + selected_offset` into the owning mode's assigned intermediate round/saturate point. Reject PWL for a floating source mode or malformed table before effects.

- [ ] **Step 5: Run PRE tests and existing PR1 numeric tests and verify GREEN**

Run the three PRE IDs, the PR1 zero-affine/order/special points, and `PTO-AVS-BLOCK-B-FPATR-ALL-MODES-007`.

Expected: omission produces byte-for-byte PR1 results; every enabled extension produces exact values/flags.

- [ ] **Step 6: Regenerate and commit PRE semantics**

```bash
python3 scripts/instruction_docs.py generate
git add asl/arch/profile/matrix-pre-stage.asl \
  asl/arch/profile/matrix-quantization.asl \
  asl/arch/profile/matrix-postprocess.asl \
  docs/arch/profile/matrix-pre-stage.md \
  tests/asl/arch/profile/matrix-pre-stage \
  tests/asl/block/attributes/B.FPATR.PRE/block-exec-b-fpatr-pre-compat-003.asl
git commit -m "feat: implement FPATR extended pre stage"
```

### Task 5: Resolve explicit elementwise and anti-quant operand roles

**Files:**
- Create: `asl/arch/profile/matrix-elementwise-stage.asl`
- Modify: `asl/block/model/dispatch/scalar-schema.asl`
- Modify: `asl/block/model/dispatch/tile-schema.asl`
- Modify: `asl/block/model/dispatch/descriptor-legality.asl`
- Modify: `asl/block/model/dispatch/cube-tmatmul.asl`
- Modify: `asl/tile/model/legality/matrix-postprocess.asl`
- Test: `tests/asl/arch/profile/matrix-elementwise-stage/arch-exec-matrix-elementwise-001.asl`
- Test: `tests/asl/block/attributes/B.FPATR.ELT/block-bound-b-fpatr-elt-bindings-003.asl`
- Test: `tests/asl/block/attributes/B.FPATR.ELT/block-fault-b-fpatr-elt-alias-004.asl`
- Generated: `docs/arch/profile/matrix-elementwise-stage.md`

**Interfaces:**
- Produces: `MatrixAntiQuantizeSource2(value: Word, source_type: TileDataType, mode: bits(4), parameter: Word, control: NumericExecutionControl) => (Word, TileDataType, bits(5))`.
- Produces: `MatrixElementwiseWithFlags(left: Word, right: Word, data_type: TileDataType, operation: bits(3), control: NumericExecutionControl) => (Word, bits(5))`.
- Produces ordered role resolvers for scalar anti-quant parameter, vector anti-quant Tile, and explicit source-2 Local or Shared binding.

- [ ] **Step 1: Add arithmetic, anti-quant, broadcast, and alias RED vectors**

Cover Add, Subtract, Multiply, Maximum; qNaN/sNaN, infinities, signed zeros, overflow and numeric flags; all eight scalar/vector S8/S4/U8/S16 anti-quant modes; full MxN source 2; 1xN PerColumn+MBroadcast; Shared source; source-2/D read-old/write-new alias; and illegal partial/shape/layout/undefined/packed-lane aliases.

- [ ] **Step 2: Run the three new points and verify RED**

Run the new architecture, binding, and alias IDs. Expected: failure because no extension role inventory or stage exists.

- [ ] **Step 3: Extend the ordered schema without hidden storage**

Append roles after mathematical sources, raw auxiliary input, PRE vector parameters, and before destinations in one documented order:

```text
source2 -> scalar anti-quant B.IOR or vector anti-quant Local/Shared -> POST/PRE remaining vectors
```

Use existing maximums `PTO_BUNDLE_SCALAR_BINDING_COUNT=32` and `PTO_BUNDLE_TILE_BINDING_COUNT=16` unless a constructed worst-case legal schema exceeds them. The worst-case test must count every role and prove the bound; do not expand a model capacity without that proof.

- [ ] **Step 4: Implement typed anti-quant then elementwise arithmetic**

Interpret S4/S8/U8/S16 source 2 before scale/offset. Anti-quant output must match the left PRE-stage type. Apply the selected operation element-by-element after source-2 broadcast. Snapshot left, source 2, and every parameter before any result write.

- [ ] **Step 5: Run all ELT points and verify GREEN**

Run the three new IDs plus descriptor-legality and CUBE schema points selected by `rg -l 'BundleMatrixPostProcess' tests/asl/block tests/asl/tile`.

Expected: all legal Local/Shared/broadcast cases pass; every malformed role fails before effects.

- [ ] **Step 6: Regenerate and commit ELT semantics**

```bash
python3 scripts/instruction_docs.py generate
git add asl/arch/profile/matrix-elementwise-stage.asl \
  asl/block/model/dispatch/scalar-schema.asl \
  asl/block/model/dispatch/tile-schema.asl \
  asl/block/model/dispatch/descriptor-legality.asl \
  asl/block/model/dispatch/cube-tmatmul.asl \
  asl/tile/model/legality/matrix-postprocess.asl \
  docs/arch/profile/matrix-elementwise-stage.md \
  tests/asl/arch/profile/matrix-elementwise-stage \
  tests/asl/block/attributes/B.FPATR.ELT
git commit -m "feat: implement FPATR elementwise stage"
```

### Task 6: Implement post conversion, activation, shift, and bit mask

**Files:**
- Create: `asl/arch/profile/matrix-post-stage.asl`
- Modify: `asl/block/model/dispatch/scalar-schema.asl`
- Modify: `asl/block/model/dispatch/tile-schema.asl`
- Modify: `asl/tile/model/legality/matrix-postprocess.asl`
- Test: `tests/asl/arch/profile/matrix-post-stage/arch-exec-matrix-post-modes-001.asl`
- Test: `tests/asl/arch/profile/matrix-post-stage/arch-exec-matrix-post-mask-002.asl`
- Test: `tests/asl/block/attributes/B.FPATR.POST/block-exec-b-fpatr-post-compat-003.asl`
- Generated: `docs/arch/profile/matrix-post-stage.md`

**Interfaces:**
- Produces: `MatrixExtendedPostStageWithFlags(value: Word, input_type: TileDataType, extension: BundleFixedPointPostAttributes, quant_param: Word, activation_param: Word, control: NumericExecutionControl) => (Word, TileDataType, bits(5))`.
- Produces: `MatrixDestinationBitMask(value: Word, destination_type: TileDataType, count: integer {0..4}) => Word`.

- [ ] **Step 1: Add all eighteen post-mode RED vectors**

For codes 1..18, cover scalar/vector parameter routing, the exact source class, signed/unsigned B8 choice, intermediate rounding/saturation, offset, final destination, and flags. Add halfway and endpoint vectors for S4, S8, U8, and S16 shift forms.

- [ ] **Step 2: Add post activation and bit-mask RED vectors**

Cover ReLU, scalar LReLU, vector PReLU, five-bin PWL, and scalar Clip-ReLU. BitMask 1..4 must clear exactly the least-significant destination bits after activation; reject nonzero masks for destinations other than S8/U8/S16 and reject reserved 5..7 at decode.

- [ ] **Step 3: Run new POST points and verify RED**

Run the three new IDs. Expected: failure because the post-stage profile and schema roles are absent.

- [ ] **Step 4: Implement the post mode table and compatibility checks**

Use a closed selector, not a generic cast. Require PostReluMode and ClipReLU to be mutually exclusive; require `UnsignedOutput=0` for S4/S16/non-B8 modes; require `NaNPreserve=0` for integer destinations; apply B.DATR rounding and Sat only at the defined post-stage points.

- [ ] **Step 5: Implement activation then bit masking in exact order**

The final stage order is:

```asl
let (converted, converted_type, conversion_flags) = MatrixPostConvert(...);
let (activated, activation_flags) = MatrixPostActivate(...);
let masked = MatrixDestinationBitMask(
    activated, converted_type, UInt(extension.bit_mask));
return (masked, converted_type, conversion_flags OR activation_flags);
```

- [ ] **Step 6: Run all POST points and verify GREEN**

Run the three new IDs, all PRE/ELT architecture points, and PR1 B.FPATR mode/special points. Expected: omission is identical to PR1 and all enabled stages match exact vectors.

- [ ] **Step 7: Regenerate and commit POST semantics**

```bash
python3 scripts/instruction_docs.py generate
git add asl/arch/profile/matrix-post-stage.asl \
  asl/block/model/dispatch/scalar-schema.asl \
  asl/block/model/dispatch/tile-schema.asl \
  asl/tile/model/legality/matrix-postprocess.asl \
  docs/arch/profile/matrix-post-stage.md \
  tests/asl/arch/profile/matrix-post-stage \
  tests/asl/block/attributes/B.FPATR.POST/block-exec-b-fpatr-post-compat-003.asl
git commit -m "feat: implement FPATR extended post stage"
```

### Task 7: Integrate the complete pipeline and prove late rollback

**Files:**
- Modify: `asl/arch/profile/matrix-postprocess.asl`
- Modify: `asl/tile/model/execution/postprocess.asl`
- Modify: `asl/block/model/dispatch/destination-shape.asl`
- Test: `tests/asl/arch/profile/matrix-postprocess/arch-exec-matrix-extended-pipeline-003.asl`
- Test: `tests/asl/tile/model/execution/postprocess/tile-atomic-postprocess-extended-004.asl`
- Test: `tests/asl/block/attributes/B.FPATR.POST/block-atomic-b-fpatr-post-rollback-004.asl`
- Generated: `docs/arch/profile/matrix-postprocess.md`
- Generated: `docs/tile/model/execution/postprocess.md`

**Interfaces:**
- Produces: one integrated evaluator executing raw reduction -> PRE -> anti-quant/source2 -> ELT -> POST -> clip/PWL -> bit mask.
- Preserves: one final publication block for D, raw auxiliaries, descriptors, representation, and numeric status.

- [ ] **Step 1: Add representative combined-pipeline vectors**

Include at least:

```text
FP32 raw -> E5M2 PRE -> Add broadcast FP16 source2 -> S8 POST -> ReLU -> mask 3
S32 raw -> U8 PRE -> Multiply anti-quantized S8 source2 -> S16 POST
HiF8 hybrid PRE -> Maximum -> no POST with NaN preservation
raw RowMax/GroupMax enabled while all three D stages are enabled
```

Compute expected raw auxiliaries independently from expected D.

- [ ] **Step 2: Add the maximum-role and last-stage-failure rollback vectors**

Construct the legal maximum scalar/Local/Shared role inventory. Then make the final POST vector parameter invalid or the final destination capacity insufficient. Snapshot sources, D, auxiliaries, descriptor records, trap-visible state, allocation, representation, and flags; assert full preservation after the assigned fault.

- [ ] **Step 3: Run combined points and verify RED**

Run the three new IDs. Expected: failure until the integrated evaluator and full preflight are wired.

- [ ] **Step 4: Integrate without intermediate architectural writes**

Use local `TileInfo`/payload values for every stage. Do not update `_Tiles`, numeric status, destination descriptor, or public representation between stages. Raw auxiliary computations must read the original CUBE result, not the evolving D temporary.

- [ ] **Step 5: Run combined, atomic, and omission points and verify GREEN**

Run the three new IDs, PR1 rollback/aux points, all three lifecycle points, and all PRE/ELT/POST owner points.

Expected: exact combined values and zero partial effects on every rejected late case.

- [ ] **Step 6: Regenerate and commit pipeline integration**

```bash
python3 scripts/instruction_docs.py generate
git add asl/arch/profile/matrix-postprocess.asl \
  asl/tile/model/execution/postprocess.asl \
  asl/block/model/dispatch/destination-shape.asl \
  docs/arch/profile/matrix-postprocess.md \
  docs/tile/model/execution/postprocess.md \
  tests/asl/arch/profile/matrix-postprocess/arch-exec-matrix-extended-pipeline-003.asl \
  tests/asl/tile/model/execution/postprocess/tile-atomic-postprocess-extended-004.asl \
  tests/asl/block/attributes/B.FPATR.POST/block-atomic-b-fpatr-post-rollback-004.asl
git commit -m "feat: integrate FPATR extended pipeline"
```

### Task 8: Close catalogs, evidence, and the PR2 exact head

**Files:**
- Regenerate: `spec/catalog/command-forms.json`
- Regenerate: `spec/evidence/instruction-contract-closure.json`
- Regenerate: `spec/evidence/executable-model-comparison.json`
- Regenerate: `spec/release-manifest.json`
- Regenerate only when selected: remaining generated docs/navigation/catalog/evidence files.

**Interfaces:**
- Produces: three accepted collision-free command forms, independent AVS ownership, exact traceability, and a release-clean PR2 branch.

- [ ] **Step 1: Regenerate every owned projection**

Run:

```bash
python3 scripts/project_asl_catalogs.py --root . --write
python3 scripts/instruction_docs.py generate
python3 scripts/generate-mnemonic-avs.py --write
./scripts/generate-instruction-contract-closure
./scripts/generate-release-traceability-readiness
./scripts/generate-release-gate-readiness
./scripts/generate-release-manifest
```

Expected: all three new mnemonics appear in catalog, docs, AVS, traceability, and manifest with separate owners.

- [ ] **Step 2: Prove encoding and reserved closure**

Run:

```bash
make check-decoder-partition
./scripts/check-binary-closure
python3 scripts/project_asl_catalogs.py --root . --check
```

Expected: no overlaps, every field has an exact domain/reserved set, and every canonical binary witness closes.

- [ ] **Step 3: Execute every new or modified ASL point**

Run each ID from Tasks 2-7 with `./scripts/run-asl-test --id`. Also run the unchanged PR1 `ALL-MODES`, `ZERO-AFFINE`, `SPECIAL`, `AUX`, and rollback points.

Expected: all pass under pinned ASLRef.

- [ ] **Step 4: Run repository gates and inspect scope**

Run:

```bash
make pr-check
make repo-check
git diff --check
git status --short
git diff --name-only origin/main | rg -n 'memory|layout|cache|unit.flag|winograd|loopenhance|nz2n' && exit 1 || true
```

Expected: gates pass; no out-of-scope transport/layout/synchronization implementation file is changed; no generated build/cache artifact is tracked.

- [ ] **Step 5: Commit generated closure**

```bash
git add asl docs tests/asl spec/catalog spec/evidence spec/release-manifest.json
git commit -m "spec: close FPATR extended-stage evidence"
```

- [ ] **Step 6: Push and open PR2 linked to its own issue and PR1**

```bash
git push -u origin codex/fpatr-extended-stages
gh pr create --title "Add explicit FPATR pre elementwise and post stages" --body "Adds the approved PR2 extension forms after merged numeric-parity PR1. Closes the NDF issue URL returned in Task 1. Excludes transfer, layout, synchronization, cache, unit-flag, and memory-atomic behavior."
```

Expected: a PR URL on `codex/fpatr-extended-stages` with PR1 already present in its base.

- [ ] **Step 7: Require hosted exact-head validation**

Run:

```bash
gh pr checks --watch
```

Expected: `PR / validate` succeeds for the exact SHA returned by `git rev-parse HEAD` before merge.
