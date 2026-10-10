// PTO-TEST: {"id":"PTO-AVS-ARCH-CORE-SYNC-HISTORY-PERSISTENCE-001","source":"asl/arch/state/core-synchronization.asl","requirements":["PTO-ARCH-CORE-SYNCHRONIZATION-001","PTO-ARCH-MEMORY-MODEL-REPLAY-001"],"kind":"ordering","summary":"completed Core collective ordering remains in memory-event provenance after generation-ring reuse, Core selection, and a later invocation","pass_condition":"the evicted generation's original publication-to-read relation remains observable while different Core, invocation, and handler events do not acquire that relation","related_sources":["asl/arch/memory-model/memory-events.asl","asl/arch/memory-model/ordering.asl","asl/arch/state/kernel-lifecycle.asl"]}
func TestCompletedCollectiveHistorySurvivesActiveRecordReuse()
begin
    ResetProfileState();
    ResetMemoryExecution();
    let entry = Zeros{PTO_XLEN} + 0x440;
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;
    let original_invocation = _KernelInvocationByCore[[0]];
    let address = Zeros{PTO_XLEN} + 0x9a0;
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
    SelectExecutionContext(0, 1);
    _CurrentProgramOrder = 3;
    let stale_read = AddLoadEvent(1, address, 8, Zeros{PTO_XLEN},
        MemoryOrder_Relaxed);
    SetMemoryReadFrom(stale_read, initial);
    assert MemoryCollectiveSyncBefore(publication, stale_read);
    assert MemoryCandidateExecutionValid();
    assert !MemoryExecutionAllowedRC();

    // Exercise real SyncCore arrivals until the active ring has evicted gen0.
    let history_rounds = PTO_MODEL_SYNC_GENERATIONS * 4;
    for round = 0 to history_rounds do
        for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            let pe = pe_number as MemoryAgentId;
            SelectExecutionContext(0, pe);
            _PC = entry + 4;
            _CurrentMemoryOrigin = MemoryEventOrigin_Kernel;
            _ScalarExecutionBlocked = FALSE;
            SyncCore();
        end;
    end;
    assert _PEBarrierNextGeneration[[0]][[0]] > PTO_MODEL_SYNC_GENERATIONS;
    assert _CoreCollectiveHistorySequence[[0]] > PTO_MODEL_SYNC_GENERATIONS;
    assert FindCoreSyncGenerationRecord(0, original_invocation, 0) ==
        PTO_MODEL_SYNC_GENERATIONS;

    // Matching PE and invocation numbers on another Core have no edge.
    let other_launch = LaunchKernelInvocation(1, entry);
    assert other_launch == KernelLifecycle_Started;
    SelectExecutionContext(1, 0);
    assert _CurrentKernelInvocation == original_invocation;
    _CurrentMemoryOrigin = MemoryEventOrigin_Kernel;
    let other_core_read = AddLoadEvent(0, address, 8, Zeros{PTO_XLEN},
        MemoryOrder_Relaxed);
    assert !MemoryCollectiveSyncBefore(publication, other_core_read);
    let other_core_end = EndKernelInvocation(1);
    assert other_core_end == KernelLifecycle_Started;

    SelectExecutionContext(0, 0);
    let old_end = EndKernelInvocation(0);
    assert old_end == KernelLifecycle_Started;
    let next_launch = LaunchKernelInvocation(0, entry);
    assert next_launch == KernelLifecycle_Started;
    let new_invocation_read = AddLoadEvent(0, address, 8,
        Zeros{PTO_XLEN}, MemoryOrder_Relaxed);
    assert _MemoryEvents[[new_invocation_read]].invocation !=
        _MemoryEvents[[publication]].invocation;
    assert !MemoryCollectiveSyncBefore(publication, new_invocation_read);
    _CurrentMemoryOrigin = MemoryEventOrigin_Handler;
    let handler_read = AddLoadEvent(0, address, 8, Zeros{PTO_XLEN},
        MemoryOrder_Relaxed);
    assert !MemoryCollectiveSyncBefore(publication, handler_read);

    // Event-stamped history survives both context selection and lifecycle reset.
    SelectExecutionContext(1, 0);
    SelectExecutionContext(0, 1);
    assert MemoryCollectiveSyncBefore(publication, stale_read);
    assert MemoryCandidateExecutionValid();
    assert !MemoryExecutionAllowedRC();
end;

func main() => integer
begin
    TestCompletedCollectiveHistorySurvivesActiveRecordReuse();
    return 0;
end;
