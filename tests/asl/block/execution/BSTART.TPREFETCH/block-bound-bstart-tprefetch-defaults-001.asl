// PTO-TEST: {"id":"PTO-AVS-BLOCK-TPREFETCH-DEFAULTS-001","source":"asl/block/execution/BSTART.TPREFETCH.asl","requirements":["PTO-BSTART-TPREFETCH-MEMORY-001"],"kind":"boundary","summary":"TPREFETCH distinguishes omitted B.IOR defaults from explicit zero selectors.","pass_condition":"Omission prefetches one dense element per PE while an explicit zero stride aliases two rows rather than taking the LB2 default.","related_sources":["asl/block/model/dispatch/tlsu-prefetch.asl"]}
pure func PrefetchDefaultsStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00311181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func PrefetchZeroIOR() => bits(64)
begin
    return Zeros{64} + 0x00000013;
end;

func main() => integer
begin
    ResetProfileState();
    let omitted_start = ExecuteCommandInstruction(
        PrefetchDefaultsStart(), 32);
    assert omitted_start == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let omitted_completed = ExecuteBundleTileOperation();
    assert omitted_completed;
    assert _MemoryEventCount == 4;
    for event = 0 to 3 do
        assert _MemoryEvents[[event]].agent == event;
        assert _MemoryEvents[[event]].address == Zeros{PTO_XLEN};
    end;
    StopMemoryEventCapture();

    ResetProfileState();
    let zero_start = ExecuteCommandInstruction(PrefetchDefaultsStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let zero_ior = ExecuteCommandInstruction(PrefetchZeroIOR(), 32);
    assert zero_start == CommandExecution_Executed;
    assert zero_ior == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let zero_completed = ExecuteBundleTileOperation();
    assert zero_completed;
    assert _MemoryEventCount == 16;
    for pe = 0 to 3 do
        let first = pe * 4;
        assert _MemoryEvents[[first]].address == Zeros{PTO_XLEN};
        assert _MemoryEvents[[first + 1]].address == Zeros{PTO_XLEN} + 1;
        assert _MemoryEvents[[first + 2]].address == Zeros{PTO_XLEN};
        assert _MemoryEvents[[first + 3]].address == Zeros{PTO_XLEN} + 1;
    end;
    StopMemoryEventCapture();
    return 0;
end;
