// PTO-TEST: {"id":"PTO-AVS-HSCB-WRONG-DONE-ID-001","source":"asl/arch/state/hscb-dispatch.asl","requirements":["PTO-ARCH-HSCB-DISPATCH-001","PTO-ARCH-HSCB-TRANSPORT-001"],"kind":"state-transition","summary":"service rejection of a sibling or mismatched ID preserves a pending launch","pass_condition":"only the source and ID of the outstanding dispatch may complete it; a consumed transport ACK leaves dispatch state unchanged","related_sources":["asl/arch/state/message-buffer.asl","asl/arch/state/message-buffer-send.asl","asl/arch/state/kernel-lifecycle.asl"]}
func SelectWorker(thread_id: integer {0..7})
begin
    SelectExecutionContext(0, (thread_id MOD 4) as MemoryAgentId);
    SelectMessageBufferThread((thread_id DIVRM 4) as MessageBufferThread);
    SetCurrentACR(0);
end;

func BootWorker(thread_id: integer {0..7})
begin
    SelectWorker(thread_id);
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

func ConsumeLaunch(expected_id: Word, expected_pc: Word, expected_arg: Word)
begin
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{64} + 1);
    let tok = ReadSystemRegisterAddress(Zeros{24} + 0x083d);
    let hi = ReadSystemRegisterAddress(Zeros{24} + 0x083e);
    let tag = ReadSystemRegisterAddress(Zeros{24} + 0x0831);
    let id = ReadSystemRegisterAddress(Zeros{24} + 0x0832);
    let target = ReadSystemRegisterAddress(Zeros{24} + 0x0833);
    let arg = ReadSystemRegisterAddress(Zeros{24} + 0x0834);
    assert hi[63:32] == Ones{32};
    assert tag == Zeros{64} + 2 && id == expected_id && target == expected_pc && arg == expected_arg;
    WriteSystemRegisterAddress(Zeros{24} + 0x0842, tok);
    let result = ReadSystemRegisterAddress(Zeros{24} + 0x0843);
    assert result == Zeros{64} + 0x101;
    WriteSystemRegisterAddress(Zeros{24} + 0x0841, tok);
end;

func SendDone(pc: integer, id: Word, value: Word)
begin
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{64} + 3);
    WriteSystemRegisterAddress(Zeros{24} + 0x0832, id);
    WriteSystemRegisterAddress(Zeros{24} + 0x0833, value);
    WorkerRequest(pc, 3);
end;

func main() => integer
begin

    ResetProfileState();
    EnableHSCBService();
    let boot = LaunchKernelInvocation(0, Zeros{64} + 0x100);
    assert boot == KernelLifecycle_Started;

    BootWorker(0); ReportReady();
    let issued = HSCBIssueLaunch(0, Zeros{64} + 73, Zeros{64} + 0x600, Zeros{64});
    assert issued == MessageBufferResult_OK;
    ConsumeLaunch(Zeros{64} + 73, Zeros{64} + 0x600, Zeros{64});
    BootWorker(4);
    SendDone(0x124, Zeros{64} + 73, Ones{64});
    let wrong_source = HSCBReceiveWorkerMessage();
    assert wrong_source == MessageBufferResult_BadCommand;
    assert _MessageBufferBanks[[0]].hscb_running;
    SelectWorker(0);
    SendDone(0x128, Zeros{64} + 74, Ones{64});
    let wrong_id = HSCBReceiveWorkerMessage();
    assert wrong_id == MessageBufferResult_BadCommand;
    assert _MessageBufferBanks[[0]].hscb_running;
    SendDone(0x12c, Zeros{64} + 73, Zeros{64} + 42);
    let right_id = HSCBReceiveWorkerMessage();
    assert right_id == MessageBufferResult_OK;
    let duplicate = HSCBIssueLaunch(0, Zeros{64} + 73, Zeros{64} + 0x600, Zeros{64});
    assert duplicate == MessageBufferResult_BadCommand;
    assert !_MessageBufferBanks[[0]].queued.valid;
    return 0;
end;
