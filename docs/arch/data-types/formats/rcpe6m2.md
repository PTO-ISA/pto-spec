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

RCPE6M2 is a source-only derived PTO numeric type that reinterprets the E6M2 raw code space through exact reciprocals. This page helps a reader connect the shared carrier, reciprocal value rule, and classification; the ASL owner remains the exact definition.

<!-- PTO-READER-BLOCK: arch-format-rcpe6m2-concepts role=concepts-state -->
## Carrier and fields

The descriptor uses an `8`-bit carrier, an `8`-bit logical lane, and `1` lane per carrier. It retains E6M2's six-bit exponent, two-bit fraction, bias `48`, and unsigned field layout so that both types interpret the same raw code.

The descriptor records no zero, signed zero, subnormal, infinity, or signaling NaN encoding, and code `0xff` remains the quiet-NaN code.

<!-- PTO-READER-BLOCK: arch-format-rcpe6m2-rules role=rules-interactions -->
## Reciprocal value and classification

For codes `0x00` through `0xfe`, `RCPE6M2FiniteValue` returns the exact mathematical reciprocal of `E6M2FiniteValue` for the same raw code. Every such code is classified as a positive normal value, while `0xff` is classified as quiet NaN.

A general reciprocal has an exact rational value rather than the integer-significand binary form used by ordinary finite decomposition. `RCPE6M2FiniteDecomposition` therefore reports decomposition unavailable, and reference conversion consumes the exact reciprocal value directly.

<!-- PTO-READER-BLOCK: arch-format-rcpe6m2-boundaries role=boundaries -->
## Boundaries and conversion boundary

`0xff` is both the sole quiet-NaN code and the canonical NaN returned by the owner. All other raw codes are finite reciprocal inputs.

When TCVT consumes RCPE6M2, it performs one final destination rounding and does not first materialize an intermediate rounded floating value.

<!-- PTO-READER-BLOCK: arch-format-rcpe6m2-example role=example-usage -->
## Non-normative reading example

This example illustrates how to read the owner functions; it does not add a conversion rule.

For example, E6M2 code `0x00` denotes `2^-48`, so RCPE6M2 code `0x00` denotes its exact reciprocal `2^48`; the raw code is unchanged and only its numeric interpretation differs.

<!-- PTO-READER-BLOCK: arch-format-rcpe6m2-related role=related-owners-navigation -->
## Related owners

- [E6M2](./e6m2.md) defines the raw code values whose reciprocals RCPE6M2 denotes.
- [Numeric format descriptor](../format-descriptor.md) defines the common metadata record.
- [Numeric formats](../numeric-formats.md) dispatches Tile data types to their format-specific helpers.
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
