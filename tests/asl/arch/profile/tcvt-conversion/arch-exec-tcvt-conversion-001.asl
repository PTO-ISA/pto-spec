// PTO-TEST: {"id":"PTO-AVS-ARCH-TCVT-CONVERSION-EXECUTION-001","source":"asl/tile/model/numeric/tcvt-conversion.asl","requirements":["PTO-TCVT-CONTRACT-001"],"kind":"execution","summary":"TCVT profile routes packed, E6M2, and reciprocal values through their exact numeric paths","pass_condition":"legal profile pairs produce the frozen result carriers and flags, special values map to their canonical destinations, and mode legality rejects unsupported E6M2 modes","related_sources":["asl/tile/model/numeric/e8m0-conversion.asl","asl/arch/data-types/formats/rcpe6m2.asl"]}
func main() => integer
begin
    let control = DefaultNumericExecutionControl();
    let (e2_result, e2_flags) = TileProfileConvert(
        Zeros{PTO_XLEN} + 0x3e99999a,
        TileDataType_FP32, TileDataType_E2M1X2, control);
    assert e2_result == Zeros{PTO_XLEN} + 1;
    assert e2_flags == Zeros{5} + 0x18;

    let (e6_result, e6_flags) = TileProfileConvert(
        Zeros{PTO_XLEN} + 0x3fc0,
        TileDataType_BF16, TileDataType_E6M2, control);
    assert e6_result == Zeros{PTO_XLEN} + 0xc2;
    assert e6_flags == Zeros{5};

    let (from_e6, from_e6_flags) = TileProfileConvert(
        Zeros{PTO_XLEN} + 0xc1,
        TileDataType_E6M2, TileDataType_FP16, control);
    assert from_e6 == Zeros{PTO_XLEN} + 0x3d00;
    assert from_e6_flags == Zeros{5};

    let (from_rcp, from_rcp_flags) = TileProfileConvert(
        Zeros{PTO_XLEN} + 0xc1,
        TileDataType_RCPE6M2, TileDataType_FP16, control);
    assert from_rcp == Zeros{PTO_XLEN} + 0x3a66;
    assert from_rcp_flags == Zeros{5} + 0x10;

    assert HardwareTCVTTypePairSupported(
        TileDataType_FP16, TileDataType_E6M2);
    assert HardwareTCVTTypePairSupported(
        TileDataType_E6M2, TileDataType_BF16);
    assert HardwareTCVTTypePairSupported(
        TileDataType_RCPE6M2, TileDataType_FP16);
    assert !HardwareTCVTTypePairSupported(
        TileDataType_FP32, TileDataType_E6M2);
    assert !HardwareTCVTTypePairSupported(
        TileDataType_FP16, TileDataType_RCPE6M2);
    assert !HardwareTCVTTypePairSupported(
        TileDataType_HiF4X2, TileDataType_FP16);
    assert HardwareTCVTRoundingModeSupported(
        TileDataType_E6M2, TileDataType_FP16, NumericRound_RNE);
    assert HardwareTCVTRoundingModeSupported(
        TileDataType_RCPE6M2, TileDataType_BF16, NumericRound_RNA);
    assert !HardwareTCVTRoundingModeSupported(
        TileDataType_E6M2, TileDataType_FP16, NumericRound_RTZ);
    return 0;
end;
