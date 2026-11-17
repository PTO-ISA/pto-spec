// PTO-TEST: {"id":"PTO-AVS-MSGB-SSRGET-BLOCKED-001","source":"asl/arch/state/message-buffer.asl","requirements":["PTO-ARCH-MSGB-SSR-001","PTO-ARCH-MSGB-SEND-001","PTO-ARCH-GM-OBLIGATIONS-001"],"kind":"state-transition","summary":"encoded SSRGET defers an irrevocable receive observation behind an earlier fault-capable GM obligation","pass_condition":"the decoded instruction reports Blocked without a fault, destination, TPC, read-mask or queue effect","related_sources":["asl/arch/memory-model/gm-obligations.asl","asl/scalar/sys/SSRGET.asl"]}
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
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{PTO_XLEN} + 0x66);
    ExecuteMessageBufferSend(Zeros{PTO_XLEN} + (1 << 32));
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{PTO_XLEN} + 1);
    let token = ReadSystemRegisterAddress(Zeros{24} + 0x083d);
    assert token != Zeros{PTO_XLEN};

    let obligation = 0 as GMObligationIndex;
    _GMObligations[[0]][[0]][[obligation]].active = TRUE;
    _GMObligations[[0]][[0]][[obligation]].invocation = _CurrentKernelInvocation;
    _GMObligations[[0]][[0]][[obligation]].submission_order = 0;
    _GMObligations[[0]][[0]][[obligation]].may_fault = TRUE;
    _GMObligations[[0]][[0]][[obligation]].state = GMObligation_Issued;
    WriteTPC(Zeros{PTO_XLEN} + 0x140);
    BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x180,
        Zeros{PTO_XLEN}, FALSE);
    EnterBundleBody();
    WriteGPR(5, Zeros{PTO_XLEN} + 0xdead);
    let before_tpc = ReadTPC();
    let status = ExecuteScalarInstruction(
        ZeroExtend{48}(Zeros{32} + 0x83e002bb), 32);
    assert status == ScalarExecution_Blocked;
    assert _LastFault == Fault_None;
    assert ReadTPC() == before_tpc;
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 0xdead;
    let bank = MessageBufferEndpointIndexOf(0, 0, 0);
    assert _MessageBufferBanks[[bank]].snapshot.read_mask == Zeros{10};
    assert _MessageBufferBanks[[bank]].queued.valid;
    return 0;
end;
