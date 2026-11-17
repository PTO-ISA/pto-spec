// PTO-TEST: {"id":"PTO-AVS-BSE-MSGB-ZERO-PAYLOAD-001","source":"asl/scalar/sys/BSE.asl","requirements":["PTO-BSE-DECISION-BINDING-001","PTO-ARCH-MSGB-SEND-001","PTO-ARCH-MSGB-ACK-001"],"kind":"execution","summary":"encoded BSE admits a zero-word message under an enabled MSGB context","pass_condition":"the decoded BSE advances once, assigns one message identity, and the receiver can ACK the empty snapshot without reading payload words","related_sources":["asl/arch/state/message-buffer-send.asl","asl/scalar/model/dispatch/sys.asl"]}
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
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x180,
        Zeros{PTO_XLEN}, FALSE);
    EnterBundleBody();
    WriteGPR(5, Zeros{PTO_XLEN} + 16);
    let status = ExecuteScalarInstruction(
        '000000000000000000000000000000101000000000101011', 32);
    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x184;
    let tx_id = ReadSystemRegisterAddress(Zeros{24} + 0x0846);
    assert tx_id == Zeros{PTO_XLEN} + 1;

    SelectExecutionContext(0, 1); SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{PTO_XLEN} + 1);
    let state = ReadSystemRegisterAddress(Zeros{24} + 0x083c);
    assert state == Zeros{PTO_XLEN} + (1 << 8) + 1;
    let token = ReadSystemRegisterAddress(Zeros{24} + 0x083d);
    WriteSystemRegisterAddress(Zeros{24} + 0x0842, token);
    let ack_status = ReadSystemRegisterAddress(Zeros{24} + 0x0843);
    assert ack_status == Zeros{PTO_XLEN} + 0x101;
    return 0;
end;
