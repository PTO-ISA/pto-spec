// PTO-TEST: {"id":"PTO-AVS-ARCH-FP16-DECOMP-001","source":"asl/arch/data-types/formats/fp16.asl","requirements":["PTO-NUMERIC-FINITE-DECOMPOSITION-001"],"kind":"boundary","summary":"FP16 exposes its exact descriptor and finite-value decomposition.","pass_condition":"Field metadata, finite boundaries, unavailable special values, and existing value-class rules agree.","related_sources":["asl/arch/data-types/numeric-formats.asl","asl/arch/features/mx-formats.asl"]}
func AssertNumericFiniteDecomposition(data_type: TileDataType, value: Word,
                                       expected_negative: boolean,
                                       expected_significand: Word,
                                       expected_exponent: integer {-1074..1023})
begin
    let (available, negative, significand, exponent) =
        TileNumericFiniteDecomposition(data_type, value);
    assert available;
    assert negative == expected_negative;
    assert significand == expected_significand;
    assert exponent == expected_exponent;
end;

func AssertNumericFiniteDecompositionUnavailable(data_type: TileDataType,
                                                  value: Word)
begin
    let (available, negative, significand, exponent) =
        TileNumericFiniteDecomposition(data_type, value);
    assert !available;
    assert !negative;
    assert significand == Zeros{PTO_XLEN};
    assert exponent == 0;
end;
func TestFP16NumericFormat()
begin
    let descriptor = TileNumericFormatDescriptor(TileDataType_FP16);
    assert descriptor.available && descriptor.kind == NumericFormatKind_FixedBinary;
    assert descriptor.carrier_bits == 16 && descriptor.lane_bits == 16;
    assert descriptor.sign_bit == 15;
    assert descriptor.exponent_bits_min == 5 && descriptor.exponent_bits_max == 5;
    assert descriptor.fraction_bits_min == 10 && descriptor.fraction_bits_max == 10;
    assert descriptor.exponent_bias_available && descriptor.exponent_bias == 15;
    assert descriptor.has_infinity && descriptor.has_quiet_nan && descriptor.has_signaling_nan;
    AssertNumericFiniteDecomposition(TileDataType_FP16, Zeros{PTO_XLEN},
        FALSE, Zeros{PTO_XLEN}, 0);
    AssertNumericFiniteDecomposition(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x8000, TRUE, Zeros{PTO_XLEN}, 0);
    AssertNumericFiniteDecomposition(TileDataType_FP16, Zeros{PTO_XLEN} + 1,
        FALSE, Zeros{PTO_XLEN} + 1, -24);
    AssertNumericFiniteDecomposition(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x03ff, FALSE, Zeros{PTO_XLEN} + 0x03ff, -24);
    AssertNumericFiniteDecomposition(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x0400, FALSE, Zeros{PTO_XLEN} + 0x0400, -24);
    AssertNumericFiniteDecomposition(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x7bff, FALSE, Zeros{PTO_XLEN} + 0x07ff, 5);
    AssertNumericFiniteDecompositionUnavailable(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x7c00);
    AssertNumericFiniteDecompositionUnavailable(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x7e00);
    assert TileNumericValueClass(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x7c00) == NumericValue_PositiveInfinity;
    assert TileNumericValueClass(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0xfc00) == NumericValue_NegativeInfinity;
    assert TileNumericValueClass(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x7e00) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x7c01) == NumericValue_SignalingNaN;
    let (nan_available, canonical_nan) = TileNumericCanonicalNaN(TileDataType_FP16);
    assert nan_available && canonical_nan == Zeros{PTO_XLEN} + 0x7e00;
end;
func main() => integer
begin
    TestFP16NumericFormat();
    return 0;
end;
