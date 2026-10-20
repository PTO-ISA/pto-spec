// PTO-TEST: {"id":"PTO-AVS-TILE-TSTORE-ATOMIC-TRANSLATION-001","source":"asl/tile/model/memory/atomic-tstore.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-ATOM-RED-FAULTS-001","PTO-ARCH-GM-OBLIGATIONS-001"],"kind":"fault","summary":"Atomic TSTORE rejects a read/write translation disagreement without effects and retries the same unadmitted dynamic request after mapping recovery","pass_condition":"a known-good identity control commits one Atomic update; a valid selected request with read and write translations disagreeing faults before effects; then the kernel retry restores the captured trap context and retries the same bundle word, execution domain, program order, invocation, and PC after identity mapping recovery, captures the recovered target, drains once, and preserves all unrelated physical sentinels","related_sources":["asl/scalar/model/agu/memory.asl","asl/block/model/dispatch/tlsu-atomic-tstore.asl","asl/arch/memory-model/atomic-tstore-obligations.asl"]}

pure func TranslationFaultStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 25;
    return instruction;
end;

pure func TranslationFaultDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[31:29] = '000';
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

pure func TranslationFaultSource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

pure func TranslationFaultIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func PrepareTranslationFaultRequest()
begin
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
    MarkTileValidRegionDefined(0);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let start = ExecuteCommandInstruction(TranslationFaultStart(), 32);
    let attributes = ExecuteCommandInstruction(TranslationFaultDATR(), 32);
    let source = ExecuteCommandInstruction(TranslationFaultSource(), 32);
    let address = ExecuteCommandInstruction(TranslationFaultIOR(), 32);
    assert start == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed &&
           BundleAtomicTStoreSelected();
end;

func main() => integer
begin
    // Control: an otherwise identical identity-mapped request is valid.
    ResetProfileState();
    _Issue397TranslationMode = 0;
    Store(Zeros{PTO_XLEN} + 0x300, 4, Zeros{PTO_XLEN} + 5);
    PrepareTranslationFaultRequest();
    WriteGPR(2, Zeros{PTO_XLEN} + 0x300);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    StartMemoryEventCapture(0);
    let control = ExecuteBundleTileOperation();
    assert control && _LastFault == Fault_None && _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Atomic &&
           _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x300 &&
           _MemoryEvents[[0]].read_value == Zeros{PTO_XLEN} + 5 &&
           _MemoryEvents[[0]].write_value == Zeros{PTO_XLEN} + 7;
    StopMemoryEventCapture();

    // One access fails only because the profile deliberately resolves its
    // read and write halves to different physical words.
    ResetProfileState();
    _Issue397TranslationMode = 0;
    Store(Zeros{PTO_XLEN} + 0x300, 4, Zeros{PTO_XLEN} + 41);
    Store(Zeros{PTO_XLEN} + 0x500, 4, Zeros{PTO_XLEN} + 51);
    Store(Zeros{PTO_XLEN} + 0x504, 4, Zeros{PTO_XLEN} + 61);
    PrepareTranslationFaultRequest();
    WriteGPR(2, Zeros{PTO_XLEN} + 0x300);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    _Issue397TranslationMode = 2;
    StartMemoryEventCapture(0);
    let rejected = ExecuteBundleTileOperation();
    assert !rejected && _LastFault == Fault_DataPage &&
           _MemoryEventCount == 0;
    StopMemoryEventCapture();
    _Issue397TranslationMode = 0;
    let va_after = LoadUnsigned(Zeros{PTO_XLEN} + 0x300, 4);
    let read_target_after = LoadUnsigned(Zeros{PTO_XLEN} + 0x500, 4);
    let write_target_after = LoadUnsigned(Zeros{PTO_XLEN} + 0x504, 4);
    assert va_after == Zeros{PTO_XLEN} + 41 &&
           read_target_after == Zeros{PTO_XLEN} + 51 &&
           write_target_after == Zeros{PTO_XLEN} + 61;

    // A kernel request that fails only target translation remains an
    // unadmitted dynamic occurrence. Mapping recovery at the same PC retries
    // that identity, captures the now-valid physical target and emits one
    // Atomic update through production scheduler service.
    ResetProfileState();
    _Issue397TranslationMode = 0;
    let entry = Zeros{PTO_XLEN} + 0xc00;
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;
    let invocation = _KernelInvocationByCore[[0]];
    SelectExecutionContext(0, 0);
    Store(Zeros{PTO_XLEN} + 0x300, 4, Zeros{PTO_XLEN} + 5);
    Store(Zeros{PTO_XLEN} + 0x500, 4, Zeros{PTO_XLEN} + 51);
    Store(Zeros{PTO_XLEN} + 0x504, 4, Zeros{PTO_XLEN} + 61);
    PrepareTranslationFaultRequest();
    WriteGPR(2, Zeros{PTO_XLEN} + 0x300);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    _PC = entry;
    _BPC = entry;
    _CurrentProgramOrder = 12;
    _PEProgramOrder[[0]][[0]] = 12;
    assert _KernelInvocationActiveByCore[[0]] &&
           _CurrentKernelInvocation == invocation &&
           _CurrentMemoryOrigin == MemoryEventOrigin_Kernel;
    SetVerificationGMProgressDeferred(TRUE);
    _Issue397TranslationMode = 2;
    StartMemoryEventCapture(0);
    let failed_retry = ExecuteBundleTileOperation();
    assert !failed_retry && _LastFault == Fault_DataPage &&
           _FaultAddress == Zeros{PTO_XLEN} + 0x300 &&
           ReadBPC() == entry && _MemoryEventCount == 0 &&
           _CurrentKernelInvocation == invocation &&
           _CurrentMemoryOrigin == MemoryEventOrigin_Handler;
    let fault_ring = CurrentACR();
    assert _TrapContexts[[fault_ring]].valid &&
           _TrapContexts[[fault_ring]].memory_origin ==
               MemoryEventOrigin_Kernel;
    assert FindCurrentAtomicTStoreObligation() < 0;
    let request_word = _BundleStartEncodedInstruction;
    let request_domain = _BundleExecutionDomainToken;
    let request_order = _CurrentProgramOrder;
    StopMemoryEventCapture();
    _Issue397TranslationMode = 0;
    let failed_target = LoadUnsigned(Zeros{PTO_XLEN} + 0x300, 4);
    let failed_read_map = LoadUnsigned(Zeros{PTO_XLEN} + 0x500, 4);
    let failed_write_map = LoadUnsigned(Zeros{PTO_XLEN} + 0x504, 4);
    assert failed_target == Zeros{PTO_XLEN} + 5 &&
           failed_read_map == Zeros{PTO_XLEN} + 51 &&
           failed_write_map == Zeros{PTO_XLEN} + 61;

    let trap_ring = CurrentACR();
    let recovered_context = RecoverTrapContext(trap_ring);
    assert recovered_context;
    ClearFault();
    assert ReadBPC() == entry &&
           _BundleStartEncodedInstruction == request_word &&
           _BundleExecutionDomainToken == request_domain &&
           _CurrentProgramOrder == request_order &&
           _KernelInvocationByCore[[0]] == invocation &&
           _CurrentKernelInvocation == invocation &&
           _CurrentMemoryOrigin == MemoryEventOrigin_Kernel;
    SetVerificationGMProgressDeferred(FALSE);
    StartMemoryEventCapture(0);
    let retried = ExecuteBundleTileOperation();
    assert _LastFault == Fault_None;
    assert retried;
    assert _MemoryEventCount == 1 &&
           _CurrentKernelInvocation == invocation &&
           _CurrentMemoryOrigin == MemoryEventOrigin_Kernel;
    let retry_event = _MemoryEvents[[0 as MemoryEventIndex]];
    assert retry_event.active && retry_event.committed &&
           retry_event.kind == MemoryEvent_Atomic;
    assert retry_event.core_identity == 0 && retry_event.agent == 0;
    assert retry_event.origin == MemoryEventOrigin_Kernel;
    assert retry_event.invocation == invocation;
    assert retry_event.address == Zeros{PTO_XLEN} + 0x300 &&
           retry_event.read_value == Zeros{PTO_XLEN} + 5 &&
           retry_event.write_value == Zeros{PTO_XLEN} + 7;
    StopMemoryEventCapture();
    let recovered_target = LoadUnsigned(Zeros{PTO_XLEN} + 0x300, 4);
    let preserved_read_map = LoadUnsigned(Zeros{PTO_XLEN} + 0x500, 4);
    let preserved_write_map = LoadUnsigned(Zeros{PTO_XLEN} + 0x504, 4);
    assert recovered_target == Zeros{PTO_XLEN} + 7 &&
           preserved_read_map == Zeros{PTO_XLEN} + 51 &&
           preserved_write_map == Zeros{PTO_XLEN} + 61;
    SetVerificationGMProgressBeatBudget(0);
    return 0;
end;
