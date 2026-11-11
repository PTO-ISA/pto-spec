// PTO-TEST: {"id":"PTO-AVS-HSCB-DONE-BEFORE-LAUNCH-001","source":"asl/arch/state/hscb-dispatch.asl","requirements":["PTO-ARCH-HSCB-DISPATCH-001","PTO-ARCH-HSCB-TRANSPORT-001"],"kind":"boundary","summary":"a pending early DONE cannot complete a later launch with the same ID","pass_condition":"issue waits for pending service ingress, processing the speculative DONE fails, and the newly issued job stays active until a fresh matching DONE","related_sources":["asl/arch/state/message-buffer-send.asl","asl/arch/state/message-buffer.asl"]}
func StartWorker()
begin
    ResetProfileState();
    EnableHSCBService();
    let started = LaunchKernelInvocation(0, Zeros{64} + 0x100);
    assert started == KernelLifecycle_Started;
    SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x084b, Zeros{64} + 1);
    WriteSystemRegisterAddress(Zeros{24} + 0x084a, Zeros{64} + 0x100010001);
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{64} + 1);
    ExecuteMessageBufferSend(Zeros{64} + 0x1ffffffff);
    let registered = HSCBReceiveWorkerMessage();
    assert registered == MessageBufferResult_OK;
end;

func SendCompletion(instruction_pc: integer)
begin
    WriteTPC(Zeros{64} + instruction_pc);
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{64} + 3);
    WriteSystemRegisterAddress(Zeros{24} + 0x0832, Zeros{64} + 17);
    WriteSystemRegisterAddress(Zeros{24} + 0x0833, Zeros{64} + 42);
    ExecuteMessageBufferSend(Zeros{64} + 0x3ffffffff);
end;

func ConsumeWork()
begin
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{64} + 1);
    let token = ReadSystemRegisterAddress(Zeros{24} + 0x083d);
    for word = 0 to 3 do
        - = ReadSystemRegisterAddress(Zeros{24} + 0x0831 + word);
    end;
    WriteSystemRegisterAddress(Zeros{24} + 0x0842, token);
    WriteSystemRegisterAddress(Zeros{24} + 0x0841, token);
    assert MessageBufferBankQuiescent(0);
end;

func main() => integer
begin
    StartWorker();
    SendCompletion(0x200);
    let busy = HSCBIssueLaunch(0, Zeros{64} + 17, Zeros{64} + 0x600, Zeros{64});
    assert busy == MessageBufferResult_Busy;
    assert !_MessageBufferBanks[[0]].hscb_running && !_MessageBufferBanks[[0]].queued.valid;
    let stale = HSCBReceiveWorkerMessage();
    assert stale == MessageBufferResult_BadCommand;
    let issued = HSCBIssueLaunch(0, Zeros{64} + 17, Zeros{64} + 0x600, Zeros{64});
    assert issued == MessageBufferResult_OK;
    let empty = HSCBReceiveWorkerMessage();
    assert empty == MessageBufferResult_Empty && _MessageBufferBanks[[0]].hscb_running;
    ConsumeWork();
    SendCompletion(0x204);
    let fresh = HSCBReceiveWorkerMessage();
    assert fresh == MessageBufferResult_OK && !_MessageBufferBanks[[0]].hscb_running;
    return 0;
end;
