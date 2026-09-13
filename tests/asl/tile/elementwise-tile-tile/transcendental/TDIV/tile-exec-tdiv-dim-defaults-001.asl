// PTO-TEST: {"id":"PTO-AVS-TILE-TDIV-DIM-DEFAULTS-001","source":"asl/tile/elementwise-tile-tile/transcendental/TDIV.asl","requirements":["PTO-INST-TILE-TDIV"],"kind":"execution","summary":"TDIV applies the value-one default for every omitted dimension","pass_condition":"with LB0, LB1, and LB2 omitted, the destination is one by one and contains the expected quotient","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/block/model/dispatch/tile-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 8, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor);
    ConfigureTile(2, 128, 8, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 8);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 2);
    let started = ExecuteCommandInstruction(
        Zeros{64} + 0xc0319181, 32);
    assert started == CommandExecution_Executed;
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].valid_rows == 1;
    assert _Tiles[[destination]].valid_columns == 1;
    assert _Tiles[[destination]].columns == 1;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 4;
    return 0;
end;
