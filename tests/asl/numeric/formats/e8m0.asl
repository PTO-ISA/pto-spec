func TestE8M0NumericFormat()
begin
    let descriptor = TileNumericFormatDescriptor(TileDataType_E8M0);
    assert descriptor.available && descriptor.kind == NumericFormatKind_E8M0;
    assert descriptor.carrier_bits == 8 && descriptor.lane_bits == 8;
    assert descriptor.lanes_per_carrier == 1 && descriptor.sign_bits == 0;
    assert descriptor.exponent_bits_min == 8 && descriptor.exponent_bits_max == 8;
    assert descriptor.fraction_bits_min == 0 && descriptor.fraction_bits_max == 0;
    assert descriptor.exponent_bias_available && descriptor.exponent_bias == 127;
    assert !descriptor.has_zero && !descriptor.has_signed_zero;
    assert !descriptor.has_subnormal && !descriptor.has_infinity;
    assert descriptor.has_quiet_nan && !descriptor.has_signaling_nan;
    AssertNumericFiniteDecomposition(TileDataType_E8M0, Zeros{PTO_XLEN},
        FALSE, Zeros{PTO_XLEN} + 1, -127);
    AssertNumericFiniteDecomposition(TileDataType_E8M0, Zeros{PTO_XLEN} + 1,
        FALSE, Zeros{PTO_XLEN} + 1, -126);
    AssertNumericFiniteDecomposition(TileDataType_E8M0,
        Zeros{PTO_XLEN} + 0x7f, FALSE, Zeros{PTO_XLEN} + 1, 0);
    AssertNumericFiniteDecomposition(TileDataType_E8M0,
        Zeros{PTO_XLEN} + 0x80, FALSE, Zeros{PTO_XLEN} + 1, 1);
    AssertNumericFiniteDecomposition(TileDataType_E8M0,
        Zeros{PTO_XLEN} + 0xfe, FALSE, Zeros{PTO_XLEN} + 1, 127);
    AssertNumericFiniteDecompositionUnavailable(TileDataType_E8M0,
        Zeros{PTO_XLEN} + 0xff);
    assert TileNumericValueClass(TileDataType_E8M0,
        Zeros{PTO_XLEN}) == NumericValue_PositiveNormal;
    assert TileNumericValueClass(TileDataType_E8M0,
        Zeros{PTO_XLEN} + 0xff) == NumericValue_QuietNaN;
    let (nan_available, canonical_nan) = TileNumericCanonicalNaN(TileDataType_E8M0);
    assert nan_available && canonical_nan == Zeros{PTO_XLEN} + 0xff;
    assert HardwareNumericScaleBlockElements() == 32;
end;
