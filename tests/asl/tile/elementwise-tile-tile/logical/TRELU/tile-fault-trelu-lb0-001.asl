// PTO-TEST: {"id":"PTO-AVS-TILE-TRELU-LB0-001","source":"asl/tile/elementwise-tile-tile/logical/TRELU.asl","requirements":["PTO-TRELU-CONTRACT-001"],"kind":"fault","summary":"TRELU requires explicit nonzero LB0 ValidCol.","pass_condition":"Omitting LB0 raises TileLegality before destination allocation or source mutation for TRELU.","related_sources":["asl/block/model/dispatch/destination-shape.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 8, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);

    let started = ExecuteCommandInstruction(
        Zeros{64} + 0xc1719181, 32);
    assert started == CommandExecution_Executed;
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 3;
    return 0;
end;
