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

This unit owns the five architecture-visible numeric status flags and the sticky update applied after a successful numeric operation.

<!-- PTO-READER-BLOCK: arch-numeric-status-concepts-state role=concepts-state -->
## Flag layout

`NumericStatusFlags` reads `CORE_STATE[36:32]`. From bit `36` down to bit `32`, the five flags are NV, DZ, OF, UF, and NX.

<!-- PTO-READER-BLOCK: arch-numeric-status-rules-interactions role=rules-interactions -->
## Sticky update rule

`RecordNumericStatusFlags` ORs the supplied five-bit value with the current status and writes the result back to `CORE_STATE[36:32]`.

A successful numeric operation can therefore set a flag but cannot clear a flag that was already set by an earlier operation.

<!-- PTO-READER-BLOCK: arch-numeric-status-boundaries role=boundaries -->
## Architectural boundaries

This owner defines the status layout and accumulation operation. It does not decide which numeric operation produces NV, DZ, OF, UF, or NX; that decision belongs to the numeric operation's current ASL owner and profile hook where applicable.

<!-- PTO-READER-BLOCK: arch-numeric-status-example-usage role=example-usage -->
## Non-normative sticky-flag example

If the current five-bit status is `10000` and a later successful operation supplies `00001`, the recorded value becomes `10001`. Supplying `00000` afterward leaves `10001` unchanged.

<!-- PTO-READER-BLOCK: arch-numeric-status-related-owners role=related-owners-navigation -->
## Related owners

- [System-register addressing](../system-registers/addressing.md) owns the `core_state` storage used here.
- [Reference profile](../profile/reference-profile.md) supplies concrete implementations for profile-defined numeric hooks.
- [Architecture overview](../overview/architecture.md) establishes the current-owner hierarchy.
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
