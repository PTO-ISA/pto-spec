// PTO-TEST: {"id":"PTO-AVS-MSGB-PARTIAL-READ-ACK-001","source":"asl/arch/state/message-buffer.asl","requirements":["PTO-ARCH-MSGB-ACK-001","PTO-ARCH-MSGB-SSR-001"],"kind":"state-transition","summary":"ACK cannot consume a message until every valid receive word has been read","pass_condition":"a partial read returns NOT_READ without dequeue, then complete reads allow one ACK and preserve the ACKED snapshot until release","related_sources":["asl/arch/state/message-buffer-state.asl"]}
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
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{PTO_XLEN} + 11);
    WriteSystemRegisterAddress(Zeros{24} + 0x0832, Zeros{PTO_XLEN} + 22);
    ExecuteMessageBufferSend(Zeros{PTO_XLEN} + 16 + (2 << 32));

    SelectExecutionContext(0, 1); SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{PTO_XLEN} + 1);
    let token = ReadSystemRegisterAddress(Zeros{24} + 0x083d);
    let first_word = ReadSystemRegisterAddress(Zeros{24} + 0x0831);
    assert first_word == Zeros{PTO_XLEN} + 11;
    WriteSystemRegisterAddress(Zeros{24} + 0x0842, token);
    let not_read_status = ReadSystemRegisterAddress(Zeros{24} + 0x0843);
    assert not_read_status == Zeros{PTO_XLEN} + 0x10a;
    let state = ReadSystemRegisterAddress(Zeros{24} + 0x083c);
    assert state[8] == '1';
    let second_word = ReadSystemRegisterAddress(Zeros{24} + 0x0832);
    assert second_word == Zeros{PTO_XLEN} + 22;
    WriteSystemRegisterAddress(Zeros{24} + 0x0842, token);
    let ack_status = ReadSystemRegisterAddress(Zeros{24} + 0x0843);
    let retained_first = ReadSystemRegisterAddress(Zeros{24} + 0x0831);
    let retained_second = ReadSystemRegisterAddress(Zeros{24} + 0x0832);
    assert ack_status == Zeros{PTO_XLEN} + 0x101;
    assert retained_first == Zeros{PTO_XLEN} + 11;
    assert retained_second == Zeros{PTO_XLEN} + 22;
    WriteSystemRegisterAddress(Zeros{24} + 0x0841, token);
    return 0;
end;
