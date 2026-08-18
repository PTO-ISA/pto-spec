// PTO-TEST: {"id":"PTO-AVS-ARCH-HF32-DECOMP-001","source":"asl/arch/data-types/formats/hf32.asl","requirements":["PTO-NUMERIC-FINITE-DECOMPOSITION-001"],"kind":"boundary","summary":"HF32 exposes its exact descriptor and finite-value decomposition.","pass_condition":"Field metadata, finite boundaries, unavailable special values, and existing value-class rules agree.","related_sources":["asl/arch/data-types/numeric-formats.asl","asl/arch/features/mx-formats.asl"]}
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
func TestHF32NumericFormat()
begin
    let descriptor = TileNumericFormatDescriptor(TileDataType_HF32);
    assert descriptor.available && descriptor.kind == NumericFormatKind_FixedBinary;
    assert descriptor.carrier_bits == 32 && descriptor.lane_bits == 32;
    assert descriptor.sign_bit == 31;
    assert descriptor.exponent_bits_min == 8 && descriptor.exponent_bits_max == 8;
    assert descriptor.fraction_bits_min == 11 && descriptor.fraction_bits_max == 11;
    assert descriptor.exponent_bias_available && descriptor.exponent_bias == 127;
    assert descriptor.required_low_zero_bits == 12;
    assert descriptor.has_infinity && descriptor.has_quiet_nan && descriptor.has_signaling_nan;
    AssertNumericFiniteDecomposition(TileDataType_HF32, Zeros{PTO_XLEN},
        FALSE, Zeros{PTO_XLEN}, 0);
    AssertNumericFiniteDecomposition(TileDataType_HF32,
        Zeros{PTO_XLEN} + 0x80000000, TRUE, Zeros{PTO_XLEN}, 0);
    AssertNumericFiniteDecomposition(TileDataType_HF32,
        Zeros{PTO_XLEN} + 0x00001000, FALSE, Zeros{PTO_XLEN} + 1, -137);
    AssertNumericFiniteDecomposition(TileDataType_HF32,
        Zeros{PTO_XLEN} + 0x007ff000, FALSE, Zeros{PTO_XLEN} + 0x7ff, -137);
    AssertNumericFiniteDecomposition(TileDataType_HF32,
        Zeros{PTO_XLEN} + 0x00800000, FALSE, Zeros{PTO_XLEN} + 0x800, -137);
    AssertNumericFiniteDecomposition(TileDataType_HF32,
        Zeros{PTO_XLEN} + 0x7f7ff000, FALSE, Zeros{PTO_XLEN} + 0xfff, 116);
    AssertNumericFiniteDecompositionUnavailable(TileDataType_HF32,
        Zeros{PTO_XLEN} + 1);
    AssertNumericFiniteDecompositionUnavailable(TileDataType_HF32,
        Zeros{PTO_XLEN} + 0x7f800000);
    AssertNumericFiniteDecompositionUnavailable(TileDataType_HF32,
        Zeros{PTO_XLEN} + 0x7fc00000);
    assert TileNumericValueClass(TileDataType_HF32,
        Zeros{PTO_XLEN} + 0x7f800000) == NumericValue_PositiveInfinity;
    assert TileNumericValueClass(TileDataType_HF32,
        Zeros{PTO_XLEN} + 0xff800000) == NumericValue_NegativeInfinity;
    assert TileNumericValueClass(TileDataType_HF32,
        Zeros{PTO_XLEN} + 0x7fc00000) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_HF32,
        Zeros{PTO_XLEN} + 0x7f801000) == NumericValue_SignalingNaN;
    let (nan_available, canonical_nan) = TileNumericCanonicalNaN(TileDataType_HF32);
    assert nan_available && canonical_nan == Zeros{PTO_XLEN} + 0x7fc00000;
end;
func main() => integer
begin
    TestHF32NumericFormat();
    return 0;
end;

