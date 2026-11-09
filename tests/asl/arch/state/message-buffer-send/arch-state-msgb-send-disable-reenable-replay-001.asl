// PTO-TEST: {"id":"PTO-AVS-MSGB-SEND-DISABLE-REENABLE-REPLAY-001","source":"asl/arch/state/message-buffer-send.asl","requirements":["PTO-ARCH-MSGB-SEND-001","PTO-ARCH-MSGB-IDENTITY-001","PTO-ARCH-MSGB-STATE-001"],"kind":"state-transition","summary":"temporary disable and same-invocation re-enable preserve an admitted BSE replay identity","pass_condition":"exact replay after disable and re-enable returns DUPLICATE with the original transport identity and does not enqueue another message","related_sources":["asl/arch/state/message-buffer.asl","asl/arch/state/message-buffer-state.asl"]}
func ConfigureDisableReplayContext(pe: MemoryAgentId)
begin
    SelectExecutionContext(0, pe);
    SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x0849, Zeros{PTO_XLEN});
    WriteSystemRegisterAddress(Zeros{24} + 0x084b, Zeros{PTO_XLEN});
    WriteSystemRegisterAddress(Zeros{24} + 0x084a,
        Zeros{PTO_XLEN} + (1 << 32) + (1 << 16) + 1);
end;

func ConsumeDisableReplayMessage(expected: Word)
begin
    SelectExecutionContext(0, 1);
    SetCurrentACR(0);
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
    ConfigureDisableReplayContext(0);
    ConfigureDisableReplayContext(1);

    SelectExecutionContext(0, 0);
    SetCurrentACR(0);
    WriteTPC(Zeros{PTO_XLEN} + 0x120);
    BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x180,
        Zeros{PTO_XLEN}, FALSE);
    EnterBundleBody();
    let occurrence = _BundleExecutionDomainToken;
    let occurrence_pc = ReadTPC();
    let control = Zeros{PTO_XLEN} + 16 + (1 << 32);
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{PTO_XLEN} + 0x55);
    ExecuteMessageBufferSend(control);
    let original_hi = ReadSystemRegisterAddress(Zeros{24} + 0x0845);
    let original_lo = ReadSystemRegisterAddress(Zeros{24} + 0x0846);
    assert original_lo == Zeros{PTO_XLEN} + 1;
    ConsumeDisableReplayMessage(Zeros{PTO_XLEN} + 0x55);

    SelectExecutionContext(0, 0);
    SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x0849, Zeros{PTO_XLEN});
    WriteSystemRegisterAddress(Zeros{24} + 0x084a, Zeros{PTO_XLEN});
    assert !MessageBufferEnabledForCurrentContext();
    WriteSystemRegisterAddress(Zeros{24} + 0x084a,
        Zeros{PTO_XLEN} + (1 << 32) + (1 << 16) + 1);
    assert MessageBufferEnabledForCurrentContext();

    _BundleExecutionDomainToken = occurrence;
    WriteTPC(occurrence_pc);
    ExecuteMessageBufferSend(control);
    assert ReadSystemRegisterAddress(Zeros{24} + 0x0847) ==
        Zeros{PTO_XLEN} + 0x102;
    assert ReadSystemRegisterAddress(Zeros{24} + 0x0845) == original_hi;
    assert ReadSystemRegisterAddress(Zeros{24} + 0x0846) == original_lo;
    let destination = MessageBufferEndpointIndexOf(0, 1, 0);
    assert !_MessageBufferBanks[[destination]].queued.valid;
    return 0;
end;
