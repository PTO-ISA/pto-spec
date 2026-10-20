// PTO-TEST: {"id":"PTO-AVS-ARCH-TSTORE-ATOMIC-DRAIN-001","source":"asl/arch/state/kernel-lifecycle.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-ARCH-GM-OBLIGATIONS-001","PTO-ARCH-KERNEL-LIFECYCLE-001","PTO-B-IOS-SHARED-STATE-001","PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001","PTO-B-ASSEMBLE-SPECULATION-001","PTO-ARCH-SHARED-VTAG-LIFETIME-001"],"kind":"state-transition","summary":"a partially committed Atomic TSTORE drains under its captured invocation while squash cancels unrelated source lifetimes","pass_condition":"encoded TLSU Function 1 TSTORE preflights a two-element Shared last-use request, one scheduler beat commits exactly one RMW, and a real execution-domain squash of a second Shared last-use capture cancels only that unrelated PE/domain occurrence while the Atomic source remains pinned; abort retains its generation pin, drain emits the remaining event once with original provenance before cleanup, and neither incomplete cohort is consumed","related_sources":["asl/arch/memory-model/atomic-tstore-obligations.asl","asl/tile/model/memory/atomic-tstore.asl","asl/tile/model/memory/gm-obligation-progress.asl","asl/block/model/state/source-lifetime.asl","asl/block/model/dispatch/tile-execution.asl","asl/block/model/operands/local-generation-squash.asl"]}

pure func AtomicDrainStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 25;
    return instruction;
end;

pure func AtomicDrainDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[31:29] = Zeros{3};
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

pure func AtomicDrainLastUse(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x04001013;
    instruction[25:20] = shared_id;
    instruction[11:9] = '101';
    return instruction;
end;

pure func AtomicDrainOtherLastUse(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x04001013;
    instruction[25:20] = shared_id;
    instruction[11:9] = '010';
    return instruction;
end;

pure func AtomicDrainAddress() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let shared_id = (Zeros{6} + 31) as SharedTileID;
    let entry = Zeros{PTO_XLEN} + 0x500;
    let launched = LaunchKernelInvocation(0, entry);
    assert launched == KernelLifecycle_Started;
    let invocation = _KernelInvocationByCore[[0]];
    SelectExecutionContext(0, 0);
    assert _CurrentMemoryOrigin == MemoryEventOrigin_Kernel &&
           _CurrentKernelInvocation == invocation;

    ConfigureTile(4, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN} + 2);
    InstallSharedTile(shared_id, _Tiles[[4]], '1111');
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x500, Zeros{8} + 10);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x501, Zeros{8});
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x502, Zeros{8});
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x503, Zeros{8});
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x504, Zeros{8} + 20);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x505, Zeros{8});
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x506, Zeros{8});
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x507, Zeros{8});
    let initial_first = LoadUnsigned(Zeros{PTO_XLEN} + 0x500, 4);
    let initial_second = LoadUnsigned(Zeros{PTO_XLEN} + 0x504, 4);
    assert initial_first == Zeros{PTO_XLEN} + 10 &&
           initial_second == Zeros{PTO_XLEN} + 20;
    assert SharedTilePublished(shared_id) &&
           SharedTilePayloadIntact(shared_id);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x500);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    _PC = entry;
    _BPC = entry;
    _CurrentProgramOrder = 3;
    _PEProgramOrder[[0]][[0]] = 3;

    let started = ExecuteCommandInstruction(AtomicDrainStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    let attributes = ExecuteCommandInstruction(AtomicDrainDATR(), 32);
    let shared = ExecuteCommandInstruction(
        AtomicDrainLastUse(Zeros{6} + 31), 32);
    let address = ExecuteCommandInstruction(AtomicDrainAddress(), 32);
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           shared == CommandExecution_Executed &&
           address == CommandExecution_Executed &&
           _BundleSharedBindings[[0]].source_reuse == FALSE &&
           _BundleSharedBindings[[0]].pe_mask == '1100';
    let (type_valid, effective_type) = ResolveBundleEffectiveDataType();
    assert BundleAtomicTStoreSelected() && type_valid &&
           effective_type == TileDataType_U32 &&
           BundleAtomicTStoreCurrentPESelected() &&
           BundleSharedBindingCount() == 1 &&
           BundleSharedBindingPhysicalCount() == 1 &&
           SharedTilePublished(shared_id) &&
           SharedTileReadSchemaLegal(shared_id, 1, 2, 2,
               TileDataType_U32, TileLayout_RowMajor);

    StartMemoryEventCapture(0);
    SetVerificationGMProgressDeferred(TRUE);
    let admitted = ExecuteBundleTileOperation();
    assert admitted;
    assert _LastFault == Fault_None;
    let before_service = _GMObligations[[0]][[0]][[0]];
    assert before_service.active && before_service.captured_atomic_tstore &&
           before_service.invocation == invocation &&
           before_service.instruction_pc == ReadBPC() &&
           before_service.atomic_tstore_target_count == 2 &&
           before_service.atomic_tstore_committed_count == 0 &&
           before_service.atomic_tstore_finalization_pending;
    assert before_service.atomic_tstore_translated_targets[[0]] ==
               Zeros{PTO_XLEN} + 0x500 &&
           before_service.atomic_tstore_translated_targets[[1]] ==
               Zeros{PTO_XLEN} + 0x504 &&
           TileReadLogicalElement(before_service.source_snapshot, 0) ==
               Zeros{PTO_XLEN} + 1 &&
           TileReadLogicalElement(before_service.source_snapshot, 1) ==
               Zeros{PTO_XLEN} + 2;
    assert SharedSourceLifetimePinned(shared_id) &&
           SharedTilePayloadIntact(shared_id) && _MemoryEventCount == 0;
    var lifetime_slot: integer {-1..63} = -1;
    for slot = 0 to 63 do
        if _BundleSourceLifetimes[[slot]].valid &&
           _BundleSourceLifetimes[[slot]].shared &&
           _BundleSourceLifetimes[[slot]].resource ==
               (UInt(shared_id) as TileIndex) then
            lifetime_slot = slot as integer {-1..63};
        end;
    end;
    assert lifetime_slot >= 0 &&
           _BundleSourceLifetimes[[lifetime_slot]].participant_mask == '1100' &&
           _BundleSourceLifetimes[[lifetime_slot]].captured_mask == '1000' &&
           _BundleSourceLifetimes[[lifetime_slot]].completed_mask == Zeros{4};
    SetVerificationGMProgressDeferred(FALSE);
    SetVerificationGMProgressBeatBudget(1);
    ProgressKernelGMObligationsForCore(0, invocation);
    let first_beat = _GMObligations[[0]][[0]][[0]];
    assert first_beat.state == GMObligation_Issued &&
           first_beat.irrevocable && first_beat.progress_element == 1 &&
           first_beat.atomic_tstore_committed_count == 1 &&
           first_beat.atomic_tstore_committed_elements[0] == '1' &&
           first_beat.atomic_tstore_committed_elements[1] == '0';
    assert SharedSourceLifetimePinned(shared_id) &&
           _BundleSourceLifetimes[[lifetime_slot]].completed_mask == Zeros{4};
    assert _MemoryEventCount == 1;
    let first_event = _MemoryEvents[[0 as MemoryEventIndex]];
    assert first_event.active && first_event.committed;
    assert first_event.kind == MemoryEvent_Atomic;
    assert first_event.core_identity == 0 && first_event.agent == 0;
    assert first_event.origin == MemoryEventOrigin_Kernel &&
           first_event.invocation == invocation;
    assert first_event.program_order == before_service.submission_order;
    assert first_event.address == Zeros{PTO_XLEN} + 0x500;
    assert first_event.read_value == Zeros{PTO_XLEN} + 10;
    assert first_event.write_value == Zeros{PTO_XLEN} + 11;

    // A second dynamic source-lifetime occurrence in PE1's execution domain
    // is captured after the Atomic request has become irrevocable. Squashing
    // that domain must cancel the unrelated S32 capture while preserving the
    // exact PE0/S31 token owned by the retained request.
    let atomic_domain = before_service.execution_domain_token;
    let atomic_lifetime_ordinal =
        before_service.atomic_tstore_source_lifetime_ordinal;
    let unrelated_shared_id = (Zeros{6} + 32) as SharedTileID;
    InstallSharedTile(unrelated_shared_id, _Tiles[[4]], '0100');
    assert SharedTilePublished(unrelated_shared_id) &&
           SharedTilePayloadIntact(unrelated_shared_id);
    SelectExecutionContext(0, 1);
    assert _CurrentKernelInvocation == invocation;
    ClearBundleHeaderState();
    let unrelated_pc = Zeros{PTO_XLEN} + 0x640;
    WriteTPC(unrelated_pc);
    WriteBPC(unrelated_pc);
    let unrelated_start = ExecuteCommandInstruction(AtomicDrainStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let unrelated_attributes = ExecuteCommandInstruction(
        AtomicDrainDATR(), 32);
    let unrelated_source = ExecuteCommandInstruction(
        AtomicDrainOtherLastUse(Zeros{6} + 32), 32);
    let unrelated_address = ExecuteCommandInstruction(
        AtomicDrainAddress(), 32);
    assert unrelated_start == CommandExecution_Executed &&
           unrelated_attributes == CommandExecution_Executed &&
           unrelated_source == CommandExecution_Executed &&
           unrelated_address == CommandExecution_Executed &&
           _BundleSharedBindings[[0]].pe_mask == '0100' &&
           !_BundleSharedBindings[[0]].source_reuse;
    let unrelated_domain = _BundleExecutionDomainToken;
    assert unrelated_domain != atomic_domain;
    let unrelated_captured = RequireBundleSharedSourcePayloads();
    let unrelated_ordinal =
        _BundleSharedBindings[[0]].source_lifetime_ordinal;
    assert unrelated_captured && unrelated_ordinal > 0 &&
           SharedSourceLifetimePinned(unrelated_shared_id) &&
           SharedSourceLifetimePinned(shared_id);
    EnterBundleExecutionDomainSquashEvent(unrelated_domain);
    assert FindBundleSourceLifetimeOrdinal(unrelated_ordinal) < 0 &&
           !SharedSourceLifetimePinned(unrelated_shared_id) &&
           SharedSourceLifetimePinned(shared_id);
    SelectExecutionContext(0, 0);
    assert AtomicTStoreOwnsSourceLifetime(0, invocation, 0,
               atomic_domain, atomic_lifetime_ordinal);

    // The exact execution domain that owns the now-irrevocable Atomic
    // request may itself be squashed. Its committed first element is kept,
    // and the captured lifetime stays pinned until the remaining element
    // drains under the original request identity.
    EnterBundleExecutionDomainSquashEvent(atomic_domain);
    let after_atomic_squash = _GMObligations[[0]][[0]][[0]];
    assert after_atomic_squash.active &&
           after_atomic_squash.captured_atomic_tstore &&
           after_atomic_squash.irrevocable &&
           after_atomic_squash.invocation == invocation &&
           after_atomic_squash.atomic_tstore_committed_count == 1 &&
           SharedSourceLifetimePinned(shared_id) &&
           AtomicTStoreOwnsSourceLifetime(0, invocation, 0,
               atomic_domain, atomic_lifetime_ordinal);

    let aborted = AbortKernelInvocation(0);
    assert aborted == KernelLifecycle_Waiting &&
           !_KernelInvocationActiveByCore[[0]] &&
           _KernelInvocationByCore[[0]] == 0 &&
           _RetiredKernelInvocationByCore[[0]] == invocation &&
           SharedSourceLifetimePinned(shared_id) &&
           !SharedSourceLifetimePinned(unrelated_shared_id) &&
           _BundleSourceLifetimes[[lifetime_slot]].completed_mask == Zeros{4};
    let blocked_launch = LaunchKernelInvocation(0, entry + 0x100);
    assert blocked_launch == KernelLifecycle_Waiting &&
           _KernelInvocationByCore[[0]] == 0;

    SetVerificationGMProgressBeatBudget(0);
    ProgressKernelGMObligationsForCore(0, invocation);
    let drained = _GMObligations[[0]][[0]][[0]];
    assert drained.state == GMObligation_Completed &&
           drained.invocation == invocation && drained.irrevocable &&
           drained.progress_element == 2 &&
           drained.atomic_tstore_committed_count == 2 &&
           drained.atomic_tstore_committed_elements[0] == '1' &&
           drained.atomic_tstore_committed_elements[1] == '1' &&
           !drained.atomic_tstore_finalization_pending;
    assert _MemoryEventCount == 2;
    let second_event = _MemoryEvents[[1 as MemoryEventIndex]];
    assert second_event.active && second_event.committed &&
           second_event.kind == MemoryEvent_Atomic &&
           second_event.core_identity == 0 && second_event.agent == 0 &&
           second_event.origin == MemoryEventOrigin_Kernel &&
           second_event.invocation == invocation &&
           second_event.program_order == before_service.submission_order &&
           second_event.address == Zeros{PTO_XLEN} + 0x504 &&
           second_event.read_value == Zeros{PTO_XLEN} + 20 &&
           second_event.write_value == Zeros{PTO_XLEN} + 22;
    assert !SharedSourceLifetimePinned(shared_id) &&
           !SharedSourceLifetimePinned(unrelated_shared_id) &&
           SharedTilePayloadIntact(shared_id) &&
           !_BundleSourceLifetimes[[lifetime_slot]].valid;
    StopMemoryEventCapture();
    let drained_first = LoadUnsigned(Zeros{PTO_XLEN} + 0x500, 4);
    let drained_second = LoadUnsigned(Zeros{PTO_XLEN} + 0x504, 4);
    assert drained_first == Zeros{PTO_XLEN} + 11 &&
           drained_second == Zeros{PTO_XLEN} + 22;
    let relaunched = LaunchKernelInvocation(0, entry + 0x100);
    assert relaunched == KernelLifecycle_Started &&
           _KernelInvocationByCore[[0]] != invocation;
    SetVerificationGMProgressBeatBudget(0);
    StopMemoryEventCapture();
    return 0;
end;
