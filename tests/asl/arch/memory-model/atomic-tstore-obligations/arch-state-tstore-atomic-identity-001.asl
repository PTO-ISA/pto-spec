// PTO-TEST: {"id":"PTO-AVS-ARCH-TSTORE-ATOMIC-IDENTITY-001","source":"asl/arch/memory-model/atomic-tstore-obligations.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-ARCH-GM-OBLIGATIONS-001","PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001"],"kind":"state-transition","summary":"same dynamic Atomic TSTORE resumes without duplicates and a same-PC later occurrence is distinct","pass_condition":"one deferred occurrence at fixed core/PE/invocation/PC/program order commits once and retains source generation; a second identical encoded occurrence at the same PC with a new program order has a distinct obligation identity and commits exactly one additional Atomic update with original provenance","related_sources":["asl/arch/memory-model/gm-obligations.asl","asl/block/model/dispatch/tlsu-atomic-tstore.asl","asl/tile/model/memory/atomic-tstore.asl"]}

pure func AtomicIdentityStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 25;
    return instruction;
end;

pure func AtomicIdentityDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[31:29] = '000';
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

pure func AtomicIdentitySource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

pure func AtomicIdentityIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func PrepareAtomicIdentityOccurrence(entry: Word, program_order: integer)
begin
    SelectExecutionContext(0, 0);
    ResetBundleControlState();
    _PC = entry;
    _BPC = entry;
    _CurrentProgramOrder = program_order;
    _PEProgramOrder[[0]][[0]] = program_order;
    let start = ExecuteCommandInstruction(AtomicIdentityStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let attributes = ExecuteCommandInstruction(AtomicIdentityDATR(), 32);
    let source = ExecuteCommandInstruction(AtomicIdentitySource(), 32);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x300);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    let address = ExecuteCommandInstruction(AtomicIdentityIOR(), 32);
    assert start == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed &&
           BundleAtomicTStoreSelected() &&
           BundleTileBindingCount() == 1 &&
           _BundleTileBindings[[0]].last;
end;

func main() => integer
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0xc00;
    let launched = LaunchKernelInvocation(0, entry);
    assert launched == KernelLifecycle_Started;
    let invocation = _KernelInvocationByCore[[0]];
    SelectExecutionContext(0, 0);
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
    MarkTileValidRegionDefined(0);
    Store(Zeros{PTO_XLEN} + 0x300, 4, Zeros{PTO_XLEN});
    StartMemoryEventCapture(0);

    // Four command attempts (start, DATR, IOT, IOR) advance the selected PE's
    // order before TLSU admits the request.
    PrepareAtomicIdentityOccurrence(entry, 1);
    SetVerificationGMProgressDeferred(TRUE);
    let first_admitted = ExecuteBundleTileOperation();
    assert first_admitted && _MemoryEventCount == 0 &&
           _LastFault == Fault_None;
    let first_slot = FindCurrentAtomicTStoreObligation();
    assert first_slot >= 0;
    let first_pending = _GMObligations[[0]][[0]]
        [[first_slot as GMObligationIndex]];
    assert first_pending.captured_atomic_tstore;
    assert first_pending.instruction_pc == entry;
    assert first_pending.invocation == invocation;
    assert first_pending.agent == 0;
    assert first_pending.submission_order == 5;
    assert first_pending.source_generation == TileStoreSourceGeneration(0);
    // A repeat of the same dynamic identity resumes its captured request;
    // it cannot reinterpret live fields or issue a second atomic effect.
    let resumed = ExecuteBundleTileOperation();
    assert resumed && _MemoryEventCount == 0;
    SetVerificationGMProgressDeferred(FALSE);
    SetVerificationGMProgressBeatBudget(0);
    ProgressKernelGMObligationsForCore(0, invocation);
    let first_completed = _GMObligations[[0]][[0]]
        [[first_slot as GMObligationIndex]];
    assert first_completed.state == GMObligation_Completed &&
           first_completed.atomic_tstore_committed_count == 1 &&
           _MemoryEventCount == 1;
    let first_event = _MemoryEvents[[0 as MemoryEventIndex]];
    assert first_event.kind == MemoryEvent_Atomic && first_event.committed &&
           first_event.core_identity == 0 && first_event.agent == 0 &&
           first_event.invocation == invocation &&
           first_event.program_order == first_pending.submission_order &&
           first_event.address == Zeros{PTO_XLEN} + 0x300 &&
           first_event.read_value == Zeros{PTO_XLEN} &&
           first_event.write_value == Zeros{PTO_XLEN} + 2;

    // Same encoded request and PC, but a new dynamic program-order occurrence.
    PrepareAtomicIdentityOccurrence(entry, 2);
    SetVerificationGMProgressDeferred(TRUE);
    let second_admitted = ExecuteBundleTileOperation();
    assert second_admitted && _LastFault == Fault_None &&
           _MemoryEventCount == 1;
    let second_slot = FindCurrentAtomicTStoreObligation();
    assert second_slot >= 0;
    let second_pending = _GMObligations[[0]][[0]]
        [[second_slot as GMObligationIndex]];
    assert second_pending.captured_atomic_tstore &&
           second_pending.instruction_pc == first_pending.instruction_pc &&
           second_pending.invocation == first_pending.invocation &&
           second_pending.agent == first_pending.agent &&
           second_pending.submission_order == 6 &&
           second_pending.identity != first_pending.identity &&
           second_pending.source_generation == first_pending.source_generation;
    SetVerificationGMProgressDeferred(FALSE);
    ProgressKernelGMObligationsForCore(0, invocation);
    let second_completed = _GMObligations[[0]][[0]]
        [[second_slot as GMObligationIndex]];
    assert second_completed.state == GMObligation_Completed &&
           second_completed.atomic_tstore_committed_count == 1 &&
           _MemoryEventCount == 2;
    let second_event = _MemoryEvents[[1 as MemoryEventIndex]];
    assert second_event.kind == MemoryEvent_Atomic && second_event.committed &&
           second_event.core_identity == 0 && second_event.agent == 0 &&
           second_event.invocation == invocation &&
           second_event.program_order == second_pending.submission_order &&
           second_event.address == Zeros{PTO_XLEN} + 0x300 &&
           second_event.read_value == Zeros{PTO_XLEN} + 2 &&
           second_event.write_value == Zeros{PTO_XLEN} + 4;
    StopMemoryEventCapture();
    let actual = LoadUnsigned(Zeros{PTO_XLEN} + 0x300, 4);
    assert actual == Zeros{PTO_XLEN} + 4;
    SetVerificationGMProgressBeatBudget(0);
    return 0;
end;
