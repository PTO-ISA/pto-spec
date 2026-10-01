<!-- GENERATED FROM: asl/arch/data-types/formats/hif4x2.asl -->
# Hif4x2

**Normative ASL source:** `asl/arch/data-types/formats/hif4x2.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-FORMAT-HIF4X2}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-format-hif4x2-purpose role=purpose-scope -->
## Purpose and scope

`HiF4X2` is an assigned PTO numeric format whose values are four-bit lanes packed two per eight-bit carrier, and this unit owns its descriptor, finite decomposition, value classification, and signed zero encodings.

The owner exposes one lane at a time through `value[3:0]`, so a consumer that reads both halves of a carrier must slice the upper lane itself.

Design point: the record keeps the carrier width and the logical lane width separate, so a packed type reports two lanes in one carrier while a single-lane type reports only its own lane width in its carrier.

<!-- PTO-READER-BLOCK: arch-format-hif4x2-concepts role=concepts-state -->
## Carrier and fields

The descriptor uses a `8`-bit carrier, a `4`-bit logical lane, and `2` lanes per carrier.

The lane has one sign bit at position `3`, `1` exponent bit(s) in `2:2`, `2` fraction bit(s) in `1:0`, and exponent bias `1`.

The descriptor sets `required_low_zero_bits` and `required_high_zero_bits` to `0`, so every eight-bit carrier holds two defined lane encodings.

A reader that only needs a value class can stop after classification, because classification never requires an available decomposition.

<!-- PTO-READER-BLOCK: arch-format-hif4x2-rules role=rules-interactions -->
## Decomposition and classification

`HiF4X2FiniteDecomposition` returns availability, the sign, an integer significand, and a binary exponent such that the exact value is `(-1)^sign * UInt(significand) * 2^exponent`; the lane exponent bit is read at `2:2` and the fraction at `1:0`.

`ClassifyHiF4X2` assigns the lane to a zero or a signed normal class; the format has no infinity, no NaN, and no subnormal encoding, so every non-zero lane is a signed normal value.

An exponent bit of zero with a zero fraction selects a signed zero, while every other lane is a signed normal value.

<!-- PTO-READER-BLOCK: arch-format-hif4x2-boundaries role=boundaries -->
## Boundaries and exact encodings

The owner returns exponent `-2` for both non-zero cases: a set exponent bit gives significand `4` plus the fraction, and a clear exponent bit with a nonzero fraction gives the fraction alone; lane `0x1` therefore denotes `0.25` and lane `0x5` denotes `1.25`, while lanes `0x4` and `0x6` determine `1` and `1.5`.

Design point: the exponent bit selects between two significand constructions at the same scale, so the lane field widens the set of representable magnitudes without widening the exponent range.

Design point: `0x00` and the negative encoding are separate encodings of the same magnitude, so a consumer that preserves the sign bit can still tell which one produced a result even when both compare equal to zero.

Read this page in the order of the functions: take the field positions from the descriptor, call the classification function when the value class matters, and call the decomposition function only after encoding validity has passed.

<!-- PTO-READER-BLOCK: arch-format-hif4x2-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Lane `0x0` is positive zero and lane `0x8` is negative zero; there is no infinity and no NaN lane.

Lane `0x1` is the smallest positive non-zero value and decomposes to significand `1` with exponent `-2`, and lane `0x7` is the largest magnitude and decomposes to significand `7` with exponent `-2`, which is `1.75`.

<!-- PTO-READER-BLOCK: arch-format-hif4x2-related role=related-owners-navigation -->
## Related owners

- [Numeric format descriptor](../format-descriptor.md) defines the common metadata record.

- [Numeric formats](../numeric-formats.md) dispatches Tile data types to their format-specific helpers.

- [HiF4 scale](hif4-scale.md) applies a shared scale word to HiF4 lanes.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/formats/hif4x2.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-FORMAT-HIF4X2","surface":"arch","classification":["data-types","formats","hif4x2"],"depends_on":["PTO-ARCH-DATA-TYPES-FORMAT-DESCRIPTOR"]}
// DOC-BEGIN: operation
// PTO-REQ-HARDWARE-NUMERIC-001: exact HiF4 E1M2 logical lanes.

pure func HiF4X2NumericFormatDescriptor() => NumericFormatDescriptor
begin
    return NumericFormatDescriptor {
        available = TRUE, kind = NumericFormatKind_FixedBinary,
        carrier_bits = 8, lane_bits = 4, lanes_per_carrier = 2,
        sign_bits = 1, sign_bit = 3,
        exponent_bits_min = 1, exponent_bits_max = 1,
        fraction_bits_min = 2, fraction_bits_max = 2,
        exponent_bias_available = TRUE, exponent_bias = 1,
        required_low_zero_bits = 0, required_high_zero_bits = 0,
        has_zero = TRUE, has_signed_zero = TRUE, has_subnormal = FALSE,
        has_infinity = FALSE, has_quiet_nan = FALSE,
        has_signaling_nan = FALSE
    };
end;

pure func HiF4X2FiniteDecomposition(value: Word)
    => (boolean, boolean, Word, integer {-1074..1023})
begin
    let lane = value[3:0];
    let exponent = lane[2:2];
    let fraction = lane[1:0];
    if exponent == Zeros{1} then
        if fraction == Zeros{2} then
            return (TRUE, lane[3] == '1', Zeros{PTO_XLEN}, 0);
        else return (TRUE, lane[3] == '1',
                     ZeroExtend{PTO_XLEN}(fraction), -2);
        end;
    else return (TRUE, lane[3] == '1',
                 LSL(Zeros{PTO_XLEN} + 1, 2) +
                     ZeroExtend{PTO_XLEN}(fraction), -2);
    end;
end;
pure func ClassifyHiF4X2(value: Word) => NumericValueClass
begin
    return NumericValueClassFromFiniteSign(value[3],
        value[2:0] == Zeros{3}, FALSE);
end;

pure func HiF4X2SignedZeroEncodings() => (Word, Word)
begin
    return (Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x8);
end;
// DOC-END: operation
```
<!-- GENERATED-ASL-END: unit -->
