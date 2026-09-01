// PTO-TEST: {"id":"PTO-AVS-BLOCK-MSCATTER-MASK-PACKED-001","source":"asl/block/execution/BSTART.MSCATTER.MASK.asl","requirements":["PTO-MSCATTER-MASK-PREDICATE-001"],"kind":"boundary","summary":"MSCATTER.MASK rejects packed transfer types without a nibble selector.","pass_condition":"U4X2 transfer rejects before memory events or writes even with legal index and predicate Tiles.","related_sources":["asl/tile/model/legality/memory-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 1, 2, 1, 1, TileDataType_U4X2,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 1, 2, 1, 1, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigurePredicateTile(3, 128, 1, 2, 1, 1);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    WriteTilePredicateBit(3, 0, 0, TRUE);
    var start: bits(64) = Zeros{64} + 0x00711181;
    start[31:27] = Zeros{5} + 28;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    WritePEGPR(0, 4, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(FALSE, 0, 0, '0001', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(FALSE, 0, 0, '0001', TRUE, FALSE, 3, 0, TRUE);
    SetBundleScalarBinding(0, 0, 0, 4, 0, 2);
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    return 0;
end;
