// PTO-TEST: {"id":"PTO-AVS-TILE-TABS-DEFAULTS-001","source":"asl/tile/elementwise-tile-tile/logical/TABS.asl","requirements":["PTO-TABS-CONTRACT-001"],"kind":"execution","summary":"TABS applies the LB1 and LB2 omission defaults.","pass_condition":"The allocated destination has ValidRow one and Col equal to LB0 after TABS.","related_sources":["asl/block/model/dispatch/destination-shape.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 8, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 7);

    let started = ExecuteCommandInstruction(
        Zeros{64} + 0xc0f19181, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].valid_rows == 1;
    assert _Tiles[[destination]].valid_columns == 2;
    assert _Tiles[[destination]].columns == 2;
    return 0;
end;
