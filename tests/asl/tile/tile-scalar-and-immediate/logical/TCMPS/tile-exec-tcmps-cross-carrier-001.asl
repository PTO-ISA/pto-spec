// PTO-TEST: {"id":"PTO-AVS-TILE-TCMPS-CROSS-CARRIER-001","source":"asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl","requirements":["PTO-TCMPS-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"TCMPS uses operation-typed scalar comparison with an E3M2 RowMajor source","pass_condition":"an E3M2 source and U8 operation accept the raw scalar low byte and publish EQ bits","related_sources":["asl/block/model/dispatch/tile-scalar-schema.asl","asl/tile/model/legality/operand-schema.asl","asl/tile/model/execution/comparison.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 8, 2, 1, 2, TileDataType_E3M2,
        TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x7f);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x01);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x7f);

    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0xdad19181, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);
    SetBundleScalarBinding(0, 0, 2, 0, 0, 3);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert ReadTilePredicateBit(destination, 0, 0);
    assert !ReadTilePredicateBit(destination, 0, 1);
    assert _Tiles[[1]].data_type == TileDataType_E3M2;
    return 0;
end;
