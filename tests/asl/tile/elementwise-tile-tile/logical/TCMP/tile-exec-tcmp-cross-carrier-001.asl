// PTO-TEST: {"id":"PTO-AVS-TILE-TCMP-CROSS-CARRIER-001","source":"asl/tile/elementwise-tile-tile/logical/TCMP.asl","requirements":["PTO-TCMP-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"TCMP uses U8 operation semantics with distinct E3M2 RowMajor source backings","pass_condition":"same-width E3M2 sources are accepted under U8 and publish the expected packed equality bits","related_sources":["asl/block/model/dispatch/comparison-schema.asl","asl/tile/model/legality/operand-schema.asl","asl/tile/model/execution/comparison.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 8, 2, 1, 2, TileDataType_E3M2,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 8, 2, 1, 2, TileDataType_E3M2,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x80);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x01);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x80);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 0x02);

    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0xd8d19181, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert ReadTilePredicateByte(destination, 0) == '00000001';
    assert _Tiles[[1]].data_type == TileDataType_E3M2;
    assert _Tiles[[2]].data_type == TileDataType_E3M2;
    return 0;
end;
