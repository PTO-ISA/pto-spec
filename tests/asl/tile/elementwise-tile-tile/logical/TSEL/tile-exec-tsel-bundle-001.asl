// PTO-TEST: {"id":"PTO-AVS-TILE-TSEL-BUNDLE-001","source":"asl/tile/elementwise-tile-tile/logical/TSEL.asl","requirements":["PTO-INST-TILE-TSEL"],"kind":"execution","summary":"TSEL consumes a packed predicate and publishes a renamed numeric destination through two B.IOT bindings","pass_condition":"the mask and true source precede the terminating false-source and destination binding, producing exact selected encodings","related_sources":["asl/block/model/dispatch/comparison-schema.asl","asl/block/model/dispatch/destination-shape.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigurePredicateTile(1, 128, 16, 2, 1, 2);
    ConfigureTile(
        2,
        128,
        8,
        2,
        1,
        2,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        3,
        128,
        8,
        2,
        1,
        2,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTilePredicateBit(1, 0, 0, TRUE);
    WriteTilePredicateBit(1, 0, 1, FALSE);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 11);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 20);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 21);

    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0x09a19181,
        32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(
        FALSE,
        0,
        0,
        '1111',
        TRUE,
        TRUE,
        1,
        2,
        FALSE);
    AddBundleTileBinding(
        TRUE,
        0,
        1,
        '1111',
        TRUE,
        FALSE,
        3,
        0,
        TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[1]].destination;
    assert _Tiles[[destination]].storage_kind == TileStorage_Numeric;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 10;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 21;
    assert ReadTilePredicateBit(1, 0, 0);
    assert !ReadTilePredicateBit(1, 0, 1);
    return 0;
end;
