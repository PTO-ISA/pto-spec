// PTO-TEST: {"id":"PTO-AVS-MSGB-CLAIM-SEQUENCE-EXHAUSTION-001","source":"asl/arch/state/message-buffer.asl","requirements":["PTO-ARCH-MSGB-IDENTITY-001","PTO-ARCH-MSGB-ACK-001","PTO-ARCH-MSGB-SEND-001"],"kind":"boundary","summary":"receive claim identity exhaustion rejects new transport admission before publication","pass_condition":"BSE reports EXHAUSTED without consuming a transport identity or publishing a packet to the exhausted destination","related_sources":["asl/arch/state/message-buffer-state.asl","asl/arch/state/message-buffer-send.asl"]}
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
    _MessageBufferBanks[[bank]].claim_sequence = Ones{48};
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{PTO_XLEN} + 9);
    ExecuteMessageBufferSend(Zeros{PTO_XLEN} + (1 << 32));
    let state = ReadSystemRegisterAddress(Zeros{24} + 0x0847);
    assert state == Zeros{PTO_XLEN} + 0x10b;
    assert !_MessageBufferBanks[[bank]].queued.valid;
    assert !_MessageBufferBanks[[bank]].snapshot.valid;
    assert _MessageBufferBanks[[bank]].claim_sequence == Ones{48};
    assert _MessageBufferBanks[[bank]].transmit_sequence == Zeros{PTO_XLEN};
    return 0;
end;
