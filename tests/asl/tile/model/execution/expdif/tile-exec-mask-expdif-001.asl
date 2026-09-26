// PTO-TEST: {"id":"PTO-AVS-TILE-EXECUTION-MASK-EXPDIF-001","source":"asl/tile/model/execution/expdif.asl","requirements":["PTO-INST-TILE-TEXPDIF","PTO-TEXPDIF-CONTRACT-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001"],"kind":"execution","summary":"TEXPDIF evaluates only active logical coordinates and merges or zeros inactive results","pass_condition":"active FP32 TEXPDIF computes and contributes its flags; undefined inactive source elements are accepted without reads or flags; inactive destination elements follow MERGE/ZERO","related_sources":["asl/tile/model/legality/execution-mask-source-schema.asl","asl/tile/model/execution/execution-mask-state.asl"]}
func main() => integer
begin
    ResetProfileState();
    let left_ready = ConfigureCubeTile(
        0, 256, 1, 2, TileDataType_FP32, TileLayout_CUBE_M16);
    let right_ready = ConfigureCubeTile(
        1, 256, 1, 2, TileDataType_FP32, TileLayout_CUBE_M16);
    let destination_ready = ConfigureCubeTile(
        2, 256, 1, 2, TileDataType_FP32, TileLayout_CUBE_M16);
    let base_ready = ConfigureCubeTile(
        3, 256, 1, 2, TileDataType_FP32, TileLayout_CUBE_M16);
    assert left_ready && right_ready && destination_ready && base_ready;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 0x41100000);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 0x41200000);
    var mask = Zeros{PTO_XLEN};
    mask[0] = '1';
    CaptureBundleExecutionMaskGPR(
        mask, Zeros{PTO_XLEN}, 1, TileLayout_CUBE_M16, 1, 2);
    _BundleExecutionMask.merge_base = 3;
    _BundleExecutionMask.merge_base_valid = TRUE;
    RecordNumericStatusFlags(Zeros{5} + 4);
    let status_before = NumericStatusFlags();
    let (expected, flags) = TileExpdifValueWithTypesAndFlags(
        TileDataType_FP32, TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x3f800000, Zeros{PTO_XLEN});
    assert TileOperandsLegal_ExecuteTileExpdif(2, 0, 1);
    ExecuteTileExpdif(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == expected;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN} + 0x41200000;
    assert NumericStatusFlags() == (status_before OR flags);

    _BundleExecutionMask.zero_inactive = TRUE;
    _BundleExecutionMask.merge_base_valid = FALSE;
    assert TileOperandsLegal_ExecuteTileExpdif(2, 0, 1);
    ExecuteTileExpdif(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == expected;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN};
    assert NumericStatusFlags() == (status_before OR flags);
    return 0;
end;
