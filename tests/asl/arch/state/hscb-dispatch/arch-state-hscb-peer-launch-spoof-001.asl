// PTO-TEST: {"id":"PTO-AVS-HSCB-PEER-LAUNCH-SPOOF-001","source":"asl/arch/state/hscb-dispatch.asl","requirements":["PTO-ARCH-HSCB-DISPATCH-001","PTO-ARCH-HSCB-TRANSPORT-001"],"kind":"state-transition","summary":"a peer can transport four LAUNCH-shaped words but cannot select the receiving worker's kernel PC","pass_condition":"the recipient reads the complete correctly sized and aligned command yet rejects it as a launch because its trusted transport source is the sibling","related_sources":["asl/arch/state/message-buffer-send.asl","asl/arch/state/message-buffer.asl"]}
func main() => integer
begin
    ResetProfileState();
    EnableHSCBService();
    let started = LaunchKernelInvocation(0, Zeros{64} + 0x100);
    assert started == KernelLifecycle_Started;
    for slot = 0 to 1 do
        SelectMessageBufferThread(slot as MessageBufferThread);
        WriteSystemRegisterAddress(Zeros{24} + 0x084b, Zeros{64} + 1);
        WriteSystemRegisterAddress(Zeros{24} + 0x084a, Zeros{64} + 0x100010001);
    end;
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{64} + 2);
    WriteSystemRegisterAddress(Zeros{24} + 0x0832, Zeros{64} + 17);
    WriteSystemRegisterAddress(Zeros{24} + 0x0833, Zeros{64} + 0x600);
    WriteSystemRegisterAddress(Zeros{24} + 0x0834, Zeros{64} + 42);
    ExecuteMessageBufferSend(Zeros{64} + (4 << 32));
    SelectMessageBufferThread(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{64} + 1);
    for word = 0 to 3 do
        - = ReadSystemRegisterAddress(Zeros{24} + 0x0831 + word);
    end;
    assert MessageBufferReadComplete(0);
    assert !HSCBWorkerAcceptsLaunch();
    return 0;
end;
