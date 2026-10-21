// PTO-TEST: {"id":"PTO-AVS-ARCH-TSTORE-ATOMIC-BSTART-PREDECESSOR-001","source":"asl/arch/state/kernel-lifecycle.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-ARCH-GM-OBLIGATIONS-001","PTO-ARCH-KERNEL-LIFECYCLE-001"],"kind":"state-transition","summary":"encoded BSTART predecessor commit waits through Atomic TSTORE drain and retries once","pass_condition":"the same encoded BSTART predecessor returns Blocked at zero and partial beats without changing the old bundle, BPC, fetched TPC, dynamic request identity, or committed count; after exact drain it executes once, installs a distinct new domain, and leaves exactly two original-provenance Atomic events","related_sources":["asl/arch/memory-model/atomic-tstore-obligations.asl","asl/block/model/dispatch/start.asl","asl/block/model/commit/validation.asl","asl/tile/model/memory/gm-obligation-progress.asl"]}

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

func main() => integer
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0xd00;
    let launched = LaunchKernelInvocation(0, entry);
    assert launched == KernelLifecycle_Started;
    let invocation = _KernelInvocationByCore[[0]];
    SelectExecutionContext(0, 0);
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 4);
    MarkTileValidRegionDefined(0);
    let base = Zeros{PTO_XLEN} + 0x900;
    Store(base, 4, Zeros{PTO_XLEN} + 30);
    Store(base + 4, 4, Zeros{PTO_XLEN} + 40);
    PrepareAtomicCompletion(entry, TileDataType_U32, base,
        Zeros{PTO_XLEN} + 8, TRUE, FALSE);
    let domain = _BundleExecutionDomainToken;
    StartMemoryEventCapture(0);
    SetVerificationGMProgressDeferred(TRUE);

    // BSTART is the actual predecessor-completion boundary. Waiting must
    // preserve its fetched PC and the old bundle through zero and partial
    // effects so the same encoded word can be retried after drain.
    let replacement = AtomicCompletionStart(TileDataType_U32);
    let start_pc = ReadTPC();
    let zero_wait = ExecuteCommandInstruction(replacement, 32);
    assert zero_wait == CommandExecution_Blocked && _LastFault == Fault_None &&
           _BundleActive && ReadTPC() == start_pc && ReadBPC() == entry &&
           _BundleExecutionDomainToken == domain && _MemoryEventCount == 0;
    let slot = FindCurrentAtomicTStoreObligation();
    assert slot >= 0;
    let original = _GMObligations[[0]][[0]][[slot as GMObligationIndex]];
    assert original.state == GMObligation_Issued &&
           original.atomic_tstore_committed_count == 0 &&
           original.invocation == invocation;

    SetVerificationGMProgressDeferred(FALSE);
    SetVerificationGMProgressBeatBudget(1);
    ProgressKernelGMObligationsForCore(0, invocation);
    let partial = _GMObligations[[0]][[0]][[slot as GMObligationIndex]];
    assert partial.state == GMObligation_Issued && partial.irrevocable &&
           partial.atomic_tstore_committed_count == 1 &&
           _MemoryEventCount == 1;
    let partial_wait = ExecuteCommandInstruction(replacement, 32);
    assert partial_wait == CommandExecution_Blocked &&
           _LastFault == Fault_None && _BundleActive &&
           ReadTPC() == start_pc && ReadBPC() == entry &&
           _BundleExecutionDomainToken == domain && _MemoryEventCount == 1;
    assert _GMObligations[[0]][[0]][[slot as GMObligationIndex]].identity ==
           original.identity &&
           _GMObligations[[0]][[0]][[slot as GMObligationIndex]]
               .atomic_tstore_committed_count == 1;

    SetVerificationGMProgressBeatBudget(0);
    ProgressKernelGMObligationsForCore(0, invocation);
    let drained = _GMObligations[[0]][[0]][[slot as GMObligationIndex]];
    assert drained.state == GMObligation_Completed &&
           drained.identity == original.identity &&
           drained.atomic_tstore_committed_count == 2 &&
           !drained.atomic_tstore_finalization_pending &&
           _MemoryEventCount == 2;
    let retried = ExecuteCommandInstruction(replacement, 32);
    assert retried == CommandExecution_Executed && _LastFault == Fault_None &&
           _BundleActive && ReadBPC() == start_pc &&
           _BundleExecutionDomainToken != domain &&
           !CurrentAtomicTStoreDrainPending() && _MemoryEventCount == 2;
    assert _GMObligations[[0]][[0]][[slot as GMObligationIndex]].identity ==
           original.identity &&
           _GMObligations[[0]][[0]][[slot as GMObligationIndex]].state ==
               GMObligation_Completed;
    let event0 = _MemoryEvents[[0 as MemoryEventIndex]];
    let event1 = _MemoryEvents[[1 as MemoryEventIndex]];
    assert event0.kind == MemoryEvent_Atomic && event0.committed &&
           event0.invocation == invocation && event0.address == base &&
           event0.read_value == Zeros{PTO_XLEN} + 30 &&
           event0.write_value == Zeros{PTO_XLEN} + 33;
    assert event1.kind == MemoryEvent_Atomic && event1.committed &&
           event1.invocation == invocation && event1.address == base + 4 &&
           event1.read_value == Zeros{PTO_XLEN} + 40 &&
           event1.write_value == Zeros{PTO_XLEN} + 44;
    StopMemoryEventCapture();
    SetVerificationGMProgressBeatBudget(0);
    return 0;
end;
