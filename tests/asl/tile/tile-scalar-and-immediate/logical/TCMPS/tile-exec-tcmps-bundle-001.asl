// PTO-TEST: {"id":"PTO-AVS-TILE-TCMPS-BUNDLE-001","source":"asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl","requirements":["PTO-INST-TILE-TCMPS"],"kind":"execution","summary":"TCMPS publishes a renamed packed predicate destination through its closed block schema","pass_condition":"RegSrc0 equality produces packed bits one then zero and leaves the numeric source unchanged","related_sources":["asl/block/model/dispatch/tile-scalar-schema.asl","asl/block/model/dispatch/destination-shape.asl"]}
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
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 3);
    WriteGPR(2, Zeros{PTO_XLEN} + 2);

    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0xdad19181,
        32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(
        TRUE,
        0,
        1,
        '1111',
        TRUE,
        FALSE,
        1,
        0,
        TRUE);
    SetBundleScalarBinding(0, 0, 2, 0, 0, 3);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].storage_kind == TileStorage_Predicate;
    assert ReadTilePredicateByte(destination, 0) == '00000001';
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 3;
    return 0;
end;
