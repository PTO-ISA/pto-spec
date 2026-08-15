// PTO-TEST: {"id":"PTO-AVS-TILE-TSELS-BUNDLE-001","source":"asl/tile/tile-scalar-and-immediate/logical/TSELS.asl","requirements":["PTO-INST-TILE-TSELS"],"kind":"execution","summary":"TSELS consumes one packed mask and one numeric source in a single terminating B.IOT","pass_condition":"packed zero selects RegSrc0 while packed one copies the exact true-source encoding","related_sources":["asl/block/model/dispatch/tile-scalar-schema.asl","asl/block/model/dispatch/destination-shape.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigurePredicateTile(1, 128, 8, 2, 1, 2);
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
    WriteTilePredicateBit(1, 0, 0, FALSE);
    WriteTilePredicateBit(1, 0, 1, TRUE);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 11);
    WriteGPR(3, Zeros{PTO_XLEN} + 99);

    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0xc3a19181,
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
    SetBundleScalarBinding(0, 0, 3, 0, 0, 3);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 99;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 11;
    return 0;
end;
