<!-- GENERATED FROM: asl/tile/model/numeric/rounding.asl -->
# Rounding

**Normative ASL source:** `asl/tile/model/numeric/rounding.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-NUMERIC-ROUNDING}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-numeric-rounding-purpose role=purpose-scope -->
## Purpose and scope

This unit contains no executable ASL. Its only content is a comment stating that Tile rounding selection is defined by the architecture rounding model and the format operations. It depends on the Tile formats unit and on the architecture rounding unit `PTO-ARCH-DATA-TYPES-ROUNDING`.

Read this page as a map of where a Tile rounding mode comes from and where it is applied.

<!-- PTO-READER-BLOCK: tile-model-numeric-rounding-concepts role=concepts-state -->
## Concepts and visible state

`NumericRoundingMode` names seven modes:

| Mode | Meaning |
| --- | --- |
| RNE | nearest, ties to even |
| RTM | toward minus infinity |
| RTP | toward plus infinity |
| RTZ | toward zero |
| RNA | nearest, ties away from zero |
| RTO | toward odd: an inexact result takes the neighbor with an odd last bit |
| RHB | nearest, ties to the numerically greater candidate |

`NumericExecutionControl` pairs one mode with a `saturating` flag. `DefaultNumericExecutionControl` is RNE without saturation.

<!-- PTO-READER-BLOCK: tile-model-numeric-rounding-rules role=rules-interactions -->
## Rules and interactions

A bundle's three-bit `RMode` field is decoded by `DecodeBundleRoundingSelection`: `000` asks for the operation default, `010` RTZ, `011` RTM, `100` RTP, `101` RNA, `110` RTO, and `111` RHB. Code `001` selects RNE explicitly.

The operation owner decides the default. For `TCVT`, the default is RTZ for floating to integer and RNE otherwise.

Design point: the mode names are semantic, and each encoded selector is mapped to them explicitly. The consequence is that the same `NumericRoundingMode` value means the same thing whether it came from a bundle, a scalar control register, or a fixed conversion, even though the encodings differ.

Design point: some operations restrict the modes they accept. `HardwareTCVTRoundingModeSupported` allows only RNE and RNA when E6M2 or RCPE6M2 is involved; other modes are rejected before destination allocation.

The rounding itself happens inside the format encoders, for example `ReferenceMatrixFloatingEncoding`, `ReferencePacked4Encoding`, `ReferenceE6M2Encoding`, and `ReferenceE8M0RoundExponent`. Some helpers ignore the requested mode: floating modulo and the finite unary reference helper always encode with the default control.

<!-- PTO-READER-BLOCK: tile-model-numeric-rounding-boundaries role=boundaries -->
## Architectural boundaries

This unit defines no mode, no encoding, and no rounding algorithm. The owners are:

- The architecture rounding unit for the mode enumeration and the control record.
- The scalar FSU arithmetic unit for `DecodeBundleRoundingSelection`.
- Each operation for its default mode and accepted modes.
- Each format encoder for how a value is rounded.

<!-- PTO-READER-BLOCK: tile-model-numeric-rounding-example role=example-usage -->
## Non-normative reading example

Round 2.5 to an integer under each mode, as `FloatingToInteger` does:

- RNE gives 2, RNA gives 3, RHB gives 3.
- RTZ gives 2, RTM gives 2, RTP gives 3.
- RTO gives 3, because 2 is even and the result is inexact.

For negative 2.5, RNE gives -2, RNA gives -3, RHB gives -2, and RTO gives -3.

A `TCVT` from FP32 to S32 with `RMode=000` uses the operation default RTZ, so 2.7 becomes 2.

<!-- PTO-READER-BLOCK: tile-model-numeric-rounding-related role=related-owners-navigation -->
## Related owners

- [Rounding](../../../arch/data-types/rounding.md) owns the mode enumeration and control record.
- [Scalar FSU arithmetic](../../../scalar/model/fsu/arithmetic.md) owns selector decoding and `FloatingToInteger`.
- [Formats](formats.md) and [E8M0 conversion](e8m0-conversion.md) show where TCVT applies modes.
- [Exceptions](exceptions.md) is the companion pointer for flags.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/numeric/rounding.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-NUMERIC-ROUNDING","surface":"tile","classification":["model","numeric","rounding"],"depends_on":["PTO-TILE-MODEL-NUMERIC-FORMATS","PTO-ARCH-DATA-TYPES-ROUNDING"]}
// Tile rounding selection is defined by the architecture rounding model and format operations.
```
<!-- GENERATED-ASL-END: unit -->
