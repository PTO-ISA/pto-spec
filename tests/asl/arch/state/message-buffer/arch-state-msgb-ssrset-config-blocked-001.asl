// PTO-TEST: {"id":"PTO-AVS-MSGB-SSRSET-CONFIG-BLOCKED-001","source":"asl/arch/state/message-buffer.asl","requirements":["PTO-ARCH-MSGB-SSR-001","PTO-ARCH-MSGB-SEND-001","PTO-ARCH-GM-OBLIGATIONS-001"],"kind":"state-transition","summary":"encoded configuration SSRSET waits behind an earlier fault-capable GM obligation before reading its source or changing persistent state","pass_condition":"the instruction reports Blocked without a fault, TPC advance, source change or selector update","related_sources":["asl/arch/memory-model/gm-obligations.asl","asl/scalar/sys/SSRSET.asl"]}
func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x100);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x0849, Zeros{PTO_XLEN});
    WriteSystemRegisterAddress(Zeros{24} + 0x084b, Zeros{PTO_XLEN});
    WriteSystemRegisterAddress(Zeros{24} + 0x084a,
        Zeros{PTO_XLEN} + (1 << 32) + (1 << 16) + 1);

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
    WriteGPR(5, Zeros{PTO_XLEN} + 1);
    let before_tpc = ReadTPC();
    let status = ExecuteScalarInstruction(
        ZeroExtend{48}(Zeros{32} + 0x8492903b), 32);
    assert _LastFault == Fault_None;
    assert status == ScalarExecution_Blocked;
    assert ReadTPC() == before_tpc;
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 1;
    assert _MessageBufferConfigSelectors[[0]][[0]][[0]] == 0;
    assert _MessageBufferConfigSelectors[[0]][[0]][[1]] == 0;
    return 0;
end;
