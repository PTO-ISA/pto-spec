// PTO-TEST: {"id":"PTO-AVS-TILE-TNEG-DEFAULTS-001","source":"asl/tile/elementwise-tile-tile/logical/TNEG.asl","requirements":["PTO-TNEG-CONTRACT-001"],"kind":"execution","summary":"TNEG applies the value-one default for every omitted dimension.","pass_condition":"With LB0, LB1, and LB2 omitted, the allocated destination has one valid row, one valid column, and one physical column.","related_sources":["asl/block/model/dispatch/destination-shape.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 8, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);

    let started = ExecuteCommandInstruction(
        Zeros{64} + 0xc1119181, 32);
    assert started == CommandExecution_Executed;
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].valid_rows == 1;
    assert _Tiles[[destination]].valid_columns == 1;
    assert _Tiles[[destination]].columns == 1;
    return 0;
end;
