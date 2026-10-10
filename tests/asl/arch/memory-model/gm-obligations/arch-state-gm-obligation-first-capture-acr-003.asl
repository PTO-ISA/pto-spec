// PTO-TEST: {"id":"PTO-AVS-ARCH-GM-OBLIGATION-FIRST-VALIDATION-ACR-003","source":"asl/arch/memory-model/gm-obligations.asl","requirements":["PTO-ARCH-GM-OBLIGATIONS-001","PTO-ARCH-MEMORY-MODEL-TRAP-RESTORE-001","PTO-ARCH-KERNEL-LIFECYCLE-001"],"kind":"state-transition","summary":"a same-request TSTORE retry binds the ACR and footprint of its first successful admission","pass_condition":"the real ACR2 access fault preserves the same request across handler recovery to ACR0; the original stop retries, captures under ACR0, and production progress commits one beat per call under that immutable capture without a stale ACR2 fault","related_sources":["asl/arch/state/trap-context.asl","asl/tile/model/memory/load-store.asl"]}
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

func main() => integer
begin
    ResetProfileState();
    let launch = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x200);
    assert launch == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    WriteSystemRegisterAddress(Zeros{24} + 0x1f07,
        Zeros{PTO_XLEN} + 3);
    SetCurrentACR(2);
    ConfigureTile(4, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 0xaa);
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN} + 0xbb);
    WriteGPR(2, Zeros{PTO_XLEN} + 0xc80);
    WriteGPR(3, Zeros{PTO_XLEN} + 16);
    SetVerificationGMProgressDeferred(TRUE);
    let start = ExecuteCommandInstruction(DelayedTStoreStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    let source = ExecuteCommandInstruction(
        DelayedTStoreSource(Zeros{6} + 4), 32);
    let address = ExecuteCommandInstruction(DelayedTStoreAddress(
        Zeros{5} + 2, Zeros{5} + 3), 32);
    let domain = _BundleExecutionDomainToken;
    let first_stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert start == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed &&
           first_stop == CommandExecution_Rejected &&
           _LastFault == Fault_DataPage && CurrentACR() == 1;
    let faulted = _GMObligations[[0]][[0]][[0]];
    assert faulted.state == GMObligation_Faulted &&
           !faulted.executable_capture_valid && faulted.submission_acr == 2 &&
           faulted.execution_domain_token == domain;
    var ecstate = ReadContextRegister(1, 0x0f00);
    var control = ReadContextRegister(1, 0x0f40);
    ecstate[3:0] = '0000';
    control[3:0] = '0000';
    WriteContextRegister(1, 0x0f00, ecstate);
    WriteContextRegister(1, 0x0f40, control);
    let recovered = RecoverTrapContext(1);
    assert recovered && CurrentACR() == 0 &&
           _BundleExecutionDomainToken == domain && _BundleActive;
    let retry = ExecuteCommandInstruction(Zeros{64}, 16);
    assert retry == CommandExecution_Executed && _LastFault == Fault_None &&
           !_BundleActive;
    let captured = _GMObligations[[0]][[0]][[0]];
    assert captured.identity == faulted.identity &&
           captured.execution_domain_token == domain &&
           captured.captured_tstore_progress &&
           captured.executable_capture_valid &&
           captured.state == GMObligation_Validated &&
           captured.submission_acr == 0 && captured.progress_element == 0;
    let first_initial_memory = LoadUnsigned(Zeros{PTO_XLEN} + 0xc80, 8);
    let second_initial_memory = LoadUnsigned(Zeros{PTO_XLEN} + 0xc88, 8);
    assert first_initial_memory == Zeros{PTO_XLEN} &&
           second_initial_memory == Zeros{PTO_XLEN};
    SetVerificationGMProgressDeferred(FALSE);
    SetVerificationGMProgressBeatBudget(1);
    ProgressKernelGMObligationsForCore(0, _CurrentKernelInvocation);
    let partial = _GMObligations[[0]][[0]][[0]];
    assert partial.identity == faulted.identity &&
           partial.execution_domain_token == domain &&
           partial.state == GMObligation_Issued &&
           partial.progress_element == 1 && partial.irrevocable;
    let first_beat_value = LoadUnsigned(Zeros{PTO_XLEN} + 0xc80, 8);
    let second_waiting_value = LoadUnsigned(Zeros{PTO_XLEN} + 0xc88, 8);
    assert first_beat_value == Zeros{PTO_XLEN} + 0xaa &&
           second_waiting_value == Zeros{PTO_XLEN};
    ProgressKernelGMObligationsForCore(0, _CurrentKernelInvocation);
    let completed = _GMObligations[[0]][[0]][[0]];
    assert completed.identity == faulted.identity &&
           completed.execution_domain_token == domain &&
           completed.state == GMObligation_Completed &&
           completed.progress_element == 2;
    let second_beat_value = LoadUnsigned(Zeros{PTO_XLEN} + 0xc88, 8);
    assert second_beat_value == Zeros{PTO_XLEN} + 0xbb;
    SetVerificationGMProgressBeatBudget(0);
    return 0;
end;
