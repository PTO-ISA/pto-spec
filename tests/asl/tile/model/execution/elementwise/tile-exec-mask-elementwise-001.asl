// PTO-TEST: {"id":"PTO-AVS-TILE-EXECUTION-MASK-ELEMENTWISE-001","source":"asl/tile/model/execution/elementwise.asl","requirements":["PTO-REQ-TEPL-PREDICATE-CARRIER-001"],"kind":"execution","summary":"Elementwise ExecutionMask skips inactive source lanes and applies ZERO or MERGE","pass_condition":"undefined inactive source elements do not reject or get read, active elements execute, inactive MERGE copies the old destination, and ZERO writes zero","related_sources":["asl/tile/model/legality/execution-mask-source-schema.asl","asl/tile/model/execution/execution-mask-state.asl"]}
func main() => integer
begin
    ResetProfileState();
    let left_ready = ConfigureCubeTile(
        0, 256, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let right_ready = ConfigureCubeTile(
        1, 256, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let destination_ready = ConfigureCubeTile(
        2, 256, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let base_ready = ConfigureCubeTile(
        3, 256, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert left_ready && right_ready && destination_ready && base_ready;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 77);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 88);

    var mask = Zeros{PTO_XLEN};
    mask[0] = '1';
    CaptureBundleExecutionMaskGPR(
        mask, Zeros{PTO_XLEN}, 1, TileLayout_CUBE_M16, 1, 2);
    _BundleExecutionMask.zero_inactive = FALSE;
    _BundleExecutionMask.merge_base = 3;
    _BundleExecutionMask.merge_base_valid = TRUE;
    assert TileOperandsLegal_ExecuteTileBinary(
        TileBinary_ADD, 2, 0, 1);
    ExecuteTileBinary(TileBinary_ADD, 2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN} + 88;

    CaptureBundleExecutionMaskGPR(
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN}, 1,
        TileLayout_CUBE_M16, 1, 2);
    _BundleExecutionMask.zero_inactive = TRUE;
    _BundleExecutionMask.merge_base_valid = FALSE;
    assert TileOperandsLegal_ExecuteTileBinary(
        TileBinary_ADD, 2, 0, 1);
    ExecuteTileBinary(TileBinary_ADD, 2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN};

    mask[16] = '1';
    CaptureBundleExecutionMaskGPR(
        mask, Zeros{PTO_XLEN}, 1, TileLayout_CUBE_M16, 1, 2);
    assert !TileOperandsLegal_ExecuteTileBinary(
        TileBinary_ADD, 2, 0, 1);
    return 0;
end;
