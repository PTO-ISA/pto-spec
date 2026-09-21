// PTO-TEST: {"id":"PTO-AVS-ARCH-RCPE6M2-CONVERSION-EXECUTION-003","source":"asl/tile/model/numeric/tcvt-conversion.asl","requirements":["PTO-TCVT-CONTRACT-001","PTO-NUMERIC-RCPE6M2-FORMAT-001"],"kind":"execution","summary":"RCPE6M2 performs one final destination rounding from exact E6M2 reciprocals","pass_condition":"The required reciprocal values, BF16/FP16 final-round regression, overflow boundaries, subnormal endpoint, NaN mapping, and source-only legality return exact carriers and flags","related_sources":["asl/arch/data-types/formats/e6m2.asl","asl/arch/data-types/formats/rcpe6m2.asl","asl/tile/model/execution/matrix-quantization.asl"]}
func ConvertRCPE(destination_type: TileDataType, raw: integer {0..255},
                 mode: NumericRoundingMode, saturating: boolean)
                 => (Word, bits(5))
begin
    let control = NumericExecutionControl {
        rounding_mode = mode, saturating = saturating
    };
    return TileProfileConvert(Zeros{PTO_XLEN} + raw,
        TileDataType_RCPE6M2, destination_type, control);
end;

func AssertRCPEInterpretation()
begin
    assert RCPE6M2FiniteValue(Zeros{8} + 0xc0) == 1.0;
    assert RCPE6M2FiniteValue(Zeros{8} + 0xc1) == 0.8;
    assert RCPE6M2FiniteValue(Zeros{8} + 0xc2) == 2.0 / 3.0;
    assert RCPE6M2FiniteValue(Zeros{8} + 0xc3) == 4.0 / 7.0;
    for code = 0 to 254 looplimit 255 do
        assert TileNumericValueClass(TileDataType_RCPE6M2,
            Zeros{PTO_XLEN} + code) == NumericValue_PositiveNormal;
        assert RCPE6M2FiniteValue(
            (Zeros{8} + code) as bits(8)) > 0.0;
    end;
end;

func AssertRCPEBF16()
begin
    let (one, one_flags) = ConvertRCPE(
        TileDataType_BF16, 0xc0, NumericRound_RNE, FALSE);
    let (four_fifths, four_fifths_flags) = ConvertRCPE(
        TileDataType_BF16, 0xc1, NumericRound_RNE, FALSE);
    let (two_thirds, two_thirds_flags) = ConvertRCPE(
        TileDataType_BF16, 0xc2, NumericRound_RNE, FALSE);
    let (four_sevenths, four_sevenths_flags) = ConvertRCPE(
        TileDataType_BF16, 0xc3, NumericRound_RNE, FALSE);
    assert one == Zeros{PTO_XLEN} + 0x3f80 && one_flags == Zeros{5};
    assert four_fifths == Zeros{PTO_XLEN} + 0x3f4d &&
           four_fifths_flags == Zeros{5} + 0x10;
    assert two_thirds == Zeros{PTO_XLEN} + 0x3f2b &&
           two_thirds_flags == Zeros{5} + 0x10;
    assert four_sevenths == Zeros{PTO_XLEN} + 0x3f12 &&
           four_sevenths_flags == Zeros{5} + 0x10;
end;

func AssertRCPEOneFinalRound()
begin
    let control = DefaultNumericExecutionControl();
    let (direct, direct_flags) = ConvertRCPE(
        TileDataType_FP16, 0xc1, NumericRound_RNE, FALSE);
    let (direct_again, direct_again_flags) = ReferenceTCVTConvert(
        Zeros{PTO_XLEN} + 0xc1, TileDataType_RCPE6M2,
        TileDataType_FP16, control);
    let (intermediate, -) = ReferenceBinary16Encoding(
        RCPE6M2FiniteValue(Zeros{8} + 0xc1),
        TileDataType_BF16, control);
    let (double_rounded, -) = ReferenceBinary16Encoding(
        ReferenceBinary16FiniteValue(intermediate, TileDataType_BF16),
        TileDataType_FP16, control);
    assert direct == Zeros{PTO_XLEN} + 0x3a66 &&
           direct_again == Zeros{PTO_XLEN} + 0x3a66;
    assert direct_flags == Zeros{5} + 0x10 &&
           direct_again_flags == Zeros{5} + 0x10;
    assert double_rounded == Zeros{PTO_XLEN} + 0x3a68;
    assert direct != double_rounded;
end;

func AssertRCPEFP16Boundaries()
begin
    let (overflow, overflow_flags) = ConvertRCPE(
        TileDataType_FP16, 0x80, NumericRound_RNE, FALSE);
    let (overflow_sat, overflow_sat_flags) = ConvertRCPE(
        TileDataType_FP16, 0x80, NumericRound_RNE, TRUE);
    let (finite, finite_flags) = ConvertRCPE(
        TileDataType_FP16, 0x81, NumericRound_RNE, FALSE);
    let (small, small_flags) = ConvertRCPE(
        TileDataType_FP16, 0xfe, NumericRound_RNE, FALSE);
    let (extreme, extreme_flags) = ConvertRCPE(
        TileDataType_FP16, 0x00, NumericRound_RNE, FALSE);
    assert overflow == Zeros{PTO_XLEN} + 0x7c00 &&
           overflow_flags == Zeros{5} + 0x14;
    assert overflow_sat == Zeros{PTO_XLEN} + 0x7bff &&
           overflow_sat_flags == Zeros{5} + 0x14;
    assert finite == Zeros{PTO_XLEN} + 0x7a66 &&
           finite_flags == Zeros{5} + 0x10;
    assert small == Zeros{PTO_XLEN} + 0x155 &&
           small_flags == Zeros{5} + 0x18;
    assert extreme == Zeros{PTO_XLEN} + 0x7c00 &&
           extreme_flags == Zeros{5} + 0x14;

    let (canonical, canonical_flags) = ConvertRCPE(
        TileDataType_FP16, 0xff, NumericRound_RNE, FALSE);
    assert canonical == Zeros{PTO_XLEN} + 0x7e00 &&
           canonical_flags == Zeros{5};
end;

func AssertRCPESourceOnlyLegality()
begin
    assert TileCarrierWidthCompatible(
        TileDataType_E6M2, TileDataType_RCPE6M2);
    assert TileCarrierWidthCompatible(
        TileDataType_RCPE6M2, TileDataType_RCPE6M2);
    assert !TileCarrierWidthCompatible(
        TileDataType_U8, TileDataType_RCPE6M2);
    assert !TileCarrierWidthCompatible(
        TileDataType_S8, TileDataType_RCPE6M2);
    assert !TileCarrierWidthCompatible(
        TileDataType_E4M3, TileDataType_RCPE6M2);
    assert !HardwareTCVTTypePairSupported(
        TileDataType_FP16, TileDataType_RCPE6M2);
    assert !HardwareTCVTTypePairSupported(
        TileDataType_BF16, TileDataType_RCPE6M2);
    assert !HardwareTCVTTypePairSupported(
        TileDataType_E6M2, TileDataType_RCPE6M2);
    assert !HardwareTCVTTypePairSupported(
        TileDataType_RCPE6M2, TileDataType_E6M2);
    assert !HardwareTCVTTypePairSupported(
        TileDataType_RCPE6M2, TileDataType_FP32);
    assert HardwareTCVTTypePairSupported(
        TileDataType_RCPE6M2, TileDataType_FP16);
    assert HardwareTCVTTypePairSupported(
        TileDataType_RCPE6M2, TileDataType_BF16);
    assert HardwareTCVTRoundingModeSupported(
        TileDataType_RCPE6M2, TileDataType_FP16, NumericRound_RNE);
    assert HardwareTCVTRoundingModeSupported(
        TileDataType_RCPE6M2, TileDataType_FP16, NumericRound_RNA);
    assert !HardwareTCVTRoundingModeSupported(
        TileDataType_RCPE6M2, TileDataType_FP16, NumericRound_RTZ);
    assert !HardwareTCVTRoundingModeSupported(
        TileDataType_RCPE6M2, TileDataType_FP16, NumericRound_RTM);
    assert !HardwareTCVTRoundingModeSupported(
        TileDataType_RCPE6M2, TileDataType_FP16, NumericRound_RTP);
    assert !HardwareTCVTRoundingModeSupported(
        TileDataType_RCPE6M2, TileDataType_FP16, NumericRound_RTO);
    assert !HardwareTCVTRoundingModeSupported(
        TileDataType_RCPE6M2, TileDataType_FP16, NumericRound_RHB);
end;

func main() => integer
begin
    AssertRCPEInterpretation();
    AssertRCPEBF16();
    AssertRCPEOneFinalRound();
    AssertRCPEFP16Boundaries();
    AssertRCPESourceOnlyLegality();
    return 0;
end;
