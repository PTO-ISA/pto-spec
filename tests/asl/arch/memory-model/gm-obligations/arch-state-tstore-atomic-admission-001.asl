// PTO-TEST: {"id":"PTO-AVS-ARCH-TSTORE-ATOMIC-ADMISSION-001","source":"asl/arch/memory-model/gm-obligations.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-ARCH-GM-OBLIGATIONS-001"],"kind":"state-transition","summary":"Atomic TSTORE admission freezes its per-PE values, mode, active set and targets while each RMW reads current GM","pass_condition":"after one encoded TLSU Function 1 request is admitted with no effects, live mode/source/GPR/mask changes and later GM writes leave its captured ADD, active coordinates, values, original targets and invocation provenance intact; a separate unadmitted source-definedness fault recovers and retries the same dynamic request exactly once","related_sources":["asl/arch/memory-model/atomic-tstore-obligations.asl","asl/block/model/dispatch/tlsu-atomic-tstore.asl","asl/tile/model/memory/atomic-tstore.asl","asl/block/model/dispatch/gm-obligation-dispatch.asl"]}
pure func AtomicAdmissionStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 25;
    return instruction;
end;

pure func AtomicAdmissionDATR(mode: bits(3), layout: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[31:29] = mode;
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = layout;
    return instruction;
end;

pure func AtomicAdmissionSource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

pure func AtomicAdmissionIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func PrepareAtomicAdmission(base: Word, layout: bits(5))
begin
    let start = ExecuteCommandInstruction(AtomicAdmissionStart(), 32);
    let attributes = ExecuteCommandInstruction(
        AtomicAdmissionDATR('000', layout), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    if layout == Zeros{5} then
        SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    end;
    let source = ExecuteCommandInstruction(AtomicAdmissionSource(), 32);
    WriteGPR(2, base);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    let address = ExecuteCommandInstruction(AtomicAdmissionIOR(), 32);
    assert start == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed;
    assert BundleAtomicTStoreSelected() &&
           BundleTileBindingCount() == 1 &&
           _BundleTileBindings[[0]].source0_valid &&
           _BundleTileBindings[[0]].last;
end;

func TestImmutableAtomicAdmission()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x700;
    let launched = LaunchKernelInvocation(0, entry);
    assert launched == KernelLifecycle_Started;
    let invocation = _KernelInvocationByCore[[0]];
    SelectExecutionContext(0, 0);
    let cube_ready = ConfigureCubeTileForMaskWithPhysical(0, 128,
        16, 2, 1, 2, TileDataType_U32, TileLayout_CUBE_M16, '1111');
    assert cube_ready;
    InstallRelativeTileFixture(0, 0);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 2);
    MarkTileValidRegionDefined(0);
    Store(Zeros{PTO_XLEN} + 0x500, 4, Zeros{PTO_XLEN} + 10);
    Store(Zeros{PTO_XLEN} + 0x504, 4, Zeros{PTO_XLEN} + 20);
    Store(Zeros{PTO_XLEN} + 0x600, 4, Zeros{PTO_XLEN} + 30);
    Store(Zeros{PTO_XLEN} + 0x614, 4, Zeros{PTO_XLEN} + 40);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x500);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    _PC = entry;
    _BPC = entry;
    _CurrentProgramOrder = 8;
    _PEProgramOrder[[0]][[0]] = 8;
    PrepareAtomicAdmission(Zeros{PTO_XLEN} + 0x500, Zeros{5} + 25);

    StartMemoryEventCapture(0);
    SetVerificationGMProgressDeferred(TRUE);
    let admitted = ExecuteBundleTileOperation();
    assert admitted && _LastFault == Fault_None && _MemoryEventCount == 0;
    let slot = FindCurrentAtomicTStoreObligation();
    assert slot >= 0;
    let captured = _GMObligations[[0]][[0]][[slot as GMObligationIndex]];
    assert captured.active && captured.captured_atomic_tstore &&
           captured.atomic_tstore_target_count == 2 &&
           captured.atomic_tstore_committed_count == 0 &&
           captured.atomic_tstore_finalization_pending;
    assert captured.atomic_tstore_data_attributes.comparison_mode == '000' &&
           captured.base_address == Zeros{PTO_XLEN} + 0x500 &&
           captured.row_stride_bytes == Zeros{PTO_XLEN} + 4 &&
           captured.invocation == invocation &&
           captured.instruction_pc == ReadBPC();
    assert captured.atomic_tstore_translated_targets[[0]] ==
               Zeros{PTO_XLEN} + 0x500 &&
           captured.atomic_tstore_translated_targets[[1]] ==
               Zeros{PTO_XLEN} + 0x504 &&
           captured.atomic_tstore_active_elements[0] == '1' &&
           captured.atomic_tstore_active_elements[1] == '1';
    assert TileReadLogicalElement(captured.source_snapshot, 0) ==
               Zeros{PTO_XLEN} + 1 &&
           TileReadLogicalElement(captured.source_snapshot, 1) ==
               Zeros{PTO_XLEN} + 2;
    assert _MemoryEventCount == 0;

    // Mutate the live request after admission.  The scheduler must use the
    // captured ADD/source/targets/active set, while observing GM's newer old
    // values only when each RMW actually executes.
    _BundleDataAttributes.comparison_mode = '101';
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 9);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 8);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x600);
    WriteGPR(3, Zeros{PTO_XLEN} + 20);
    CaptureBundleExecutionMaskGPR(Zeros{PTO_XLEN}, Zeros{PTO_XLEN}, 1,
        TileLayout_CUBE_M16, 1, 2);
    assert _BundleExecutionMask.valid &&
           !BundleExecutionMaskActiveAt(TileLayout_CUBE_M16, 0, 0) &&
           !BundleExecutionMaskActiveAt(TileLayout_CUBE_M16, 0, 1);
    StopMemoryEventCapture();
    Store(Zeros{PTO_XLEN} + 0x500, 4, Zeros{PTO_XLEN} + 100);
    Store(Zeros{PTO_XLEN} + 0x504, 4, Zeros{PTO_XLEN} + 200);
    StartMemoryEventCapture(0);
    SetVerificationGMProgressDeferred(FALSE);
    SetVerificationGMProgressBeatBudget(0);
    ProgressKernelGMObligationsForCore(0, invocation);

    let completed = _GMObligations[[0]][[0]][[slot as GMObligationIndex]];
    assert completed.state == GMObligation_Completed &&
           completed.atomic_tstore_committed_count == 2 &&
           completed.atomic_tstore_committed_elements[0] == '1' &&
           completed.atomic_tstore_committed_elements[1] == '1';
    assert _MemoryEventCount == 2;
    let first = _MemoryEvents[[0]];
    let second = _MemoryEvents[[1]];
    assert first.kind == MemoryEvent_Atomic && first.committed &&
           first.core_identity == 0 && first.agent == 0 &&
           first.origin == MemoryEventOrigin_Kernel &&
           first.invocation == invocation &&
           first.program_order == captured.submission_order &&
           first.address == Zeros{PTO_XLEN} + 0x500 &&
           first.read_value == Zeros{PTO_XLEN} + 100 &&
           first.write_value == Zeros{PTO_XLEN} + 101;
    assert second.kind == MemoryEvent_Atomic && second.committed &&
           second.core_identity == 0 && second.agent == 0 &&
           second.origin == MemoryEventOrigin_Kernel &&
           second.invocation == invocation &&
           second.program_order == captured.submission_order &&
           second.address == Zeros{PTO_XLEN} + 0x504 &&
           second.read_value == Zeros{PTO_XLEN} + 200 &&
           second.write_value == Zeros{PTO_XLEN} + 202;
    assert _Memory[[0x600]] == Zeros{8} + 30 &&
           _Memory[[0x614]] == Zeros{8} + 40;
    StopMemoryEventCapture();
end;

func TestAtomicFailedPreflightRetry()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x900;
    let launched = LaunchKernelInvocation(0, entry);
    assert launched == KernelLifecycle_Started;
    let invocation = _KernelInvocationByCore[[0]];
    SelectExecutionContext(0, 0);
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor);
    Store(Zeros{PTO_XLEN} + 0x300, 4, Zeros{PTO_XLEN} + 5);
    Store(Zeros{PTO_XLEN} + 0x304, 4, Zeros{PTO_XLEN} + 6);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x300);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    _PC = entry;
    _BPC = entry;
    _CurrentProgramOrder = 12;
    _PEProgramOrder[[0]][[0]] = 12;
    PrepareAtomicAdmission(Zeros{PTO_XLEN} + 0x300, Zeros{5});
    StartMemoryEventCapture(0);
    let rejected = ExecuteBundleTileOperation();
    assert !rejected && _LastFault == Fault_TileLegality &&
           _FaultAddress == ReadTPC() && _MemoryEventCount == 0;
    let pending_slot = FindCurrentAtomicTStoreObligation();
    assert pending_slot >= 0;
    let pending = _GMObligations[[0]][[0]]
        [[pending_slot as GMObligationIndex]];
    assert !pending.captured_atomic_tstore &&
           pending.atomic_tstore_target_count == 0 &&
           pending.atomic_tstore_committed_count == 0 &&
           !pending.atomic_tstore_finalization_pending;
    var any_lifetime_completion = FALSE;
    for lifetime = 0 to 63 do
        if _BundleSourceLifetimes[[lifetime]].valid &&
           _BundleSourceLifetimes[[lifetime]].core == 0 &&
           _BundleSourceLifetimes[[lifetime]].invocation == invocation then
            if _BundleSourceLifetimes[[lifetime]].completed_mask != Zeros{4} then
                any_lifetime_completion = TRUE;
            end;
        end;
    end;
    assert !any_lifetime_completion;
    StopMemoryEventCapture();
    let initial_first = LoadUnsigned(Zeros{PTO_XLEN} + 0x300, 4);
    let initial_second = LoadUnsigned(Zeros{PTO_XLEN} + 0x304, 4);
    assert initial_first == Zeros{PTO_XLEN} + 5 &&
           initial_second == Zeros{PTO_XLEN} + 6;

    ClearFault();
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 8);
    MarkTileValidRegionDefined(0);
    assert TileElementwiseSourceContentsDefined(0) &&
           TileElementwiseSourceEncodingsValidAs(0, TileDataType_U32);
    StartMemoryEventCapture(0);
    let retried = ExecuteBundleTileOperation();
    assert _LastFault == Fault_None;
    assert retried;
    assert _MemoryEventCount == 2;
    let event = _MemoryEvents[[0]];
    assert event.kind == MemoryEvent_Atomic && event.address ==
               Zeros{PTO_XLEN} + 0x300 &&
           event.read_value == Zeros{PTO_XLEN} + 5 &&
           event.write_value == Zeros{PTO_XLEN} + 12 &&
           event.invocation == invocation && event.committed;
    let second_event = _MemoryEvents[[1]];
    assert second_event.kind == MemoryEvent_Atomic &&
           second_event.address == Zeros{PTO_XLEN} + 0x304 &&
           second_event.read_value == Zeros{PTO_XLEN} + 6 &&
           second_event.write_value == Zeros{PTO_XLEN} + 14 &&
           second_event.invocation == invocation && second_event.committed;
    StopMemoryEventCapture();
    let recovered_first = LoadUnsigned(Zeros{PTO_XLEN} + 0x300, 4);
    let recovered_second = LoadUnsigned(Zeros{PTO_XLEN} + 0x304, 4);
    assert recovered_first == Zeros{PTO_XLEN} + 12 &&
           recovered_second == Zeros{PTO_XLEN} + 14;
end;

func main() => integer
begin
    TestImmutableAtomicAdmission();
    TestAtomicFailedPreflightRetry();
    return 0;
end;
