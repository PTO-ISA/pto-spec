// PTO-TEST: {"id":"PTO-AVS-MSGB-SSRGET-PRECISE-001","source":"asl/arch/state/message-buffer.asl","requirements":["PTO-ARCH-MSGB-SSR-001","PTO-ARCH-MSGB-STATE-001"],"kind":"fault","summary":"a receive-data SSRGET without an active claim faults before changing the scalar destination or message state","pass_condition":"the destination sentinel and empty queue state remain unchanged while IllegalInstruction is recorded","related_sources":["asl/scalar/model/sys/registers.asl","asl/scalar/sys/SSRGET.asl"]}
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
    ClearFault();
    WriteGPR(3, Zeros{PTO_XLEN} + 0xdead);
    ExecuteSystemRegisterGet(3, Zeros{24} + 0x0831);
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0xdead;
    ClearFault();
    let state = ReadSystemRegisterAddress(Zeros{24} + 0x083c);
    assert state == Zeros{PTO_XLEN};
    return 0;
end;
