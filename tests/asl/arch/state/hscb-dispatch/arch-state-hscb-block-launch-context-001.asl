// PTO-TEST: {"id":"PTO-AVS-HSCB-BLOCK-LAUNCH-CONTEXT-001","source":"asl/arch/state/hscb-dispatch.asl","requirements":["PTO-ARCH-HSCB-DISPATCH-001","PTO-ARCH-HSCB-BLOCK-LAUNCH-001"],"kind":"state-transition","summary":"HSCB launches bind independent one-dimensional geometry to each resident thread until its matching completion","pass_condition":"two thread slots on one PE read their own BLOCKNUM and BLOCKID through SSRGET, another ACR observes ambient values, invalid or busy launch attempts and wrong DONE preserve the binding, exact DONE and invocation abort restore ambient values, a fresh invocation has independent geometry, a reused dispatch ID has no effects, and the legacy launch binds one block with identity zero","related_sources":["asl/arch/state/message-buffer-state.asl","asl/arch/system-registers/addressing.asl","asl/scalar/model/sys/semantics.asl"]}
func SelectWorker(slot: MessageBufferThread)
begin
    SelectExecutionContext(0, 0);
    SelectMessageBufferThread(slot);
    SetCurrentACR(0);
end;

func ConfigureWorker(slot: MessageBufferThread)
begin
    SelectWorker(slot);
    WriteSystemRegisterAddress(Zeros{24} + 0x084b, Zeros{64} + 1);
    WriteSystemRegisterAddress(Zeros{24} + 0x084a, Zeros{64} + 0x100010001);
end;

func WorkerRequest(pc: integer, words: MessageBufferWordCount)
begin
    WriteTPC(Zeros{64} + pc);
    BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
        Zeros{64}, Zeros{64} + pc, Zeros{64}, FALSE);
    EnterBundleBody();
    WriteGPR(5, Zeros{64} + (words << 32) + 0xffffffff);
    let sent = ExecuteScalarInstruction('000000000000000000000000000000101000000000101011', 32);
    assert sent == ScalarExecution_Executed;
    StopBundle();
    assert _LastFault == Fault_None;
end;

func ReportReady()
begin
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{64} + 1);
    WorkerRequest(0x100, 1);
    let accepted = HSCBReceiveWorkerMessage();
    assert accepted == MessageBufferResult_OK;
end;

func ReadSSR(address: integer {0..4095}, pc: integer) => Word
begin
    WriteTPC(Zeros{64} + pc);
    BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
        Zeros{64}, Zeros{64} + pc, Zeros{64}, FALSE);
    EnterBundleBody();
    var instruction: bits(48) = Zeros{48} + 0x0000003b;
    instruction[31:20] = Zeros{12} + address;
    instruction[11:7] = Zeros{5} + 6;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    let value = ReadGPR(6);
    StopBundle();
    assert _LastFault == Fault_None;
    return value;
end;

func CheckGeometry(expected_num: Word, expected_id: Word)
begin
    let actual_num = ReadSSR(0x0050, 0x180);
    let actual_id = ReadSSR(0x0051, 0x190);
    assert actual_num == expected_num;
    assert actual_id == expected_id;
end;

func ConsumeLaunch(expected_num: Word, expected_id: Word)
begin
    CheckGeometry(expected_num, expected_id);
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{64} + 1);
    let token = ReadSystemRegisterAddress(Zeros{24} + 0x083d);
    for word = 0 to 3 do
        - = ReadSystemRegisterAddress(Zeros{24} + 0x0831 + word);
    end;
    assert HSCBWorkerAcceptsLaunch();
    WriteSystemRegisterAddress(Zeros{24} + 0x0842, token);
    WriteSystemRegisterAddress(Zeros{24} + 0x0841, token);
    CheckGeometry(expected_num, expected_id);
end;

func SendDone(dispatch_id: Word) => MessageBufferResult
begin
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{64} + 3);
    WriteSystemRegisterAddress(Zeros{24} + 0x0832, dispatch_id);
    WriteSystemRegisterAddress(Zeros{24} + 0x0833, Zeros{64});
    WorkerRequest(0x120, 3);
    let accepted = HSCBReceiveWorkerMessage();
    return accepted;
end;

func main() => integer
begin
    ResetProfileState();
    EnableHSCBService();
    let started = LaunchKernelInvocation(0, Zeros{64} + 0x100);
    assert started == KernelLifecycle_Started;
    ConfigureWorker(0);
    ReportReady();
    ConfigureWorker(1);
    ReportReady();

    _SystemRegisters.blocknum = Zeros{64} + 19;
    _SystemRegisters.blockid = Zeros{64} + 7;

    let zero_num = HSCBIssueBlockLaunch(0, Zeros{64} + 10,
        Zeros{64} + 0x600, Zeros{64} + 42, Zeros{64}, Zeros{64});
    assert zero_num == MessageBufferResult_BadCommand;
    let bad_id = HSCBIssueBlockLaunch(0, Zeros{64} + 10,
        Zeros{64} + 0x600, Zeros{64} + 42, Zeros{64} + 4, Zeros{64} + 4);
    assert bad_id == MessageBufferResult_BadCommand;
    let wide_num = HSCBIssueBlockLaunch(0, Zeros{64} + 10,
        Zeros{64} + 0x600, Zeros{64} + 42, Zeros{64} + (1 << 32), Zeros{64});
    assert wide_num == MessageBufferResult_BadCommand;
    assert !_MessageBufferBanks[[0]].hscb_running;

    let issued0 = HSCBIssueBlockLaunch(0, Zeros{64} + 11,
        Zeros{64} + 0x600, Zeros{64} + 42, Zeros{64} + 8, Zeros{64} + 3);
    let issued1 = HSCBIssueBlockLaunch(64, Zeros{64} + 21,
        Zeros{64} + 0x604, Zeros{64} + 44, Zeros{64} + 4, Zeros{64} + 1);
    assert issued0 == MessageBufferResult_OK && issued1 == MessageBufferResult_OK;

    SelectWorker(0);
    CheckGeometry(Zeros{64} + 8, Zeros{64} + 3);
    SetCurrentACR(1);
    CheckGeometry(Zeros{64} + 19, Zeros{64} + 7);
    SetCurrentACR(0);

    let busy = HSCBIssueBlockLaunch(0, Zeros{64} + 12,
        Zeros{64} + 0x608, Zeros{64} + 46, Zeros{64} + 2, Zeros{64});
    assert busy == MessageBufferResult_Busy;
    CheckGeometry(Zeros{64} + 8, Zeros{64} + 3);

    SelectWorker(1);
    CheckGeometry(Zeros{64} + 4, Zeros{64} + 1);

    SelectWorker(0);
    ConsumeLaunch(Zeros{64} + 8, Zeros{64} + 3);
    let wrong_done = SendDone(Zeros{64} + 99);
    assert wrong_done == MessageBufferResult_BadCommand;
    CheckGeometry(Zeros{64} + 8, Zeros{64} + 3);
    let completed0 = SendDone(Zeros{64} + 11);
    assert completed0 == MessageBufferResult_OK;
    CheckGeometry(Zeros{64} + 19, Zeros{64} + 7);
    let reused = HSCBIssueBlockLaunch(0, Zeros{64} + 11,
        Zeros{64} + 0x608, Zeros{64} + 46, Zeros{64} + 2, Zeros{64});
    assert reused == MessageBufferResult_BadCommand;
    CheckGeometry(Zeros{64} + 19, Zeros{64} + 7);

    SelectWorker(1);
    CheckGeometry(Zeros{64} + 4, Zeros{64} + 1);
    ConsumeLaunch(Zeros{64} + 4, Zeros{64} + 1);
    let completed1 = SendDone(Zeros{64} + 21);
    assert completed1 == MessageBufferResult_OK;
    CheckGeometry(Zeros{64} + 19, Zeros{64} + 7);

    let legacy = HSCBIssueLaunch(0, Zeros{64} + 12,
        Zeros{64} + 0x602, Zeros{64} + 43);
    assert legacy == MessageBufferResult_OK;
    SelectWorker(0);
    ConsumeLaunch(Zeros{64} + 1, Zeros{64});
    let legacy_done = SendDone(Zeros{64} + 12);
    assert legacy_done == MessageBufferResult_OK;
    CheckGeometry(Zeros{64} + 19, Zeros{64} + 7);

    let before_abort = HSCBIssueBlockLaunch(0, Zeros{64} + 13,
        Zeros{64} + 0x606, Zeros{64} + 45, Zeros{64} + 6, Zeros{64} + 2);
    assert before_abort == MessageBufferResult_OK;
    CheckGeometry(Zeros{64} + 6, Zeros{64} + 2);
    ConsumeLaunch(Zeros{64} + 6, Zeros{64} + 2);
    let aborted = AbortKernelInvocation(0);
    assert aborted == KernelLifecycle_Started;
    CheckGeometry(Zeros{64} + 19, Zeros{64} + 7);

    let restarted = LaunchKernelInvocation(0, Zeros{64} + 0x100);
    assert restarted == KernelLifecycle_Started;
    ConfigureWorker(0);
    ReportReady();
    let fresh = HSCBIssueBlockLaunch(0, Zeros{64} + 13,
        Zeros{64} + 0x606, Zeros{64} + 45, Zeros{64} + 3, Zeros{64} + 1);
    assert fresh == MessageBufferResult_OK;
    CheckGeometry(Zeros{64} + 3, Zeros{64} + 1);
    ConsumeLaunch(Zeros{64} + 3, Zeros{64} + 1);
    let fresh_done = SendDone(Zeros{64} + 13);
    assert fresh_done == MessageBufferResult_OK;
    CheckGeometry(Zeros{64} + 19, Zeros{64} + 7);
    return 0;
end;
