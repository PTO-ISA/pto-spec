// PTO-TEST: {"id":"PTO-AVS-MSGB-SEND-SEQUENCE-EXHAUSTION-001","source":"asl/arch/state/message-buffer-send.asl","requirements":["PTO-ARCH-MSGB-IDENTITY-001","PTO-ARCH-MSGB-SEND-001"],"kind":"boundary","summary":"transmit identity exhaustion rejects admission without wrapping or publishing","pass_condition":"BSE reports EXHAUSTED while the all-ones sequence, empty destination and previous ID outputs remain unchanged","related_sources":["asl/arch/state/message-buffer-state.asl"]}
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
    let bank = MessageBufferEndpointIndexOf(0, 0, 0);
    _MessageBufferBanks[[bank]].transmit_sequence = Ones{PTO_XLEN};
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{PTO_XLEN} + 9);
    ExecuteMessageBufferSend(Zeros{PTO_XLEN} + (1 << 32));
    let status = ReadSystemRegisterAddress(Zeros{24} + 0x0847);
    let id_hi = ReadSystemRegisterAddress(Zeros{24} + 0x0845);
    let id_lo = ReadSystemRegisterAddress(Zeros{24} + 0x0846);
    assert status == Zeros{PTO_XLEN} + 0x10b;
    assert id_hi == Zeros{PTO_XLEN};
    assert id_lo == Zeros{PTO_XLEN};
    assert _MessageBufferBanks[[bank]].transmit_sequence == Ones{PTO_XLEN};
    assert !_MessageBufferBanks[[bank]].queued.valid;
    return 0;
end;
