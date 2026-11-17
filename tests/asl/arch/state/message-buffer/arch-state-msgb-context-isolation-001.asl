// PTO-TEST: {"id":"PTO-AVS-MSGB-CONTEXT-ISOLATION-001","source":"asl/arch/state/message-buffer.asl","requirements":["PTO-ARCH-MSGB-STATE-001","PTO-ARCH-MSGB-SSR-001"],"kind":"state-transition","summary":"message payload and receive ownership remain isolated across PE and ACR execution contexts","pass_condition":"only the configured destination context can claim and read its message, and a nonzero ACR cannot alter privileged configuration","related_sources":["asl/scalar/model/sys/registers.asl"]}
func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x100);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0, 0); SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x0849, Zeros{PTO_XLEN});
    WriteSystemRegisterAddress(Zeros{24} + 0x084b, Zeros{PTO_XLEN});
    WriteSystemRegisterAddress(Zeros{24} + 0x084a,
        Zeros{PTO_XLEN} + (1 << 32) + (1 << 16) + 1);
    SelectExecutionContext(0, 1); SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x0849, Zeros{PTO_XLEN});
    WriteSystemRegisterAddress(Zeros{24} + 0x084b, Zeros{PTO_XLEN});
    WriteSystemRegisterAddress(Zeros{24} + 0x084a,
        Zeros{PTO_XLEN} + (1 << 32) + (1 << 16) + 1);

    SelectExecutionContext(0, 0); SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{PTO_XLEN} + 0xaa);
    ExecuteMessageBufferSend(Zeros{PTO_XLEN} + 16 + (1 << 32));
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{PTO_XLEN} + 1);
    let source_state = ReadSystemRegisterAddress(Zeros{24} + 0x083c);
    assert source_state == Zeros{PTO_XLEN} + 3;

    SelectExecutionContext(0, 1); SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{PTO_XLEN} + 1);
    let state = ReadSystemRegisterAddress(Zeros{24} + 0x083c);
    assert state[8] == '1';
    let payload = ReadSystemRegisterAddress(Zeros{24} + 0x0831);
    assert payload == Zeros{PTO_XLEN} + 0xaa;
    SetCurrentACR(1);
    ClearFault();
    WriteSystemRegisterAddress(Zeros{24} + 0x0849, Zeros{PTO_XLEN} + 1);
    assert _LastFault == Fault_IllegalInstruction;
    return 0;
end;
