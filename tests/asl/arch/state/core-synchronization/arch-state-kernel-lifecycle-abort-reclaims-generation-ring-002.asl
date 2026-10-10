// PTO-TEST: {"id":"PTO-AVS-ARCH-SYNC-ABORT-RECLAIMS-RING-002","source":"asl/arch/state/core-synchronization.asl","requirements":["PTO-ARCH-CORE-SYNCHRONIZATION-001","PTO-ARCH-KERNEL-LIFECYCLE-001"],"kind":"state-transition","summary":"abort and end reclaim completed active release records with unconsumed peer tokens","pass_condition":"repeated completed collectives closed before every release token is consumed do not exhaust the bounded active ring; close removes old records/tokens, a later launch completes a fresh collective, and retained memory-history provenance remains owned by events","related_sources":["asl/arch/state/core-synchronization.asl","asl/arch/state/kernel-lifecycle.asl","asl/arch/memory-model/memory-events.asl"]}
func ReachCompleteSync(site: Word)
begin
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        _PC = site;
        _CurrentMemoryOrigin = MemoryEventOrigin_Kernel;
        _ScalarExecutionBlocked = FALSE;
        SyncCore();
    end;
end;

func AssertClosedInvocationHasNoActiveGeneration(invocation: integer)
begin
    assert FindCoreSyncGenerationRecord(0, invocation, 0) ==
        PTO_MODEL_SYNC_GENERATIONS;
    assert _PEReleaseValid[[0]] == Zeros{4};
    for slot = 0 to PTO_MODEL_SYNC_GENERATIONS - 1 do
        assert !_CoreSyncRecords[[0]][[slot]].valid ||
               _CoreSyncRecords[[0]][[slot]].invocation != invocation;
    end;
end;

func main() => integer
begin
    ResetProfileState();
    ResetMemoryExecution();
    let entry = Zeros{PTO_XLEN} + 0x900;
    let site = entry + 4;
    let close_count = PTO_MODEL_SYNC_GENERATIONS * 2 + 1;
    for round = 0 to close_count - 1 do
        let launched = LaunchKernelInvocation(0, entry);
        assert launched == KernelLifecycle_Started;
        let invocation = _KernelInvocationByCore[[0]];
        ReachCompleteSync(site);
        let slot = FindCoreSyncGenerationRecord(0, invocation, 0);
        assert slot < PTO_MODEL_SYNC_GENERATIONS;
        assert _CoreSyncRecords[[0]][[slot]].released &&
               _CoreSyncRecords[[0]][[slot]].arrived == '1111';
        // PE3 reached LAST; the other three completed-generation tokens are
        // intentionally unconsumed when this invocation is closed.
        assert _CoreSyncRecords[[0]][[slot]].consumed != '1111';
        assert _PEReleaseValid[[0]] != Zeros{4};
        SelectExecutionContext(0, 0);
        if round MOD 2 == 0 then
            let aborted = AbortKernelInvocation(0);
            assert aborted == KernelLifecycle_Started;
        else
            let ended = EndKernelInvocation(0);
            assert ended == KernelLifecycle_Started;
        end;
        AssertClosedInvocationHasNoActiveGeneration(invocation);
    end;

    let history_before = _CoreCollectiveHistorySequence[[0]];
    assert history_before == close_count;
    let relaunched = LaunchKernelInvocation(0, entry + 0x100);
    assert relaunched == KernelLifecycle_Started;
    let new_invocation = _KernelInvocationByCore[[0]];
    ReachCompleteSync(site + 0x100);
    let new_slot = FindCoreSyncGenerationRecord(0, new_invocation, 0);
    assert new_slot < PTO_MODEL_SYNC_GENERATIONS;
    assert _CoreSyncRecords[[0]][[new_slot]].released &&
           _CoreSyncRecords[[0]][[new_slot]].arrived == '1111';
    assert _CoreCollectiveHistorySequence[[0]] == history_before + 1;
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        assert _PEBarrierNextGeneration[[0]][[pe]] ==
            if pe_number == PTO_MODEL_MEMORY_AGENTS - 1 then 1 else 0;
    end;
    let final_abort = AbortKernelInvocation(0);
    assert final_abort == KernelLifecycle_Started;
    AssertClosedInvocationHasNoActiveGeneration(new_invocation);
    return 0;
end;
