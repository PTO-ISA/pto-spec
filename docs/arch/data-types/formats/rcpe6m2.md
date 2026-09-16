<!-- GENERATED FROM: asl/arch/data-types/formats/rcpe6m2.asl -->
# Rcpe6m2

**Normative ASL source:** `asl/arch/data-types/formats/rcpe6m2.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-FORMAT-RCPE6M2}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->

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
