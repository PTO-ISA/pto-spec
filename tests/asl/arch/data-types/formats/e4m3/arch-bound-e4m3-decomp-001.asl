// PTO-TEST: {"id":"PTO-AVS-ARCH-E4M3-DECOMP-001","source":"asl/arch/data-types/formats/e4m3.asl","requirements":["PTO-NUMERIC-FINITE-DECOMPOSITION-001"],"kind":"boundary","summary":"E4M3 exposes its exact descriptor and finite-value decomposition.","pass_condition":"Field metadata, finite boundaries, unavailable special values, and existing value-class rules agree.","related_sources":["asl/arch/data-types/numeric-formats.asl","asl/arch/features/mx-formats.asl"]}
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
func TestE4M3NumericFormat()
begin
    let descriptor = TileNumericFormatDescriptor(TileDataType_E4M3);
    assert descriptor.available && descriptor.kind == NumericFormatKind_FixedBinary;
    assert descriptor.carrier_bits == 8 && descriptor.lane_bits == 8;
    assert descriptor.lanes_per_carrier == 1;
    assert descriptor.sign_bit == 7 && descriptor.exponent_bits_min == 4;
    assert descriptor.fraction_bits_min == 3 && descriptor.exponent_bias == 7;
    assert descriptor.has_zero && descriptor.has_signed_zero && descriptor.has_subnormal;
    assert !descriptor.has_infinity && descriptor.has_quiet_nan;
    assert !descriptor.has_signaling_nan;
    AssertNumericFiniteDecomposition(TileDataType_E4M3, Zeros{PTO_XLEN} + 1,
        FALSE, Zeros{PTO_XLEN} + 1, -9);
    AssertNumericFiniteDecomposition(TileDataType_E4M3, Zeros{PTO_XLEN} + 7,
        FALSE, Zeros{PTO_XLEN} + 7, -9);
    AssertNumericFiniteDecomposition(TileDataType_E4M3, Zeros{PTO_XLEN} + 8,
        FALSE, Zeros{PTO_XLEN} + 8, -9);
    AssertNumericFiniteDecomposition(TileDataType_E4M3,
        Zeros{PTO_XLEN} + 0x7e, FALSE, Zeros{PTO_XLEN} + 14, 5);
    AssertNumericFiniteDecomposition(TileDataType_E4M3,
        Zeros{PTO_XLEN} + 0x80, TRUE, Zeros{PTO_XLEN}, 0);
    AssertNumericFiniteDecompositionUnavailable(TileDataType_E4M3,
        Zeros{PTO_XLEN} + 0x7f);
    AssertNumericFiniteDecompositionUnavailable(TileDataType_E4M3,
        Zeros{PTO_XLEN} + 0xff);
    assert !NumericValueClassIsInfinity(TileNumericValueClass(
        TileDataType_E4M3, Zeros{PTO_XLEN} + 0x78));
    assert TileNumericValueClass(TileDataType_E4M3,
        Zeros{PTO_XLEN} + 0x7f) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_E4M3,
        Zeros{PTO_XLEN} + 0xff) == NumericValue_QuietNaN;
    let (nan_available, canonical_nan) = TileNumericCanonicalNaN(TileDataType_E4M3);
    assert nan_available && canonical_nan == Zeros{PTO_XLEN} + 0x7f;
end;
func main() => integer
begin
    TestE4M3NumericFormat();
    return 0;
end;
