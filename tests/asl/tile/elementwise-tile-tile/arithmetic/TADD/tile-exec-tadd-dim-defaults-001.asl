// PTO-TEST: {"id":"PTO-AVS-TILE-TADD-DIM-DEFAULTS-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TADD.asl","requirements":["PTO-INST-TILE-TADD"],"kind":"execution","summary":"TADD defaults omitted LB1 to one and omitted LB2 to LB0","pass_condition":"the allocated destination has ValidRow one, ValidCol two, physical Col two, and the expected sums","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/block/model/dispatch/tile-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 8, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 8, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 6);
    let started = ExecuteCommandInstruction(
        Zeros{64} + 0xc0019181, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].valid_rows == 1;
    assert _Tiles[[destination]].valid_columns == 2;
    assert _Tiles[[destination]].columns == 2;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 8;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 10;
    return 0;
end;
