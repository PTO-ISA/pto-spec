// PTO-TEST: {"id":"PTO-AVS-BSE-MSGB-REPLAY-IDENTITY-001","source":"asl/scalar/sys/BSE.asl","requirements":["PTO-BSE-DECISION-BINDING-001","PTO-ARCH-MSGB-IDENTITY-001","PTO-ARCH-MSGB-SEND-001"],"kind":"state-transition","summary":"retry of one dynamic BSE occurrence reuses its message identity while a new bundle occurrence allocates another identity","pass_condition":"the retained occurrence reports DUPLICATE without republishing, and after the first message drains a new bundle token admits sequence two","related_sources":["asl/arch/state/message-buffer.asl","asl/block/model/lifecycle/begin.asl"]}
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
    WriteTPC(Zeros{PTO_XLEN} + 0x120);
    BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x180, Zeros{PTO_XLEN}, FALSE);
    EnterBundleBody();
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{PTO_XLEN} + 1);
    let control = Zeros{PTO_XLEN} + 16 + (1 << 32);
    ExecuteMessageBufferSend(control);
    let first_id = ReadSystemRegisterAddress(Zeros{24} + 0x0846);
    ExecuteMessageBufferSend(control + (1 << 32));
    let changed_status = ReadSystemRegisterAddress(Zeros{24} + 0x0847);
    let changed_id = ReadSystemRegisterAddress(Zeros{24} + 0x0846);
    assert changed_status == Zeros{PTO_XLEN} + 0x10c;
    assert changed_id == first_id;
    ExecuteMessageBufferSend(control);
    let replay_status = ReadSystemRegisterAddress(Zeros{24} + 0x0847);
    let replay_id = ReadSystemRegisterAddress(Zeros{24} + 0x0846);
    assert replay_status == Zeros{PTO_XLEN} + 0x102;
    assert replay_id == first_id;

    SelectExecutionContext(0, 1); SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{PTO_XLEN} + 1);
    let token = ReadSystemRegisterAddress(Zeros{24} + 0x083d);
    - = ReadSystemRegisterAddress(Zeros{24} + 0x0831);
    WriteSystemRegisterAddress(Zeros{24} + 0x0842, token);
    WriteSystemRegisterAddress(Zeros{24} + 0x0841, token);

    SelectExecutionContext(0, 0); SetCurrentACR(0);
    StopBundle();
    BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x280, Zeros{PTO_XLEN}, FALSE);
    EnterBundleBody();
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{PTO_XLEN} + 2);
    ExecuteMessageBufferSend(control);
    let next_status = ReadSystemRegisterAddress(Zeros{24} + 0x0847);
    let next_id = ReadSystemRegisterAddress(Zeros{24} + 0x0846);
    assert next_status == Zeros{PTO_XLEN} + 0x101;
    assert next_id == first_id + 1;
    return 0;
end;
