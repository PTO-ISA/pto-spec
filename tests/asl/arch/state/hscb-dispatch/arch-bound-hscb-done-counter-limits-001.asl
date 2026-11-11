// PTO-TEST: {"id":"PTO-AVS-HSCB-DONE-COUNTER-LIMITS-001","source":"asl/arch/state/hscb-dispatch.asl","requirements":["PTO-ARCH-HSCB-DISPATCH-001","PTO-ARCH-HSCB-TRANSPORT-001"],"kind":"boundary","summary":"nonwrapping service and worker counters reserve capacity for an outstanding DONE","pass_condition":"exhausted host transmit, host claim or worker claim prevents launch; the final host claim and worker sequence are available only to the exact completion","related_sources":["asl/arch/state/message-buffer-send.asl","asl/arch/state/message-buffer.asl"]}
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
    // A second worker shares only service claim capacity, not the first
    // worker's transmit sequence or receipt budget.
    SelectMessageBufferThread(1);
    WriteSystemRegisterAddress(Zeros{24} + 0x084b, Zeros{64} + 1);
    WriteSystemRegisterAddress(Zeros{24} + 0x084a, Zeros{64} + 0x100010001);
    SelectMessageBufferThread(0);
    let tx = _MessageBufferBanks[[PTO_HSCB_BANK]].transmit_sequence;
    _MessageBufferBanks[[PTO_HSCB_BANK]].transmit_sequence = Ones{64};
    let host_tx = HSCBIssueLaunch(0, Zeros{64} + 17, Zeros{64} + 0x600, Zeros{64});
    assert host_tx == MessageBufferResult_Exhausted;
    _MessageBufferBanks[[PTO_HSCB_BANK]].transmit_sequence = tx;
    let claim = _MessageBufferBanks[[0]].claim_sequence;
    _MessageBufferBanks[[0]].claim_sequence = Ones{48};
    let worker_rx = HSCBIssueLaunch(0, Zeros{64} + 17, Zeros{64} + 0x600, Zeros{64});
    assert worker_rx == MessageBufferResult_Exhausted;
    _MessageBufferBanks[[0]].claim_sequence = claim;
    _MessageBufferBanks[[PTO_HSCB_BANK]].claim_sequence = Ones{48};
    let host_rx = HSCBIssueLaunch(0, Zeros{64} + 17, Zeros{64} + 0x600, Zeros{64});
    assert host_rx == MessageBufferResult_Exhausted;
    _MessageBufferBanks[[PTO_HSCB_BANK]].claim_sequence = Ones{48} - 1;
    _MessageBufferBanks[[0]].transmit_sequence = Ones{64} - 1;
    let issued = HSCBIssueLaunch(0, Zeros{64} + 17, Zeros{64} + 0x600, Zeros{64});
    assert issued == MessageBufferResult_OK;
    ConsumeWork();
    WriteTPC(Zeros{64} + 0x200);
    ExecuteMessageBufferSend(Zeros{64} + 64);
    assert _MessageBufferBanks[[0]].tx_result == MessageBufferResult_Exhausted;
    assert !_MessageBufferBanks[[64]].queued.valid;
    SelectMessageBufferThread(1);
    ExecuteMessageBufferSend(Zeros{64} + 0xffffffff);
    assert _MessageBufferBanks[[64]].tx_result == MessageBufferResult_Exhausted;
    assert !_MessageBufferBanks[[PTO_HSCB_BANK]].queued.valid;
    SelectMessageBufferThread(0);
    let draining = EndKernelInvocation(0);
    assert draining == KernelLifecycle_Waiting;
    SendCompletion(0x204);
    let completed = HSCBReceiveWorkerMessage();
    assert completed == MessageBufferResult_OK;
    assert _MessageBufferBanks[[PTO_HSCB_BANK]].claim_sequence == Ones{48};
    assert _MessageBufferBanks[[0]].transmit_sequence == Ones{64};
    return 0;
end;
