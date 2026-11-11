// PTO-TEST: {"id":"PTO-AVS-MSGB-LIFECYCLE-DRAIN-001","source":"asl/arch/state/message-buffer.asl","requirements":["PTO-ARCH-MSGB-LIFECYCLE-001","PTO-ARCH-MSGB-SEND-001","PTO-ARCH-KERNEL-LIFECYCLE-001"],"kind":"state-transition","summary":"kernel retirement freezes new message admission while preserving receive operations needed to drain existing state","pass_condition":"End waits with an outstanding message, drain rejects another send, then receive ACK and RELEASE permit retirement and disable the old banks","related_sources":["asl/arch/state/kernel-lifecycle.asl","asl/arch/state/message-buffer-state.asl"]}
func ConfigureMessageContext(pe: MemoryAgentId)
begin
    SelectExecutionContext(0, pe); SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x0849, Zeros{PTO_XLEN});
    WriteSystemRegisterAddress(Zeros{24} + 0x084b, Zeros{PTO_XLEN});
    WriteSystemRegisterAddress(Zeros{24} + 0x084a,
        Zeros{PTO_XLEN} + (1 << 32) + (1 << 16) + 1);
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x100);
    assert launched == KernelLifecycle_Started;
    ConfigureMessageContext(0); ConfigureMessageContext(1);
    SelectExecutionContext(0, 0); SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{PTO_XLEN} + 7);
    ExecuteMessageBufferSend(Zeros{PTO_XLEN} + 16 + (1 << 32));
    let first_end = EndKernelInvocation(0);
    assert first_end == KernelLifecycle_Waiting;
    assert _MessageBufferCoreDraining[[0]];
    _BundleExecutionDomainToken = _BundleExecutionDomainToken + 1;
    ExecuteMessageBufferSend(Zeros{PTO_XLEN} + 16 + (1 << 32));
    let drain_status = ReadSystemRegisterAddress(Zeros{24} + 0x0847);
    assert drain_status == Zeros{PTO_XLEN} + 0x10c;

    SelectExecutionContext(0, 1); SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{PTO_XLEN} + 1);
    let token = ReadSystemRegisterAddress(Zeros{24} + 0x083d);
    let payload = ReadSystemRegisterAddress(Zeros{24} + 0x0831);
    assert payload == Zeros{PTO_XLEN} + 7;
    WriteSystemRegisterAddress(Zeros{24} + 0x0842, token);
    WriteSystemRegisterAddress(Zeros{24} + 0x0841, token);
    let final_end = EndKernelInvocation(0);
    assert final_end == KernelLifecycle_Started;
    assert !_KernelInvocationActiveByCore[[0]];
    assert !_MessageBufferBanks[[MessageBufferEndpointIndexOf(0, 0, 0)]].enabled;
    assert !_MessageBufferBanks[[MessageBufferEndpointIndexOf(0, 1, 0)]].enabled;
    return 0;
end;
