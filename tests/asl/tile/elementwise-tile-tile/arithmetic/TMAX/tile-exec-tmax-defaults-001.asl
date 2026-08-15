// PTO-TEST: {"id":"PTO-AVS-TILE-TMAX-DEFAULTS-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TMAX.asl","requirements":["PTO-TMAX-CONTRACT-001"],"kind":"execution","summary":"TMAX defaults omitted LB1 to one and LB2 to LB0.","pass_condition":"The allocated destination shape uses ValidRow one and Col equal to ValidCol while elements contain pairwise maxima.","related_sources":["asl/block/model/dispatch/destination-shape.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 8, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 8, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 7);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 4);

    let started = ExecuteCommandInstruction(
        Zeros{64} + 0xc0b19181, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].valid_rows == 1;
    assert _Tiles[[destination]].valid_columns == 2;
    assert _Tiles[[destination]].columns == 2;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 5;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 7;
    return 0;
end;
