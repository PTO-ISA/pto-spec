<!-- GENERATED FROM: asl/arch/data-types/formats/rcpe6m2.asl -->
# Rcpe6m2

**Normative ASL source:** `asl/arch/data-types/formats/rcpe6m2.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-FORMAT-RCPE6M2}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-format-rcpe6m2-purpose role=purpose-scope -->
## Purpose and scope

`RCPE6M2` is an assigned PTO numeric type that reinterprets the `E6M2` code space as exact reciprocals, and this unit owns its descriptor, exact finite value, decomposition availability, classification, and canonical NaN.

It is a source-only type: the raw eight-bit code is unchanged, and only the numeric interpretation of that code differs from `E6M2`.

<!-- PTO-READER-BLOCK: arch-format-rcpe6m2-concepts role=concepts-state -->
## Carrier and fields

The descriptor uses a `8`-bit carrier, a `8`-bit logical lane, and `1` lane per carrier.

It keeps the `E6M2` shape: `6` exponent bit(s) in `7:2`, `2` fraction bit(s) in `1:0`, exponent bias `48`, no sign bit, and `required_low_zero_bits` and `required_high_zero_bits` both `0`.

Design point: the descriptor repeats the `E6M2` field widths rather than referencing them, so a reader can see from one record that both types consume exactly the same raw code.

<!-- PTO-READER-BLOCK: arch-format-rcpe6m2-rules role=rules-interactions -->
## Decomposition and classification

`RCPE6M2FiniteValue` returns `1.0 / E6M2FiniteValue(value)` for a code that is not `0xff`, and `RCPE6M2FiniteDecomposition` always reports a decomposition unavailable.

`ClassifyRCPE6M2` returns quiet NaN for `0xff` and the positive normal class for every other code, so no code is a zero, subnormal, infinity, or signaling NaN.

The decomposition is unavailable for every code, including finite ones, because a reciprocal of a general significand is an exact rational rather than an integer-significand binary value.

Design point: the unavailable decomposition is not a statement about special codes; `RCPE6M2FiniteDecomposition` returns `FALSE` for every code, finite ones included, so a consumer takes the value from `RCPE6M2FiniteValue` instead.

<!-- PTO-READER-BLOCK: arch-format-rcpe6m2-boundaries role=boundaries -->
## Boundaries and exact encodings

Design point: reporting unavailable rather than rounding the reciprocal to the nearest binary value keeps the exact rational available to the conversion that consumes it, so a later rounding happens once at the destination.

`0x00` denotes the exact reciprocal of `2^-48`, the smallest `E6M2` value, so it is `2^48`; `0xfe` denotes the reciprocal of `1.5 * 2^15`.

Design point: the format declares no zero encoding at all, so a consumer that needs zero must reach it through a conversion rather than through a raw code in this type.

Read this page in the order of the functions: take the field positions from the descriptor, call `ClassifyRCPE6M2` when the value class matters, and take the value from `RCPE6M2FiniteValue`, because this type never reports an available decomposition.

<!-- PTO-READER-BLOCK: arch-format-rcpe6m2-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

`0xff` is both the sole quiet-NaN code and the canonical NaN returned by `RCPE6M2CanonicalNaN`, and `RCPE6M2FiniteValue` asserts that its argument is not `0xff`.

Reference conversion consumes the exact reciprocal value directly instead of a decomposition, so a consumer must not require an available decomposition before using this type.

<!-- PTO-READER-BLOCK: arch-format-rcpe6m2-related role=related-owners-navigation -->
## Related owners

- [Numeric format descriptor](../format-descriptor.md) defines the common metadata record.

- [Numeric formats](../numeric-formats.md) dispatches Tile data types to their format-specific helpers.

- [E6M2](e6m2.md) defines the raw code values whose reciprocals this type denotes.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/formats/rcpe6m2.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-FORMAT-RCPE6M2","surface":"arch","classification":["data-types","formats","rcpe6m2"],"depends_on":["PTO-ARCH-DATA-TYPES-FORMAT-E6M2"]}
// NDF-BEGIN: PTO-NUMERIC-RCPE6M2-FORMAT-001
// ndf: kind=executable level=L3 layer=architecture status=accepted
// RCPE6M2 uses the E6M2 raw eight-bit code space as a source-only derived
// numeric type. Code FF is quiet NaN; every finite code denotes the exact
// mathematical reciprocal of the corresponding E6M2 value. TCVT performs
// one final destination rounding and never materializes an intermediate
// rounded floating value.
// NDF-END: PTO-NUMERIC-RCPE6M2-FORMAT-001
// DOC-BEGIN: operation
// PTO-REQ-HARDWARE-NUMERIC-001: exact reciprocal interpretation of E6M2.

pure func RCPE6M2NumericFormatDescriptor() => NumericFormatDescriptor
begin
    return NumericFormatDescriptor {
        available = TRUE, kind = NumericFormatKind_FixedBinary,
        carrier_bits = 8, lane_bits = 8, lanes_per_carrier = 1,
        sign_bits = 0, sign_bit = 0,
        exponent_bits_min = 6, exponent_bits_max = 6,
        fraction_bits_min = 2, fraction_bits_max = 2,
        exponent_bias_available = TRUE, exponent_bias = 48,
        required_low_zero_bits = 0, required_high_zero_bits = 0,
        has_zero = FALSE, has_signed_zero = FALSE, has_subnormal = FALSE,
        has_infinity = FALSE, has_quiet_nan = TRUE,
        has_signaling_nan = FALSE
    };
end;

pure func RCPE6M2FiniteValue(value: bits(8)) => real
begin
    assert value != Ones{8};
    return 1.0 / E6M2FiniteValue(value);
end;

pure func RCPE6M2FiniteDecomposition(value: bits(8))
    => (boolean, boolean, Word, integer {-1074..1023})
begin
    // A reciprocal of a general E6M2 significand is an exact rational rather
    // than an integer-significand binary value. Reference conversion consumes
    // RCPE6M2FiniteValue directly, so the ordinary binary decomposition is
    // intentionally unavailable for this derived source type.
    return (FALSE, FALSE, Zeros{PTO_XLEN}, 0);
end;

pure func ClassifyRCPE6M2(value: bits(8)) => NumericValueClass
begin
    if value == Ones{8} then return NumericValue_QuietNaN; end;
    return NumericValue_PositiveNormal;
end;

pure func RCPE6M2CanonicalNaN() => Word
begin
    return Zeros{PTO_XLEN} + 0xff;
end;
// DOC-END: operation
```
<!-- GENERATED-ASL-END: unit -->
