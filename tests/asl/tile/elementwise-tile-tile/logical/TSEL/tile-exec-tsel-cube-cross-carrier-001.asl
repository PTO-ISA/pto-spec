// PTO-TEST: {"id":"PTO-AVS-TILE-TSEL-CUBE-CROSS-CARRIER-001","source":"asl/tile/elementwise-tile-tile/logical/TSEL.asl","requirements":["PTO-TSEL-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"CUBE_M32 TSEL consumes a U8-basis cell with distinct E4M3 and S8 sources","pass_condition":"operation-typed U8 PredicateCell bits select exact source encodings into a U8 destination","related_sources":["asl/block/model/dispatch/comparison-schema.asl","asl/block/model/dispatch/predicate-destination.asl","asl/tile/model/execution/predicate-carriers.asl"]}
func main() => integer
begin
    ResetProfileState();
    let mask_ready = ConfigurePredicateCell(1, 128, 1, 2, TileDataType_U8,
        TileLayout_CUBE_M32);
    let true_ready = ConfigureCubeTile(2, 128, 1, 2, TileDataType_E4M3,
        TileLayout_CUBE_M32);
    let false_ready = ConfigureCubeTile(3, 128, 1, 2, TileDataType_S8,
        TileLayout_CUBE_M32);
    assert mask_ready && true_ready && false_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0xa5);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 0xa6);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 0xb5);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 0xb6);
    _Tiles[[1]].contents_defined = TRUE;
    MarkTileValidRegionDefined(2);
    MarkTileValidRegionDefined(3);
    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0xd9a19181, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(FALSE, 0, 0, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, FALSE, 3, 0, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[1]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_U8;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0xa5;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 0xb6;
    return 0;
end;
