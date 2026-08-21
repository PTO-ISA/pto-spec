func TestFP64NumericFormat()
begin
    let descriptor = TileNumericFormatDescriptor(TileDataType_FP64);
    assert descriptor.available;
    assert descriptor.kind == NumericFormatKind_FixedBinary;
    assert descriptor.carrier_bits == 64 && descriptor.lane_bits == 64;
    assert descriptor.lanes_per_carrier == 1;
    assert descriptor.sign_bits == 1 && descriptor.sign_bit == 63;
    assert descriptor.exponent_bits_min == 11 && descriptor.exponent_bits_max == 11;
    assert descriptor.fraction_bits_min == 52 && descriptor.fraction_bits_max == 52;
    assert descriptor.exponent_bias_available && descriptor.exponent_bias == 1023;
    assert descriptor.required_low_zero_bits == 0 && descriptor.required_high_zero_bits == 0;
    assert descriptor.has_zero && descriptor.has_signed_zero && descriptor.has_subnormal;
    assert descriptor.has_infinity && descriptor.has_quiet_nan && descriptor.has_signaling_nan;
    AssertNumericFiniteDecomposition(TileDataType_FP64, Zeros{PTO_XLEN},
        FALSE, Zeros{PTO_XLEN}, 0);
    AssertNumericFiniteDecomposition(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x8000000000000000, TRUE, Zeros{PTO_XLEN}, 0);
    AssertNumericFiniteDecomposition(TileDataType_FP64, Zeros{PTO_XLEN} + 1,
        FALSE, Zeros{PTO_XLEN} + 1, -1074);
    AssertNumericFiniteDecomposition(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x000fffffffffffff, FALSE,
        Zeros{PTO_XLEN} + 0x000fffffffffffff, -1074);
    AssertNumericFiniteDecomposition(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x0010000000000000, FALSE,
        Zeros{PTO_XLEN} + 0x0010000000000000, -1074);
    AssertNumericFiniteDecomposition(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x7fefffffffffffff, FALSE,
        Zeros{PTO_XLEN} + 0x001fffffffffffff, 971);
    AssertNumericFiniteDecomposition(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0xbff0000000000000, TRUE,
        Zeros{PTO_XLEN} + 0x0010000000000000, -52);
    AssertNumericFiniteDecompositionUnavailable(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x7ff0000000000000);
    AssertNumericFiniteDecompositionUnavailable(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x7ff8000000000000);
    assert TileNumericValueClass(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x7ff0000000000000) == NumericValue_PositiveInfinity;
    assert TileNumericValueClass(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0xfff0000000000000) == NumericValue_NegativeInfinity;
    assert TileNumericValueClass(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x7ff8000000000000) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x7ff0000000000001) == NumericValue_SignalingNaN;
    let (nan_available, canonical_nan) = TileNumericCanonicalNaN(TileDataType_FP64);
    assert nan_available && canonical_nan ==
        Zeros{PTO_XLEN} + 0x7ff8000000000000;
end;
