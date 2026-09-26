// PTO-TEST: {"id":"PTO-AVS-TILE-EXECUTION-MASK-CONVERT-001","source":"asl/tile/model/numeric/formats.asl","requirements":["PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-INST-TILE-TCVT"],"kind":"execution","summary":"Conversion does not inspect inactive sources and applies destination merge policy","pass_condition":"an active CUBE conversion executes while an undefined inactive source element is ignored and its destination is preserved for MERGE or zeroed for ZERO","related_sources":["asl/tile/model/legality/operand-schema.asl","asl/tile/model/execution/execution-mask-state.asl"]}
func main() => integer
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        0, 256, 1, 2, TileDataType_FP32, TileLayout_CUBE_M16);
    let destination_ready = ConfigureCubeTile(
        2, 256, 1, 2, TileDataType_FP32, TileLayout_CUBE_M16);
    let base_ready = ConfigureCubeTile(
        3, 256, 1, 2, TileDataType_FP32, TileLayout_CUBE_M16);
    assert source_ready && destination_ready && base_ready;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 0x40000000);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 0x40400000);

    var mask = Zeros{PTO_XLEN};
    mask[0] = '1';
    CaptureBundleExecutionMaskGPR(
        mask, Zeros{PTO_XLEN}, 1,
        TileLayout_CUBE_M16, 1, 2);
    _BundleExecutionMask.merge_base = 3;
    _BundleExecutionMask.merge_base_valid = TRUE;
    let control = DefaultNumericExecutionControl();
    assert TileOperandsLegal_TCVT(2, 0, control);
    TCVT(2, 0, control);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 0x3f800000;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN} + 0x40400000;

    CaptureBundleExecutionMaskGPR(
        mask, Zeros{PTO_XLEN}, 1,
        TileLayout_CUBE_M16, 1, 2);
    _BundleExecutionMask.zero_inactive = TRUE;
    _BundleExecutionMask.merge_base_valid = FALSE;
    assert TileOperandsLegal_TCVT(2, 0, control);
    TCVT(2, 0, control);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 0x3f800000;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN};
    return 0;
end;
