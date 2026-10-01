<!-- GENERATED FROM: asl/arch/state/numeric-status.asl -->
# Numeric Status

**Normative ASL source:** `asl/arch/state/numeric-status.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-NUMERIC-STATUS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-numeric-status-purpose-scope role=purpose-scope -->
## Purpose and scope

`asl/arch/state/numeric-status.asl` owns two functions and one contract clause. `NumericStatusFlags` is a `readonly` function returning `bits(5)`, and `RecordNumericStatusFlags` takes one `flags: bits(5)` argument. Both address `_SystemRegisters.core_state[36:32]`, and the `NDF-BEGIN` clause `PTO-NUMERIC-STATUS-STICKY-001` fixes that bit mapping together with the sticky update rule.

`core_state` is one field of the `BaseSystemRegisterState` record declared in `asl/arch/system-registers/addressing.asl` and is typed `Word`; `Word` is `bits(PTO_XLEN)` with `PTO_XLEN` `64`. The five flags are therefore a subfield of a wider register, not a register of their own.

<!-- PTO-READER-BLOCK: arch-numeric-status-concepts-state role=concepts-state -->
## Flag layout in the shared word

`NumericStatusFlags` performs a plain read of `core_state[36:32]`. The clause names the bits in descending order, so bit `36` is `NV`, bit `35` is `DZ`, bit `34` is `OF`, bit `33` is `UF` and bit `32` is `NX`.

Other code reads and writes neighbouring bits of the same word: `SetCurrentACR` in `asl/arch/system-registers/access-control.asl` writes the current ring into `core_state[3:0]`, and `ScalarFPActiveRoundingMode` in `asl/scalar/model/fsu/scalar-fp.asl` reads the active rounding mode from `core_state[39:37]`.

Design point: the five flags have no dedicated register and no reset value of their own; they are bits `36:32` of a word that also holds the rounding mode at `39:37` and the ring selection at `3:0`. The observable consequence is that reading `CORE_STATE` at address `0x0020` returns the flags only as part of a combined word, so software that wants one field must mask the others out.

<!-- PTO-READER-BLOCK: arch-numeric-status-rules-interactions role=rules-interactions -->
## Sticky update and its callers

`RecordNumericStatusFlags(flags)` writes `NumericStatusFlags() OR flags` back into `core_state[36:32]`. The body contains no conditional, no assertion and no fault call, so recording status adds no failure path of its own, and no call can clear a bit that an earlier call set.

`RecordNumericStatusFlags` has `14` call sites under `asl/`. For example `ScalarFPRecordFlags` in `asl/scalar/model/fsu/scalar-fp.asl` forwards the scalar floating result flags, `TileCommitConversionResult` records the flags of a Tile conversion publish, and the Tile execution owners `ExecuteTileUnary` (whose last statement is `ScalarFPRecordFlags(flags)`), `ExecuteTileScalar`, the comparison, reduction, expansion, matrix-scale, predicate-carrier, postprocess and `expdif` helpers record through the same function. `ExecuteTileBinary` is not among them: it computes values with `TileProfileBinary`, which discards the flag vector with `let (result, -) = TileProfileBinaryWithFlags(op, data_type, left, right);`.

Design point: `RecordNumericStatusFlags` writes only bits `36:32`, so an accumulating Tile or scalar operation cannot disturb the rounding-mode field or the ring selection that share the word. A software write of the `CORE_STATE` system register is not a subfield write: `WriteSystemRegister` in `asl/scalar/model/sys/semantics.asl` stores the whole `Word` and then sets `_CurrentACR` from `value[3:0]`. Clearing the five flags by writing `CORE_STATE` therefore also replaces the rounding mode and the current ring, and the model offers no status-only clear.

<!-- PTO-READER-BLOCK: arch-numeric-status-boundaries role=boundaries -->
## Architectural boundaries

This owner stores and accumulates the five bits; it does not decide which operation produces `NV`, `DZ`, `OF`, `UF` or `NX`. Those vectors are built by the numeric owners that compute them, for example `TileProfileUnary` and `TileProfileBinaryWithFlags` in `asl/tile/model/execution/`.

Not every recording call carries information. The integer paths of `TileConvertValue` and `TileProfileConvert` return `Zeros{5}`, and `TileCommitConversionResult` still records that value, which leaves the stored field unchanged.

The clause covers successful numeric operations. `RecordNumericStatusFlags` itself has no success test and no fault parameter, so the decision to record is made by the caller and is not re-checked here.

<!-- PTO-READER-BLOCK: arch-numeric-status-example-usage role=example-usage -->
## Non-normative status example

Assume the stored field reads `10000`. A later operation that supplies `00001` makes the stored value `10001`, because the write is an OR of the old value with the new one. Supplying `00000` afterwards leaves `10001` unchanged. A software write of `CORE_STATE` with `Zeros{PTO_XLEN} + 3` stores `3` in the whole word, so all five flags read back as `00000` and the current ring becomes `3`.

<!-- PTO-READER-BLOCK: arch-numeric-status-related-owners role=related-owners-navigation -->
## Related owners

- [System-register addressing](../system-registers/addressing.md) owns `_SystemRegisters` and the `core_state` storage used here.
- [Access control](../system-registers/access-control.md) owns `AccessControlRingBits` and the `core_state[3:0]` encoding.
- [Scalar floating point](../../scalar/model/fsu/scalar-fp.md) forwards the scalar floating flags through `ScalarFPRecordFlags`.
- [Tile numeric formats](../../tile/model/numeric/formats.md) records conversion flags at the Tile publish boundary.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/numeric-status.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-STATE-NUMERIC-STATUS","surface":"arch","classification":["state","numeric-status"],"depends_on":["PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING"]}
// NDF-BEGIN: PTO-NUMERIC-STATUS-STICKY-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// Numeric execution flags MUST map to CORE_STATE[36:32] as NV, DZ, OF, UF,
// and NX, and a successful numeric operation MUST OR its produced flags into
// the existing sticky status without clearing an earlier flag.
// NDF-END: PTO-NUMERIC-STATUS-STICKY-001
// DOC-BEGIN: state
readonly func NumericStatusFlags() => bits(5)
begin
    return _SystemRegisters.core_state[36:32];
end;

func RecordNumericStatusFlags(flags: bits(5))
begin
    _SystemRegisters.core_state[36:32] = NumericStatusFlags() OR flags;
end;
// DOC-END: state
```
<!-- GENERATED-ASL-END: unit -->
