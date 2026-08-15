// PTO-TEST: {"id":"PTO-AVS-TILE-TCMP-BUNDLE-001","source":"asl/tile/elementwise-tile-tile/logical/TCMP.asl","requirements":["PTO-INST-TILE-TCMP"],"kind":"execution","summary":"TCMP allocates and publishes a packed predicate destination through its complete block schema","pass_condition":"the terminating B.IOT produces a renamed predicate Tile with source geometry, packed results, and persistent sources","related_sources":["asl/block/model/dispatch/comparison-schema.asl","asl/block/model/dispatch/destination-shape.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        1,
        128,
        8,
        2,
        1,
        2,
        TileDataType_U64,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        2,
        128,
        8,
        2,
        1,
        2,
        TileDataType_U64,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 9);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 8);

    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0xc0d19181,
        32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(
        TRUE,
        0,
        1,
        '1111',
        TRUE,
        TRUE,
        1,
        2,
        TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].storage_kind == TileStorage_Predicate;
    assert _Tiles[[destination]].rows == _Tiles[[1]].rows;
    assert _Tiles[[destination]].columns == _Tiles[[1]].columns;
    assert _Tiles[[destination]].valid_rows == 1;
    assert _Tiles[[destination]].valid_columns == 2;
    assert ReadTilePredicateByte(destination, 0) == '00000001';
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 9;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN} + 8;
    return 0;
end;
