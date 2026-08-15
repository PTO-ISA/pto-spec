// PTO-TEST: {"id":"PTO-AVS-BLOCK-TPREFETCH-PACKED-001","source":"asl/block/execution/BSTART.TPREFETCH.asl","requirements":["PTO-TPREFETCH-FOOTPRINT-001"],"kind":"execution","summary":"Packed four-bit TPREFETCH preserves TLOAD logical-element byte addressing.","pass_condition":"Each PE's two U4X2 logical elements generate two one-byte events at the same containing-byte address.","related_sources":["asl/tile/model/memory/addressing.asl"]}
pure func PrefetchPackedStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00311181;
    instruction[31:27] = Zeros{5} + 28;
    return instruction;
end;

pure func PrefetchPackedIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    for pe = 0 to 3 do
        WritePEGPR(pe as MemoryAgentId, 2,
            Zeros{PTO_XLEN} + 0x100 + pe * 0x20);
        WritePEGPR(pe as MemoryAgentId, 3, Zeros{PTO_XLEN} + 2);
    end;
    let started = ExecuteCommandInstruction(PrefetchPackedStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    let bound = ExecuteCommandInstruction(PrefetchPackedIOR(), 32);
    assert started == CommandExecution_Executed;
    assert bound == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _MemoryEventCount == 8;
    for pe = 0 to 3 do
        let first = pe * 2;
        assert _MemoryEvents[[first]].agent == pe;
        assert _MemoryEvents[[first + 1]].agent == pe;
        assert _MemoryEvents[[first]].size_bytes == 1;
        assert _MemoryEvents[[first]].address ==
            Zeros{PTO_XLEN} + 0x100 + pe * 0x20;
        assert _MemoryEvents[[first + 1]].address ==
            _MemoryEvents[[first]].address;
    end;
    StopMemoryEventCapture();
    return 0;
end;
