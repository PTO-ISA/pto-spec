// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-FORMAT-PROFILES-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001"],"kind":"fault","summary":"TCVT rejects private, source-only, unsupported-width, and unsupported-rounding profiles before effects","pass_condition":"HiF4X2, FP32-to-E6M2, every conversion-to-RCPE6M2, reverse RCPE6M2 destinations outside FP16/BF16, and all non-RNE/RNA E6M2 modes are rejected while assigned and reserved DataType encodings retain their required identities","related_sources":["asl/tile/model/numeric/e8m0-conversion.asl","asl/arch/data-types/tile-data-types.asl","asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert TileDataTypeEncodingValid(Zeros{5} + 15);
    assert TileDataTypeEncodingValid(Zeros{5} + 21);
    assert TileDataTypeFromEncoding(Zeros{5} + 15) == TileDataType_E6M2;
    assert TileDataTypeFromEncoding(Zeros{5} + 21) == TileDataType_RCPE6M2;
    assert !TileDataTypeEncodingValid(Zeros{5} + 22);
    assert !TileDataTypeEncodingValid(Zeros{5} + 23);
    assert !TileDataTypeEncodingValid(Zeros{5} + 29);
    assert !TileDataTypeEncodingValid(Zeros{5} + 30);
    assert !TileDataTypeEncodingValid(Zeros{5} + 31);

    assert !HardwareTCVTTypePairSupported(
        TileDataType_FP32, TileDataType_E6M2);
    assert !HardwareTCVTTypePairSupported(
        TileDataType_HiF4X2, TileDataType_FP16);
    assert !HardwareTCVTTypePairSupported(
        TileDataType_FP16, TileDataType_HiF4X2);
    assert !HardwareTCVTTypePairSupported(
        TileDataType_HiF4X2, TileDataType_E6M2);
    assert !HardwareTCVTTypePairSupported(
        TileDataType_E6M2, TileDataType_HiF4X2);
    assert !HardwareTCVTTypePairSupported(
        TileDataType_RCPE6M2, TileDataType_E6M2);
    assert !HardwareTCVTTypePairSupported(
        TileDataType_RCPE6M2, TileDataType_FP32);
    assert !HardwareTCVTTypePairSupported(
        TileDataType_E6M2, TileDataType_RCPE6M2);
    assert !HardwareTCVTTypePairSupported(
        TileDataType_FP16, TileDataType_RCPE6M2);
    assert !HardwareTCVTTypePairSupported(
        TileDataType_BF16, TileDataType_RCPE6M2);
    assert HardwareTCVTTypePairSupported(
        TileDataType_E6M2, TileDataType_FP16);
    assert HardwareTCVTTypePairSupported(
        TileDataType_FP16, TileDataType_E6M2);
    assert HardwareTCVTTypePairSupported(
        TileDataType_RCPE6M2, TileDataType_BF16);

    assert TilePadValueForDataType(
        TilePad_Max, TileDataType_E2M1X2) == Zeros{PTO_XLEN} + 0x7;
    assert TilePadValueForDataType(
        TilePad_Min, TileDataType_E2M1X2) == Zeros{PTO_XLEN} + 0xf;
    assert TilePadValueForDataType(
        TilePad_Max, TileDataType_E1M2X2) == Zeros{PTO_XLEN} + 0x7;
    assert TilePadValueForDataType(
        TilePad_Min, TileDataType_E1M2X2) == Zeros{PTO_XLEN} + 0xf;
    assert TilePadValueForDataType(
        TilePad_Max, TileDataType_E6M2) == Zeros{PTO_XLEN} + 0xfe;
    assert TilePadValueForDataType(
        TilePad_Min, TileDataType_E6M2) == Zeros{PTO_XLEN};
    assert TilePadValueForDataType(
        TilePad_Max, TileDataType_RCPE6M2) == Zeros{PTO_XLEN};
    assert TilePadValueForDataType(
        TilePad_Min, TileDataType_RCPE6M2) == Zeros{PTO_XLEN} + 0xfe;

    assert HardwareTCVTRoundingModeSupported(
        TileDataType_E6M2, TileDataType_FP16, NumericRound_RNE);
    assert HardwareTCVTRoundingModeSupported(
        TileDataType_E6M2, TileDataType_FP16, NumericRound_RNA);
    assert !HardwareTCVTRoundingModeSupported(
        TileDataType_E6M2, TileDataType_FP16, NumericRound_RTZ);
    assert !HardwareTCVTRoundingModeSupported(
        TileDataType_E6M2, TileDataType_FP16, NumericRound_RTM);
    assert !HardwareTCVTRoundingModeSupported(
        TileDataType_E6M2, TileDataType_FP16, NumericRound_RTP);
    assert !HardwareTCVTRoundingModeSupported(
        TileDataType_E6M2, TileDataType_FP16, NumericRound_RTO);
    assert !HardwareTCVTRoundingModeSupported(
        TileDataType_E6M2, TileDataType_FP16, NumericRound_RHB);
    return 0;
end;
