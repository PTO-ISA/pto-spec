// PTO-TEST: {"id":"PTO-AVS-ARCH-RC-ATOMIC-FENCE-ORDER-002","source":"asl/arch/memory-model/ordering.asl","requirements":["PTO-ARCH-MEMORY-MODEL-ATOMIC-CROSS-AGENT-001","PTO-ARCH-MEMORY-MODEL-FENCE-TRANSPORT-001","PTO-ARCH-MEMORY-MODEL-REPLAY-001","PTO-ARCH-MEMORY-MODEL-FLUSH-001","PTO-ARCH-CORE-SYNCHRONIZATION-001"],"kind":"ordering","summary":"Cross-agent atomics synchronize only through reads-from release/acquire pairs, fences order only matching class masks, replay flush keeps committed effects, and Core synchronization rejects a stale post-barrier read.","pass_condition":"Fence masks, cross-agent atomic reads-from, relaxed atomic negatives, replay flush retention, and the encoded Core barrier memory relation all hold.","related_sources":["asl/arch/memory-model/fault-precision.asl","asl/arch/memory-model/memory-events.asl","asl/arch/state/core-synchronization.asl"]}
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
    assert _MemoryEventCount == 3;
    assert _MemoryEvents[[0]].active;
    assert _MemoryEvents[[1]].active;
    assert !_MemoryEvents[[2]].active;
    assert !_MemoryReplayState.active;
    assert MemoryReplayCanRetryWholeRequest(request);
    assert MemoryCandidateExecutionValid();
end;

func TestRCInactiveReplayFencesAndWritesAreIgnored()
begin
    ResetProfileState();
    ResetMemoryExecution();
    let launch = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x180);
    assert launch == KernelLifecycle_Started;
    let initial_x = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN});
    let initial_y = AddInitialWriteEvent(Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN});
    SelectExecutionContext(0, 0);
    _CurrentProgramOrder = 1;
    _CurrentMemoryOrigin = MemoryEventOrigin_Kernel;
    let store_x = AddStoreEvent(0, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN} + 1, MemoryOrder_Relaxed, 1);
    _CurrentProgramOrder = 2;
    BeginMemoryReplay(Zeros{PTO_XLEN} + 0x188);
    let fence_x = AddDataFenceEvent(0, '0010', '0001');
    assert !_MemoryEvents[[fence_x]].committed;
    FlushMemoryReplay();
    assert !_MemoryEvents[[fence_x]].active;

    SelectExecutionContext(0, 1);
    _CurrentProgramOrder = 1;
    _CurrentMemoryOrigin = MemoryEventOrigin_Kernel;
    let store_y = AddStoreEvent(1, Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN} + 1, MemoryOrder_Relaxed, 1);
    _CurrentProgramOrder = 2;
    BeginMemoryReplay(Zeros{PTO_XLEN} + 0x198);
    let fence_y = AddDataFenceEvent(1, '0010', '0001');
    assert !_MemoryEvents[[fence_y]].committed;
    FlushMemoryReplay();
    assert !_MemoryEvents[[fence_y]].active;

    SelectExecutionContext(0, 0);
    _CurrentProgramOrder = 3;
    let read_y = AddLoadEvent(0, Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN}, MemoryOrder_Relaxed);
    SetMemoryReadFrom(read_y, initial_y);
    SelectExecutionContext(0, 1);
    _CurrentProgramOrder = 3;
    let read_x = AddLoadEvent(1, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN}, MemoryOrder_Relaxed);
    SetMemoryReadFrom(read_x, initial_x);
    assert !MemoryFenceOrders(store_x, read_y);
    assert !MemoryFenceOrders(store_y, read_x);
    assert MemoryCandidateExecutionValid();
    // Store buffering remains an allowed RC outcome once replay discarded
    // both fences; a tombstone must not add either cycle edge.
    assert MemoryExecutionAllowedRC();

    // Inactive initial writes and accesses are tombstones, not candidates in
    // location accounting or mixed-overlap checks.
    let stale_initial = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN});
    _MemoryEvents[[stale_initial]].active = FALSE;
    let stale_overlap = AddStoreEvent(1, Zeros{PTO_XLEN} + 1, 4,
        Zeros{PTO_XLEN} + 7, MemoryOrder_Relaxed, 2);
    _MemoryEvents[[stale_overlap]].active = FALSE;
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

func TestRCCoreSynchronizationRejectsStaleRead()
begin
    ResetProfileState();
    ResetMemoryExecution();
    let entry = Zeros{PTO_XLEN} + 0x400;
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;
    let address = Zeros{PTO_XLEN} + 0x980;
    let initial = AddInitialWriteEvent(address, 8, Zeros{PTO_XLEN});

    SelectExecutionContext(0, 0);
    _PC = entry + 4;
    _CurrentMemoryOrigin = MemoryEventOrigin_Kernel;
    _CurrentProgramOrder = 1;
    let publication = AddStoreEvent(0, address, 8,
        Zeros{PTO_XLEN} + 1, MemoryOrder_Relaxed, 1);
    _CurrentProgramOrder = 2;
    _ScalarExecutionBlocked = FALSE;
    SyncCore();

    for pe_number = 1 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        _PC = entry + 4;
        _CurrentMemoryOrigin = MemoryEventOrigin_Kernel;
        _ScalarExecutionBlocked = FALSE;
        SyncCore();
    end;
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 2 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        _ScalarExecutionBlocked = FALSE;
        SyncCore();
    end;
    assert _CoreSyncRecords[[0]][[0]].released;

    SelectExecutionContext(0, 1);
    assert _CurrentCollectiveEpoch == 1;
    let stale_read = AddLoadEvent(1, address, 8, Zeros{PTO_XLEN},
        MemoryOrder_Relaxed);
    SetMemoryReadFrom(stale_read, initial);
    assert MemoryCollectiveSyncBefore(publication, stale_read);
    let candidate_valid = MemoryCandidateExecutionValid();
    assert candidate_valid;
    let candidate_allowed = MemoryExecutionAllowedRC();
    assert !candidate_allowed;

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
    TestRCInactiveReplayFencesAndWritesAreIgnored();
    TestRCMemoryReplayCompleteKeepsWholeRequest();
    TestRCCoreSynchronizationRejectsStaleRead();
    return 0;
end;
