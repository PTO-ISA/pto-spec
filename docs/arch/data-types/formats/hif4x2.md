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

HiF4X2 is an assigned PTO numeric format. This page helps a reader connect its carrier layout, finite-value decomposition, and value classification; the exact contract remains in `HiF4X2NumericFormatDescriptor`, `HiF4X2FiniteDecomposition`, and `ClassifyHiF4X2` in the ASL owner.

<!-- PTO-READER-BLOCK: arch-format-hif4x2-concepts role=concepts-state -->
## Carrier and fields

The descriptor uses a `8`-bit carrier, a `4`-bit logical lane, and `2` lane(s) per carrier. The lane has one sign bit at position `3`, `1` exponent bit(s), `2` fraction bit(s), and exponent bias `1`.

The descriptor covers one four-bit logical lane at a time; two lanes share the eight-bit carrier.

<!-- PTO-READER-BLOCK: arch-format-hif4x2-rules role=rules-interactions -->
## Decomposition and classification

`HiF4X2FiniteDecomposition` reports whether a finite decomposition is available and, when available, returns the sign, an integer significand, and a binary exponent. `ClassifyHiF4X2` separately assigns the raw lane to zero, subnormal, normal, infinity, or NaN classes supported by this format.

It has signed zero but no subnormal class, infinity, or NaN class. Every nonzero four-bit lane is classified as a signed normal value.

<!-- PTO-READER-BLOCK: arch-format-hif4x2-boundaries role=boundaries -->
## Boundaries and exact encodings

Lane encodings `0x0` and `0x8` are positive and negative zero.

The finite-decomposition function reports availability with its returned tuple; value classification is a separate function result.

<!-- PTO-READER-BLOCK: arch-format-hif4x2-example role=example-usage -->
## Non-normative reading example

This example illustrates how to read the functions; it does not add an encoding rule.

For example, lane `0x1` decomposes to positive significand `1` with exponent `-2`; lane `0x9` has the same magnitude and a negative sign.

<!-- PTO-READER-BLOCK: arch-format-hif4x2-related role=related-owners-navigation -->
## Related owners

- [Numeric format descriptor](../format-descriptor.md) defines the common metadata record.
- [Numeric formats](../numeric-formats.md) dispatches Tile data types to their format-specific helpers.
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
