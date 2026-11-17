// PTO-TEST: {"id":"PTO-AVS-MSGB-DIAGNOSTIC-ACCESS-001","source":"asl/arch/state/message-buffer.asl","requirements":["PTO-ARCH-MSGB-SSR-001","PTO-ARCH-MSGB-STATE-001"],"kind":"fault","summary":"operational SSRGET requires the enabled kernel bank even for a diagnostic register","pass_condition":"disabled and non-kernel attempts fault before changing the destination, while an enabled kernel can read the same register","related_sources":["asl/scalar/model/sys/registers.asl","asl/scalar/sys/SSRGET.asl"]}
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
    let status_address = Zeros{24} + 0x0847;
    WriteGPR(3, Zeros{64} + 0xdead);
    ExecuteSystemRegisterGet(3, status_address);
    assert _LastFault == Fault_None && ReadGPR(3) == Zeros{64};
    WriteGPR(3, Zeros{64} + 0xdead);
    _CurrentMemoryOrigin = MemoryEventOrigin_Handler;
    ExecuteSystemRegisterGet(3, status_address);
    assert _LastFault == Fault_IllegalInstruction && ReadGPR(3) == Zeros{64} + 0xdead;
    _CurrentMemoryOrigin = MemoryEventOrigin_Kernel;
    ClearFault();
    WriteSystemRegisterAddress(Zeros{24} + 0x084a, Zeros{64});
    ExecuteSystemRegisterGet(3, status_address);
    assert _LastFault == Fault_IllegalInstruction && ReadGPR(3) == Zeros{64} + 0xdead;
    return 0;
end;
