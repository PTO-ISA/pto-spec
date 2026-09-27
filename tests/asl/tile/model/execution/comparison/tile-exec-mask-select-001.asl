// PTO-TEST: {"id":"PTO-AVS-TILE-EXECUTION-MASK-SELECT-001","source":"asl/tile/model/execution/comparison.asl","requirements":["PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001"],"kind":"execution","summary":"Selection predicate and ExecutionMask control independent parts of TSEL","pass_condition":"active TSEL coordinates read the operation-owned selector and selected data; inactive coordinates skip those reads and apply the independent ExecutionMask MERGE or ZERO rule","related_sources":["asl/tile/model/execution/predicate-carriers.asl","asl/tile/model/execution/execution-mask-state.asl"]}
func main() => integer
begin
    ResetProfileState();
    let true_ready = ConfigureCubeTile(
        0, 256, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let false_ready = ConfigureCubeTile(
        1, 256, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let destination_ready = ConfigureCubeTile(
        2, 256, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let base_ready = ConfigureCubeTile(
        3, 256, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let selection_ready = ConfigurePredicateCell(
        4, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert true_ready && false_ready && destination_ready && base_ready &&
           selection_ready;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 11);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 22);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 77);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 88);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN});

    var execution_mask = Zeros{PTO_XLEN};
    execution_mask[0] = '1';
    CaptureBundleExecutionMaskGPR(
        execution_mask, Zeros{PTO_XLEN}, 1,
        TileLayout_CUBE_M16, 1, 2);
    _BundleExecutionMask.merge_base = 3;
    _BundleExecutionMask.merge_base_valid = TRUE;
    assert TileOperandsLegal_ExecuteTileSelectAs(
        2, 4, 0, 1, TileDataType_U32);
    ExecuteTileSelectAs(2, 4, 0, 1, TileDataType_U32);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN} + 88;

    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN});
    CaptureBundleExecutionMaskGPR(
        execution_mask, Zeros{PTO_XLEN}, 1,
        TileLayout_CUBE_M16, 1, 2);
    _BundleExecutionMask.zero_inactive = TRUE;
    _BundleExecutionMask.merge_base_valid = FALSE;
    assert TileOperandsLegal_ExecuteTileSelectAs(
        2, 4, 0, 1, TileDataType_U32);
    ExecuteTileSelectAs(2, 4, 0, 1, TileDataType_U32);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 22;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN};
    return 0;
end;
