// PTO-TEST: {"source":"asl/scalar/model/sys/semantics.asl","requirements":["PTO-THREAD-ID-PE-IDENTITY-001"],"kind":"state-transition","related_sources":["asl/arch/state/pe-execution-context.asl","asl/scalar/sys/SSRGET.asl"],"id":"PTO-AVS-THREAD-ID-FOUR-PE-001","summary":"decoded canonical THREAD_ID distinguishes four PEs launched at a common entry","pass_condition":"each PE reads its own index and preserves its private destination across context switches"}
func main() => integer
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;
    for pe = 0 to 3 do
        SelectExecutionContext(0, pe as MemoryAgentId);
        assert ReadTPC() == entry;
        SetCurrentACR(0);
        BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
            Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x180,
            Zeros{PTO_XLEN}, FALSE);
        EnterBundleBody();
        let status = ExecuteScalarInstruction(Zeros{48} + 0x026001bb, 32);
        assert status == ScalarExecution_Executed;
        assert _LastFault == Fault_None;
        assert ReadGPR(3) == Zeros{PTO_XLEN} + pe;
        assert ReadTPC() == Zeros{PTO_XLEN} + 0x184;
    end;
    for pe = 3 downto 0 do
        SelectExecutionContext(0, pe as MemoryAgentId);
        assert ReadGPR(3) == Zeros{PTO_XLEN} + pe;
        let identity = ReadSystemRegisterAddress(Zeros{24} + 0x26);
        assert identity == Zeros{PTO_XLEN} + pe;
    end;
    return 0;
end;
