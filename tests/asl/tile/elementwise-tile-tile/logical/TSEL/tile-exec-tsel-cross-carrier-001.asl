// PTO-TEST: {"id":"PTO-AVS-TILE-TSEL-CROSS-CARRIER-001","source":"asl/tile/elementwise-tile-tile/logical/TSEL.asl","requirements":["PTO-TSEL-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"TSEL copies invalid-under-operation raw bits from distinct RowMajor backings","pass_condition":"S32 and U32 sources are selected under TF32 into an operation-typed destination without numeric validation","related_sources":["asl/block/model/dispatch/comparison-schema.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/execution/comparison.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigurePredicateTile(1, 128, 16, 2, 1, 2);
    ConfigureTile(2, 128, 8, 2, 1, 2, TileDataType_S32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(3, 128, 8, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTilePredicateBit(1, 0, 0, TRUE);
    WriteTilePredicateBit(1, 0, 1, FALSE);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x3f800001);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 0x40000001);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 0x11111111);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 0x22222222);

    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0x11a19181, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(FALSE, 0, 0, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, FALSE, 3, 0, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[1]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_TF32;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0x3f800001;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 0x22222222;
    return 0;
end;
