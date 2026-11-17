// PTO-TEST: {"id":"PTO-AVS-HSCB-SIBLING-CLAIM-ISOLATION-001","source":"asl/arch/state/hscb-dispatch.asl","requirements":["PTO-ARCH-HSCB-ENDPOINT-001","PTO-ARCH-HSCB-TRANSPORT-001"],"kind":"state-transition","summary":"a physical PE sibling cannot read or acknowledge the other slot\u2019s outstanding receive snapshot","pass_condition":"the sibling has no token or claim and its configuration selector and unsuccessful ACK leave the first slot\u2019s snapshot unchanged","related_sources":["asl/arch/state/message-buffer.asl","asl/arch/state/message-buffer-send.asl","asl/arch/state/kernel-lifecycle.asl"]}
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

func main() => integer
begin

    ResetProfileState();
    EnableHSCBService();
    let boot = LaunchKernelInvocation(0, Zeros{64} + 0x100);
    assert boot == KernelLifecycle_Started;

    BootWorker(0); BootWorker(4);
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{64} + 23);
    ExecuteMessageBufferSend(Zeros{64} + (1 << 32));
    SelectWorker(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{64} + 1);
    let original = ReadSystemRegisterAddress(Zeros{24} + 0x083d);
    let contents = ReadSystemRegisterAddress(Zeros{24} + 0x0831);
    assert contents == Zeros{64} + 23;
    WriteSystemRegisterAddress(Zeros{24} + 0x0849, Zeros{64} + 3);
    SelectWorker(4);
    let sibling_selector = ReadSystemRegisterAddress(Zeros{24} + 0x0849);
    let sibling_token = ReadSystemRegisterAddress(Zeros{24} + 0x083d);
    assert sibling_selector == Zeros{64} && sibling_token == Zeros{64};
    WriteSystemRegisterAddress(Zeros{24} + 0x0842, original);
    let denied = ReadSystemRegisterAddress(Zeros{24} + 0x0843);
    assert denied == Zeros{64} + 0x105;
    SelectWorker(0);
    let selector = ReadSystemRegisterAddress(Zeros{24} + 0x0849);
    assert selector == Zeros{64} + 3;
    let retained = ReadSystemRegisterAddress(Zeros{24} + 0x083d);
    assert retained == original && _MessageBufferBanks[[0]].queued.valid;
    WriteSystemRegisterAddress(Zeros{24} + 0x0842, original);
    assert !_MessageBufferBanks[[0]].queued.valid;
    return 0;
end;
