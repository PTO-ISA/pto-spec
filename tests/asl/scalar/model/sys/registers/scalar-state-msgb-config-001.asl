// PTO-TEST: {"id":"PTO-AVS-MSGB-CONFIG-001","source":"asl/scalar/model/sys/registers.asl","requirements":["PTO-ARCH-MSGB-SSR-001"],"kind":"state-transition","summary":"ACR0 installs a current-kernel message context through actual SSR writes","pass_condition":"configuration and endpoint discovery succeed without a fault","related_sources":["asl/arch/state/message-buffer.asl"]}
func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x100);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x0849, Zeros{PTO_XLEN});
    assert _LastFault == Fault_None;
    WriteSystemRegisterAddress(Zeros{24} + 0x084b, Zeros{PTO_XLEN});
    assert _LastFault == Fault_None;
    WriteSystemRegisterAddress(Zeros{24} + 0x084a,
        Zeros{PTO_XLEN} + 0x0000000100010001);
    assert _LastFault == Fault_None;
    let configuration = ReadSystemRegisterAddress(Zeros{24} + 0x084a);
    assert configuration == Zeros{PTO_XLEN} + 0x0000000100010001;
    let endpoint = ReadSystemRegisterAddress(Zeros{24} + 0x0848);
    assert endpoint == Zeros{PTO_XLEN};
    return 0;
end;
