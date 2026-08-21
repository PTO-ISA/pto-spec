func TestHiF8NumericFormat()
begin
    let descriptor = TileNumericFormatDescriptor(TileDataType_HiF8);
    assert descriptor.available && descriptor.kind == NumericFormatKind_HiF8;
    assert descriptor.carrier_bits == 8 && descriptor.lane_bits == 8;
    assert descriptor.lanes_per_carrier == 1;
    assert descriptor.sign_bits == 1 && descriptor.sign_bit == 7;
    assert descriptor.exponent_bits_min == 0 && descriptor.exponent_bits_max == 4;
    assert descriptor.fraction_bits_min == 1 && descriptor.fraction_bits_max == 3;
    assert !descriptor.exponent_bias_available;
    assert descriptor.has_zero && !descriptor.has_signed_zero;
    assert descriptor.has_subnormal && descriptor.has_infinity;
    assert descriptor.has_quiet_nan && !descriptor.has_signaling_nan;

    let (denormal, denormal_e, denormal_m) = HiF8DecodeDotField('00000000');
    let (d0, d0_e, d0_m) = HiF8DecodeDotField('00001000');
    let (d1, d1_e, d1_m) = HiF8DecodeDotField('00010000');
    let (d2, d2_e, d2_m) = HiF8DecodeDotField('00100000');
    let (d3, d3_e, d3_m) = HiF8DecodeDotField('01000000');
    let (d4, d4_e, d4_m) = HiF8DecodeDotField('01100000');
    assert denormal == HiF8DotField_Denormal && denormal_e == 0 && denormal_m == 3;
    assert d0 == HiF8DotField_D0 && d0_e == 0 && d0_m == 3;
    assert d1 == HiF8DotField_D1 && d1_e == 1 && d1_m == 3;
    assert d2 == HiF8DotField_D2 && d2_e == 2 && d2_m == 3;
    assert d3 == HiF8DotField_D3 && d3_e == 3 && d3_m == 2;
    assert d4 == HiF8DotField_D4 && d4_e == 4 && d4_m == 1;

    AssertNumericFiniteDecomposition(TileDataType_HiF8, Zeros{PTO_XLEN},
        FALSE, Zeros{PTO_XLEN}, 0);
    AssertNumericFiniteDecomposition(TileDataType_HiF8, Zeros{PTO_XLEN} + 1,
        FALSE, Zeros{PTO_XLEN} + 1, -22);
    AssertNumericFiniteDecomposition(TileDataType_HiF8, Zeros{PTO_XLEN} + 7,
        FALSE, Zeros{PTO_XLEN} + 1, -16);
    AssertNumericFiniteDecomposition(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x81, TRUE, Zeros{PTO_XLEN} + 1, -22);
    AssertNumericFiniteDecomposition(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x08, FALSE, Zeros{PTO_XLEN} + 8, -3);
    AssertNumericFiniteDecomposition(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x0f, FALSE, Zeros{PTO_XLEN} + 15, -3);
    AssertNumericFiniteDecomposition(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x10, FALSE, Zeros{PTO_XLEN} + 8, -2);
    AssertNumericFiniteDecomposition(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x18, FALSE, Zeros{PTO_XLEN} + 8, -4);
    AssertNumericFiniteDecomposition(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x20, FALSE, Zeros{PTO_XLEN} + 8, -1);
    AssertNumericFiniteDecomposition(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x28, FALSE, Zeros{PTO_XLEN} + 8, 0);
    AssertNumericFiniteDecomposition(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x30, FALSE, Zeros{PTO_XLEN} + 8, -5);
    AssertNumericFiniteDecomposition(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x38, FALSE, Zeros{PTO_XLEN} + 8, -6);
    AssertNumericFiniteDecomposition(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x40, FALSE, Zeros{PTO_XLEN} + 4, 2);
    AssertNumericFiniteDecomposition(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x4c, FALSE, Zeros{PTO_XLEN} + 4, 5);
    AssertNumericFiniteDecomposition(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x50, FALSE, Zeros{PTO_XLEN} + 4, -6);
    AssertNumericFiniteDecomposition(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x5c, FALSE, Zeros{PTO_XLEN} + 4, -9);
    AssertNumericFiniteDecomposition(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x60, FALSE, Zeros{PTO_XLEN} + 2, 7);
    AssertNumericFiniteDecomposition(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x6e, FALSE, Zeros{PTO_XLEN} + 2, 14);
    AssertNumericFiniteDecomposition(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x70, FALSE, Zeros{PTO_XLEN} + 2, -9);
    AssertNumericFiniteDecomposition(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x7e, FALSE, Zeros{PTO_XLEN} + 2, -16);
    AssertNumericFiniteDecompositionUnavailable(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x80);
    AssertNumericFiniteDecompositionUnavailable(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x6f);
    AssertNumericFiniteDecompositionUnavailable(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0xef);
    assert TileNumericValueClass(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x80) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x6f) == NumericValue_PositiveInfinity;
    assert TileNumericValueClass(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0xef) == NumericValue_NegativeInfinity;
    let (nan_available, canonical_nan) = TileNumericCanonicalNaN(TileDataType_HiF8);
    assert nan_available && canonical_nan == Zeros{PTO_XLEN} + 0x80;
end;
