// PTO-TEST: {"id":"PTO-AVS-ARCH-RC-ATOMIC-FENCE-ORDER-002","source":"asl/arch/memory-model/ordering.asl","requirements":["PTO-ARCH-MEMORY-MODEL-ATOMIC-CROSS-AGENT-001","PTO-ARCH-MEMORY-MODEL-FENCE-TRANSPORT-001","PTO-ARCH-MEMORY-MODEL-REPLAY-001","PTO-ARCH-MEMORY-MODEL-FLUSH-001"],"kind":"ordering","summary":"Cross-agent atomics synchronize only through reads-from release/acquire pairs, fences order only matching class masks, and replay flush keeps committed effects.","pass_condition":"Fence masks, cross-agent atomic reads-from, relaxed atomic negatives, and replay flush retention all hold.","related_sources":["asl/arch/memory-model/fault-precision.asl","asl/arch/memory-model/memory-events.asl"]}
func TestRCFenceOrdersMatchingClassPair()
begin
    ResetMemoryExecution();
    - = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN});
    let initial_b = AddInitialWriteEvent(Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN});
    let store_a = AddStoreEvent(0, Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN} + 1,
        MemoryOrder_Relaxed, 1);
    - = AddDataFenceEvent(0, '0010', '0001');
    let load_b = AddLoadEvent(0, Zeros{PTO_XLEN} + 8, 8, Zeros{PTO_XLEN},
        MemoryOrder_Relaxed);
    SetMemoryReadFrom(load_b, initial_b);
    assert MemoryFenceOrders(store_a, load_b);
    assert MemoryCandidateExecutionValid();
    assert MemoryExecutionAllowedRC();
end;

func TestRCFenceClassMismatchDoesNotOrder()
begin
    ResetMemoryExecution();
    - = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN});
    let initial_b = AddInitialWriteEvent(Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN});
    let store_a = AddStoreEvent(0, Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN} + 1,
        MemoryOrder_Relaxed, 1);
    - = AddDataFenceEvent(0, '0001', '0001');
    let load_b = AddLoadEvent(0, Zeros{PTO_XLEN} + 8, 8, Zeros{PTO_XLEN},
        MemoryOrder_Relaxed);
    SetMemoryReadFrom(load_b, initial_b);
    assert !MemoryFenceOrders(store_a, load_b);
    assert MemoryCandidateExecutionValid();
    assert MemoryExecutionAllowedRC();
end;

func TestRCFenceOnAnotherAgentDoesNotOrder()
begin
    ResetMemoryExecution();
    - = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN});
    let initial_b = AddInitialWriteEvent(Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN});
    let store_a = AddStoreEvent(0, Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN} + 1,
        MemoryOrder_Relaxed, 1);
    - = AddDataFenceEvent(1, '0010', '0001');
    let load_b = AddLoadEvent(0, Zeros{PTO_XLEN} + 8, 8, Zeros{PTO_XLEN},
        MemoryOrder_Relaxed);
    SetMemoryReadFrom(load_b, initial_b);
    assert !MemoryFenceOrders(store_a, load_b);
end;

func TestRCFenceDoesNotSynchronizeAcrossAgents()
begin
    ResetMemoryExecution();
    - = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN});
    let published = AddStoreEvent(0, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN} + 7, MemoryOrder_Relaxed, 1);
    - = AddDataFenceEvent(1, '0010', '0001');
    let observed = AddLoadEvent(1, Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN} + 7,
        MemoryOrder_Relaxed);
    SetMemoryReadFrom(observed, published);
    // A fence transports strength inside one agent; it never fabricates the
    // release/acquire accesses that cross-agent synchronizes-with requires.
    assert !MemorySynchronizesWith(published, observed);
    assert MemoryCandidateExecutionValid();
    assert MemoryExecutionAllowedRC();
end;

func TestRCAtomicOrderingRequiresReadsFrom()
begin
    ResetMemoryExecution();
    let initial = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN});
    let release = AddAtomicEvent(0, Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN},
        Zeros{PTO_XLEN} + 1, MemoryOrder_Release, 1);
    SetMemoryReadFrom(release, initial);
    let acquire = AddAtomicEvent(1, Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 2, MemoryOrder_Acquire, 2);
    SetMemoryReadFrom(acquire, release);
    assert MemorySynchronizesWith(release, acquire);
    assert MemoryCandidateExecutionValid();
    assert MemoryExecutionAllowedRC();

    // The same release/acquire orders do not synchronize when the acquire reads
    // a different coherence successor instead of the release itself.
    ResetMemoryExecution();
    let second_initial = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN});
    let second_release = AddAtomicEvent(0, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 1, MemoryOrder_Release, 1);
    SetMemoryReadFrom(second_release, second_initial);
    let successor = AddStoreEvent(1, Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN} + 1,
        MemoryOrder_Relaxed, 2);
    let second_acquire = AddAtomicEvent(1, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN} + 1, Zeros{PTO_XLEN} + 2, MemoryOrder_Acquire, 3);
    SetMemoryReadFrom(second_acquire, successor);
    assert !MemorySynchronizesWith(second_release, second_acquire);
    assert MemoryCandidateExecutionValid();
    assert MemoryExecutionAllowedRC();
end;

func TestRCRelaxedAtomicPairDoesNotSynchronize()
begin
    ResetMemoryExecution();
    let initial = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN});
    let release = AddAtomicEvent(0, Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN},
        Zeros{PTO_XLEN} + 1, MemoryOrder_Relaxed, 1);
    SetMemoryReadFrom(release, initial);
    let acquire = AddAtomicEvent(1, Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 2, MemoryOrder_Relaxed, 2);
    SetMemoryReadFrom(acquire, release);
    assert !MemorySynchronizesWith(release, acquire);
    assert MemoryCandidateExecutionValid();
    assert MemoryExecutionAllowedRC();
end;

func TestRCMemoryReplayFlushRetainsCommitted()
begin
    ResetProfileState();
    ResetMemoryExecution();
    let request = Zeros{PTO_XLEN} + 0x900;
    BeginMemoryReplay(request);
    assert !MemoryReplayCanRetryWholeRequest(request);
    - = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN});
    - = AddStoreEvent(0, Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN} + 1,
        MemoryOrder_Relaxed, 1);
    CommitMemoryReplayEffect();
    assert _MemoryReplayState.committed_event_count == 2;
    - = AddStoreEvent(0, Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN} + 2,
        MemoryOrder_Relaxed, 2);
    assert _MemoryEventCount == 3;
    FlushMemoryReplay();
    assert _MemoryEventCount == 2;
    assert !_MemoryReplayState.active;
    assert MemoryReplayCanRetryWholeRequest(request);
    assert MemoryCandidateExecutionValid();
end;

func TestRCMemoryReplayCompleteKeepsWholeRequest()
begin
    ResetProfileState();
    ResetMemoryExecution();
    let request = Zeros{PTO_XLEN} + 0x908;
    BeginMemoryReplay(request);
    - = AddInitialWriteEvent(Zeros{PTO_XLEN} + 8, 8, Zeros{PTO_XLEN});
    - = AddStoreEvent(0, Zeros{PTO_XLEN} + 8, 8, Zeros{PTO_XLEN} + 3,
        MemoryOrder_AcquireRelease, 1);
    CompleteMemoryReplay();
    assert !_MemoryReplayState.active;
    assert _MemoryReplayState.committed_event_count == 2;
    assert MemoryReplayCanRetryWholeRequest(request);
    assert MemoryCandidateExecutionValid();
    assert MemoryExecutionAllowedRC();
end;

func main() => integer
begin
    ResetProfileState();
    TestRCFenceOrdersMatchingClassPair();
    TestRCFenceClassMismatchDoesNotOrder();
    TestRCFenceOnAnotherAgentDoesNotOrder();
    TestRCFenceDoesNotSynchronizeAcrossAgents();
    TestRCAtomicOrderingRequiresReadsFrom();
    TestRCRelaxedAtomicPairDoesNotSynchronize();
    TestRCMemoryReplayFlushRetainsCommitted();
    TestRCMemoryReplayCompleteKeepsWholeRequest();
    return 0;
end;
