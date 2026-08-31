// PTO-TEST: {"id":"PTO-AVS-ARCH-CONCRETE-ROUNDING-EXEC-004","source":"asl/arch/profile/reference-profile.asl","requirements":[],"kind":"execution","summary":"reference-profile rounding and conversion operations are exact","pass_condition":"rounding selectors, scalar FP, and Tile conversion assertions hold","related_sources":[]}
func TestConcreteRoundingProfile()
begin
    assert CurrentACR() == 0;
    let reset_time = ReadMonotonicTime();
    assert reset_time == Zeros{PTO_XLEN};
    AdvanceArchitecturalTime();
    let advanced_time = ReadMonotonicTime();
    assert advanced_time == Zeros{PTO_XLEN} + 1;

    let exponential_zero = FloatingExponential(0.0);
    assert exponential_zero == 1.0;
    let rounded_even_low = FloatingRoundNearest(2.5);
    let rounded_even_high = FloatingRoundNearest(3.5);
    let rounded_even_negative_low = FloatingRoundNearest(-2.5);
    let rounded_even_negative_high = FloatingRoundNearest(-3.5);
    assert rounded_even_low == 2;
    assert rounded_even_high == 4;
    assert rounded_even_negative_low == -2;
    assert rounded_even_negative_high == -4;

    let rne_positive = FloatingToInteger(2.5, NumericRound_RNE);
    let rne_negative = FloatingToInteger(-2.5, NumericRound_RNE);
    let down_positive = FloatingToInteger(2.5, NumericRound_RTM);
    let down_negative = FloatingToInteger(-2.5, NumericRound_RTM);
    let up_positive = FloatingToInteger(2.5, NumericRound_RTP);
    let up_negative = FloatingToInteger(-2.5, NumericRound_RTP);
    let zero_positive = FloatingToInteger(2.5, NumericRound_RTZ);
    let zero_negative = FloatingToInteger(-2.5, NumericRound_RTZ);
    let away_nonhalf_positive = FloatingToInteger(2.1, NumericRound_RNA);
    let away_nonhalf_negative = FloatingToInteger(-2.1, NumericRound_RNA);
    let away_positive = FloatingToInteger(2.5, NumericRound_RNA);
    let away_negative = FloatingToInteger(-2.5, NumericRound_RNA);
    let odd_exact_even = FloatingToInteger(2.0, NumericRound_RTO);
    let odd_exact_odd = FloatingToInteger(3.0, NumericRound_RTO);
    let odd_positive = FloatingToInteger(2.25, NumericRound_RTO);
    let odd_negative = FloatingToInteger(-2.25, NumericRound_RTO);
    let half_up_positive = FloatingToInteger(2.5, NumericRound_RHB);
    let half_up_negative = FloatingToInteger(-2.5, NumericRound_RHB);
    assert rne_positive == 2;
    assert rne_negative == -2;
    assert down_positive == 2;
    assert down_negative == -3;
    assert up_positive == 3;
    assert up_negative == -2;
    assert zero_positive == 2;
    assert zero_negative == -2;
    assert away_nonhalf_positive == 2;
    assert away_nonhalf_negative == -2;
    assert away_positive == 3;
    assert away_negative == -3;
    assert odd_exact_even == 2;
    assert odd_exact_odd == 3;
    assert odd_positive == 3;
    assert odd_negative == -3;
    assert half_up_positive == 3;
    assert half_up_negative == -2;

    assert ResolveScalarFPActiveRoundingMode('000') == NumericRound_RNE;
    assert ResolveScalarFPActiveRoundingMode('001') == NumericRound_RTM;
    assert ResolveScalarFPActiveRoundingMode('010') == NumericRound_RTP;
    assert ResolveScalarFPActiveRoundingMode('011') == NumericRound_RTZ;
    // Active FRM has only four modes. Reserved raw values use the specified
    // RNE fallback and never inherit the bundle namespace.
    assert ResolveScalarFPActiveRoundingMode('100') == NumericRound_RNE;
    assert ResolveScalarFPActiveRoundingMode('111') == NumericRound_RNE;

    let bundle_none = DecodeBundleRoundingSelection('000');
    let bundle_rne = DecodeBundleRoundingSelection('001');
    let bundle_rtz = DecodeBundleRoundingSelection('010');
    let bundle_rdn = DecodeBundleRoundingSelection('011');
    let bundle_rup = DecodeBundleRoundingSelection('100');
    let bundle_rna = DecodeBundleRoundingSelection('101');
    let bundle_rto = DecodeBundleRoundingSelection('110');
    let bundle_rhb = DecodeBundleRoundingSelection('111');
    assert bundle_none.use_operation_default;
    assert bundle_rne.rounding_mode == NumericRound_RNE;
    assert bundle_rtz.rounding_mode == NumericRound_RTZ;
    assert bundle_rdn.rounding_mode == NumericRound_RTM;
    assert bundle_rup.rounding_mode == NumericRound_RTP;
    assert bundle_rna.rounding_mode == NumericRound_RNA;
    assert bundle_rto.rounding_mode == NumericRound_RTO;
    assert bundle_rhb.rounding_mode == NumericRound_RHB;

    let (public_none_valid, public_none) =
        DecodePublicConversionRoundingSelection('000');
    let (public_round_valid, public_round) =
        DecodePublicConversionRoundingSelection('010');
    let (public_floor_valid, public_floor) =
        DecodePublicConversionRoundingSelection('011');
    let (public_trunc_valid, public_trunc) =
        DecodePublicConversionRoundingSelection('101');
    let (public_odd_valid, public_odd) =
        DecodePublicConversionRoundingSelection('110');
    let (public_reserved_valid, -) =
        DecodePublicConversionRoundingSelection('111');
    assert public_none_valid && public_none.use_operation_default;
    assert public_round_valid &&
           public_round.rounding_mode == NumericRound_RNA;
    assert public_floor_valid &&
           public_floor.rounding_mode == NumericRound_RTM;
    assert public_trunc_valid &&
           public_trunc.rounding_mode == NumericRound_RTZ;
    assert public_odd_valid && public_odd.rounding_mode == NumericRound_RTO;
    assert !public_reserved_valid;

    let (fp_binary, fp_binary_flags) = ScalarFPBinaryProfile(
        FloatingBinary_ADD, NumericRound_RNE, Zeros{5},
        Zeros{PTO_XLEN} + 0x4000000000000000,
        Zeros{PTO_XLEN} + 0x4008000000000000);
    assert fp_binary == Zeros{PTO_XLEN} + 0x4014000000000000;
    assert fp_binary_flags == Zeros{5};
    let (fp_unary, fp_unary_flags) = ScalarFPUnaryProfile(
        FloatingUnary_EXP, NumericRound_RNE, Zeros{5}, Zeros{PTO_XLEN});
    assert fp_unary == Zeros{PTO_XLEN} + 0x3ff0000000000000;
    assert fp_unary_flags == Zeros{5};
    let (fp_fused, fp_fused_flags) = ScalarFPFusedProfile(
        FloatingFused_MADD, NumericRound_RNE, Zeros{5},
        Zeros{PTO_XLEN} + 0x3ff0000000000000,
        Zeros{PTO_XLEN} + 0x4000000000000000,
        Zeros{PTO_XLEN} + 0x4008000000000000);
    assert fp_fused == Zeros{PTO_XLEN} + 0x401c000000000000;
    assert fp_fused_flags == Zeros{5};
    let (fp_integer, fp_integer_flags) = ScalarFPToIntegerProfile(
        NumericRound_RNE, Zeros{5}, Zeros{5},
        Zeros{PTO_XLEN} + 0x4022000000000000);
    assert fp_integer == Zeros{PTO_XLEN} + 9;
    assert fp_integer_flags == Zeros{5};
    let (fp_convert, fp_convert_flags) = ScalarFPConvertProfile(
        NumericRound_RNE, Zeros{5} + 1, Zeros{5},
        Zeros{PTO_XLEN} + 0x4024000000000000);
    assert fp_convert == Zeros{PTO_XLEN} + 0x41200000;
    assert fp_convert_flags == Zeros{5};
    let (integer_fp, integer_fp_flags) = ScalarIntegerToFPProfile(
        NumericRound_RNE, Zeros{5}, Zeros{5} + 1, Zeros{PTO_XLEN} + 11);
    assert integer_fp == Zeros{PTO_XLEN} + 0x41300000;
    assert integer_fp_flags == Zeros{5};

    let tile_square_root = TileSquareRoot(Zeros{PTO_XLEN} + 9);
    let tile_logarithm = TileLogarithm(Zeros{PTO_XLEN} + 9);
    assert tile_square_root == Zeros{PTO_XLEN} + 9;
    assert tile_logarithm == Zeros{PTO_XLEN} + 9;
    let reciprocal_three = TileReciprocal(Zeros{PTO_XLEN} + 3);
    assert reciprocal_three == DivideWordUnsigned(
        Ones{PTO_XLEN}, Zeros{PTO_XLEN} + 3);
    let tile_exponential = TileExponential(Zeros{PTO_XLEN} + 4);
    assert tile_exponential == Zeros{PTO_XLEN} + 5;

    let (converted_tile, converted_tile_flags) = TileProfileConvert(
        Zeros{PTO_XLEN} + 0x123,
        TileDataType_U64, TileDataType_U8, DefaultNumericExecutionControl());
    assert converted_tile == Zeros{PTO_XLEN} + 0x23;
    assert converted_tile_flags == Zeros{5};
    let (quantized_tile, quantized_tile_flags) = TileProfileQuantize(
        Zeros{PTO_XLEN} + 0x41a00000,
        Zeros{PTO_XLEN} + 0x3e800000,
        Zeros{PTO_XLEN} + 1,
        TileDataType_FP32,
        TileDataType_U8,
        DefaultNumericExecutionControl());
    assert quantized_tile == Zeros{PTO_XLEN} + 6;
    assert quantized_tile_flags == Zeros{5};
    let (dequantized_tile, dequantized_tile_flags) = TileProfileDequantize(
        Zeros{PTO_XLEN} + 7,
        Zeros{PTO_XLEN} + 0x40400000,
        Zeros{PTO_XLEN} + 1,
        TileDataType_U8,
        TileDataType_FP32,
        DefaultNumericExecutionControl());
    assert dequantized_tile == Zeros{PTO_XLEN} + 0x41900000;
    assert dequantized_tile_flags == Zeros{5};
end;
func main() => integer
begin
    ResetProfileState();
    TestConcreteRoundingProfile();
    return 0;
end;
