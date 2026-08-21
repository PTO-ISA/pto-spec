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
        Zeros{PTO_XLEN} + 0x80);
    assert TileNumericValueClass(TileDataType_E2M3,
        Zeros{PTO_XLEN} + 0x1f) == NumericValue_PositiveNormal;
    assert TileNumericValueClass(TileDataType_E2M3,
        Zeros{PTO_XLEN} + 0x20) == NumericValue_NegativeZero;
end;
