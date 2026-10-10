// PTO-TEST: {"source":"asl/scalar/model/sys/semantics.asl","requirements":["PTO-THREAD-ID-PE-IDENTITY-001"],"kind":"state-transition","related_sources":["asl/arch/state/pe-execution-context.asl","asl/scalar/sys/SSRGET.asl"],"id":"PTO-AVS-THREAD-ID-LIFECYCLE-001","summary":"PE identity survives Core selection and kernel retirement","pass_condition":"direct-boot and relaunched PEs retain their own indices and reset selects PE0"}
func main() => integer
begin
    ResetProfileState();
    for core = 0 to 1 do
        for pe = 0 to 3 do
            SelectExecutionContext(core as PTOModelCoreIdentity, pe as MemoryAgentId);
            let before = ReadSystemRegister(SystemRegister_THREAD_ID);
            assert before == Zeros{PTO_XLEN} + pe;
        end;
    end;
    let entry = Zeros{PTO_XLEN} + 0x100;
    let launched = LaunchKernelInvocation(0, entry);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0, 3);
    RaiseInterrupt(0 as InterruptID, Zeros{24} + 9);
    assert _CurrentMemoryOrigin == MemoryEventOrigin_Handler;
    let handler_id = ReadSystemRegister(SystemRegister_THREAD_ID);
    assert handler_id == Zeros{PTO_XLEN} + 3;
    SelectExecutionContext(0, 1);
    let peer_id = ReadSystemRegister(SystemRegister_THREAD_ID);
    assert peer_id == Zeros{PTO_XLEN} + 1;
    SelectExecutionContext(0, 3);
    let returned = RecoverTrapContext(CurrentACR());
    assert returned;
    assert _CurrentMemoryOrigin == MemoryEventOrigin_Kernel;
    assert ReadTPC() == entry;
    BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN}, entry + 4, Zeros{PTO_XLEN}, FALSE);
    EnterBundleBody();
    for retry = 0 to 1 do
        let rejected = ExecuteScalarInstruction(Zeros{48} + 0x802001bb, 32);
        assert rejected == ScalarExecution_Rejected;
        assert _LastFault == Fault_IllegalInstruction;
        let fault_id = ReadSystemRegister(SystemRegister_THREAD_ID);
        assert fault_id == Zeros{PTO_XLEN} + 3;
        let recovered = RecoverTrapContext(CurrentACR());
        assert recovered;
        assert ReadTPC() == entry + 4;
    end;
    let read_status = ExecuteScalarInstruction(Zeros{48} + 0x026001bb, 32);
    assert read_status == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 3;
    let aborted = AbortKernelInvocation(0);
    assert aborted == KernelLifecycle_Started;
    let relaunched = LaunchKernelInvocation(0, entry + 0x100);
    assert relaunched == KernelLifecycle_Started;
    for pe = 0 to 3 do
        SelectExecutionContext(0, pe as MemoryAgentId);
        let after = ReadSystemRegister(SystemRegister_THREAD_ID);
        assert after == Zeros{PTO_XLEN} + pe;
        assert ReadTPC() == entry + 0x100;
    end;
    ResetProfileState();
    let reset_id = ReadSystemRegister(SystemRegister_THREAD_ID);
    assert reset_id == Zeros{PTO_XLEN};
    return 0;
end;
