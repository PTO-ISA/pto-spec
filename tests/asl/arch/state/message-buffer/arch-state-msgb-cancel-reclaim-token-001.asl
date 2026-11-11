// PTO-TEST: {"id":"PTO-AVS-MSGB-CANCEL-RECLAIM-TOKEN-001","source":"asl/arch/state/message-buffer.asl","requirements":["PTO-ARCH-MSGB-IDENTITY-001","PTO-ARCH-MSGB-ACK-001"],"kind":"state-transition","summary":"reclaiming one queued message changes the receive token without changing its transport identity","pass_condition":"a released token cannot ACK the reclaimed snapshot, while the fresh token consumes the same message identity","related_sources":["asl/arch/state/message-buffer-state.asl"]}
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
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{PTO_XLEN} + 0x55);
    ExecuteMessageBufferSend(Zeros{PTO_XLEN} + 16 + (1 << 32));

    SelectExecutionContext(0, 1); SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{PTO_XLEN} + 1);
    let old_token = ReadSystemRegisterAddress(Zeros{24} + 0x083d);
    let old_hi = ReadSystemRegisterAddress(Zeros{24} + 0x083e);
    let old_lo = ReadSystemRegisterAddress(Zeros{24} + 0x083f);
    WriteSystemRegisterAddress(Zeros{24} + 0x0841, old_token);
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{PTO_XLEN} + 1);
    let new_token = ReadSystemRegisterAddress(Zeros{24} + 0x083d);
    assert new_token != old_token;
    let new_hi = ReadSystemRegisterAddress(Zeros{24} + 0x083e);
    let new_lo = ReadSystemRegisterAddress(Zeros{24} + 0x083f);
    assert new_hi == old_hi;
    assert new_lo == old_lo;
    WriteSystemRegisterAddress(Zeros{24} + 0x0842, old_token);
    let stale_ack_status = ReadSystemRegisterAddress(Zeros{24} + 0x0843);
    let payload = ReadSystemRegisterAddress(Zeros{24} + 0x0831);
    assert stale_ack_status == Zeros{PTO_XLEN} + 0x107;
    assert payload == Zeros{PTO_XLEN} + 0x55;
    WriteSystemRegisterAddress(Zeros{24} + 0x0842, new_token);
    let ack_status = ReadSystemRegisterAddress(Zeros{24} + 0x0843);
    assert ack_status == Zeros{PTO_XLEN} + 0x101;
    return 0;
end;
