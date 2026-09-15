// PTO-TEST: {"id":"PTO-AVS-TILE-TSELS-CROSS-CARRIER-001","source":"asl/tile/tile-scalar-and-immediate/logical/TSELS.asl","requirements":["PTO-TSELS-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"TSELS copies a cross-type true source and raw scalar under TF32","pass_condition":"predicate zero copies an invalid-under-TF32 scalar encoding while predicate one copies the distinct S32 source into an operation-typed destination","related_sources":["asl/block/model/dispatch/tile-scalar-schema.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/execution/comparison.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigurePredicateTile(1, 128, 16, 2, 1, 2);
    ConfigureTile(2, 128, 8, 2, 1, 2, TileDataType_S32,
        TileLayout_RowMajor);
    WriteTilePredicateBit(1, 0, 0, FALSE);
    WriteTilePredicateBit(1, 0, 1, TRUE);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x3f800001);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 0x40000001);
    WriteGPR(3, Zeros{PTO_XLEN} + 0x3f800001);

    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0x13a19181, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, TRUE);
    SetBundleScalarBinding(0, 0, 3, 0, 0, 3);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_TF32;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0x3f800001;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 0x40000001;
    return 0;
end;
