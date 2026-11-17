// PTO-TEST: {"id":"PTO-AVS-HSCB-LAUNCH-IDENTITY-001","source":"asl/arch/state/hscb-dispatch.asl","requirements":["PTO-ARCH-HSCB-DISPATCH-001","PTO-ARCH-HSCB-TRANSPORT-001"],"kind":"state-transition","summary":"a worker accepts only the exact HSCBIssueLaunch packet bound to its outstanding dispatch","pass_condition":"direct HSCB-origin, wrong-ID and duplicate-shaped packets are rejected while the exact issued transport identity and dispatch ID are accepted once","related_sources":["asl/arch/state/message-buffer-state.asl","asl/arch/state/message-buffer-send.asl","asl/arch/state/message-buffer.asl"]}
func ConfigureWorker()
begin
    SelectExecutionContext(0, 0);
    SelectMessageBufferThread(0);
    SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x084b, Zeros{64} + 1);
    WriteSystemRegisterAddress(Zeros{24} + 0x084a, Zeros{64} + 0x100010001);
end;

func StageServiceLaunch(dispatch_id: Word)
begin
    _MessageBufferBanks[[PTO_HSCB_BANK]].staging_words[[0]] = Zeros{64} + 2;
    _MessageBufferBanks[[PTO_HSCB_BANK]].staging_words[[1]] = dispatch_id;
    _MessageBufferBanks[[PTO_HSCB_BANK]].staging_words[[2]] = Zeros{64} + 0x600;
    _MessageBufferBanks[[PTO_HSCB_BANK]].staging_words[[3]] = Zeros{64} + 42;
end;

func ClaimReadAndCheck(expected: boolean)
begin
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{64} + 1);
    let token = ReadSystemRegisterAddress(Zeros{24} + 0x083d);
    for word = 0 to 3 do
        - = ReadSystemRegisterAddress(Zeros{24} + 0x0831 + word);
    end;
    assert HSCBWorkerAcceptsLaunch() == expected;
    WriteSystemRegisterAddress(Zeros{24} + 0x0842, token);
    assert _MessageBufferBanks[[0]].ack_result == MessageBufferResult_OK;
    assert !HSCBWorkerAcceptsLaunch();
    WriteSystemRegisterAddress(Zeros{24} + 0x0841, token);
end;

func main() => integer
begin
    ResetProfileState();
    EnableHSCBService();
    let started = LaunchKernelInvocation(0, Zeros{64} + 0x100);
    assert started == KernelLifecycle_Started;
    ConfigureWorker();

    // Source identity and shape alone do not authorize a worker launch.
    StageServiceLaunch(Zeros{64} + 17);
    let bypass = AdmitMessageBufferPacket(PTO_HSCB_BANK,
        Zeros{64} + (4 << 32), TRUE);
    assert bypass == MessageBufferResult_OK;
    ClaimReadAndCheck(FALSE);

    _MessageBufferBanks[[0]].hscb_ready = TRUE;
    let issued = HSCBIssueLaunch(0, Zeros{64} + 17,
        Zeros{64} + 0x600, Zeros{64} + 42);
    assert issued == MessageBufferResult_OK;
    let expected_hi = _MessageBufferBanks[[0]].hscb_launch_message_id_hi;
    let expected_lo = _MessageBufferBanks[[0]].hscb_launch_message_id_lo;
    ClaimReadAndCheck(TRUE);
    assert _MessageBufferBanks[[0]].hscb_launch_message_id_hi == expected_hi;
    assert _MessageBufferBanks[[0]].hscb_launch_message_id_lo == expected_lo;

    // A second service packet cannot replace the exact issued transport.
    StageServiceLaunch(Zeros{64} + 18);
    let wrong_id = AdmitMessageBufferPacket(PTO_HSCB_BANK,
        Zeros{64} + (4 << 32), TRUE);
    assert wrong_id == MessageBufferResult_OK;
    ClaimReadAndCheck(FALSE);

    StageServiceLaunch(Zeros{64} + 17);
    let duplicate_shape = AdmitMessageBufferPacket(PTO_HSCB_BANK,
        Zeros{64} + (4 << 32), TRUE);
    assert duplicate_shape == MessageBufferResult_OK;
    ClaimReadAndCheck(FALSE);
    assert _MessageBufferBanks[[0]].hscb_running;
    return 0;
end;
