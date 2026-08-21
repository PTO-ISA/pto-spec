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
