// PTO-TEST: {"id":"PTO-AVS-TILE-EXECUTION-MASK-EXPAND-001","source":"asl/tile/model/execution/expansion.asl","requirements":["PTO-REQ-TEPL-EXPAND-001","PTO-REQ-TEPL-PREDICATE-CARRIER-001"],"kind":"execution","summary":"Expansion reads and validates only active result coordinates","pass_condition":"an active expanded result computes from its mapped source/broadcast coordinates while undefined inactive source and broadcast values are ignored and inactive results follow MERGE or ZERO","related_sources":["asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/execution-mask-state.asl"]}
func main() => integer
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        0, 256, 2, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let broadcast_ready = ConfigureCubeTile(
        1, 256, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let destination_ready = ConfigureCubeTile(
        2, 256, 2, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let base_ready = ConfigureCubeTile(
        3, 256, 2, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert source_ready && broadcast_ready && destination_ready && base_ready;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 17);
    WriteTileElement(3, 1, 0, Zeros{PTO_XLEN} + 27);
    WriteTileElement(3, 1, 1, Zeros{PTO_XLEN} + 37);

    var mask = Zeros{PTO_XLEN};
    mask[0] = '1';
    CaptureBundleExecutionMaskGPR(
        mask, Zeros{PTO_XLEN}, 1,
        TileLayout_CUBE_M16, 2, 2);
    _BundleExecutionMask.merge_base = 3;
    _BundleExecutionMask.merge_base_valid = TRUE;
    assert TileOperandsLegal_ExecuteTileExpand(
        TileExpand_ADD, TileAxis_Column, 2, 0, 1);
    ExecuteTileExpand(TileExpand_ADD, TileAxis_Column, 2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 13;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN} + 17;
    assert ReadTileElement(2, 1, 0) == Zeros{PTO_XLEN} + 27;
    assert ReadTileElement(2, 1, 1) == Zeros{PTO_XLEN} + 37;

    CaptureBundleExecutionMaskGPR(
        mask, Zeros{PTO_XLEN}, 1,
        TileLayout_CUBE_M16, 2, 2);
    _BundleExecutionMask.zero_inactive = TRUE;
    _BundleExecutionMask.merge_base_valid = FALSE;
    assert TileOperandsLegal_ExecuteTileExpand(
        TileExpand_ADD, TileAxis_Column, 2, 0, 1);
    ExecuteTileExpand(TileExpand_ADD, TileAxis_Column, 2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 13;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(2, 1, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(2, 1, 1) == Zeros{PTO_XLEN};
    return 0;
end;
