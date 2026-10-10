// PTO-TEST: {"id":"PTO-AVS-ARCH-GM-OBLIGATION-DYNAMIC-ACR-004","source":"asl/arch/memory-model/gm-obligations.asl","requirements":["PTO-ARCH-GM-OBLIGATIONS-001","PTO-ARCH-MEMORY-MODEL-TRAP-RESTORE-001","PTO-ARCH-KERNEL-LIFECYCLE-001"],"kind":"state-transition","summary":"same-PC dynamic TSTORE requests retain distinct ACR captures across real handler recovery","pass_condition":"a first deferred request admitted under ACR2 and a second same-PC request after real recovery under ACR0 keep separate domain, identity, address, source snapshot, and ACR provenance; actual scheduler progress completes both without reusing the first capture or late fault","related_sources":["asl/arch/state/trap-context.asl","asl/tile/model/memory/load-store.asl"]}
pure func DelayedTStoreStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 25;
    return instruction;
end;

pure func DelayedTStoreSource(source: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = '111';
    instruction[25:20] = source;
    instruction[19] = '1';
    return instruction;
end;

pure func DelayedTStoreAddress(base: bits(5), stride: bits(5))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = base;
    instruction[24:20] = stride;
    return instruction;
end;

func SubmitDynamicStore(address_value: Word, value: Word)
begin
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    WriteGPR(2, address_value);
    WriteGPR(3, Zeros{PTO_XLEN} + 8);
    WriteTileElement(4, 0, 0, value);
    let start = ExecuteCommandInstruction(DelayedTStoreStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let source = ExecuteCommandInstruction(
        DelayedTStoreSource(Zeros{6} + 4), 32);
    let address = ExecuteCommandInstruction(DelayedTStoreAddress(
        Zeros{5} + 2, Zeros{5} + 3), 32);
    let stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert start == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed &&
           stop == CommandExecution_Executed && !_BundleActive &&
           _LastFault == Fault_None;
end;

func main() => integer
begin
    ResetProfileState();
    let launch = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x200);
    assert launch == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    WriteSystemRegisterAddress(Zeros{24} + 0x1f07,
        Zeros{PTO_XLEN} + 3);
    SetCurrentACR(2);
    ConfigureTile(4, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor);
    SetVerificationGMProgressDeferred(TRUE);
    SubmitDynamicStore(Zeros{PTO_XLEN} + 0x700,
        Zeros{PTO_XLEN} + 0xaa);
    let first = _GMObligations[[0]][[0]][[0]];
    assert first.active && first.captured_tstore_progress &&
           first.executable_capture_valid && first.submission_acr == 2 &&
           first.base_address == Zeros{PTO_XLEN} + 0x700;
    let first_domain = first.execution_domain_token;

    RaiseInterrupt(0 as InterruptID, Zeros{24} + 9);
    assert CurrentACR() == 1 && _TrapContexts[[1]].valid &&
           _CurrentMemoryOrigin == MemoryEventOrigin_Handler;
    var ecstate = ReadContextRegister(1, 0x0f00);
    var control = ReadContextRegister(1, 0x0f40);
    ecstate[3:0] = '0000';
    control[3:0] = '0000';
    WriteContextRegister(1, 0x0f00, ecstate);
    WriteContextRegister(1, 0x0f40, control);
    let recovered = RecoverTrapContext(1);
    assert recovered && CurrentACR() == 0 &&
           _CurrentMemoryOrigin == MemoryEventOrigin_Kernel;
    SubmitDynamicStore(Zeros{PTO_XLEN} + 0xc80,
        Zeros{PTO_XLEN} + 0xbb);
    let second = _GMObligations[[0]][[0]][[1]];
    assert second.active && second.captured_tstore_progress &&
           second.executable_capture_valid && second.submission_acr == 0 &&
           second.base_address == Zeros{PTO_XLEN} + 0xc80 &&
           second.identity != first.identity &&
           second.execution_domain_token != first_domain &&
           first.identity != second.identity &&
           first.submission_acr == 2 &&
           first.base_address == Zeros{PTO_XLEN} + 0x700 &&
           TileReadLogicalElement(first.source_snapshot, 0) ==
               Zeros{PTO_XLEN} + 0xaa &&
           TileReadLogicalElement(second.source_snapshot, 0) ==
               Zeros{PTO_XLEN} + 0xbb;
    SetVerificationGMProgressDeferred(FALSE);
    ProgressKernelGMObligationsForCore(0, _CurrentKernelInvocation);
    assert _GMObligations[[0]][[0]][[0]].state == GMObligation_Completed &&
           _GMObligations[[0]][[0]][[1]].state == GMObligation_Completed &&
           _GMObligations[[0]][[0]][[0]].submission_acr == 2 &&
           _GMObligations[[0]][[0]][[1]].submission_acr == 0;
    let first_value = LoadUnsigned(Zeros{PTO_XLEN} + 0x700, 8);
    let second_value = LoadUnsigned(Zeros{PTO_XLEN} + 0xc80, 8);
    assert first_value == Zeros{PTO_XLEN} + 0xaa &&
           second_value == Zeros{PTO_XLEN} + 0xbb &&
           _LastFault == Fault_None;
    return 0;
end;
