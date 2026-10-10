// PTO-TEST: {"id":"PTO-AVS-ARCH-GM-OBLIGATION-TSTORE-QUIESCENCE-002","source":"asl/arch/state/kernel-lifecycle.asl","requirements":["PTO-ARCH-GM-OBLIGATIONS-001","PTO-ARCH-CORE-SYNCHRONIZATION-001","PTO-ARCH-KERNEL-LIFECYCLE-001"],"kind":"state-transition","summary":"a real committed TSTORE beat remains irrevocable across abort and drains before a new invocation","pass_condition":"a captured request progresses one real committed beat, abort waits for the exact old request's real completion, and only then admits a fresh invocation; a stale completion cannot update the new request","related_sources":["asl/tile/model/memory/load-store.asl","asl/arch/memory-model/gm-obligations.asl","asl/arch/state/core-synchronization.asl"]}
func TestAbortDrainsActualIrrevocableTStoreBeforeNewLaunch()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x500;
    let launched = LaunchKernelInvocation(0, entry);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    ConfigureTile(4, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 0x11);
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN} + 0x22);
    _BPC = entry;
    _BundleStartEncodedInstruction =
        '0000000000000000000000000000000011000000000100010001000110000001';
    _CurrentProgramOrder = 3;
    _PEProgramOrder[[0]][[0]] = 3;
    StartMemoryEventCapture(0);
    SetVerificationGMProgressDeferred(TRUE);
    TSTORE(Zeros{PTO_XLEN} + 0x500, Zeros{PTO_XLEN} + 16, 4);
    let old_invocation = _KernelInvocationByCore[[0]];
    let old_obligation = _GMObligations[[0]][[0]][[0]];
    assert old_obligation.state == GMObligation_Validated;
    assert old_obligation.progress_element == 0;
    assert old_obligation.reversible;
    assert !old_obligation.irrevocable;
    let initial_first = LoadUnsigned(Zeros{PTO_XLEN} + 0x500, 8);
    let initial_second = LoadUnsigned(Zeros{PTO_XLEN} + 0x508, 8);
    assert initial_first == Zeros{PTO_XLEN};
    assert initial_second == Zeros{PTO_XLEN};

    SetVerificationGMProgressDeferred(FALSE);
    SetVerificationGMProgressBeatBudget(1);
    ProgressKernelGMObligationsForCore(0, old_invocation);
    let partly_completed = _GMObligations[[0]][[0]][[0]];
    assert partly_completed.state == GMObligation_Issued;
    assert partly_completed.progress_element == 1;
    assert partly_completed.irrevocable;
    assert !partly_completed.reversible;
    let first_after_beat = LoadUnsigned(Zeros{PTO_XLEN} + 0x500, 8);
    let second_after_beat = LoadUnsigned(Zeros{PTO_XLEN} + 0x508, 8);
    assert first_after_beat == Zeros{PTO_XLEN} + 0x11;
    assert second_after_beat == Zeros{PTO_XLEN};
    var first_beat_event_found = FALSE;
    for event_number = 0 to _MemoryEventCount - 1 do
        let event = _MemoryEvents[[event_number as MemoryEventIndex]];
        if event.active && event.kind == MemoryEvent_Store &&
           event.address == Zeros{PTO_XLEN} + 0x500 &&
           event.write_value == Zeros{PTO_XLEN} + 0x11 &&
           event.committed && event.invocation == old_invocation then
            first_beat_event_found = TRUE;
        end;
    end;
    assert first_beat_event_found;

    _PC = entry + 8;
    _CurrentProgramOrder = 4;
    _PEProgramOrder[[0]][[0]] = 4;
    _ScalarExecutionBlocked = FALSE;
    SyncCore();
    assert _ScalarExecutionBlocked;
    assert _CoreSyncRecords[[0]][[0]].arrived == '1000';
    assert !_CoreSyncRecords[[0]][[0]].released;
    for pe_number = 1 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        _PC = entry + 8;
        _CurrentProgramOrder = 4;
        _PEProgramOrder[[0]][[pe]] = 4;
        _ScalarExecutionBlocked = FALSE;
        SyncCore();
        assert _ScalarExecutionBlocked;
    end;
    assert _CoreSyncRecords[[0]][[0]].arrived == '1111';
    assert !_CoreSyncRecords[[0]][[0]].released;
    SelectExecutionContext(0, 0);
    _ScalarExecutionBlocked = FALSE;

    let aborted = AbortKernelInvocation(0);
    assert aborted == KernelLifecycle_Waiting;
    assert _KernelInvocationByCore[[0]] == 0;
    assert !_CoreSyncRecords[[0]][[0]].valid;
    let blocked_launch = LaunchKernelInvocation(0, entry + 0x100);
    assert blocked_launch == KernelLifecycle_Waiting;
    assert _KernelInvocationByCore[[0]] == 0;

    ProgressKernelGMObligationsForCore(0, old_invocation);
    let completed_old = _GMObligations[[0]][[0]][[0]];
    assert completed_old.state == GMObligation_Completed;
    assert completed_old.invocation == old_invocation;
    assert completed_old.progress_element == 2;
    assert completed_old.irrevocable;
    let second_after_drain = LoadUnsigned(Zeros{PTO_XLEN} + 0x508, 8);
    assert second_after_drain == Zeros{PTO_XLEN} + 0x22;
    var drained_beat_event_found = FALSE;
    for event_number = 0 to _MemoryEventCount - 1 do
        let event = _MemoryEvents[[event_number as MemoryEventIndex]];
        if event.active && event.kind == MemoryEvent_Store &&
           event.address == Zeros{PTO_XLEN} + 0x508 &&
           event.write_value == Zeros{PTO_XLEN} + 0x22 &&
           event.committed && event.invocation == old_invocation then
            drained_beat_event_found = TRUE;
        end;
    end;
    assert drained_beat_event_found;

    let relaunched = LaunchKernelInvocation(0, entry + 0x100);
    assert relaunched == KernelLifecycle_Started;
    let new_invocation = _KernelInvocationByCore[[0]];
    assert new_invocation != old_invocation;
    SelectExecutionContext(0, 0);
    ConfigureTile(4, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 0x33);
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN} + 0x44);
    _BPC = entry;
    _BundleStartEncodedInstruction =
        '0000000000000000000000000000000011000000000100010001000110000001';
    _CurrentProgramOrder = 3;
    _PEProgramOrder[[0]][[0]] = 3;
    SetVerificationGMProgressDeferred(TRUE);
    TSTORE(Zeros{PTO_XLEN} + 0x600, Zeros{PTO_XLEN} + 16, 4);
    let new_obligation = _GMObligations[[0]][[0]][[0]];
    assert new_obligation.invocation == new_invocation;
    assert new_obligation.identity != old_obligation.identity;
    assert new_obligation.state == GMObligation_Validated;
    CompleteGMObligationForIdentity(0, 0, 0 as GMObligationIndex,
        old_invocation, old_obligation.identity);
    assert _GMObligations[[0]][[0]][[0]].state == GMObligation_Validated;
    assert _GMObligations[[0]][[0]][[0]].invocation == new_invocation;
    let cancelled = AbortKernelInvocation(0);
    assert cancelled == KernelLifecycle_Started;
    assert _GMObligations[[0]][[0]][[0]].state == GMObligation_Cancelled;
    SetVerificationGMProgressDeferred(FALSE);
    SetVerificationGMProgressBeatBudget(0);
    StopMemoryEventCapture();
end;

func main() => integer
begin
    TestAbortDrainsActualIrrevocableTStoreBeforeNewLaunch();
    return 0;
end;
