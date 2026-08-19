// PTO-TEST: {"id":"PTO-AVS-ARCH-E2M1X2-DECOMP-001","source":"asl/arch/data-types/formats/e2m1x2.asl","requirements":["PTO-NUMERIC-FINITE-DECOMPOSITION-001"],"kind":"boundary","summary":"E2M1X2 exposes its exact descriptor and finite-value decomposition.","pass_condition":"Field metadata, finite boundaries, unavailable special values, and existing value-class rules agree.","related_sources":["asl/arch/data-types/numeric-formats.asl","asl/arch/features/mx-formats.asl"]}
func AssertNumericFiniteDecomposition(data_type: TileDataType, value: Word,
                                       expected_negative: boolean,
                                       expected_significand: Word,
                                       expected_exponent: integer {-1074..1023})
begin
    let (available, negative, significand, exponent) =
        TileNumericFiniteDecomposition(data_type, value);
    assert available;
    assert negative == expected_negative;
    assert significand == expected_significand;
    assert exponent == expected_exponent;
end;

func AssertNumericFiniteDecompositionUnavailable(data_type: TileDataType,
                                                  value: Word)
begin
    let (available, negative, significand, exponent) =
        TileNumericFiniteDecomposition(data_type, value);
    assert !available;
    assert !negative;
    assert significand == Zeros{PTO_XLEN};
    assert exponent == 0;
end;
func AssertE2M1X2Lane(raw: integer {0..15}, negative: boolean,
                       significand: Word,
                       exponent: integer {-1074..1023})
begin
    AssertNumericFiniteDecomposition(TileDataType_E2M1X2,
        Zeros{PTO_XLEN} + raw, negative, significand, exponent);
end;

func TestE2M1X2NumericFormat()
begin
    let descriptor = TileNumericFormatDescriptor(TileDataType_E2M1X2);
    assert descriptor.available && descriptor.kind == NumericFormatKind_FixedBinary;
    assert descriptor.carrier_bits == 8 && descriptor.lane_bits == 4;
    assert descriptor.lanes_per_carrier == 2 && descriptor.sign_bit == 3;
    assert descriptor.exponent_bits_min == 2 && descriptor.fraction_bits_min == 1;
    assert descriptor.exponent_bias == 1;
    assert descriptor.has_zero && descriptor.has_signed_zero;
    assert !descriptor.has_subnormal && !descriptor.has_infinity;
    assert !descriptor.has_quiet_nan && !descriptor.has_signaling_nan;
    AssertE2M1X2Lane(0, FALSE, Zeros{PTO_XLEN}, 0);
    AssertE2M1X2Lane(1, FALSE, Zeros{PTO_XLEN} + 1, -1);
    AssertE2M1X2Lane(2, FALSE, Zeros{PTO_XLEN} + 2, -1);
    AssertE2M1X2Lane(3, FALSE, Zeros{PTO_XLEN} + 3, -1);
    AssertE2M1X2Lane(4, FALSE, Zeros{PTO_XLEN} + 2, 0);
    AssertE2M1X2Lane(5, FALSE, Zeros{PTO_XLEN} + 3, 0);
    AssertE2M1X2Lane(6, FALSE, Zeros{PTO_XLEN} + 2, 1);
    AssertE2M1X2Lane(7, FALSE, Zeros{PTO_XLEN} + 3, 1);
    AssertE2M1X2Lane(8, TRUE, Zeros{PTO_XLEN}, 0);
    AssertE2M1X2Lane(9, TRUE, Zeros{PTO_XLEN} + 1, -1);
    AssertE2M1X2Lane(10, TRUE, Zeros{PTO_XLEN} + 2, -1);
    AssertE2M1X2Lane(11, TRUE, Zeros{PTO_XLEN} + 3, -1);
    AssertE2M1X2Lane(12, TRUE, Zeros{PTO_XLEN} + 2, 0);
    AssertE2M1X2Lane(13, TRUE, Zeros{PTO_XLEN} + 3, 0);
    AssertE2M1X2Lane(14, TRUE, Zeros{PTO_XLEN} + 2, 1);
    AssertE2M1X2Lane(15, TRUE, Zeros{PTO_XLEN} + 3, 1);
    assert TileNumericValueClass(TileDataType_E2M1X2,
        Zeros{PTO_XLEN}) == NumericValue_PositiveZero;
    assert TileNumericValueClass(TileDataType_E2M1X2,
        Zeros{PTO_XLEN} + 8) == NumericValue_NegativeZero;
    assert TileNumericValueClass(TileDataType_E2M1X2,
        Zeros{PTO_XLEN} + 1) == NumericValue_PositiveNormal;
    assert TileNumericValueClass(TileDataType_E2M1X2,
        Zeros{PTO_XLEN} + 9) == NumericValue_NegativeNormal;
end;
func main() => integer
begin
    TestE2M1X2NumericFormat();
    return 0;
end;
