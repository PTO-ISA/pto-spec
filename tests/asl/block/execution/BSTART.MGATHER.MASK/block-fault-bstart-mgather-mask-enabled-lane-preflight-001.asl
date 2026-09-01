// PTO-TEST: {"id":"PTO-AVS-BLOCK-MGATHER-MASK-FAULT-001","source":"asl/block/execution/BSTART.MGATHER.MASK.asl","requirements":["PTO-MGATHER-MASK-PREDICATE-001","PTO-MGATHER-MASK-PUBLICATION-001","PTO-INST-TILE-MGATHER-MASK"],"kind":"fault","summary":"MGATHER.MASK ignores disabled addresses and precisely preflights all enabled lanes.","pass_condition":"An invalid disabled displacement is ignored, but a later enabled page fault rejects the whole block before the earlier enabled load, destination allocation, or event effect.","related_sources":["asl/tile/model/memory/gather-scatter.asl","asl/arch/memory-model/fault-precision.asl"]}
pure func FaultMaskGatherStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00611181;
    instruction[31:27] = Zeros{5} + 26;
    return instruction;
end;

pure func FaultMaskGatherBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 1;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

pure func FaultMaskGatherIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 4;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 4, 1, 3, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigurePredicateTile(1, 128, 1, 4, 1, 3);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x7fff);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(0, 0, 2, Zeros{PTO_XLEN} + 2);
    WriteTilePredicateBit(1, 0, 0, FALSE);
    WriteTilePredicateBit(1, 0, 1, TRUE);
    WriteTilePredicateBit(1, 0, 2, TRUE);
    Store(Zeros{PTO_XLEN} + 4094, 2, Zeros{PTO_XLEN} + 11);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 4094);
    let started = ExecuteCommandInstruction(FaultMaskGatherStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    WritePEGPR(0, 4, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let bound = ExecuteCommandInstruction(FaultMaskGatherBinding(), 32);
    assert bound == CommandExecution_Executed;
    let scalar = ExecuteCommandInstruction(FaultMaskGatherIOR(), 32);
    assert scalar == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 0;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    StopMemoryEventCapture();
    return 0;
end;
