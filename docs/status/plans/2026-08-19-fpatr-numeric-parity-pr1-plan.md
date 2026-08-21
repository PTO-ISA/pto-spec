# FPATR Numeric Parity PR1 Implementation Plan

**Goal:** Correct the bit-exact numeric, legality, fault, and atomic-publication behavior of the existing twenty-seven `B.FPATR` modes without changing any command encoding or operand role.

**Architecture:** Keep `B.FPATR` as the required Matrix post-process anchor and retain its mask, match, fields, and closed mode table. Refactor the profile hook into explicit source classification, sign-dependent multiplier selection, mode-specific intermediate rounding/saturation, offset, and final encoding; keep raw RowMax/GroupMax evaluation and complete output publication in the Tile layer.

**Tech Stack:** ASL1 at `.aslref-version`, PTO NDF clauses, generated Markdown/catalog/evidence projections, Python 3 generators, GNU Make, pinned ASLRef.

## Global Constraints

- Start from the exact merged `main` commit and open one linked NDF architecture-change issue before editing normative ASL.
- Change no `B.FPATR` assembly spelling, mask `0x00007fff`, match `0x00002023`, field position, `PreQuantMode` allocation, source/destination role, or CUBE selector.
- Keep ASL as the only normative source; generated docs are projections and must not be hand-edited.
- Do not commit private reference names, paths, prose, code, diagrams, encodings, citations, or indexes.
- Preserve raw-accumulator RowMax/GroupMax semantics and one atomic Local Tile publication group.
- Preserve the one-level Tile architecture; add no implicit parameter buffer, body-local queue, replay state, memory transfer, layout transform, cache policy, unit flag, or memory-atomic behavior.
- Put every executable test below the exact mirror of its primary ASL owner and retain the repository filename grammar.
- Use RED-GREEN TDD per task; do not update an expected result until a failing test proves the old behavior.
- Stop only after `make pr-check`, `make repo-check`, `git diff --check`, all affected ASL points, and hosted `PR / validate` pass at the exact reviewed head.

---

### Task 1: Open the PR1 architecture issue and establish the branch baseline

**Files:**
- Reference: `docs/status/plans/2026-08-19-fpatr-functional-parity-design.md`
- Reference: `CONTRIBUTING.md`
- No repository file changes in this task.

**Interfaces:**
- Consumes: merged `main` commit SHA and the approved PR1 design section.
- Produces: one NDF issue URL naming `PTO-B-FPATR-MATRIX-POSTPROCESS-001`, `PTO-FP19-PARAMETER-CARRIER-001`, `PTO-MATRIX-QUANT-BITEXACT-001`, `PTO-MATRIX-POSTPROCESS-BITEXACT-001`, and `PTO-REQ-CUBE-POSTPROCESS-001`.

- [ ] **Step 1: Create a clean PR1 branch from the exact current main**

Run:

```bash
git fetch origin main
git switch -c codex/fpatr-numeric-parity origin/main
git rev-parse HEAD
git status --short
```

Expected: a clean branch whose printed SHA equals `origin/main`.

- [ ] **Step 2: Open the NDF architecture-change issue with the complete accepted contract**

Run `gh issue create` with title `NDF: correct B.FPATR numeric pipeline semantics` and this exact body:

```text
Baseline: the full 40-character commit printed by git rev-parse HEAD.

Affected clauses:
- PTO-B-FPATR-MATRIX-POSTPROCESS-001
- PTO-FP19-PARAMETER-CARRIER-001
- PTO-MATRIX-QUANT-BITEXACT-001
- PTO-MATRIX-POSTPROCESS-BITEXACT-001
- PTO-REQ-CUBE-POSTPROCESS-001

Decision:
- Existing B.FPATR encodings and its 27 assigned PreQuantMode values remain unchanged.
- Activation selects the negative-path multiplier before destination conversion.
- Floating signed zero participates in scale and offset; it is not a terminal special case.
- REQ4/REQ8/DEQS16 and shift modes retain their assigned intermediate saturation and rounding points before final Sat clamp or wrap.
- F32-to-F16/BF16 and F32-to-E4M3 fixed conversions use RNE; HiF8 retains half-away.
- FP19 scale is positive finite normal nonzero; activation is finite nonnegative normal or zero. Subnormal, infinity, NaN, nonzero unused bits, and wrong-sign carriers reject before effects.
- Decode-reserved encodings are Fault_IllegalInstruction; accepted but incompatible state/fields/parameters/bindings/shapes/aliases are Fault_TileLegality; missing/duplicate/misplaced/non-Matrix use is Fault_BundleControl.
- RowMax and GroupMax consume the raw accumulator and publish with D and numeric status atomically.

Defaults: unchanged from the existing B.FPATR contract.
Encoding impact: none.
Assembly impact: none.
Toolchain impact: expected-result updates only; no parser or decoder surface change.
Release impact: numeric ABI correction requiring fresh AVS and release evidence.
Open questions: none.
```

Expected: `gh` returns a new issue URL; retain it for every commit/PR description.

- [ ] **Step 3: Prove the unchanged baseline passes the short repository gates**

Run:

```bash
make pr-check
make repo-check
git diff --check
```

Expected: all commands pass before semantic edits.

### Task 2: Reject non-normal FP19 parameters before effects

**Files:**
- Modify: `asl/arch/data-types/fp19.asl`
- Test: `tests/asl/arch/data-types/fp19/arch-bound-fp19-parameter-domain-002.asl`
- Generated: `docs/arch/data-types/fp19.md`

**Interfaces:**
- Consumes: `FP19ValueClass(value: bits(19)) => NumericValueClass`.
- Produces: unchanged signatures `FP19ScaleLegal(value: bits(19)) => boolean` and `FP19ActivationParameterLegal(value: bits(19)) => boolean`, with normal-only finite domains.

- [ ] **Step 1: Add the independent FP19 domain test**

Create one `PTO-TEST` point sourced from `asl/arch/data-types/fp19.asl` and assert this exact matrix:

```asl
assert !FP19ScaleLegal('0000000000000000000);       // +0
assert !FP19ScaleLegal('0000000000000000001);       // min +subnormal
assert FP19ScaleLegal('0000000001000000000);        // min +normal
assert FP19ScaleLegal('0111111101111111111);         // max +normal
assert !FP19ScaleLegal('1000000001000000000);       // negative normal
assert !FP19ScaleLegal('0111111111000000000);        // +infinity
assert !FP19ScaleLegal('0111111111100000000);        // qNaN
assert !FP19ScaleLegal('0111111111000000001);        // sNaN

assert FP19ActivationParameterLegal('0000000000000000000);  // +0
assert !FP19ActivationParameterLegal('0000000000000000001); // subnormal
assert FP19ActivationParameterLegal('0000000001000000000);  // min normal
assert !FP19ActivationParameterLegal('1000000000000000000); // -0/wrong sign
assert !FP19ActivationParameterLegal('0111111111000000000); // infinity
assert !FP19ActivationParameterLegal('0111111111100000000); // qNaN
```

- [ ] **Step 2: Run the focused test and verify RED**

Run:

```bash
./scripts/check-asl-tests
./scripts/run-asl-test --id PTO-AVS-ARCH-FP19-PARAMETER-DOMAIN-002
```

Expected: the point fails because the current helpers accept FP19 subnormals.

- [ ] **Step 3: Narrow both legality helpers to zero-or-normal as assigned**

Implement the domain explicitly:

```asl
pure func FP19ScaleLegal(value: bits(19)) => boolean
begin
    return value[18] == '0' &&
           FP19ValueClass(value) == NumericValue_PositiveNormal;
end;

pure func FP19ActivationParameterLegal(value: bits(19)) => boolean
begin
    let value_class = FP19ValueClass(value);
    return value[18] == '0' &&
           (value_class == NumericValue_PositiveZero ||
            value_class == NumericValue_PositiveNormal);
end;
```

Update `PTO-FP19-PARAMETER-CARRIER-001` to state that subnormal carriers are illegal and that activation alone admits positive zero.

- [ ] **Step 4: Regenerate the same-basename documentation and verify GREEN**

Run:

```bash
python3 scripts/instruction_docs.py generate
./scripts/run-asl-test --id PTO-AVS-ARCH-FP19-PARAMETER-DOMAIN-002
python3 scripts/instruction_docs.py --check
```

Expected: the test and documentation check pass.

- [ ] **Step 5: Commit the FP19 domain correction**

```bash
git add asl/arch/data-types/fp19.asl \
  docs/arch/data-types/fp19.md \
  tests/asl/arch/data-types/fp19/arch-bound-fp19-parameter-domain-002.asl
git commit -m "fix: narrow FPATR FP19 parameter domain"
```

### Task 3: Model the assigned intermediate rounding and saturation points

**Files:**
- Modify: `asl/arch/profile/matrix-quantization.asl`
- Test: `tests/asl/arch/profile/matrix-quantization/arch-exec-matrix-intermediate-002.asl`
- Test: `tests/asl/block/attributes/B.FPATR/block-exec-b-fpatr-rounding-008.asl`
- Generated: `docs/arch/profile/matrix-quantization.md`

**Interfaces:**
- Produces: `MatrixRoundAndSaturateSigned(value: real, width: integer {5,9,17}, rounding_mode: NumericRoundingMode) => (integer {-65536..65535}, bits(5))`.
- Produces: `MatrixQuantizedAffine(value: real, scale: real, offset: integer, intermediate_width: integer {0,5,9,17}, output_type: TileDataType, control: NumericExecutionControl) => (Word, bits(5))`.
- Produces: `MatrixShiftS32ToS16(value: bits(32), shift: integer {1..16}) => (Word, bits(5))`.

- [ ] **Step 1: Write boundary tests for S5, S9, S17, and shift rounding**

The architecture test must cover each signed intermediate at minimum, maximum, one below, one above, and both halfway directions. The mnemonic test must prove that final `Sat=0` wrapping occurs only after intermediate saturation:

```asl
let (s9_hi, s9_hi_flags) = MatrixRoundAndSaturateSigned(
    255.75, 9, NumericRound_RNE);
assert s9_hi == 255;
assert s9_hi_flags == Zeros{5} + 0x14;

let (s9_lo, s9_lo_flags) = MatrixRoundAndSaturateSigned(
    -256.75, 9, NumericRound_RNE);
assert s9_lo == -256;
assert s9_lo_flags == Zeros{5} + 0x14;

let (shifted, shifted_flags) = MatrixShiftS32ToS16(
    '11111111111111111111111111011111', 1);
assert shifted == Zeros{PTO_XLEN} + 0xffffffffffffffef;
assert shifted_flags == Zeros{5};
```

Use analogous exact assertions for S5 `[-16,15]` and S17 `[-65536,65535]`; add RNE, RNA, RTZ, RTP, and RTM tie distinguishers at the mode-defined point.

- [ ] **Step 2: Run both focused points and verify RED**

Run:

```bash
./scripts/check-asl-tests
./scripts/run-asl-test --id PTO-AVS-ARCH-MATRIX-INTERMEDIATE-002
./scripts/run-asl-test --id PTO-AVS-BLOCK-B-FPATR-ROUNDING-008
```

Expected: both fail because the current generic `real -> destination` path has no explicit S5/S9/S17 intermediate.

- [ ] **Step 3: Add the intermediate helper and keep final Sat behavior separate**

Implement signed bounds from `width` and return OF|NX (`0x14`) when intermediate clamping changes the rounded mathematical integer. `MatrixQuantizedAffine` must execute:

```asl
let scaled = value * scale;
let (intermediate, intermediate_flags) = if intermediate_width == 0 then
    (0, Zeros{5})
else
    MatrixRoundAndSaturateSigned(scaled, intermediate_width, control.rounding_mode);
let affine = if intermediate_width == 0 then scaled + Real(offset)
             else Real(intermediate + offset);
let (encoded, final_flags) = MatrixEncodeReal(affine, output_type, control);
return (encoded, intermediate_flags OR final_flags);
```

`MatrixShiftS32ToS16` must apply the assigned one-through-sixteen arithmetic right shift and its fixed rounding before S16 saturation; it must not route through a floating approximation.

- [ ] **Step 4: Route each existing family to the exact helper**

Use `BundleFPATRModeOffsetWidth` and an explicit mode-family selector so:

```text
REQ4/VREQ4                -> S5 intermediate -> signed offset -> S4X2
REQ8/VREQ8/QF322B8 forms  -> S9 intermediate -> signed offset -> S8
DEQS16/VDEQS16            -> S17 intermediate -> signed offset -> S16
SHIFTS322S16              -> fixed shift/round -> S16 saturation
floating families         -> no integer intermediate
```

Do not change the twenty-seven mode codes.

- [ ] **Step 5: Run focused and existing quantization points and verify GREEN**

Run:

```bash
./scripts/run-asl-test --id PTO-AVS-ARCH-MATRIX-INTERMEDIATE-002
./scripts/run-asl-test --id PTO-AVS-BLOCK-B-FPATR-ROUNDING-008
./scripts/run-asl-test --id PTO-AVS-BLOCK-B-FPATR-QUANT-002
./scripts/run-asl-test --id PTO-AVS-BLOCK-B-FPATR-ALL-MODES-007
```

Expected: all four pass.

- [ ] **Step 6: Regenerate and commit the quantization owner**

```bash
python3 scripts/instruction_docs.py generate
git add asl/arch/profile/matrix-quantization.asl \
  docs/arch/profile/matrix-quantization.md \
  tests/asl/arch/profile/matrix-quantization/arch-exec-matrix-intermediate-002.asl \
  tests/asl/block/attributes/B.FPATR/block-exec-b-fpatr-rounding-008.asl
git commit -m "fix: model FPATR intermediate saturation"
```

### Task 4: Apply activation before destination conversion and keep zero affine

**Files:**
- Modify: `asl/arch/profile/matrix-postprocess.asl`
- Test: `tests/asl/arch/profile/matrix-postprocess/arch-exec-matrix-pipeline-002.asl`
- Test: `tests/asl/block/attributes/B.FPATR/block-exec-b-fpatr-zero-affine-009.asl`
- Modify: `tests/asl/block/attributes/B.FPATR/block-exec-b-fpatr-activation-004.asl`
- Generated: `docs/arch/profile/matrix-postprocess.md`

**Interfaces:**
- Replaces: conversion-first `MatrixActivationWithFlags` use.
- Produces: `MatrixSelectedMultiplier(source_value: real, source_negative: boolean, relu_mode: bits(3), quant_scale: real, relu_param: Word) => real`.
- Preserves: `TileProfileMatrixPostProcessWithFlags(...) => (Word, bits(5))` public signature.

- [ ] **Step 1: Add zero-plus-offset and order-distinguishing tests**

Use FP32 `+0` (`0x00000000`) and `-0` (`0x80000000`) with positive, negative, and zero S9 offsets. Assert that nonzero offsets survive and that signed zero is retained only when the complete affine result is zero and the destination supports signed zero.

Add a negative FP32 input, alpha, and FP16/BF16 boundary where these differ:

```text
encode(source * alpha) != encode(encode(source) * alpha)
```

The expected value must be computed from the pre-conversion product using existing reference encoders, not copied from the production helper.

- [ ] **Step 2: Run the new points and verify RED**

Run:

```bash
./scripts/run-asl-test --id PTO-AVS-ARCH-MATRIX-PIPELINE-002
./scripts/run-asl-test --id PTO-AVS-BLOCK-B-FPATR-ZERO-AFFINE-009
```

Expected: zero-plus-offset fails because `MatrixPostQuantSpecialValue` returns early, and the order vector fails because conversion currently precedes activation.

- [ ] **Step 3: Make zero nonterminal and select the multiplier before conversion**

Keep NaN and infinity classification at the first floating interpretation point, but remove zero from the terminal special-result return. Use this selector:

```asl
pure func MatrixSelectedMultiplier(
    source_value: real, source_negative: boolean,
    relu_mode: bits(3), quant_scale: real, relu_param: Word) => real
begin
    if !source_negative || UInt(relu_mode) == 0 then return quant_scale; end;
    if UInt(relu_mode) == 1 then return 0.0; end;
    return FP19FiniteValue(relu_param[18:0]);
end;
```

Feed `source_value * selected_multiplier` to the mode-specific intermediate/offset/final encoder. Do not multiply a destination encoding or decoded destination value.

- [ ] **Step 4: Close floating fixed-round and special-value behavior**

Ensure the mode dispatcher applies:

```text
F322F16/F322BF16     fixed RNE
QF322FP8 -> E4M3    fixed RNE
QF322HIF8            fixed half-away
QF322F32             scale plus status in FP32
S32 floating modes   signed S32 interpretation before scaling
```

For `Sat=1`, map assigned floating overflow to largest finite and assigned NaN to zero. For `Sat=0`, retain infinity/canonical NaN when the destination represents it; E4M3 uses its assigned NaN or largest finite. Raise NV for sNaN before canonicalization.

- [ ] **Step 5: Expand special-value evidence and verify GREEN**

Update `block-exec-b-fpatr-special-005.asl` to cover qNaN, sNaN, both infinities, both zeros, and subnormals for FP16, BF16, E4M3, and HiF8 under applicable Sat choices. Then run:

```bash
./scripts/run-asl-test --id PTO-AVS-ARCH-MATRIX-PIPELINE-002
./scripts/run-asl-test --id PTO-AVS-BLOCK-B-FPATR-ZERO-AFFINE-009
./scripts/run-asl-test --id PTO-AVS-BLOCK-B-FPATR-ACT-004
./scripts/run-asl-test --id PTO-AVS-BLOCK-B-FPATR-SPECIAL-005
```

Expected: all points pass with exact words and flags.

- [ ] **Step 6: Regenerate and commit the pipeline correction**

```bash
python3 scripts/instruction_docs.py generate
git add asl/arch/profile/matrix-postprocess.asl \
  docs/arch/profile/matrix-postprocess.md \
  tests/asl/arch/profile/matrix-postprocess/arch-exec-matrix-pipeline-002.asl \
  tests/asl/block/attributes/B.FPATR/block-exec-b-fpatr-zero-affine-009.asl \
  tests/asl/block/attributes/B.FPATR/block-exec-b-fpatr-activation-004.asl \
  tests/asl/block/attributes/B.FPATR/block-exec-b-fpatr-special-005.asl
git commit -m "fix: order FPATR activation before conversion"
```

### Task 5: Enforce fixed controls and precise fault classes

**Files:**
- Modify: `asl/block/attributes/B.FPATR.asl`
- Modify: `asl/block/model/dispatch/tile-schema.asl`
- Modify: `asl/block/model/dispatch/scalar-schema.asl`
- Modify: `asl/tile/model/legality/matrix-postprocess.asl`
- Test: `tests/asl/block/attributes/B.FPATR/block-fault-b-fpatr-controls-010.asl`
- Test: `tests/asl/tile/model/legality/matrix-postprocess/tile-bound-matrix-params-002.asl`
- Generated: `docs/block/attributes/B.FPATR.md`
- Generated: `docs/tile/model/legality/matrix-postprocess.md`

**Interfaces:**
- Produces: `BundleFPATRModeFixedRounding(code: bits(6)) => boolean`.
- Produces: `BundleFPATRModeFinalSatProgrammable(code: bits(6)) => boolean`.
- Preserves: decode-reserved values fail before `SetBundleFixedPointAttributeState`.

- [ ] **Step 1: Add control and fault-identity tests**

Assert:

```text
fixed-bit mismatch or decode-reserved mode       -> Fault_IllegalInstruction
duplicate/missing/misplaced/non-Matrix B.FPATR   -> Fault_BundleControl
fixed-round mode with conflicting RMode          -> Fault_TileLegality
mode with inapplicable Sat=1                      -> Fault_TileLegality
bad FP19 carrier or parameter Tile payload       -> Fault_TileLegality
```

For every rejected accepted-encoding case, snapshot TPC, descriptors, Tile payloads, numeric flags, bindings, and allocation state and assert no non-fault effect changed.

- [ ] **Step 2: Run the new points and verify RED**

Run:

```bash
./scripts/run-asl-test --id PTO-AVS-BLOCK-B-FPATR-CONTROLS-010
./scripts/run-asl-test --id PTO-AVS-TILE-MATRIX-PARAMS-002
```

Expected: conflicts fail because the current DATR rule accepts every non-shift `RMode` and independent `Sat`.

- [ ] **Step 3: Encode fixed-versus-programmable controls in the owner**

Implement mode predicates and make `BundleFPATRDATRFieldsLegal` reject a non-default `RMode` for F16, BF16, E4M3, HiF8, and fixed shift modes. Reject `Sat=1` where no final saturation choice exists. Keep programmable integer rounding at the intermediate point and PTO's final clamp/wrap polarity.

- [ ] **Step 4: Make parameter checks precede snapshots and allocation**

In scalar and vector paths, validate all carrier unused bits and every payload word with `BundleFPATRQuantParameterWordLegal` or `BundleFPATRReluParameterWordLegal` during complete preflight. Do not call `FP19FiniteValue` until legality has succeeded for the full operand set.

- [ ] **Step 5: Run the complete mnemonic fault set and verify GREEN**

Run:

```bash
for id in \
  PTO-AVS-BLOCK-B-FPATR-MODE-TABLE-BOUNDARY-001 \
  PTO-AVS-BLOCK-B-FPATR-DUPLICATE-001 \
  PTO-AVS-BLOCK-B-FPATR-GROUP-RSVD-001 \
  PTO-AVS-BLOCK-B-FPATR-INPUT-TYPE-002 \
  PTO-AVS-BLOCK-B-FPATR-NONMATRIX-001 \
  PTO-AVS-BLOCK-B-FPATR-PLACE-001 \
  PTO-AVS-BLOCK-B-FPATR-RSVD-001 \
  PTO-AVS-BLOCK-B-FPATR-PQ14-15-001 \
  PTO-AVS-BLOCK-B-FPATR-PQ21-22-001 \
  PTO-AVS-BLOCK-B-FPATR-PQ29-31-001 \
  PTO-AVS-BLOCK-B-FPATR-PQ40-47-001 \
  PTO-AVS-BLOCK-B-FPATR-PQ48-55-001 \
  PTO-AVS-BLOCK-B-FPATR-PQ56-63-001 \
  PTO-AVS-BLOCK-B-FPATR-RELU-RSVD-001; do
  ./scripts/run-asl-test --id "$id" || exit 1
done
```

Expected: all B.FPATR fault and boundary points pass.

- [ ] **Step 6: Regenerate and commit legality/fault closure**

```bash
python3 scripts/instruction_docs.py generate
git add asl/block/attributes/B.FPATR.asl \
  asl/block/model/dispatch/tile-schema.asl \
  asl/block/model/dispatch/scalar-schema.asl \
  asl/tile/model/legality/matrix-postprocess.asl \
  docs/block/attributes/B.FPATR.md \
  docs/tile/model/legality/matrix-postprocess.md \
  tests/asl/block/attributes/B.FPATR/block-fault-b-fpatr-controls-010.asl \
  tests/asl/tile/model/legality/matrix-postprocess/tile-bound-matrix-params-002.asl
git commit -m "fix: enforce FPATR control legality"
```

### Task 6: Prove raw reductions and all-or-nothing publication

**Files:**
- Modify: `asl/tile/model/execution/postprocess.asl`
- Modify: `asl/block/model/dispatch/destination-shape.asl`
- Modify: `tests/asl/tile/model/execution/postprocess/tile-exec-postprocess-aux-001.asl`
- Create: `tests/asl/tile/model/execution/postprocess/tile-atomic-postprocess-rollback-003.asl`
- Test: `tests/asl/block/attributes/B.FPATR/block-atomic-b-fpatr-aux-011.asl`
- Generated: `docs/tile/model/execution/postprocess.md`

**Interfaces:**
- Preserves: `MatrixRowMaxResult` and `MatrixGroupMaxResult` consume the raw accumulator `TileInfo`.
- Produces: a prepared result record or tuple containing D, optional RowMaxOut, optional GroupMaxOut, combined flags, and publication booleans before any architectural write.

- [ ] **Step 1: Correct and expand auxiliary success vectors**

Use legal mode-zero FP32, S32, and U32 accumulators. Add:

```text
N not divisible by GroupN, including the partial final group
GroupN greater than N
RowMaxInit with legal RowMaxIn/RowMaxOut read-old/write-new alias
MaxAbs minimum-S32 flag behavior
```

Assert auxiliaries use raw accumulator values even when D is scaled, activated, and converted.

- [ ] **Step 2: Add a late-failure rollback test and verify RED**

Construct a legal D and RowMaxOut but make GroupMaxOut capacity or shape fail at the last preflight check. Snapshot the complete Tile array, descriptor state, numeric flags, allocation state, and bindings. Assert `Fault_TileLegality` or the repository-assigned allocation fault and bit-for-bit equality of every snapshot after rejection.

Run:

```bash
./scripts/run-asl-test --id PTO-AVS-TILE-POSTPROCESS-ROLLBACK-003
./scripts/run-asl-test --id PTO-AVS-BLOCK-B-FPATR-AUX-011
```

Expected: the new rollback vector exposes any publication or allocation that occurs before all destinations are ready.

- [ ] **Step 3: Prepare every result and descriptor before the first effect**

Restructure completion so the only effect block is equivalent to:

```asl
_Tiles[[destination]] = prepared.d;
if prepared.row_valid then
    _Tiles[[row_destination]] = prepared.row;
end;
if prepared.group_valid then
    _Tiles[[group_destination]] = prepared.group;
end;
RecordNumericStatusFlags(prepared.flags);
```

All shape, alias, definedness, payload, capacity, and destination allocation checks must happen before constructing this block.

- [ ] **Step 4: Run auxiliary, commit, alias, and rollback points and verify GREEN**

Run:

```bash
./scripts/run-asl-test --id PTO-AVS-TILE-MODEL-EXECUTION-POSTPROCESS-AUX-EXECUTION-001
./scripts/run-asl-test --id PTO-AVS-TILE-POST-MAXABS-SINGLE-002
./scripts/run-asl-test --id PTO-AVS-TILE-POSTPROCESS-ROLLBACK-003
./scripts/run-asl-test --id PTO-AVS-BLOCK-B-FPATR-COMMIT-006
./scripts/run-asl-test --id PTO-AVS-BLOCK-B-FPATR-AUX-011
```

Expected: all pass and reductions remain raw.

- [ ] **Step 5: Regenerate and commit atomic publication closure**

```bash
python3 scripts/instruction_docs.py generate
git add asl/tile/model/execution/postprocess.asl \
  asl/block/model/dispatch/destination-shape.asl \
  docs/tile/model/execution/postprocess.md \
  tests/asl/tile/model/execution/postprocess/tile-exec-postprocess-aux-001.asl \
  tests/asl/tile/model/execution/postprocess/tile-atomic-postprocess-rollback-003.asl \
  tests/asl/block/attributes/B.FPATR/block-atomic-b-fpatr-aux-011.asl
git commit -m "test: close FPATR auxiliary atomicity"
```

### Task 7: Regenerate traceability and validate the PR1 head

**Files:**
- Regenerate: `spec/catalog/command-forms.json`
- Regenerate: `spec/evidence/instruction-contract-closure.json`
- Regenerate: `spec/evidence/executable-model-comparison.json`
- Regenerate: `spec/release-manifest.json`
- Regenerate only when generators select them: other files below `spec/evidence/`
- Verify: all modified ASL, docs, and test files from Tasks 2-6.

**Interfaces:**
- Produces: a clean exact-head PR with no command-form encoding delta and fresh test/evidence hashes.

- [ ] **Step 1: Regenerate every ASL-owned projection**

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

Expected: generated changes are limited to owners and evidence affected by PR1.

- [ ] **Step 2: Prove the existing encoding is byte-for-byte unchanged**

Run:

```bash
git diff origin/main -- spec/catalog/command-forms.json | \
  grep -E 'B\.FPATR|mask|match|PreQuantMode|ReluMode|GroupNCode' || true
```

Expected: no added or removed B.FPATR mask, match, field, or mode-code line.

- [ ] **Step 3: Run every affected checked-in ASL point**

Run each ID added or modified in Tasks 2-6 with `./scripts/run-asl-test --id`, then run:

```bash
./scripts/run-asl-test --id PTO-AVS-BLOCK-B-FPATR-ALL-MODES-007
./scripts/run-asl-test --id PTO-AVS-BLOCK-B-FPATR-OPERAND-ROUTING-EXECUTION-001
./scripts/run-asl-test --id PTO-AVS-BLOCK-B-FPATR-RESET-CLEAR-001
```

Expected: every point passes under pinned ASLRef.

- [ ] **Step 4: Run repository closure gates**

Run:

```bash
make pr-check
make repo-check
git diff --check
git status --short
```

Expected: all gates pass; status lists only intentional PR1 files and no `build/` or `.cache/` artifacts.

- [ ] **Step 5: Commit generated evidence**

```bash
git add spec/catalog spec/evidence spec/release-manifest.json docs tests/asl asl
git commit -m "spec: close FPATR numeric parity evidence"
```

- [ ] **Step 6: Push and open PR1 linked to its NDF issue**

```bash
git push -u origin codex/fpatr-numeric-parity
gh pr create --title "Correct B.FPATR numeric pipeline semantics" --body "Implements the approved PR1 numeric-parity design. Closes the NDF issue URL returned in Task 1. No B.FPATR encoding changes; no transfer/layout/synchronization scope."
```

Expected: a PR URL on `codex/fpatr-numeric-parity`.

- [ ] **Step 7: Require exact-head hosted validation before merge**

Run:

```bash
gh pr checks --watch
```

Expected: `PR / validate` succeeds for the same SHA returned by `git rev-parse HEAD`. Do not begin PR2 until PR1 is merged into `main`.
