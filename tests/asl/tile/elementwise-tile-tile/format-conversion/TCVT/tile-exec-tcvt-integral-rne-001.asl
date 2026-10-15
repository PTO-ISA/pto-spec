// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-INTEGRAL-RNE-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001"],"kind":"execution","summary":"Explicit RNE selects same-type FP32 round-to-integral in TCVT","pass_condition":"an explicitly selected RNE converts FP32 2.75 to 3.0 in FP32 and publishes NX","related_sources":["asl/tile/model/numeric/formats.asl","asl/tile/model/numeric/reference-conversion.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0, 256, 1, 1, 1, 1,
        TileDataType_FP32, TileLayout_RowMajor);
    ConfigureTile(
        1, 256, 1, 1, 1, 1,
        TileDataType_FP32, TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x40300000);
    SetBundleDataAttributeState(
        TileDataTypeToEncoding(TileDataType_FP32), Zeros{5}, '00',
        Zeros{3}, '001', FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;

    let control = NumericExecutionControl {
        rounding_mode = NumericRound_RNE,
        saturating = FALSE
    };
    assert TileOperandsLegal_TCVT(1, 0, control);
    InstructionContractExecute_TCVT(1, 0, control);

    assert _LastFault == Fault_None;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0x40400000;
    assert NumericStatusFlags() == '10000';
    return 0;
end;
