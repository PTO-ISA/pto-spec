// PTO-TEST: {"id":"PTO-AVS-BLOCK-TPREFETCH-FAULT-001","source":"asl/block/execution/BSTART.TPREFETCH.asl","requirements":["PTO-BSTART-TPREFETCH-MEMORY-001","PTO-INST-TILE-TPREFETCH"],"kind":"fault","summary":"A fault in one PE rejects the complete four-PE TPREFETCH footprint without a partial event prefix.","pass_condition":"A PE2 page fault leaves zero events and the same block can be retried after repair to produce four events.","related_sources":["asl/tile/model/memory/gather-scatter.asl"]}
pure func PrefetchFaultStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00311181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func PrefetchFaultIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    WritePEGPR(0, 2, Zeros{PTO_XLEN});
    WritePEGPR(1, 2, Zeros{PTO_XLEN} + 0x100);
    WritePEGPR(2, 2, Ones{PTO_XLEN});
    WritePEGPR(3, 2, Zeros{PTO_XLEN} + 0x300);
    for pe = 0 to 3 do
        WritePEGPR(pe as MemoryAgentId, 3, Zeros{PTO_XLEN} + 1);
    end;
    let started = ExecuteCommandInstruction(PrefetchFaultStart(), 32);
    let bound = ExecuteCommandInstruction(PrefetchFaultIOR(), 32);
    assert started == CommandExecution_Executed;
    assert bound == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let faulted = ExecuteBundleTileOperation();
    assert !faulted;
    assert _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 0;

    ClearFault();
    WritePEGPR(2, 2, Zeros{PTO_XLEN} + 0x200);
    let retried = ExecuteBundleTileOperation();
    assert retried;
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 4;
    for event = 0 to 3 do
        assert _MemoryEvents[[event]].agent == event;
    end;
    StopMemoryEventCapture();
    return 0;
end;
