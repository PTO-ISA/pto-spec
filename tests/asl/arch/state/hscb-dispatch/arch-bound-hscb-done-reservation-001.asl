// PTO-TEST: {"id":"PTO-AVS-HSCB-DONE-RESERVATION-001","source":"asl/arch/state/hscb-dispatch.asl","requirements":["PTO-ARCH-HSCB-DISPATCH-001","PTO-ARCH-HSCB-TRANSPORT-001"],"kind":"boundary","summary":"a launch reserves the last free worker replay receipt against ordinary traffic","pass_condition":"the ordinary BSE cannot spend the reserved receipt, the exact DONE succeeds, exact replay does not publish twice, and a new launch with a full receipt table fails before effects","related_sources":["asl/arch/state/message-buffer-send.asl","asl/arch/state/message-buffer.asl"]}
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
    // Fill all but one receipt using admitted zero-word sends.
    for occurrence = 1 to PTO_MODEL_MESSAGE_BUFFER_RECEIPTS - 2 do
        WriteTPC(Zeros{64} + 0x200 + 4 * occurrence);
        ExecuteMessageBufferSend(Zeros{64} + 0xffffffff);
        assert _MessageBufferBanks[[0]].tx_result == MessageBufferResult_OK;
        let rejected = HSCBReceiveWorkerMessage();
        assert rejected == MessageBufferResult_BadCommand;
    end;
    let sent = HSCBIssueLaunch(0, Zeros{64} + 17, Zeros{64} + 0x600, Zeros{64});
    assert sent == MessageBufferResult_OK;
    ConsumeWork();
    WriteTPC(Zeros{64} + 0x300);
    ExecuteMessageBufferSend(Zeros{64} + 0xffffffff);
    assert _MessageBufferBanks[[0]].tx_result == MessageBufferResult_Busy;
    assert !_MessageBufferBanks[[PTO_HSCB_BANK]].queued.valid;
    SendCompletion(0x304);
    let completed = HSCBReceiveWorkerMessage();
    assert completed == MessageBufferResult_OK;
    SendCompletion(0x304);
    assert _MessageBufferBanks[[0]].tx_result == MessageBufferResult_Duplicate;
    assert !_MessageBufferBanks[[PTO_HSCB_BANK]].queued.valid;
    let exhausted = HSCBIssueLaunch(0, Zeros{64} + 18, Zeros{64} + 0x600, Zeros{64});
    assert exhausted == MessageBufferResult_Exhausted;
    assert !_MessageBufferBanks[[0]].queued.valid && !_MessageBufferBanks[[0]].hscb_running;
    return 0;
end;
