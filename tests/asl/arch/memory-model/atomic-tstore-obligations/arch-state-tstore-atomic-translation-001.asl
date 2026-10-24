// PTO-TEST: {"id":"PTO-AVS-ARCH-TSTORE-ATOMIC-TRANSLATION-001","source":"asl/arch/memory-model/atomic-tstore-obligations.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-ARCH-GM-OBLIGATIONS-001"],"kind":"state-transition","summary":"admitted Atomic TSTORE retains translated targets when the test mapping changes","pass_condition":"a deferred kernel request captures the mode-3 translated target, then a mode change and GM write before service leave that target immutable while the RMW reads the current old GM value and preserves invocation provenance","related_sources":["asl/scalar/model/agu/memory.asl","asl/block/model/dispatch/tlsu-atomic-tstore.asl"]}

pure func AtomicTranslationStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 25;
    return instruction;
end;

pure func AtomicTranslationDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[31:29] = '000';
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

pure func AtomicTranslationSource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

pure func AtomicTranslationIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    _Issue397TranslationMode = 0;
    let entry = Zeros{PTO_XLEN} + 0xa00;
    let launched = LaunchKernelInvocation(0, entry);
    assert launched == KernelLifecycle_Started;
    let invocation = _KernelInvocationByCore[[0]];
    SelectExecutionContext(0, 0);
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
    MarkTileValidRegionDefined(0);
    Store(Zeros{PTO_XLEN} + 0x300, 4, Zeros{PTO_XLEN} + 20);
    Store(Zeros{PTO_XLEN} + 0x600, 4, Zeros{PTO_XLEN} + 10);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x300);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    _PC = entry;
    _BPC = entry;
    _CurrentProgramOrder = 9;
    _PEProgramOrder[[0]][[0]] = 9;

    let start = ExecuteCommandInstruction(AtomicTranslationStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let attributes = ExecuteCommandInstruction(AtomicTranslationDATR(), 32);
    let source = ExecuteCommandInstruction(AtomicTranslationSource(), 32);
    let address = ExecuteCommandInstruction(AtomicTranslationIOR(), 32);
    assert start == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed &&
           BundleAtomicTStoreSelected();

    _Issue397TranslationMode = 3;
    StartMemoryEventCapture(0);
    SetVerificationGMProgressDeferred(TRUE);
    let admitted = ExecuteBundleTileOperation();
    assert admitted && _LastFault == Fault_None && _MemoryEventCount == 0;
    let slot = FindCurrentAtomicTStoreObligation();
    assert slot >= 0;
    let captured = _GMObligations[[0]][[0]]
        [[slot as GMObligationIndex]];
    assert captured.captured_atomic_tstore &&
           captured.invocation == invocation &&
           captured.atomic_tstore_target_count == 1 &&
           captured.atomic_tstore_translated_targets[[0]] ==
               Zeros{PTO_XLEN} + 0x600 &&
           TileReadLogicalElement(captured.source_snapshot, 0) ==
               Zeros{PTO_XLEN} + 2;

    // Drop the mapping and change the old GM value after admission. The
    // captured physical target survives; the RMW still samples current GM.
    StopMemoryEventCapture();
    _Issue397TranslationMode = 0;
    Store(Zeros{PTO_XLEN} + 0x600, 4, Zeros{PTO_XLEN} + 100);
    StartMemoryEventCapture(0);
    SetVerificationGMProgressDeferred(FALSE);
    SetVerificationGMProgressBeatBudget(0);
    ProgressKernelGMObligationsForCore(0, invocation);
    let completed = _GMObligations[[0]][[0]]
        [[slot as GMObligationIndex]];
    assert completed.state == GMObligation_Completed;
    assert completed.atomic_tstore_committed_count == 1;
    assert _MemoryEventCount == 1;
    let event = _MemoryEvents[[0 as MemoryEventIndex]];
    assert event.kind == MemoryEvent_Atomic && event.committed;
    assert event.address == Zeros{PTO_XLEN} + 0x600;
    assert event.read_value == Zeros{PTO_XLEN} + 100;
    assert event.write_value == Zeros{PTO_XLEN} + 102;
    assert event.invocation == invocation &&
           event.program_order == captured.submission_order;
    let physical_after = LoadUnsigned(Zeros{PTO_XLEN} + 0x600, 4);
    let virtual_after = LoadUnsigned(Zeros{PTO_XLEN} + 0x300, 4);
    assert physical_after == Zeros{PTO_XLEN} + 102 &&
           virtual_after == Zeros{PTO_XLEN} + 20;
    SetVerificationGMProgressBeatBudget(0);
    StopMemoryEventCapture();
    return 0;
end;
