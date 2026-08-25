// PTO-TEST: {"id":"PTO-AVS-ARCH-E2M3-DECOMP-001","source":"asl/arch/data-types/formats/e2m3.asl","requirements":["PTO-NUMERIC-FINITE-DECOMPOSITION-001"],"kind":"boundary","summary":"E2M3 exposes its exact descriptor and finite-value decomposition.","pass_condition":"Field metadata, finite boundaries, unavailable special values, and existing value-class rules agree.","related_sources":["asl/arch/data-types/numeric-formats.asl","asl/arch/features/mx-formats.asl"]}
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
func TestE2M3NumericFormat()
begin
    let descriptor = TileNumericFormatDescriptor(TileDataType_E2M3);
    assert descriptor.available && descriptor.kind == NumericFormatKind_FixedBinary;
    assert descriptor.carrier_bits == 8 && descriptor.lane_bits == 6;
    assert descriptor.sign_bit == 5 && descriptor.exponent_bits_min == 2;
    assert descriptor.fraction_bits_min == 3 && descriptor.exponent_bias == 1;
    assert descriptor.required_high_zero_bits == 2;
    assert !descriptor.has_infinity && !descriptor.has_quiet_nan;
    assert !descriptor.has_signaling_nan && descriptor.has_subnormal;
    AssertNumericFiniteDecomposition(TileDataType_E2M3, Zeros{PTO_XLEN} + 1,
        FALSE, Zeros{PTO_XLEN} + 1, -3);
    AssertNumericFiniteDecomposition(TileDataType_E2M3, Zeros{PTO_XLEN} + 7,
        FALSE, Zeros{PTO_XLEN} + 7, -3);
    AssertNumericFiniteDecomposition(TileDataType_E2M3, Zeros{PTO_XLEN} + 8,
        FALSE, Zeros{PTO_XLEN} + 8, -3);
    AssertNumericFiniteDecomposition(TileDataType_E2M3,
        Zeros{PTO_XLEN} + 0x1f, FALSE, Zeros{PTO_XLEN} + 15, -1);
    AssertNumericFiniteDecomposition(TileDataType_E2M3,
        Zeros{PTO_XLEN} + 0x20, TRUE, Zeros{PTO_XLEN}, 0);
    AssertNumericFiniteDecompositionUnavailable(TileDataType_E2M3,
        Zeros{PTO_XLEN} + 0x40);
    AssertNumericFiniteDecompositionUnavailable(TileDataType_E2M3,
        Zeros{PTO_XLEN} + 0x80);
    assert TileNumericValueClass(TileDataType_E2M3,
        Zeros{PTO_XLEN} + 0x1f) == NumericValue_PositiveNormal;
    assert TileNumericValueClass(TileDataType_E2M3,
        Zeros{PTO_XLEN} + 0x20) == NumericValue_NegativeZero;
end;
func main() => integer
begin
    TestE2M3NumericFormat();
    return 0;
end;
