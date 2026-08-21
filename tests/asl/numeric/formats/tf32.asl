func TestTF32NumericFormat()
begin
    let descriptor = TileNumericFormatDescriptor(TileDataType_TF32);
    assert descriptor.available && descriptor.kind == NumericFormatKind_FixedBinary;
    assert descriptor.carrier_bits == 32 && descriptor.lane_bits == 32;
    assert descriptor.sign_bit == 31;
    assert descriptor.exponent_bits_min == 8 && descriptor.exponent_bits_max == 8;
    assert descriptor.fraction_bits_min == 10 && descriptor.fraction_bits_max == 10;
    assert descriptor.exponent_bias_available && descriptor.exponent_bias == 127;
    assert descriptor.required_low_zero_bits == 13;
    assert descriptor.has_infinity && descriptor.has_quiet_nan && descriptor.has_signaling_nan;
    AssertNumericFiniteDecomposition(TileDataType_TF32, Zeros{PTO_XLEN},
        FALSE, Zeros{PTO_XLEN}, 0);
    AssertNumericFiniteDecomposition(TileDataType_TF32,
        Zeros{PTO_XLEN} + 0x80000000, TRUE, Zeros{PTO_XLEN}, 0);
    AssertNumericFiniteDecomposition(TileDataType_TF32,
        Zeros{PTO_XLEN} + 0x00002000, FALSE, Zeros{PTO_XLEN} + 1, -136);
    AssertNumericFiniteDecomposition(TileDataType_TF32,
        Zeros{PTO_XLEN} + 0x007fe000, FALSE, Zeros{PTO_XLEN} + 0x3ff, -136);
    AssertNumericFiniteDecomposition(TileDataType_TF32,
        Zeros{PTO_XLEN} + 0x00800000, FALSE, Zeros{PTO_XLEN} + 0x400, -136);
    AssertNumericFiniteDecomposition(TileDataType_TF32,
        Zeros{PTO_XLEN} + 0x7f7fe000, FALSE, Zeros{PTO_XLEN} + 0x7ff, 117);
    AssertNumericFiniteDecompositionUnavailable(TileDataType_TF32,
        Zeros{PTO_XLEN} + 1);
    AssertNumericFiniteDecompositionUnavailable(TileDataType_TF32,
        Zeros{PTO_XLEN} + 0x7f800000);
    AssertNumericFiniteDecompositionUnavailable(TileDataType_TF32,
        Zeros{PTO_XLEN} + 0x7fc00000);
    assert TileNumericValueClass(TileDataType_TF32,
        Zeros{PTO_XLEN} + 0x7f800000) == NumericValue_PositiveInfinity;
    assert TileNumericValueClass(TileDataType_TF32,
        Zeros{PTO_XLEN} + 0xff800000) == NumericValue_NegativeInfinity;
    assert TileNumericValueClass(TileDataType_TF32,
        Zeros{PTO_XLEN} + 0x7fc00000) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_TF32,
        Zeros{PTO_XLEN} + 0x7f802000) == NumericValue_SignalingNaN;
    let (nan_available, canonical_nan) = TileNumericCanonicalNaN(TileDataType_TF32);
    assert nan_available && canonical_nan == Zeros{PTO_XLEN} + 0x7fc00000;
end;
