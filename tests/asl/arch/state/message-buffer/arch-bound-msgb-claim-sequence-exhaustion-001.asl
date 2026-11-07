// PTO-TEST: {"id":"PTO-AVS-MSGB-CLAIM-SEQUENCE-EXHAUSTION-001","source":"asl/arch/state/message-buffer.asl","requirements":["PTO-ARCH-MSGB-IDENTITY-001","PTO-ARCH-MSGB-ACK-001"],"kind":"boundary","summary":"receive claim identity exhaustion preserves the queued message and refuses token wrap","pass_condition":"CLAIM reports EXHAUSTED with no snapshot or token while the queued transport identity remains intact","related_sources":["asl/arch/state/message-buffer-state.asl"]}
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
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{PTO_XLEN} + 9);
    ExecuteMessageBufferSend(Zeros{PTO_XLEN} + (1 << 32));
    let bank = MessageBufferEndpointIndexOf(0, 0, 0);
    let message_hi = _MessageBufferBanks[[bank]].queued.message_id_hi;
    let message_lo = _MessageBufferBanks[[bank]].queued.message_id_lo;
    _MessageBufferBanks[[bank]].claim_sequence = Ones{48};
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{PTO_XLEN} + 1);
    let state = ReadSystemRegisterAddress(Zeros{24} + 0x083c);
    let token = ReadSystemRegisterAddress(Zeros{24} + 0x083d);
    assert state == Zeros{PTO_XLEN} + 11;
    assert token == Zeros{PTO_XLEN};
    assert _MessageBufferBanks[[bank]].queued.valid;
    assert !_MessageBufferBanks[[bank]].snapshot.valid;
    assert _MessageBufferBanks[[bank]].queued.message_id_hi == message_hi;
    assert _MessageBufferBanks[[bank]].queued.message_id_lo == message_lo;
    assert _MessageBufferBanks[[bank]].claim_sequence == Ones{48};
    return 0;
end;
