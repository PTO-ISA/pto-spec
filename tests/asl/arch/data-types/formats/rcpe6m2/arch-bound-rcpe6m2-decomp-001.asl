// PTO-TEST: {"id":"PTO-AVS-ARCH-RCPE6M2-DECOMP-001","source":"asl/arch/data-types/formats/rcpe6m2.asl","requirements":["PTO-NUMERIC-RCPE6M2-FORMAT-001"],"kind":"boundary","summary":"RCPE6M2 exposes exact reciprocal interpretation and source-only numeric boundaries","pass_condition":"RCPE6M2 shares E6M2 raw classification, returns exact mathematical reciprocals, and does not claim an ordinary binary decomposition","related_sources":["asl/arch/data-types/formats/e6m2.asl","asl/arch/data-types/numeric-formats.asl"]}
func TestRCPE6M2NumericFormat()
begin
    let descriptor = TileNumericFormatDescriptor(TileDataType_RCPE6M2);
    assert descriptor.available && descriptor.kind == NumericFormatKind_FixedBinary;
    assert descriptor.carrier_bits == 8 && descriptor.lane_bits == 8;
    assert descriptor.lanes_per_carrier == 1 && descriptor.sign_bits == 0;
    assert descriptor.exponent_bits_min == 6 && descriptor.fraction_bits_min == 2;
    assert descriptor.exponent_bias_available && descriptor.exponent_bias == 48;
    assert !descriptor.has_zero && !descriptor.has_signed_zero;
    assert !descriptor.has_subnormal && !descriptor.has_infinity;
    assert descriptor.has_quiet_nan && !descriptor.has_signaling_nan;

    assert TileNumericValueClass(TileDataType_RCPE6M2,
        Zeros{PTO_XLEN} + 0xc0) == NumericValue_PositiveNormal;
    assert RCPE6M2FiniteValue(0xc0 as bits(8)) == 1.0;
    assert RCPE6M2FiniteValue(0xc1 as bits(8)) == 0.8;
    assert RCPE6M2FiniteValue(0xc2 as bits(8)) == 2.0 / 3.0;
    assert TileNumericValueClass(TileDataType_RCPE6M2,
        Zeros{PTO_XLEN} + 0xff) == NumericValue_QuietNaN;

    let (available, negative, significand, exponent) =
        TileNumericFiniteDecomposition(TileDataType_RCPE6M2,
            Zeros{PTO_XLEN} + 0xc1);
    assert !available && !negative;
    assert significand == Zeros{PTO_XLEN} && exponent == 0;
end;
func main() => integer
begin
    TestRCPE6M2NumericFormat();
    return 0;
end;
