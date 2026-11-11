// PTO-TEST: {"id":"PTO-AVS-MSGB-DUPLICATE-ACK-NEW-CLAIM-001","source":"asl/arch/state/message-buffer.asl","requirements":["PTO-ARCH-MSGB-ACK-001","PTO-ARCH-MSGB-IDENTITY-001"],"kind":"state-transition","summary":"replaying the latest successful ACK never disturbs a later message claim","pass_condition":"the old token reports DUPLICATE while the new token and unread payload remain active and can subsequently be ACKed","related_sources":["asl/arch/state/message-buffer-state.asl"]}
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
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{PTO_XLEN} + 1);
    ExecuteMessageBufferSend(Zeros{PTO_XLEN} + 16 + (1 << 32));
    SelectExecutionContext(0, 1); SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{PTO_XLEN} + 1);
    let old_token = ReadSystemRegisterAddress(Zeros{24} + 0x083d);
    - = ReadSystemRegisterAddress(Zeros{24} + 0x0831);
    WriteSystemRegisterAddress(Zeros{24} + 0x0842, old_token);
    WriteSystemRegisterAddress(Zeros{24} + 0x0841, old_token);

    SelectExecutionContext(0, 0); SetCurrentACR(0);
    _BundleExecutionDomainToken = _BundleExecutionDomainToken + 1;
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{PTO_XLEN} + 2);
    ExecuteMessageBufferSend(Zeros{PTO_XLEN} + 16 + (1 << 32));
    SelectExecutionContext(0, 1); SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{PTO_XLEN} + 1);
    let new_token = ReadSystemRegisterAddress(Zeros{24} + 0x083d);
    assert new_token != old_token;
    WriteSystemRegisterAddress(Zeros{24} + 0x0842, old_token);
    let duplicate_status = ReadSystemRegisterAddress(Zeros{24} + 0x0843);
    let retained_token = ReadSystemRegisterAddress(Zeros{24} + 0x083d);
    let payload = ReadSystemRegisterAddress(Zeros{24} + 0x0831);
    assert duplicate_status == Zeros{PTO_XLEN} + 0x102;
    assert retained_token == new_token;
    assert payload == Zeros{PTO_XLEN} + 2;
    WriteSystemRegisterAddress(Zeros{24} + 0x0842, new_token);
    let ack_status = ReadSystemRegisterAddress(Zeros{24} + 0x0843);
    assert ack_status == Zeros{PTO_XLEN} + 0x101;
    return 0;
end;
