// PTO-TEST: {"id":"PTO-AVS-ARCH-SYNC-HISTORY-RING-001","source":"asl/arch/state/core-synchronization.asl","requirements":["PTO-ARCH-CORE-SYNCHRONIZATION-001","PTO-ARCH-MEMORY-MODEL-REPLAY-001"],"kind":"state-transition","summary":"Completed Core synchronization history remains represented by event provenance across generation-ring reuse and kernel lifetimes.","pass_condition":"Repeated real collective completion and End reclaim active release records while event stamps preserve the first relation across ring reuse and a later invocation; a stale post-barrier read remains rejected.","related_sources":["asl/arch/state/core-synchronization.asl","asl/arch/state/kernel-lifecycle.asl","asl/arch/memory-model/memory-events.asl","asl/arch/memory-model/ordering.asl"]}
func main() => integer
begin
    ResetProfileState();
    ResetMemoryExecution();
    let entry = Zeros{PTO_XLEN} + 0x900;
    var first_store: MemoryEventIndex = 0 as MemoryEventIndex;
    var first_post_barrier_read: MemoryEventIndex = 0 as MemoryEventIndex;
    for round = 0 to PTO_MODEL_SYNC_GENERATIONS do
        let launch = LaunchKernelInvocation(0, entry);
        assert launch == KernelLifecycle_Started;
        let invocation = _KernelInvocationByCore[[0]];
        SelectExecutionContext(0, 0);
        _PC = entry + 4;
        _CurrentMemoryOrigin = MemoryEventOrigin_Kernel;
        _CurrentProgramOrder = 1;
        if round == 0 then
            first_store = AddStoreEvent(0, Zeros{PTO_XLEN} + 0xb00,
                8, Zeros{PTO_XLEN} + 1, MemoryOrder_Relaxed, 1);
        end;
        for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            let pe = pe_number as MemoryAgentId;
            SelectExecutionContext(0, pe);
            _PC = entry + 4;
            _CurrentMemoryOrigin = MemoryEventOrigin_Kernel;
            _ScalarExecutionBlocked = FALSE;
            SyncCore();
        end;
        assert _CoreSyncRecords[[0]][[0]].released;
        if round == 0 then
            SelectExecutionContext(0, 1);
            _CurrentProgramOrder = 2;
            first_post_barrier_read = AddLoadEvent(1,
                Zeros{PTO_XLEN} + 0xb00, 8, Zeros{PTO_XLEN},
                MemoryOrder_Relaxed);
            let initial = AddInitialWriteEvent(Zeros{PTO_XLEN} + 0xb00,
                8, Zeros{PTO_XLEN});
            SetMemoryReadFrom(first_post_barrier_read, initial);
            assert MemoryCollectiveSyncBefore(first_store,
                first_post_barrier_read);
        end;
        SelectExecutionContext(0, 0);
        let ended = EndKernelInvocation(0);
        assert ended == KernelLifecycle_Started;
        assert _PEReleaseValid[[0]] == Zeros{4};
        assert FindCoreSyncGenerationRecord(0, invocation, 0) ==
            PTO_MODEL_SYNC_GENERATIONS;
    end;
    assert _CoreCollectiveHistorySequence[[0]] >
        PTO_MODEL_SYNC_GENERATIONS;
    assert MemoryCollectiveSyncBefore(first_store, first_post_barrier_read);

    let relaunched = LaunchKernelInvocation(0, entry + 0x100);
    assert relaunched == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    _PC = entry + 0x104;
    _CurrentMemoryOrigin = MemoryEventOrigin_Kernel;
    _ScalarExecutionBlocked = FALSE;
    SyncCore();
    assert _CoreSyncRecords[[0]][[0]].valid;
    let aborted = AbortKernelInvocation(0);
    assert aborted == KernelLifecycle_Started;
    assert FindCoreSyncGenerationRecord(0,
        _RetiredKernelInvocationByCore[[0]], 0) ==
        PTO_MODEL_SYNC_GENERATIONS;
    assert MemoryCollectiveSyncBefore(first_store, first_post_barrier_read);
    StopMemoryEventCapture();
    return 0;
end;
