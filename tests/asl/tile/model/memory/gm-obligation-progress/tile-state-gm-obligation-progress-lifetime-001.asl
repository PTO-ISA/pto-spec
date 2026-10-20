// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSTORE-ATOMIC-LIFETIME-001","source":"asl/tile/model/memory/gm-obligation-progress.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001","PTO-B-IOS-SHARED-STATE-001"],"kind":"state-transition","summary":"a Shared last-use Atomic TSTORE pins its generation until all declared PEs finish","pass_condition":"PE0's successful event and completion leave the Shared generation pinned with only PE0 completed; PE1 then completes its own event and consumes the payload exactly once after the full declared participant cohort, while both targets and original event provenance are correct","related_sources":["asl/block/model/state/source-lifetime.asl","asl/block/model/operands/shared-generation.asl","asl/block/model/dispatch/tlsu-atomic-tstore.asl"]}

pure func AtomicLifetimeStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 25;
    return instruction;
end;

pure func AtomicLifetimeDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[31:29] = '000';
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

pure func AtomicLifetimeLastUse(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x04001013;
    instruction[25:20] = shared_id;
    instruction[11:9] = '101';
    return instruction;
end;

pure func AtomicLifetimeIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func PrepareAtomicLifetimePE(pe: MemoryAgentId, entry: Word, base: Word)
begin
    SelectExecutionContext(0, pe);
    ResetBundleControlState();
    _PC = entry;
    _BPC = entry;
    _CurrentProgramOrder = 7;
    _PEProgramOrder[[0]][[pe]] = 7;
    let start = ExecuteCommandInstruction(AtomicLifetimeStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let attributes = ExecuteCommandInstruction(AtomicLifetimeDATR(), 32);
    let source = ExecuteCommandInstruction(
        AtomicLifetimeLastUse(Zeros{6} + 31), 32);
    WriteGPR(2, base);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    let address = ExecuteCommandInstruction(AtomicLifetimeIOR(), 32);
    assert start == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed &&
           BundleAtomicTStoreSelected() &&
           BundleSharedBindingCount() == 1 &&
           !_BundleSharedBindings[[0]].source_reuse &&
           _BundleSharedBindings[[0]].pe_mask == '1100';
end;

func main() => integer
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0xb00;
    let launched = LaunchKernelInvocation(0, entry);
    assert launched == KernelLifecycle_Started;
    let invocation = _KernelInvocationByCore[[0]];
    SelectExecutionContext(0, 0);
    ConfigureTile(4, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 5);
    MarkTileValidRegionDefined(4);
    let shared_id = (Zeros{6} + 31) as SharedTileID;
    InstallSharedTile(shared_id, _Tiles[[4]], '1111');
    let source_before = SharedTileRecord(shared_id);
    Store(Zeros{PTO_XLEN} + 0x500, 4, Zeros{PTO_XLEN} + 10);
    Store(Zeros{PTO_XLEN} + 0x504, 4, Zeros{PTO_XLEN} + 20);
    StartMemoryEventCapture(0);

    PrepareAtomicLifetimePE(0 as MemoryAgentId, entry,
        Zeros{PTO_XLEN} + 0x500);
    SetVerificationGMProgressDeferred(TRUE);
    let pe0_admitted = ExecuteBundleTileOperation();
    assert pe0_admitted && _LastFault == Fault_None &&
           _MemoryEventCount == 0 && SharedSourceLifetimePinned(shared_id);
    var lifetime_slot: integer {-1..63} = -1;
    for slot = 0 to 63 do
        if _BundleSourceLifetimes[[slot]].valid &&
           _BundleSourceLifetimes[[slot]].shared &&
           _BundleSourceLifetimes[[slot]].invocation == invocation &&
           _BundleSourceLifetimes[[slot]].resource ==
               (UInt(shared_id) as TileIndex) then
            lifetime_slot = slot as integer {-1..63};
        end;
    end;
    assert lifetime_slot >= 0;
    let pe0_slot = FindCurrentAtomicTStoreObligation();
    assert pe0_slot >= 0;
    let pe0_pending = _GMObligations[[0]][[0]]
        [[pe0_slot as GMObligationIndex]];
    let before_pe0_service = _BundleSourceLifetimes[[lifetime_slot]];
    assert before_pe0_service.participant_mask == '1100' &&
           before_pe0_service.captured_mask == '1000' &&
           before_pe0_service.completed_mask == Zeros{4} &&
           pe0_pending.captured_atomic_tstore &&
           pe0_pending.atomic_tstore_finalization_pending &&
           SharedTilePayloadIntact(shared_id) &&
           SharedTileRecord(shared_id).payload_generation ==
               source_before.payload_generation;
    SetVerificationGMProgressDeferred(FALSE);
    SetVerificationGMProgressBeatBudget(0);
    ProgressKernelGMObligationsForCore(0, invocation);
    let after_pe0 = _BundleSourceLifetimes[[lifetime_slot]];
    let pe0_completed = _GMObligations[[0]][[0]]
        [[pe0_slot as GMObligationIndex]];
    assert pe0_completed.state == GMObligation_Completed &&
           pe0_completed.atomic_tstore_committed_count == 1 &&
           after_pe0.completed_mask == '1000' &&
           SharedSourceLifetimePinned(shared_id) &&
           _MemoryEventCount == 1;
    let first = _MemoryEvents[[0 as MemoryEventIndex]];
    assert first.kind == MemoryEvent_Atomic && first.committed &&
           first.agent == 0 && first.core_identity == 0 &&
           first.invocation == invocation &&
           first.program_order == pe0_pending.submission_order &&
           first.address == Zeros{PTO_XLEN} + 0x500 &&
           first.read_value == Zeros{PTO_XLEN} + 10 &&
           first.write_value == Zeros{PTO_XLEN} + 15;

    PrepareAtomicLifetimePE(1 as MemoryAgentId, entry,
        Zeros{PTO_XLEN} + 0x504);
    SetVerificationGMProgressDeferred(TRUE);
    let pe1_admitted = ExecuteBundleTileOperation();
    assert pe1_admitted && _LastFault == Fault_None &&
           _MemoryEventCount == 1 && SharedSourceLifetimePinned(shared_id);
    let pe1_slot = FindCurrentAtomicTStoreObligation();
    assert pe1_slot >= 0;
    let pe1_pending = _GMObligations[[0]][[1]]
        [[pe1_slot as GMObligationIndex]];
    assert pe1_pending.captured_atomic_tstore &&
           pe1_pending.atomic_tstore_finalization_pending;
    SetVerificationGMProgressDeferred(FALSE);
    SetVerificationGMProgressBeatBudget(0);
    ProgressKernelGMObligationsForCore(0, invocation);
    let pe1_completed = _GMObligations[[0]][[1]]
        [[pe1_slot as GMObligationIndex]];
    assert pe1_completed.state == GMObligation_Completed &&
           pe1_completed.atomic_tstore_committed_count == 1 &&
           _MemoryEventCount == 2;
    let second = _MemoryEvents[[1 as MemoryEventIndex]];
    assert second.kind == MemoryEvent_Atomic && second.committed &&
           second.agent == 1 && second.core_identity == 0 &&
           second.invocation == invocation &&
           second.program_order == pe1_pending.submission_order &&
           second.address == Zeros{PTO_XLEN} + 0x504 &&
           second.read_value == Zeros{PTO_XLEN} + 20 &&
           second.write_value == Zeros{PTO_XLEN} + 25;
    assert !SharedSourceLifetimePinned(shared_id) &&
           !_BundleSourceLifetimes[[lifetime_slot]].valid &&
           SharedTileRecord(shared_id).descriptor_valid &&
           !SharedTilePayloadIntact(shared_id) &&
           SharedTileRecord(shared_id).payload_generation ==
               source_before.payload_generation;
    StopMemoryEventCapture();
    let first_after = LoadUnsigned(Zeros{PTO_XLEN} + 0x500, 4);
    let second_after = LoadUnsigned(Zeros{PTO_XLEN} + 0x504, 4);
    assert first_after == Zeros{PTO_XLEN} + 15 &&
           second_after == Zeros{PTO_XLEN} + 25;
    return 0;
end;
