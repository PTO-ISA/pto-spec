func TestE5M2NumericFormat()
begin
    let descriptor = TileNumericFormatDescriptor(TileDataType_E5M2);
    assert descriptor.available && descriptor.kind == NumericFormatKind_FixedBinary;
    assert descriptor.carrier_bits == 8 && descriptor.lane_bits == 8;
    assert descriptor.sign_bit == 7 && descriptor.exponent_bits_min == 5;
    assert descriptor.fraction_bits_min == 2 && descriptor.exponent_bias == 15;
    assert descriptor.has_infinity && descriptor.has_quiet_nan;
    assert descriptor.has_signaling_nan && descriptor.has_subnormal;
    AssertNumericFiniteDecomposition(TileDataType_E5M2, Zeros{PTO_XLEN} + 1,
        FALSE, Zeros{PTO_XLEN} + 1, -16);
    AssertNumericFiniteDecomposition(TileDataType_E5M2, Zeros{PTO_XLEN} + 3,
        FALSE, Zeros{PTO_XLEN} + 3, -16);
    AssertNumericFiniteDecomposition(TileDataType_E5M2, Zeros{PTO_XLEN} + 4,
        FALSE, Zeros{PTO_XLEN} + 4, -16);
    AssertNumericFiniteDecomposition(TileDataType_E5M2,
        Zeros{PTO_XLEN} + 0x7b, FALSE, Zeros{PTO_XLEN} + 7, 13);
    AssertNumericFiniteDecompositionUnavailable(TileDataType_E5M2,
        Zeros{PTO_XLEN} + 0x7c);
    AssertNumericFiniteDecompositionUnavailable(TileDataType_E5M2,
        Zeros{PTO_XLEN} + 0xfc);
    AssertNumericFiniteDecompositionUnavailable(TileDataType_E5M2,
        Zeros{PTO_XLEN} + 0x7e);
    AssertNumericFiniteDecompositionUnavailable(TileDataType_E5M2,
        Zeros{PTO_XLEN} + 0x7d);
    assert TileNumericValueClass(TileDataType_E5M2,
        Zeros{PTO_XLEN} + 0x7c) == NumericValue_PositiveInfinity;
    assert TileNumericValueClass(TileDataType_E5M2,
        Zeros{PTO_XLEN} + 0xfc) == NumericValue_NegativeInfinity;
    assert TileNumericValueClass(TileDataType_E5M2,
        Zeros{PTO_XLEN} + 0x7e) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_E5M2,
        Zeros{PTO_XLEN} + 0x7d) == NumericValue_SignalingNaN;
    let (nan_available, canonical_nan) = TileNumericCanonicalNaN(TileDataType_E5M2);
    assert nan_available && canonical_nan == Zeros{PTO_XLEN} + 0x7e;
end;
