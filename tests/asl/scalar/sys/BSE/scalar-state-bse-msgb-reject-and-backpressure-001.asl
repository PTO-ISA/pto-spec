// PTO-TEST: {"id":"PTO-AVS-BSE-MSGB-REJECT-BACKPRESSURE-001","source":"asl/scalar/sys/BSE.asl","requirements":["PTO-BSE-DECISION-BINDING-001","PTO-ARCH-MSGB-SEND-001"],"kind":"state-transition","summary":"reserved control bits and a full destination reject BSE admission without allocating another message identity","pass_condition":"BAD_COMMAND and BUSY retain the previous transmit sequence and destination message","related_sources":["asl/arch/state/message-buffer.asl"]}
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
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{PTO_XLEN} + 0x11);
    ExecuteMessageBufferSend(Zeros{PTO_XLEN} + 16 + (1 << 32));
    let accepted_id = ReadSystemRegisterAddress(Zeros{24} + 0x0846);
    assert accepted_id == Zeros{PTO_XLEN} + 1;

    _BundleExecutionDomainToken = _BundleExecutionDomainToken + 1;
    ExecuteMessageBufferSend(Zeros{PTO_XLEN} + 16 + (1 << 36));
    let bad_status = ReadSystemRegisterAddress(Zeros{24} + 0x0847);
    let bad_id = ReadSystemRegisterAddress(Zeros{24} + 0x0846);
    assert bad_status == Zeros{PTO_XLEN} + 0x10c;
    assert bad_id == accepted_id;
    _BundleExecutionDomainToken = _BundleExecutionDomainToken + 1;
    ExecuteMessageBufferSend(Zeros{PTO_XLEN} + 16 + (1 << 32));
    let busy_status = ReadSystemRegisterAddress(Zeros{24} + 0x0847);
    let busy_id = ReadSystemRegisterAddress(Zeros{24} + 0x0846);
    assert busy_status == Zeros{PTO_XLEN} + 0x104;
    assert busy_id == accepted_id;

    SelectExecutionContext(0, 1); SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{PTO_XLEN} + 1);
    let payload = ReadSystemRegisterAddress(Zeros{24} + 0x0831);
    assert payload == Zeros{PTO_XLEN} + 0x11;
    return 0;
end;
