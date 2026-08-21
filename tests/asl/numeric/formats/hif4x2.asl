func AssertHiF4X2Lane(raw: integer {0..15}, negative: boolean,
                       significand: Word,
                       exponent: integer {-1074..1023})
begin
    AssertNumericFiniteDecomposition(TileDataType_HiF4X2,
        Zeros{PTO_XLEN} + raw, negative, significand, exponent);
end;

func TestHiF4X2NumericFormat()
begin
    let descriptor = TileNumericFormatDescriptor(TileDataType_HiF4X2);
    assert descriptor.available && descriptor.kind == NumericFormatKind_FixedBinary;
    assert descriptor.carrier_bits == 8 && descriptor.lane_bits == 4;
    assert descriptor.lanes_per_carrier == 2 && descriptor.sign_bit == 3;
    assert descriptor.exponent_bits_min == 1 && descriptor.fraction_bits_min == 2;
    assert descriptor.exponent_bias == 1;
    assert descriptor.has_zero && descriptor.has_signed_zero;
    assert !descriptor.has_subnormal && !descriptor.has_infinity;
    AssertHiF4X2Lane(0, FALSE, Zeros{PTO_XLEN}, 0);
    AssertHiF4X2Lane(1, FALSE, Zeros{PTO_XLEN} + 1, -2);
    AssertHiF4X2Lane(2, FALSE, Zeros{PTO_XLEN} + 2, -2);
    AssertHiF4X2Lane(3, FALSE, Zeros{PTO_XLEN} + 3, -2);
    AssertHiF4X2Lane(4, FALSE, Zeros{PTO_XLEN} + 4, -2);
    AssertHiF4X2Lane(5, FALSE, Zeros{PTO_XLEN} + 5, -2);
    AssertHiF4X2Lane(6, FALSE, Zeros{PTO_XLEN} + 6, -2);
    AssertHiF4X2Lane(7, FALSE, Zeros{PTO_XLEN} + 7, -2);
    AssertHiF4X2Lane(8, TRUE, Zeros{PTO_XLEN}, 0);
    AssertHiF4X2Lane(9, TRUE, Zeros{PTO_XLEN} + 1, -2);
    AssertHiF4X2Lane(10, TRUE, Zeros{PTO_XLEN} + 2, -2);
    AssertHiF4X2Lane(11, TRUE, Zeros{PTO_XLEN} + 3, -2);
    AssertHiF4X2Lane(12, TRUE, Zeros{PTO_XLEN} + 4, -2);
    AssertHiF4X2Lane(13, TRUE, Zeros{PTO_XLEN} + 5, -2);
    AssertHiF4X2Lane(14, TRUE, Zeros{PTO_XLEN} + 6, -2);
    AssertHiF4X2Lane(15, TRUE, Zeros{PTO_XLEN} + 7, -2);
    assert TileNumericValueClass(TileDataType_HiF4X2,
        Zeros{PTO_XLEN}) == NumericValue_PositiveZero;
    assert TileNumericValueClass(TileDataType_HiF4X2,
        Zeros{PTO_XLEN} + 8) == NumericValue_NegativeZero;
    assert TileNumericValueClass(TileDataType_HiF4X2,
        Zeros{PTO_XLEN} + 1) == NumericValue_PositiveNormal;
    assert TileNumericValueClass(TileDataType_HiF4X2,
        Zeros{PTO_XLEN} + 9) == NumericValue_NegativeNormal;
end;
