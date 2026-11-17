// PTO-TEST: {"id":"PTO-AVS-MSGB-MAX-PAYLOAD-IDENTITY-001","source":"asl/arch/state/message-buffer.asl","requirements":["PTO-ARCH-MSGB-IDENTITY-001","PTO-ARCH-MSGB-SSR-001","PTO-ARCH-MSGB-SEND-001"],"kind":"state-transition","summary":"a ten-word message preserves its trusted transport identity from BSE admission through receive ACK","pass_condition":"the destination observes all ten staged words, the source and receive message IDs agree, and exact-token ACK consumes one message","related_sources":["asl/arch/state/message-buffer-state.asl","asl/scalar/sys/BSE.asl"]}
func ConfigureMessageContext(pe: MemoryAgentId)
begin
    SelectExecutionContext(0, pe);
    SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x0849, Zeros{PTO_XLEN});
    WriteSystemRegisterAddress(Zeros{24} + 0x084b, Zeros{PTO_XLEN});
    WriteSystemRegisterAddress(Zeros{24} + 0x084a,
        Zeros{PTO_XLEN} + (1 << 32) + (1 << 16) + 1);
    assert _LastFault == Fault_None;
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x100);
    assert launched == KernelLifecycle_Started;
    ConfigureMessageContext(0);
    ConfigureMessageContext(1);

    SelectExecutionContext(0, 0);
    SetCurrentACR(0);
    for word = 0 to 9 do
        WriteSystemRegisterAddress(Zeros{24} + 0x0831 + word,
            Zeros{PTO_XLEN} + 0x100 + word);
    end;
    ExecuteMessageBufferSend(Zeros{PTO_XLEN} + 16 + (10 << 32));
    assert _LastFault == Fault_None;
    let tx_status = ReadSystemRegisterAddress(Zeros{24} + 0x0847);
    assert tx_status == Zeros{PTO_XLEN} + 0x101;
    let tx_id_hi = ReadSystemRegisterAddress(Zeros{24} + 0x0845);
    let tx_id_lo = ReadSystemRegisterAddress(Zeros{24} + 0x0846);
    assert tx_id_hi == Zeros{PTO_XLEN} + 1;
    assert tx_id_lo == Zeros{PTO_XLEN} + 1;

    SelectExecutionContext(0, 1);
    SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{PTO_XLEN} + 1);
    let rx_state = ReadSystemRegisterAddress(Zeros{24} + 0x083c);
    assert rx_state == Zeros{PTO_XLEN} + (10 << 12) + (1 << 8) + 1;
    let token = ReadSystemRegisterAddress(Zeros{24} + 0x083d);
    assert token == Zeros{PTO_XLEN} + (1 << 48) + 1;
    let rx_id_hi = ReadSystemRegisterAddress(Zeros{24} + 0x083e);
    let rx_id_lo = ReadSystemRegisterAddress(Zeros{24} + 0x083f);
    assert rx_id_hi == tx_id_hi;
    assert rx_id_lo == tx_id_lo;
    for word = 0 to 9 do
        let payload = ReadSystemRegisterAddress(Zeros{24} + 0x0831 + word);
        assert payload == Zeros{PTO_XLEN} + 0x100 + word;
    end;
    WriteSystemRegisterAddress(Zeros{24} + 0x0842, token);
    let ack_status = ReadSystemRegisterAddress(Zeros{24} + 0x0843);
    let ack_id = ReadSystemRegisterAddress(Zeros{24} + 0x0844);
    assert ack_status == Zeros{PTO_XLEN} + 0x101;
    assert ack_id == token;
    WriteSystemRegisterAddress(Zeros{24} + 0x0841, token);
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{PTO_XLEN} + 1);
    let empty_state = ReadSystemRegisterAddress(Zeros{24} + 0x083c);
    assert empty_state == Zeros{PTO_XLEN} + 3;
    return 0;
end;
