// PTO-TEST: {"id":"PTO-AVS-ARCH-PACKED-CONVERSION-BOUNDARIES-002","source":"asl/arch/profile/packed-conversion.asl","requirements":["PTO-TCVT-CONTRACT-001"],"kind":"boundary","summary":"Packed FP4 reference conversion covers complete code sets, signed special values, and rounding boundaries","pass_condition":"All E2M1 and S1P2 values, midpoint controls, endpoint overflow, NaN/Infinity policy, signed zero, and exact reverse conversions return the frozen carriers and flags","related_sources":["asl/arch/data-types/formats/e1m2x2.asl","asl/arch/data-types/formats/e2m1x2.asl","asl/arch/profile/tcvt-conversion.asl"]}
func AssertPackedValueSet(data_type: TileDataType)
begin
    assert ReferencePacked4FiniteValue(data_type, 0) == 0.0;
    assert ReferencePacked4FiniteValue(data_type, 1) ==
        (if data_type == TileDataType_E2M1X2 then 0.5 else 0.25);
    assert ReferencePacked4FiniteValue(data_type, 2) ==
        (if data_type == TileDataType_E2M1X2 then 1.0 else 0.5);
    assert ReferencePacked4FiniteValue(data_type, 3) ==
        (if data_type == TileDataType_E2M1X2 then 1.5 else 0.75);
    assert ReferencePacked4FiniteValue(data_type, 4) ==
        (if data_type == TileDataType_E2M1X2 then 2.0 else 1.0);
    assert ReferencePacked4FiniteValue(data_type, 5) ==
        (if data_type == TileDataType_E2M1X2 then 3.0 else 1.25);
    assert ReferencePacked4FiniteValue(data_type, 6) ==
        (if data_type == TileDataType_E2M1X2 then 4.0 else 1.5);
    assert ReferencePacked4FiniteValue(data_type, 7) ==
        (if data_type == TileDataType_E2M1X2 then 6.0 else 1.75);
    for code = 8 to 15 looplimit 8 do
        assert ReferencePacked4FiniteValue(data_type,
            code as integer {0..15}) ==
            -ReferencePacked4FiniteValue(data_type,
                (code - 8) as integer {0..15});
    end;
end;

func ConvertFP32(value: integer {0..4294967295},
                 destination_type: TileDataType,
                 mode: NumericRoundingMode,
                 saturating: boolean) => (Word, bits(5))
begin
    let control = NumericExecutionControl {
        rounding_mode = mode, saturating = saturating
    };
    return TileProfileConvert(
        Zeros{PTO_XLEN} + value, TileDataType_FP32,
        destination_type, control);
end;

func AssertPackedForwardBoundaries()
begin
    let control = DefaultNumericExecutionControl();
    let (e2_020, e2_020_flags) = ConvertFP32(
        0x3e4ccccd, TileDataType_E2M1X2, NumericRound_RNE, FALSE);
    let (e2_025, e2_025_flags) = ConvertFP32(
        0x3e800000, TileDataType_E2M1X2, NumericRound_RNE, FALSE);
    let (e2_030, e2_030_flags) = ConvertFP32(
        0x3e99999a, TileDataType_E2M1X2, NumericRound_RNE, FALSE);
    let (e2_n020, e2_n020_flags) = ConvertFP32(
        0xbe4ccccd, TileDataType_E2M1X2, NumericRound_RNE, FALSE);
    let (e2_n025, e2_n025_flags) = ConvertFP32(
        0xbe800000, TileDataType_E2M1X2, NumericRound_RNE, FALSE);
    let (e2_n030, e2_n030_flags) = ConvertFP32(
        0xbe99999a, TileDataType_E2M1X2, NumericRound_RNE, FALSE);
    assert e2_020 == Zeros{PTO_XLEN} &&
           e2_025 == Zeros{PTO_XLEN} &&
           e2_030 == Zeros{PTO_XLEN} + 1;
    assert e2_n020 == Zeros{PTO_XLEN} + 8 &&
           e2_n025 == Zeros{PTO_XLEN} + 8 &&
           e2_n030 == Zeros{PTO_XLEN} + 9;
    assert e2_020_flags == Zeros{5} + 0x18 &&
           e2_025_flags == Zeros{5} + 0x18 &&
           e2_030_flags == Zeros{5} + 0x18;
    assert e2_n020_flags == Zeros{5} + 0x18 &&
           e2_n025_flags == Zeros{5} + 0x18 &&
           e2_n030_flags == Zeros{5} + 0x18;

    let (e1_0125, e1_0125_flags) = ConvertFP32(
        0x3e000000, TileDataType_E1M2X2, NumericRound_RNE, FALSE);
    let (e1_0375, e1_0375_flags) = ConvertFP32(
        0x3ec00000, TileDataType_E1M2X2, NumericRound_RNE, FALSE);
    let (e1_0625, e1_0625_flags) = ConvertFP32(
        0x3f200000, TileDataType_E1M2X2, NumericRound_RNE, FALSE);
    let (e1_0875, e1_0875_flags) = ConvertFP32(
        0x3f600000, TileDataType_E1M2X2, NumericRound_RNE, FALSE);
    assert e1_0125 == Zeros{PTO_XLEN} &&
           e1_0375 == Zeros{PTO_XLEN} + 2 &&
           e1_0625 == Zeros{PTO_XLEN} + 2 &&
           e1_0875 == Zeros{PTO_XLEN} + 4;
    assert e1_0125_flags == Zeros{5} + 0x18 &&
           e1_0375_flags == Zeros{5} + 0x10 &&
           e1_0625_flags == Zeros{5} + 0x10 &&
           e1_0875_flags == Zeros{5} + 0x10;

    let (rne, -) = ConvertFP32(
        0x3e99999a, TileDataType_E2M1X2, NumericRound_RNE, FALSE);
    let (rna, -) = ConvertFP32(
        0x3e99999a, TileDataType_E2M1X2, NumericRound_RNA, FALSE);
    let (rtp, -) = ConvertFP32(
        0x3e99999a, TileDataType_E2M1X2, NumericRound_RTP, FALSE);
    let (rtm, -) = ConvertFP32(
        0x3e99999a, TileDataType_E2M1X2, NumericRound_RTM, FALSE);
    let (rtz, -) = ConvertFP32(
        0x3e99999a, TileDataType_E2M1X2, NumericRound_RTZ, FALSE);
    let (rto, -) = ConvertFP32(
        0x3e99999a, TileDataType_E2M1X2, NumericRound_RTO, FALSE);
    let (negative_rto, -) = ConvertFP32(
        0xbe99999a, TileDataType_E2M1X2, NumericRound_RTO, FALSE);
    assert rne == Zeros{PTO_XLEN} + 1 &&
           rna == Zeros{PTO_XLEN} + 1 &&
           rtp == Zeros{PTO_XLEN} + 1 &&
           rtm == Zeros{PTO_XLEN} &&
           rtz == Zeros{PTO_XLEN} &&
           rto == Zeros{PTO_XLEN} + 1 &&
           negative_rto == Zeros{PTO_XLEN} + 9;

    let (e2_over, e2_over_flags) = ConvertFP32(
        0x40e00000, TileDataType_E2M1X2, NumericRound_RNE, FALSE);
    let (e2_n_over, e2_n_over_flags) = ConvertFP32(
        0xc0e00000, TileDataType_E2M1X2, NumericRound_RNE, FALSE);
    let (e1_over, e1_over_flags) = ConvertFP32(
        0x40000000, TileDataType_E1M2X2, NumericRound_RNE, FALSE);
    assert e2_over == Zeros{PTO_XLEN} + 6 &&
           e2_n_over == Zeros{PTO_XLEN} + 14 &&
           e1_over == Zeros{PTO_XLEN} + 7;
    assert e2_over_flags == Zeros{5} + 0x14 &&
           e2_n_over_flags == Zeros{5} + 0x14 &&
           e1_over_flags == Zeros{5} + 0x14;

    let (positive_zero, -) = ConvertFP32(
        0x00000000, TileDataType_E2M1X2, NumericRound_RNE, FALSE);
    let (negative_zero, -) = ConvertFP32(
        0x80000000, TileDataType_E2M1X2, NumericRound_RNE, FALSE);
    assert positive_zero == Zeros{PTO_XLEN};
    assert negative_zero == Zeros{PTO_XLEN} + 8;

    let (qnan, qnan_flags) = ConvertFP32(
        0x7fc00000, TileDataType_E2M1X2, NumericRound_RNE, FALSE);
    let (snan, snan_flags) = ConvertFP32(
        0x7f800001, TileDataType_E2M1X2, NumericRound_RNE, FALSE);
    let (positive_inf, positive_inf_flags) = ConvertFP32(
        0x7f800000, TileDataType_E2M1X2, NumericRound_RNE, FALSE);
    let (negative_inf, negative_inf_flags) = ConvertFP32(
        0xff800000, TileDataType_E2M1X2, NumericRound_RNE, FALSE);
    assert qnan == Zeros{PTO_XLEN} && qnan_flags == Zeros{5};
    assert snan == Zeros{PTO_XLEN} && snan_flags == Zeros{5} + 1;
    assert positive_inf == Zeros{PTO_XLEN} + 6 &&
           negative_inf == Zeros{PTO_XLEN} + 14;
    assert positive_inf_flags == Zeros{5} + 0x14 &&
           negative_inf_flags == Zeros{5} + 0x14;

end;

func AssertPackedReverseExact()
begin
    let control = DefaultNumericExecutionControl();
    let (e2_half, e2_half_flags) = ReferenceTCVTConvert(
        Zeros{PTO_XLEN} + 1, TileDataType_E2M1X2,
        TileDataType_FP32, control);
    let (e2_negative_four, e2_negative_four_flags) = ReferenceTCVTConvert(
        Zeros{PTO_XLEN} + 14, TileDataType_E2M1X2,
        TileDataType_FP32, control);
    let (e1_quarter, e1_quarter_flags) = ReferenceTCVTConvert(
        Zeros{PTO_XLEN} + 1, TileDataType_E1M2X2,
        TileDataType_FP32, control);
    let (e1_negative_endpoint, e1_negative_endpoint_flags) =
        ReferenceTCVTConvert(
            Zeros{PTO_XLEN} + 15, TileDataType_E1M2X2,
            TileDataType_FP32, control);
    assert e2_half == Zeros{PTO_XLEN} + 0x3f000000 &&
           e2_negative_four == Zeros{PTO_XLEN} + 0xc0800000;
    assert e1_quarter == Zeros{PTO_XLEN} + 0x3e800000 &&
           e1_negative_endpoint == Zeros{PTO_XLEN} + 0xbfe00000;
    assert e2_half_flags == Zeros{5} &&
           e2_negative_four_flags == Zeros{5} &&
           e1_quarter_flags == Zeros{5} &&
           e1_negative_endpoint_flags == Zeros{5};
end;

func main() => integer
begin
    AssertPackedValueSet(TileDataType_E2M1X2);
    AssertPackedValueSet(TileDataType_E1M2X2);
    AssertPackedForwardBoundaries();
    AssertPackedReverseExact();
    return 0;
end;
