// PTO-TEST: {"id":"PTO-AVS-ARCH-E6M2-DECOMP-001","source":"asl/arch/data-types/formats/e6m2.asl","requirements":["PTO-NUMERIC-E6M2-FORMAT-001"],"kind":"boundary","summary":"E6M2 exposes its exact eight-bit descriptor, finite values, and quiet-NaN boundary","pass_condition":"E6M2 codes 00..FE classify as positive normal values with the specified bias-48 value map and FF classifies as quiet NaN","related_sources":["asl/arch/data-types/numeric-formats.asl","asl/arch/features/mx-formats.asl"]}
func TestE6M2NumericFormat()
begin
    let descriptor = TileNumericFormatDescriptor(TileDataType_E6M2);
    assert descriptor.available && descriptor.kind == NumericFormatKind_FixedBinary;
    assert descriptor.carrier_bits == 8 && descriptor.lane_bits == 8;
    assert descriptor.lanes_per_carrier == 1 && descriptor.sign_bits == 0;
    assert descriptor.exponent_bits_min == 6 && descriptor.fraction_bits_min == 2;
    assert descriptor.exponent_bias_available && descriptor.exponent_bias == 48;
    assert !descriptor.has_zero && !descriptor.has_signed_zero;
    assert !descriptor.has_subnormal && !descriptor.has_infinity;
    assert descriptor.has_quiet_nan && !descriptor.has_signaling_nan;

    assert TileNumericValueClass(TileDataType_E6M2,
        Zeros{PTO_XLEN} + 0xc0) == NumericValue_PositiveNormal;
    assert E6M2FiniteValue(0xc0 as bits(8)) == 1.0;
    assert E6M2FiniteValue(0xc1 as bits(8)) == 1.25;
    assert E6M2FiniteValue(0xc2 as bits(8)) == 1.5;
    assert E6M2FiniteValue(0xc3 as bits(8)) == 1.75;
    assert E6M2FiniteValue(0xfe as bits(8)) == 49152.0;
    assert TileNumericValueClass(TileDataType_E6M2,
        Zeros{PTO_XLEN} + 0xff) == NumericValue_QuietNaN;

    let (available, negative, significand, exponent) =
        TileNumericFiniteDecomposition(TileDataType_E6M2,
            Zeros{PTO_XLEN} + 0xc1);
    assert available && !negative;
    assert significand == Zeros{PTO_XLEN} + 5 && exponent == -2;
end;
func main() => integer
begin
    TestE6M2NumericFormat();
    return 0;
end;
