// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-BUNDLE-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-INST-TILE-TCVT"],"kind":"execution","summary":"TCVT bundle conversion allocates the destination with its own type and transformed layout","pass_condition":"U8 ND source values become a U16 DN destination with equal logical and physical shape while the source persists","related_sources":["asl/block/model/dispatch/tcvt-schema.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/numeric/formats.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        1,
        128,
        16,
        8,
        1,
        2,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 9);

    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0xd9b19181,
        32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 26,
        Zeros{5} + 1,
        '11',
        Zeros{3},
        Zeros{3},
        FALSE,
        FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 8);
    AddBundleTileBinding(
        TRUE,
        0,
        2,
        '1111',
        TRUE,
        FALSE,
        1,
        0,
        TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_U16;
    assert _Tiles[[destination]].layout == TileLayout_ColumnMajor;
    assert _Tiles[[destination]].rows == _Tiles[[1]].rows;
    assert _Tiles[[destination]].columns == _Tiles[[1]].columns;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 9;
    assert _Tiles[[destination]].payload[[16]] == Zeros{PTO_XLEN} + 9;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 9;
    return 0;
end;
