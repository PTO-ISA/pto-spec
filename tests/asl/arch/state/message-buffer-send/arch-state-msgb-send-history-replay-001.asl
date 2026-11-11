// PTO-TEST: {"id":"PTO-AVS-MSGB-SEND-HISTORY-REPLAY-001","source":"asl/arch/state/message-buffer-send.asl","requirements":["PTO-ARCH-MSGB-SEND-001","PTO-ARCH-MSGB-IDENTITY-001"],"kind":"state-transition","summary":"an admitted BSE occurrence retains its replay receipt across another admitted occurrence and same-invocation reconfiguration","pass_condition":"changed control for the old occurrence rejects, exact replay returns its original identity, and neither action publishes a third message","related_sources":["asl/arch/state/message-buffer.asl","asl/arch/state/message-buffer-state.asl","asl/block/model/lifecycle/begin.asl"]}
func ConfigureMessageContext(pe: MemoryAgentId)
begin
    SelectExecutionContext(0, pe); SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x0849, Zeros{PTO_XLEN});
    WriteSystemRegisterAddress(Zeros{24} + 0x084b, Zeros{PTO_XLEN});
    WriteSystemRegisterAddress(Zeros{24} + 0x084a,
        Zeros{PTO_XLEN} + (1 << 32) + (1 << 16) + 1);
end;

func ConsumeDestinationWord(expected: Word)
begin
    SelectExecutionContext(0, 1); SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{PTO_XLEN} + 1);
    let token = ReadSystemRegisterAddress(Zeros{24} + 0x083d);
    let payload = ReadSystemRegisterAddress(Zeros{24} + 0x0831);
    assert payload == expected;
    WriteSystemRegisterAddress(Zeros{24} + 0x0842, token);
    WriteSystemRegisterAddress(Zeros{24} + 0x0841, token);
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x100);
    assert launched == KernelLifecycle_Started;
    ConfigureMessageContext(0); ConfigureMessageContext(1);

    SelectExecutionContext(0, 0); SetCurrentACR(0);
    WriteTPC(Zeros{PTO_XLEN} + 0x120);
    BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x180, Zeros{PTO_XLEN}, FALSE);
    EnterBundleBody();
    let occurrence_a = _BundleExecutionDomainToken;
    let pc_a = ReadTPC();
    let control = Zeros{PTO_XLEN} + 16 + (1 << 32);
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{PTO_XLEN} + 1);
    ExecuteMessageBufferSend(control);
    let id_a_hi = ReadSystemRegisterAddress(Zeros{24} + 0x0845);
    let id_a_lo = ReadSystemRegisterAddress(Zeros{24} + 0x0846);
    ConsumeDestinationWord(Zeros{PTO_XLEN} + 1);

    SelectExecutionContext(0, 0); SetCurrentACR(0);
    StopBundle();
    BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x280, Zeros{PTO_XLEN}, FALSE);
    EnterBundleBody();
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{PTO_XLEN} + 2);
    ExecuteMessageBufferSend(control);
    let id_b_lo = ReadSystemRegisterAddress(Zeros{24} + 0x0846);
    assert id_b_lo == id_a_lo + 1;
    ConsumeDestinationWord(Zeros{PTO_XLEN} + 2);

    SelectExecutionContext(0, 0); SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x0849, Zeros{PTO_XLEN});
    WriteSystemRegisterAddress(Zeros{24} + 0x084a,
        Zeros{PTO_XLEN} + (1 << 32) + (1 << 16) + 1);
    _BundleExecutionDomainToken = occurrence_a;
    WriteTPC(pc_a);
    ExecuteMessageBufferSend(control + (1 << 32));
    let changed_status = ReadSystemRegisterAddress(Zeros{24} + 0x0847);
    let changed_hi = ReadSystemRegisterAddress(Zeros{24} + 0x0845);
    let changed_lo = ReadSystemRegisterAddress(Zeros{24} + 0x0846);
    assert changed_status == Zeros{PTO_XLEN} + 0x10c;
    assert changed_hi == id_a_hi;
    assert changed_lo == id_a_lo;
    ExecuteMessageBufferSend(control);
    let replay_status = ReadSystemRegisterAddress(Zeros{24} + 0x0847);
    let replay_hi = ReadSystemRegisterAddress(Zeros{24} + 0x0845);
    let replay_lo = ReadSystemRegisterAddress(Zeros{24} + 0x0846);
    assert replay_status == Zeros{PTO_XLEN} + 0x102;
    assert replay_hi == id_a_hi;
    assert replay_lo == id_a_lo;
    let destination = MessageBufferEndpointIndexOf(0, 1, 0);
    assert !_MessageBufferBanks[[destination]].queued.valid;
    return 0;
end;
