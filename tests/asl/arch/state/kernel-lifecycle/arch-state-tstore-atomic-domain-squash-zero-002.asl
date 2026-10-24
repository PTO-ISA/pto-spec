// PTO-TEST: {"id":"PTO-AVS-ARCH-TSTORE-ATOMIC-DOMAIN-SQUASH-ZERO-002","source":"asl/arch/state/kernel-lifecycle.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-ARCH-GM-OBLIGATIONS-001","PTO-ARCH-KERNEL-LIFECYCLE-001","PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001","PTO-B-ASSEMBLE-SPECULATION-001"],"kind":"state-transition","summary":"a zero-effect Atomic TSTORE becomes terminal on exact-domain squash and a later same-site occurrence skips its abandoned cohort position","pass_condition":"an encoded Local last-use Function 1 request is admitted with service deferred, exact-domain squash terminally cancels its reversible obligation and leaves its source live but unpinned; stale-domain re-entry emits no effect; encoded BSTOP and a same-PC BSTART reached through control flow produce a distinct obligation and source-lifetime ordinal, which drains once without reviving the cancelled request; abort after squash releases only the incomplete fresh cohort pin, leaves the cancelled dynamic request terminal, and adds no memory effect","related_sources":["asl/arch/memory-model/atomic-tstore-obligations.asl","asl/arch/state/kernel-lifecycle.asl","asl/tile/model/memory/atomic-tstore.asl","asl/block/model/state/atomic-tstore-source-lifetime.asl","asl/block/model/operands/local-generation-squash.asl"]}

pure func CancelAtomicStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func CancelAtomicDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

pure func CancelAtomicSource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[26] = '1';
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

pure func CancelAtomicAddress() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0xa80;
    let launched = LaunchKernelInvocation(0, entry);
    assert launched == KernelLifecycle_Started;
    let invocation = _KernelInvocationByCore[[0]];
    SelectExecutionContext(0, 0);
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor);
    assert TileDescriptorLegal(0);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 9);
    MarkTileValidRegionDefined(0);
    let base = Zeros{PTO_XLEN} + 0x700;
    Store(base - 4, 4, Zeros{PTO_XLEN} + 0x55);
    Store(base, 4, Zeros{PTO_XLEN} + 5);
    Store(base + 4, 4, Zeros{PTO_XLEN} + 0x66);
    WriteGPR(2, base);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    _PC = entry;
    _BPC = entry;
    _CurrentProgramOrder = 5;
    _PEProgramOrder[[0]][[0]] = 5;

    let start = ExecutePTOInstruction(CancelAtomicStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let attributes = ExecuteCommandInstruction(CancelAtomicDATR(), 32);
    let source = ExecuteCommandInstruction(CancelAtomicSource(), 32);
    let address = ExecuteCommandInstruction(CancelAtomicAddress(), 32);
    assert start == PTOInstruction_Executed &&
           attributes == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed &&
           BundleAtomicTStoreSelected() &&
           _BundleTileBindings[[0]].source0_valid &&
           _BundleTileBindings[[0]].last;

    SetVerificationGMProgressDeferred(TRUE);
    StartMemoryEventCapture(0);
    let admitted = ExecuteBundleTileOperation();
    assert admitted && _LastFault == Fault_None && _MemoryEventCount == 0;
    let slot = FindCurrentAtomicTStoreObligation();
    assert slot >= 0;
    let pending = _GMObligations[[0]][[0]][[slot as GMObligationIndex]];
    assert pending.active && pending.captured_atomic_tstore &&
           pending.state == GMObligation_Issued &&
           pending.invocation == invocation && !pending.irrevocable &&
           pending.atomic_tstore_target_count == 1 &&
           pending.atomic_tstore_committed_count == 0 &&
           pending.atomic_tstore_source_lifetime_ordinal != 0;
    let ordinal = pending.atomic_tstore_source_lifetime_ordinal;
    var lifetime_slot: integer {-1..63} = -1;
    for index = 0 to 63 do
        if _BundleSourceLifetimes[[index]].valid &&
           _BundleSourceLifetimes[[index]].ordinal == ordinal then
            lifetime_slot = index as integer {-1..63};
        end;
    end;
    assert lifetime_slot >= 0 &&
           _BundleSourceLifetimes[[lifetime_slot]].captured_mask == '1000' &&
           _BundleSourceLifetimes[[lifetime_slot]].completed_mask == Zeros{4};
    let domain = pending.execution_domain_token;
    let source_epoch = pending.atomic_tstore_source_payload_epoch;
    let mask_bit = PTOPEMaskBitOfPEIdentity(0);
    assert LocalSourceLifetimePinned(0, 0) &&
           TilePayloadIntactForMask(0, '1000');

    EnterBundleExecutionDomainSquashEvent(domain);
    let after_squash = _GMObligations[[0]][[0]][[slot as GMObligationIndex]];
    let abandoned = FindBundleSourceLifetimeOrdinal(ordinal);
    assert after_squash.state == GMObligation_Cancelled;
    assert after_squash.active &&
           after_squash.captured_atomic_tstore &&
           after_squash.execution_domain_token == domain &&
           after_squash.atomic_tstore_committed_count == 0 &&
           !after_squash.atomic_tstore_finalization_pending;
    assert abandoned >= 0;
    assert _BundleSourceLifetimes[[abandoned]].captured_mask[mask_bit] == '0';
    assert _BundleSourceLifetimes[[abandoned]].retry_only_mask[mask_bit] == '1';
    assert _BundleSourceLifetimes[[abandoned]].completed_mask[mask_bit] == '0';
    assert !LocalSourceLifetimePinned(0, 0);
    assert LocalTilePayloadGeneration(0, 0) == source_epoch;
    assert TilePayloadIntactForMask(0, '1000');
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    let squashed_target = LoadUnsigned(base, 4);
    assert squashed_target == Zeros{PTO_XLEN} + 5;
    StartMemoryEventCapture(0);

    // Retrying the stale exact dynamic identity is a no-op: the Cancelled
    // tombstone prevents scheduler service and cannot reacquire its cohort.
    assert _BundleExecutionDomainToken == domain &&
           _CurrentKernelInvocation == invocation &&
           ReadBPC() == pending.instruction_pc &&
           FindCurrentAtomicTStoreOccurrence() == slot &&
           BundleAtomicTStoreSelected();
    let stale_reentry = ExecuteBundleTileOperation();
    let after_stale = _GMObligations[[0]][[0]][[slot as GMObligationIndex]];
    assert stale_reentry && _LastFault == Fault_None;
    assert after_stale.state == GMObligation_Cancelled &&
           after_stale.atomic_tstore_committed_count == 0;
    assert FindCurrentAtomicTStoreObligation() < 0;
    assert FindBundleSourceLifetimeOrdinal(ordinal) == abandoned;
    assert _BundleSourceLifetimes[[abandoned]].retry_only_mask[mask_bit] == '1';
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    let stale_target = LoadUnsigned(base, 4);
    assert stale_target == Zeros{PTO_XLEN} + 5;
    StartMemoryEventCapture(0);

    let stopped = ExecutePTOInstruction(Zeros{64} + 1, 32);
    assert stopped == PTOInstruction_Executed && !_BundleActive &&
           ReadBPC() == Zeros{PTO_XLEN} && _MemoryEventCount == 0;
    WriteTPC(entry);
    let second_start = ExecutePTOInstruction(CancelAtomicStart(), 32);
    assert second_start == PTOInstruction_Executed &&
           _BundleExecutionDomainToken != domain &&
           _CurrentKernelInvocation == invocation;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let second_attributes = ExecuteCommandInstruction(CancelAtomicDATR(), 32);
    let second_source = ExecuteCommandInstruction(CancelAtomicSource(), 32);
    let second_address = ExecuteCommandInstruction(CancelAtomicAddress(), 32);
    assert second_attributes == CommandExecution_Executed &&
           second_source == CommandExecution_Executed &&
           second_address == CommandExecution_Executed &&
           BundleAtomicTStoreSelected();
    let second_domain = _BundleExecutionDomainToken;
    SetVerificationGMProgressDeferred(TRUE);
    let second_admitted = ExecuteBundleTileOperation();
    assert second_admitted && _LastFault == Fault_None &&
           _MemoryEventCount == 0;
    let second_slot = FindCurrentAtomicTStoreObligation();
    assert second_slot >= 0;
    let second_pending = _GMObligations[[0]][[0]]
        [[second_slot as GMObligationIndex]];
    let second_ordinal = second_pending.atomic_tstore_source_lifetime_ordinal;
    assert second_pending.state == GMObligation_Issued &&
           second_pending.execution_domain_token == second_domain &&
           second_pending.invocation == invocation &&
           second_pending.identity != pending.identity &&
           second_pending.instruction_pc == pending.instruction_pc &&
           second_pending.atomic_tstore_committed_count == 0 &&
           second_ordinal > ordinal && second_ordinal != ordinal &&
           FindBundleSourceLifetimeOrdinal(ordinal) == abandoned &&
           FindBundleSourceLifetimeOrdinal(second_ordinal) >= 0 &&
           _BundleSourceLifetimes[[abandoned]].retry_only_mask[mask_bit] == '1' &&
           _MemoryEventCount == 0;

    SetVerificationGMProgressDeferred(FALSE);
    ProgressKernelGMObligationsForCore(0, invocation);
    let second_completed = _GMObligations[[0]][[0]]
        [[second_slot as GMObligationIndex]];
    assert after_squash.state == GMObligation_Cancelled &&
           after_squash.atomic_tstore_committed_count == 0 &&
           second_completed.state == GMObligation_Completed &&
           second_completed.identity != pending.identity &&
           second_completed.atomic_tstore_committed_count == 1 &&
           _MemoryEventCount == 1;
    let event = _MemoryEvents[[0 as MemoryEventIndex]];
    StopMemoryEventCapture();
    let final_target = LoadUnsigned(base, 4);
    let final_before_guard = LoadUnsigned(base - 4, 4);
    let final_after_guard = LoadUnsigned(base + 4, 4);
    assert event.kind == MemoryEvent_Atomic && event.agent == 0 &&
           event.invocation == invocation && event.address == base;
    assert event.read_value == Zeros{PTO_XLEN} + 5 &&
           event.write_value == Zeros{PTO_XLEN} + 14 &&
           final_target == Zeros{PTO_XLEN} + 14;
    assert final_before_guard == Zeros{PTO_XLEN} + 0x55 &&
           final_after_guard == Zeros{PTO_XLEN} + 0x66;
    let fresh_lifetime = FindBundleSourceLifetimeOrdinal(second_ordinal);
    assert fresh_lifetime >= 0 &&
           _BundleSourceLifetimes[[fresh_lifetime]].captured_mask == '1000' &&
           _BundleSourceLifetimes[[fresh_lifetime]].completed_mask == '1000' &&
           _BundleSourceLifetimes[[fresh_lifetime]].participant_mask == '1111';
    assert LocalSourceLifetimePinned(0, 0) &&
           TilePayloadIntactForMask(0, '1000');
    assert _BundleSourceLifetimes[[abandoned]].retry_only_mask[mask_bit] == '1';
    StopMemoryEventCapture();
    let aborted_after_squash = AbortKernelInvocation(0);
    assert aborted_after_squash == KernelLifecycle_Started &&
           !_KernelInvocationActiveByCore[[0]] &&
           _RetiredKernelInvocationByCore[[0]] == invocation &&
           after_squash.state == GMObligation_Cancelled &&
           after_squash.atomic_tstore_committed_count == 0 &&
           second_completed.state == GMObligation_Completed &&
           second_completed.atomic_tstore_committed_count == 1 &&
           FindBundleSourceLifetimeOrdinal(second_ordinal) < 0 &&
           _MemoryEventCount == 1;
    return 0;
end;
