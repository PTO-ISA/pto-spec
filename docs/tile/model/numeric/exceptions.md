<!-- GENERATED FROM: asl/tile/model/numeric/exceptions.asl -->
# Exceptions

**Normative ASL source:** `asl/tile/model/numeric/exceptions.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-NUMERIC-EXCEPTIONS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-numeric-exceptions-purpose role=purpose-scope -->
## Purpose and scope

This unit contains no executable ASL. Its only content is a comment stating that Tile numeric exceptions use the architecture fault and numeric classification contracts. It depends on the Tile rounding unit, which is also a pointer.

Read this page as a map. It explains where numeric exception behavior for Tile operations is actually defined.

<!-- PTO-READER-BLOCK: tile-model-numeric-exceptions-concepts role=concepts-state -->
## Concepts and visible state

Two different things are called exceptions in PTO, and they must be kept apart.

- A numeric status flag records that an arithmetic event happened. The five flags are NV (invalid), DZ (divide by zero), OF (overflow), UF (underflow), and NX (inexact). They live in `CORE_STATE[36:32]` and are sticky.
- A fault stops an instruction. Tile legality problems raise `Fault_TileLegality`; memory problems raise faults such as `Fault_DataAlignment` and `Fault_DataPage`.

In the Tile reference helpers, a flag set is a `bits(5)` value, and the constants used are `0x01` NV, `0x02` DZ, `0x04` OF, `0x08` UF, and `0x10` NX.

<!-- PTO-READER-BLOCK: tile-model-numeric-exceptions-rules role=rules-interactions -->
## Rules and interactions

A numeric special case such as NaN input, overflow, or division by zero produces a result value and flags. It does not raise a fault in the Tile numeric helpers of this directory; none of them calls `SetFault`.

`RecordNumericStatusFlags` ORs a flag set into the sticky status. For example, `TCVT` calls it once, in `TileCommitConversionResult` just before publication, with the OR of all element flags.

Design point: flags are sticky bits, not a trap. `RecordNumericStatusFlags` ORs new flags into `CORE_STATE[36:32]` and never clears an earlier flag (NDF `PTO-NUMERIC-STATUS-STICKY-001`), so a flag recorded by one operation stays set after later recording operations.

Not every operation records its flags: for example, `ExecuteTileBinary` discards numeric flags, while `ExecuteTileUnary` records them. Check each operation's owner.

<!-- PTO-READER-BLOCK: tile-model-numeric-exceptions-boundaries role=boundaries -->
## Architectural boundaries

This unit defines no flag, no fault, and no priority rule. The owners are:

- The numeric status unit for the flag layout and the sticky update.
- The numeric classification unit for NaN, infinity, zero, subnormal, and invalid-encoding classes.
- Each numeric helper, for example the reference, TCVT, packed, and E8M0 conversion units, for which flags a result produces.

<!-- PTO-READER-BLOCK: tile-model-numeric-exceptions-example role=example-usage -->
## Non-normative reading example

A `TCVT` from FP32 to FP16 converts two elements with RNE and `Sat` zero.

- 70000.0 is above the FP16 maximum 65504, so that element gives infinity `0x7C00` with OF and NX, flags `0x14`.
- 1.0 converts exactly to `0x3C00`, flags `0x00`.

TCVT ORs these into `0x14` and records it once. If the status was `0x01` before, it becomes `0x15`. No fault is raised.

<!-- PTO-READER-BLOCK: tile-model-numeric-exceptions-related role=related-owners-navigation -->
## Related owners

- [Numeric status](../../../arch/state/numeric-status.md) owns the sticky flags.
- [Numeric classification](../../../arch/data-types/numeric-classification.md) owns value classes.
- [Fault types](../../../arch/data-types/fault.md) owns fault codes.
- [Rounding](rounding.md) is the companion pointer for rounding.
- [Reference conversion](reference-conversion.md) and [formats](formats.md) show flag production and recording.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/numeric/exceptions.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-NUMERIC-EXCEPTIONS","surface":"tile","classification":["model","numeric","exceptions"],"depends_on":["PTO-TILE-MODEL-NUMERIC-ROUNDING"]}
// Tile numeric exceptions use the architecture fault and numeric classification contracts.
```
<!-- GENERATED-ASL-END: unit -->
