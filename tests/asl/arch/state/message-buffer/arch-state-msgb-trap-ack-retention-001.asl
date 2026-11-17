// PTO-TEST: {"id":"PTO-AVS-MSGB-TRAP-ACK-RETENTION-001","source":"asl/arch/state/message-buffer.asl","requirements":["PTO-ARCH-MSGB-STATE-001","PTO-ARCH-MSGB-ACK-001","PTO-ARCH-MEMORY-MODEL-TRAP-RESTORE-001"],"kind":"state-transition","summary":"trap recovery does not rewind a committed ACK or its retained receive snapshot","pass_condition":"the recovered context observes the same ACK result, token and immutable payload, then releases the snapshot without another dequeue","related_sources":["asl/arch/state/trap-context.asl","asl/arch/memory-model/fault-precision.asl"]}
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
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{PTO_XLEN} + 0x44);
    ExecuteMessageBufferSend(Zeros{PTO_XLEN} + 16 + (1 << 32));
    SelectExecutionContext(0, 1); SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{PTO_XLEN} + 1);
    let token = ReadSystemRegisterAddress(Zeros{24} + 0x083d);
    let payload_before = ReadSystemRegisterAddress(Zeros{24} + 0x0831);
    assert payload_before == Zeros{PTO_XLEN} + 0x44;
    WriteSystemRegisterAddress(Zeros{24} + 0x0842, token);
    let status_before = ReadSystemRegisterAddress(Zeros{24} + 0x0843);
    assert status_before == Zeros{PTO_XLEN} + 0x101;

    RaiseInterrupt(0 as InterruptID, Zeros{24} + 9);
    assert _TrapContexts[[0]].valid;
    let recovered = RecoverTrapContext(0);
    assert recovered;
    let status_after = ReadSystemRegisterAddress(Zeros{24} + 0x0843);
    let ack_id = ReadSystemRegisterAddress(Zeros{24} + 0x0844);
    let payload_after = ReadSystemRegisterAddress(Zeros{24} + 0x0831);
    assert status_after == Zeros{PTO_XLEN} + 0x101;
    assert ack_id == token;
    assert payload_after == Zeros{PTO_XLEN} + 0x44;
    WriteSystemRegisterAddress(Zeros{24} + 0x0842, token);
    let duplicate_status = ReadSystemRegisterAddress(Zeros{24} + 0x0843);
    assert duplicate_status == Zeros{PTO_XLEN} + 0x102;
    WriteSystemRegisterAddress(Zeros{24} + 0x0841, token);
    return 0;
end;
