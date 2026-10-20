// PTO-TEST: {"id":"PTO-AVS-ARCH-TSTORE-ATOMIC-COMPLETION-001","source":"asl/arch/state/kernel-lifecycle.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-ARCH-GM-OBLIGATIONS-001","PTO-B-CATR-CONTROL-001","PTO-ARCH-KERNEL-LIFECYCLE-001"],"kind":"state-transition","summary":"encoded Atomic TSTORE completion waits through zero and partial drain, then commits and traps once without replay","pass_condition":"the actual encoded BSTOP path returns Blocked with the bundle and continuation intact at zero and partial RMWs; the same obligation identity drains two active updates exactly once; final BSTOP clears the bundle and raises its post-commit trap at the continuation once, trap recovery does not replay effects; a Normal TSTORE control retains posted completion while service is deferred","related_sources":["asl/arch/memory-model/atomic-tstore-obligations.asl","asl/block/model/commit/validation.asl","asl/block/model/dispatch/commands.asl","asl/tile/model/memory/gm-obligation-progress.asl"]}

pure func AtomicCompletionStart(data_type: TileDataType) => bits(64)
begin
    var instruction = Zeros{64} + 0x00111181;
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

pure func AtomicCompletionDATR() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

pure func AtomicCompletionCATR(trap: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000023;
    instruction[19] = if trap then '1' else '0';
    return instruction;
end;

pure func AtomicCompletionSource(last_use: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[11:9] = '001';
    instruction[19] = '1';
    instruction[26] = if last_use then '1' else '0';
    return instruction;
end;

pure func AtomicCompletionAddress() => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func PrepareAtomicCompletion(entry: Word, data_type: TileDataType,
    base: Word, stride: Word, atomic: boolean, trap: boolean)
begin
    SelectExecutionContext(0, 0);
    WriteGPR(2, base);
    WriteGPR(3, stride);
    _PC = entry;
    _BPC = entry;
    let started = ExecuteCommandInstruction(
        AtomicCompletionStart(data_type), 32);
    var attributes: CommandExecutionStatus = CommandExecution_Executed;
    if atomic then
        attributes = ExecuteCommandInstruction(AtomicCompletionDATR(), 32);
    end;
    let control = ExecuteCommandInstruction(AtomicCompletionCATR(trap), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    let source = ExecuteCommandInstruction(
        AtomicCompletionSource(TRUE), 32);
    let address = ExecuteCommandInstruction(AtomicCompletionAddress(), 32);
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           control == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed;
end;

func TestAtomicCompletionWaitAndTrap()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0xb00;
    let launched = LaunchKernelInvocation(0, entry);
    assert launched == KernelLifecycle_Started;
    let invocation = _KernelInvocationByCore[[0]];
    SelectExecutionContext(0, 0);
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 2);
    MarkTileValidRegionDefined(0);
    let base = Zeros{PTO_XLEN} + 0x500;
    Store(base, 4, Zeros{PTO_XLEN} + 10);
    Store(base + 4, 4, Zeros{PTO_XLEN} + 20);
    PrepareAtomicCompletion(entry, TileDataType_U32, base,
        Zeros{PTO_XLEN} + 8, TRUE, TRUE);
    assert _BundleControlAttributes.trap_enabled &&
           BundleAtomicTStoreSelected() &&
           _BundleTileBindings[[0]].pe_mask == '1000';

    StartMemoryEventCapture(0);
    SetVerificationGMProgressDeferred(TRUE);
    let zero_beat_stop_pc = ReadTPC();
    let zero_beat_status = ExecutePTOInstruction(Zeros{64} + 1, 32);
    assert zero_beat_status == PTOInstruction_Blocked;
    assert _BundleActive;
    assert _LastFault == Fault_None;
    assert ReadTPC() == zero_beat_stop_pc && ReadBPC() == entry;
    assert _MemoryEventCount == 0;
    assert CurrentAtomicTStoreDrainPending();
    let slot = FindCurrentAtomicTStoreObligation();
    assert slot >= 0;
    let initial = _GMObligations[[0]][[0]][[slot as GMObligationIndex]];
    assert initial.state == GMObligation_Issued &&
           initial.atomic_tstore_target_count == 2 &&
           initial.atomic_tstore_committed_count == 0 &&
           initial.atomic_tstore_finalization_pending &&
           initial.invocation == invocation &&
           initial.instruction_pc == entry &&
           initial.execution_domain_token == _BundleExecutionDomainToken;
    let first_target = initial.atomic_tstore_translated_targets[[0]];
    let second_target = initial.atomic_tstore_translated_targets[[1]];
    assert first_target == base && second_target == base + 4;

    SetVerificationGMProgressDeferred(FALSE);
    SetVerificationGMProgressBeatBudget(1);
    ProgressKernelGMObligationsForCore(0, invocation);
    let partial = _GMObligations[[0]][[0]][[slot as GMObligationIndex]];
    assert partial.state == GMObligation_Issued && partial.irrevocable &&
           partial.atomic_tstore_committed_count == 1 &&
           partial.atomic_tstore_committed_elements[0] == '1' &&
           partial.atomic_tstore_committed_elements[1] == '0' &&
           partial.identity == initial.identity &&
           _MemoryEventCount == 1 && _BundleActive;
    let partial_stop_pc = ReadTPC();
    let partial_stop_status = ExecutePTOInstruction(Zeros{64} + 1, 32);
    assert partial_stop_status == PTOInstruction_Blocked &&
           _LastFault == Fault_None && _BundleActive &&
           ReadTPC() == partial_stop_pc &&
           CurrentAtomicTStoreDrainPending() && _MemoryEventCount == 1;
    let partial_retry = _GMObligations[[0]][[0]][[slot as GMObligationIndex]];
    assert partial_retry.identity == initial.identity &&
           partial_retry.atomic_tstore_committed_count == 1 &&
           partial_retry.progress_element == 1;

    SetVerificationGMProgressBeatBudget(0);
    ProgressKernelGMObligationsForCore(0, invocation);
    let drained = _GMObligations[[0]][[0]][[slot as GMObligationIndex]];
    assert drained.state == GMObligation_Completed &&
           drained.identity == initial.identity &&
           drained.atomic_tstore_committed_count == 2 &&
           drained.atomic_tstore_committed_elements[0] == '1' &&
           drained.atomic_tstore_committed_elements[1] == '1' &&
           !drained.atomic_tstore_finalization_pending &&
           !CurrentAtomicTStoreDrainPending() &&
           _BundleActive && _MemoryEventCount == 2;
    let event0 = _MemoryEvents[[0 as MemoryEventIndex]];
    let event1 = _MemoryEvents[[1 as MemoryEventIndex]];
    assert event0.kind == MemoryEvent_Atomic && event0.committed &&
           event0.core_identity == 0 && event0.agent == 0 &&
           event0.origin == MemoryEventOrigin_Kernel &&
           event0.invocation == invocation && event0.address == first_target &&
           event0.read_value == Zeros{PTO_XLEN} + 10 &&
           event0.write_value == Zeros{PTO_XLEN} + 11;
    assert event1.kind == MemoryEvent_Atomic && event1.committed &&
           event1.core_identity == 0 && event1.agent == 0 &&
           event1.origin == MemoryEventOrigin_Kernel &&
           event1.invocation == invocation && event1.address == second_target &&
           event1.read_value == Zeros{PTO_XLEN} + 20 &&
           event1.write_value == Zeros{PTO_XLEN} + 22;

    assert _BundleControlAttributes.trap_enabled;
    assert ReadBPC() == entry &&
           _BundleExecutionDomainToken == initial.execution_domain_token &&
           _CurrentKernelInvocation == invocation &&
           FindCurrentAtomicTStoreOccurrence() == slot;
    let continuation = ReadTPC() + (Zeros{PTO_XLEN} + 4);
    let final_status = ExecutePTOInstruction(Zeros{64} + 1, 32);
    assert final_status == PTOInstruction_Rejected;
    assert !_BundleActive && ReadTPC() == continuation;
    assert _LastFault == Fault_BundlePostCommit;
    assert _FaultAddress == continuation;
    assert !_BundleActive && ReadTPC() == continuation;
    assert _MemoryEventCount == 2;
    assert _GMObligations[[0]][[0]][[slot as GMObligationIndex]].identity ==
        initial.identity;
    let recovered = RecoverTrapContext(CurrentACR());
    assert recovered;
    assert _LastFault == Fault_BundlePostCommit;
    ClearFault();
    assert _LastFault == Fault_None;
    assert ReadTPC() == continuation && !_BundleActive;
    assert _MemoryEventCount == 2;
    let actual0 = LoadUnsigned(base, 4);
    let actual1 = LoadUnsigned(base + 4, 4);
    assert actual0 == Zeros{PTO_XLEN} + 11 &&
           actual1 == Zeros{PTO_XLEN} + 22;
    StopMemoryEventCapture();
    SetVerificationGMProgressBeatBudget(0);
end;

func TestNormalTStorePostedCommit()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0xc00;
    let launched = LaunchKernelInvocation(0, entry);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);
    MarkTileValidRegionDefined(0);
    let base = Zeros{PTO_XLEN} + 0x700;
    Store(base, 4, Zeros{PTO_XLEN} + 3);
    WriteGPR(2, base);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    _PC = entry;
    _BPC = entry;
    let started = ExecuteCommandInstruction(
        AtomicCompletionStart(TileDataType_U32), 32);
    let control = ExecuteCommandInstruction(AtomicCompletionCATR(TRUE), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let source = ExecuteCommandInstruction(AtomicCompletionSource(TRUE), 32);
    let address = ExecuteCommandInstruction(AtomicCompletionAddress(), 32);
    assert started == CommandExecution_Executed &&
           control == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed &&
           !BundleAtomicTStoreSelected();
    StartMemoryEventCapture(0);
    SetVerificationGMProgressDeferred(TRUE);
    let stop_pc = ReadTPC();
    let status = ExecutePTOInstruction(Zeros{64} + 1, 32);
    assert status == PTOInstruction_Rejected &&
           _LastFault == Fault_BundlePostCommit && !_BundleActive &&
           ReadTPC() == stop_pc + 4 && !CurrentAtomicTStoreDrainPending();
    let normal_obligation = _GMObligations[[0]][[0]][[0]];
    assert normal_obligation.active &&
           normal_obligation.request_class == GMRequest_Tile &&
           normal_obligation.invocation == _KernelInvocationByCore[[0]] &&
           normal_obligation.state == GMObligation_Validated &&
           _MemoryEventCount == 0;
    let recovered = RecoverTrapContext(CurrentACR());
    assert recovered && ReadTPC() == stop_pc + 4 && !_BundleActive &&
           _GMObligations[[0]][[0]][[0]].state == GMObligation_Validated &&
           _MemoryEventCount == 0;
    SetVerificationGMProgressDeferred(FALSE);
    SetVerificationGMProgressBeatBudget(0);
    ProgressKernelGMObligationsForCore(0, _KernelInvocationByCore[[0]]);
    let stored = LoadUnsigned(base, 4);
    assert _GMObligations[[0]][[0]][[0]].state == GMObligation_Completed &&
           stored == Zeros{PTO_XLEN} + 7;
    StopMemoryEventCapture();
    SetVerificationGMProgressBeatBudget(0);
end;

func main() => integer
begin
    TestAtomicCompletionWaitAndTrap();
    TestNormalTStorePostedCommit();
    return 0;
end;
