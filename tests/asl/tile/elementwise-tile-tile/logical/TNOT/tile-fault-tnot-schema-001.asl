// PTO-TEST: {"id":"PTO-AVS-TILE-TNOT-SCHEMA-001","source":"asl/tile/elementwise-tile-tile/logical/TNOT.asl","requirements":["PTO-TNOT-CONTRACT-001"],"kind":"fault","summary":"TNOT requires one terminal Local B.IOT.","pass_condition":"A split source and destination binding sequence raises TileLegality before effects for TNOT.","related_sources":["asl/block/model/dispatch/tile-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);

    let started = ExecuteCommandInstruction(
        Zeros{64} + 0xc1019181, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(
        FALSE, 0, 0, '1111', TRUE, FALSE, 1, 0, FALSE);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', FALSE, FALSE, 0, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[1]].destination_allocated_by_bundle;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 3;
    return 0;
end;
