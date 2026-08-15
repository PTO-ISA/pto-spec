// PTO-TEST: {"id":"PTO-AVS-TILE-TMIN-LB0-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TMIN.asl","requirements":["PTO-TMIN-CONTRACT-001"],"kind":"fault","summary":"TMIN requires an explicit nonzero LB0 ValidCol.","pass_condition":"Omitting LB0 raises TileLegality before destination allocation or source mutation.","related_sources":["asl/block/model/dispatch/destination-shape.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 8, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 8, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 5);

    let started = ExecuteCommandInstruction(
        Zeros{64} + 0xc0c19181, 32);
    assert started == CommandExecution_Executed;
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 3;
    return 0;
end;
