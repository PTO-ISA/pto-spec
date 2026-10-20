// PTO-TEST: {"id":"PTO-AVS-ARCH-TSTORE-ATOMIC-IDENTITY-001","source":"asl/arch/memory-model/atomic-tstore-obligations.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-ARCH-GM-OBLIGATIONS-001","PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001"],"kind":"state-transition","summary":"same dynamic Atomic TSTORE resumes without duplicates and a same-PC later occurrence is distinct","pass_condition":"one deferred occurrence at fixed core/PE/invocation/PC/program order commits once; an actual encoded BSTOP retires it, then a real same-PC BSTART reached through control flow receives a distinct domain/obligation identity and later order while capturing the newly published Local payload epoch; each request commits exactly one Atomic update with original provenance and final BSTOP does not replay","related_sources":["asl/arch/memory-model/gm-obligations.asl","asl/block/model/dispatch/tlsu-atomic-tstore.asl","asl/tile/model/memory/atomic-tstore.asl"]}

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

func PrepareAtomicIdentityOccurrence(
    entry: Word, initial_program_order: integer,
    reset_control_state: boolean)
begin
    SelectExecutionContext(0, 0);
    if reset_control_state then
        ResetBundleControlState();
        _CurrentProgramOrder = initial_program_order;
        _PEProgramOrder[[0]][[0]] = initial_program_order;
    end;
    // The second dynamic occurrence reaches the same static BSTART through
    // ordinary control flow after the first block has committed. Keep its
    // execution-domain allocator and all lifetime state intact.
    WriteTPC(entry);
    let start = ExecutePTOInstruction(AtomicIdentityStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let attributes = ExecuteCommandInstruction(AtomicIdentityDATR(), 32);
    let source = ExecuteCommandInstruction(AtomicIdentitySource(), 32);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x300);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    let address = ExecuteCommandInstruction(AtomicIdentityIOR(), 32);
    assert start == PTOInstruction_Executed &&
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
    PrepareAtomicIdentityOccurrence(entry, 1, TRUE);
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
    let first_domain = first_pending.execution_domain_token;
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

    // Retire the first bundle through encoded BSTOP. Re-publish the Local
    // payload through the production allocator, then reach the same static
    // BSTART through control flow.
    let first_stop = ExecutePTOInstruction(Zeros{64} + 1, 32);
    assert first_stop == PTOInstruction_Executed && !_BundleActive &&
           ReadBPC() == Zeros{PTO_XLEN} && _MemoryEventCount == 1;
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 3);
    MarkTileValidRegionDefined(0);

    // Same encoded request and PC, but a new BSTART/domain/program-order
    // occurrence; no lifecycle allocator or source state is reset.
    PrepareAtomicIdentityOccurrence(entry, 0, FALSE);
    assert _BundleExecutionDomainToken != first_domain &&
           ReadBPC() == entry && _CurrentProgramOrder == 10 &&
           _CurrentKernelInvocation == invocation;
    SetVerificationGMProgressDeferred(TRUE);
    let second_admitted = ExecuteBundleTileOperation();
    assert second_admitted && _LastFault == Fault_None &&
           _MemoryEventCount == 1;
    let second_slot = FindCurrentAtomicTStoreObligation();
    assert second_slot >= 0;
    let second_pending = _GMObligations[[0]][[0]]
        [[second_slot as GMObligationIndex]];
    assert second_pending.captured_atomic_tstore;
    assert second_pending.instruction_pc == first_pending.instruction_pc;
    assert second_pending.invocation == first_pending.invocation;
    assert second_pending.agent == first_pending.agent;
    assert second_pending.submission_order == 10;
    assert second_pending.identity != first_pending.identity;
    assert second_pending.source_generation == first_pending.source_generation;
    assert second_pending.atomic_tstore_source_payload_epoch !=
           first_pending.atomic_tstore_source_payload_epoch;
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
           second_event.write_value == Zeros{PTO_XLEN} + 5;
    let second_stop = ExecutePTOInstruction(Zeros{64} + 1, 32);
    assert second_stop == PTOInstruction_Executed && !_BundleActive &&
           _MemoryEventCount == 2;
    StopMemoryEventCapture();
    let actual = LoadUnsigned(Zeros{PTO_XLEN} + 0x300, 4);
    assert actual == Zeros{PTO_XLEN} + 5;
    SetVerificationGMProgressBeatBudget(0);
    return 0;
end;
