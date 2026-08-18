// PTO-TEST: {"id":"PTO-AVS-ARCH-FP32-DECOMP-001","source":"asl/arch/data-types/formats/fp32.asl","requirements":["PTO-NUMERIC-FINITE-DECOMPOSITION-001"],"kind":"boundary","summary":"FP32 exposes its exact descriptor and finite-value decomposition.","pass_condition":"Field metadata, finite boundaries, unavailable special values, and existing value-class rules agree.","related_sources":["asl/arch/data-types/numeric-formats.asl","asl/arch/features/mx-formats.asl"]}
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
func TestFP32NumericFormat()
begin
    let descriptor = TileNumericFormatDescriptor(TileDataType_FP32);
    assert descriptor.available && descriptor.kind == NumericFormatKind_FixedBinary;
    assert descriptor.carrier_bits == 32 && descriptor.lane_bits == 32;
    assert descriptor.lanes_per_carrier == 1;
    assert descriptor.sign_bits == 1 && descriptor.sign_bit == 31;
    assert descriptor.exponent_bits_min == 8 && descriptor.exponent_bits_max == 8;
    assert descriptor.fraction_bits_min == 23 && descriptor.fraction_bits_max == 23;
    assert descriptor.exponent_bias_available && descriptor.exponent_bias == 127;
    assert descriptor.has_zero && descriptor.has_signed_zero && descriptor.has_subnormal;
    assert descriptor.has_infinity && descriptor.has_quiet_nan && descriptor.has_signaling_nan;
    AssertNumericFiniteDecomposition(TileDataType_FP32, Zeros{PTO_XLEN},
        FALSE, Zeros{PTO_XLEN}, 0);
    AssertNumericFiniteDecomposition(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x80000000, TRUE, Zeros{PTO_XLEN}, 0);
    AssertNumericFiniteDecomposition(TileDataType_FP32, Zeros{PTO_XLEN} + 1,
        FALSE, Zeros{PTO_XLEN} + 1, -149);
    AssertNumericFiniteDecomposition(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x007fffff, FALSE,
        Zeros{PTO_XLEN} + 0x007fffff, -149);
    AssertNumericFiniteDecomposition(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x00800000, FALSE,
        Zeros{PTO_XLEN} + 0x00800000, -149);
    AssertNumericFiniteDecomposition(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7f7fffff, FALSE,
        Zeros{PTO_XLEN} + 0x00ffffff, 104);
    AssertNumericFiniteDecomposition(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0xbf800000, TRUE,
        Zeros{PTO_XLEN} + 0x00800000, -23);
    AssertNumericFiniteDecompositionUnavailable(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7f800000);
    AssertNumericFiniteDecompositionUnavailable(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7fc00000);
    assert TileNumericValueClass(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7f800000) == NumericValue_PositiveInfinity;
    assert TileNumericValueClass(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0xff800000) == NumericValue_NegativeInfinity;
    assert TileNumericValueClass(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7fc00000) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7f800001) == NumericValue_SignalingNaN;
    let (nan_available, canonical_nan) = TileNumericCanonicalNaN(TileDataType_FP32);
    assert nan_available && canonical_nan == Zeros{PTO_XLEN} + 0x7fc00000;
end;
func main() => integer
begin
    TestFP32NumericFormat();
    return 0;
end;

