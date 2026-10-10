// PTO-TEST: {"id":"PTO-AVS-ARCH-MEMORY-REPLAY-PEER-READ-FROM-001","source":"asl/arch/memory-model/ordering.asl","requirements":["PTO-ARCH-MEMORY-MODEL-REPLAY-001","PTO-ARCH-MEMORY-MODEL-FLUSH-001"],"kind":"state-transition","summary":"Selective replay discard preserves another PE's read-from reference to a surviving committed write.","pass_condition":"PE1's live read keeps the stable event reference to PE0's committed write after PE0 discards its later speculative store, and the memory candidate remains valid.","related_sources":["asl/arch/memory-model/fault-precision.asl","asl/arch/memory-model/memory-events.asl","asl/arch/memory-model/ordering.asl"]}
func main() => integer
begin
    ResetProfileState();
    ResetMemoryExecution();
    SelectExecutionContext(0, 0);
    _CurrentMemoryOrigin = MemoryEventOrigin_Kernel;
    _CurrentKernelInvocation = 9;
    _CurrentProgramOrder = 1;
    let address = Zeros{PTO_XLEN} + 0x980;
    - = AddInitialWriteEvent(address, 8, Zeros{PTO_XLEN});
    BeginMemoryReplay(address);
    let earlier_write = AddStoreEvent(0, address, 8,
        Zeros{PTO_XLEN} + 7, MemoryOrder_Relaxed, 1);
    CommitMemoryReplayEffect();

    // PE1 reads the admitted write while PE0's next request is pending.
    // Recovery must preserve the stable read_from index and both live events.
    SelectExecutionContext(0, 1);
    _CurrentMemoryOrigin = MemoryEventOrigin_Kernel;
    _CurrentKernelInvocation = 9;
    _CurrentProgramOrder = 1;
    let peer_read = AddLoadEvent(1, address, 8, Zeros{PTO_XLEN} + 7,
        MemoryOrder_Relaxed);
    SetMemoryReadFrom(peer_read, earlier_write);

    SelectExecutionContext(0, 0);
    _CurrentProgramOrder = 2;
    BeginMemoryReplay(address + Zeros{PTO_XLEN} + 8);
    let speculative = AddStoreEvent(0, address, 8,
        Zeros{PTO_XLEN} + 8, MemoryOrder_Relaxed, 2);
    assert _MemoryEventCount == speculative + 1;
    FlushMemoryReplay();

    assert _MemoryEvents[[earlier_write]].active;
    assert _MemoryEvents[[peer_read]].active;
    assert _MemoryEvents[[peer_read]].read_from == earlier_write;
    assert !_MemoryEvents[[speculative]].active;
    assert MemoryCandidateExecutionValid();
    return 0;
end;
