// PTO-TEST: {"id":"PTO-AVS-MSGB-FINAL-CLAIM-RELEASE-001","source":"asl/arch/state/message-buffer.asl","requirements":["PTO-ARCH-MSGB-IDENTITY-001","PTO-ARCH-MSGB-ACK-001","PTO-ARCH-MSGB-LIFECYCLE-001"],"kind":"boundary","summary":"the final receive claim cannot be cancelled before ACK and remains drainable","pass_condition":"RELEASE reports EXHAUSTED and preserves the final unacknowledged snapshot, after which read, ACK and RELEASE drain the bank and permit kernel retirement","related_sources":["asl/arch/state/message-buffer-send.asl","asl/arch/state/kernel-lifecycle.asl"]}
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
    _MessageBufferBanks[[bank]].claim_sequence = Ones{48} - 1;
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{PTO_XLEN} + 9);
    ExecuteMessageBufferSend(Zeros{PTO_XLEN} + (1 << 32));
    let send_status = ReadSystemRegisterAddress(Zeros{24} + 0x0847);
    assert send_status == Zeros{PTO_XLEN} + 0x101;

    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{PTO_XLEN} + 1);
    let token = ReadSystemRegisterAddress(Zeros{24} + 0x083d);
    assert token[47:0] == Ones{48};
    WriteSystemRegisterAddress(Zeros{24} + 0x0841, token);
    let blocked_release = ReadSystemRegisterAddress(Zeros{24} + 0x083c);
    assert blocked_release == Zeros{PTO_XLEN} + 0x110b;
    assert _MessageBufferBanks[[bank]].queued.valid;
    assert _MessageBufferBanks[[bank]].snapshot.valid;
    assert !_MessageBufferBanks[[bank]].snapshot.acked;

    let payload = ReadSystemRegisterAddress(Zeros{24} + 0x0831);
    assert payload == Zeros{PTO_XLEN} + 9;
    WriteSystemRegisterAddress(Zeros{24} + 0x0842, token);
    let ack_status = ReadSystemRegisterAddress(Zeros{24} + 0x0843);
    assert ack_status == Zeros{PTO_XLEN} + 0x101;
    assert !_MessageBufferBanks[[bank]].queued.valid;
    assert _MessageBufferBanks[[bank]].snapshot.acked;
    WriteSystemRegisterAddress(Zeros{24} + 0x0841, token);
    let final_release = ReadSystemRegisterAddress(Zeros{24} + 0x083c);
    assert final_release == Zeros{PTO_XLEN} + 1;
    assert !_MessageBufferBanks[[bank]].snapshot.valid;
    let retired = EndKernelInvocation(0);
    assert retired == KernelLifecycle_Started;
    assert !_KernelInvocationActiveByCore[[0]];
    return 0;
end;
