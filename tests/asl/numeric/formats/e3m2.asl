func TestE3M2NumericFormat()
begin
    let descriptor = TileNumericFormatDescriptor(TileDataType_E3M2);
    assert descriptor.available && descriptor.kind == NumericFormatKind_FixedBinary;
    assert descriptor.carrier_bits == 8 && descriptor.lane_bits == 6;
    assert descriptor.sign_bit == 5 && descriptor.exponent_bits_min == 3;
    assert descriptor.fraction_bits_min == 2 && descriptor.exponent_bias == 3;
    assert descriptor.required_high_zero_bits == 2;
    assert !descriptor.has_infinity && !descriptor.has_quiet_nan;
    assert !descriptor.has_signaling_nan && descriptor.has_subnormal;
    AssertNumericFiniteDecomposition(TileDataType_E3M2, Zeros{PTO_XLEN} + 1,
        FALSE, Zeros{PTO_XLEN} + 1, -4);
    AssertNumericFiniteDecomposition(TileDataType_E3M2, Zeros{PTO_XLEN} + 3,
        FALSE, Zeros{PTO_XLEN} + 3, -4);
    AssertNumericFiniteDecomposition(TileDataType_E3M2, Zeros{PTO_XLEN} + 4,
        FALSE, Zeros{PTO_XLEN} + 4, -4);
    AssertNumericFiniteDecomposition(TileDataType_E3M2,
        Zeros{PTO_XLEN} + 0x1f, FALSE, Zeros{PTO_XLEN} + 7, 2);
    AssertNumericFiniteDecomposition(TileDataType_E3M2,
        Zeros{PTO_XLEN} + 0x20, TRUE, Zeros{PTO_XLEN}, 0);
    AssertNumericFiniteDecompositionUnavailable(TileDataType_E3M2,
        Zeros{PTO_XLEN} + 0x40);
    assert TileNumericValueClass(TileDataType_E3M2,
        Zeros{PTO_XLEN} + 0x1f) == NumericValue_PositiveNormal;
    assert TileNumericValueClass(TileDataType_E3M2,
        Zeros{PTO_XLEN} + 0x20) == NumericValue_NegativeZero;
end;
