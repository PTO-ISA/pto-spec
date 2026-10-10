// PTO-TEST: {"source":"asl/scalar/model/sys/semantics.asl","requirements":["PTO-THREAD-ID-PE-IDENTITY-001"],"kind":"state-transition","related_sources":["asl/arch/state/pe-execution-context.asl","asl/scalar/sys/SSRGET.asl"],"id":"PTO-AVS-THREAD-ID-REJECTIONS-001","summary":"canonical writes and retired-address reads retain access faults","pass_condition":"rejected accesses preserve PE identity and scalar destination"}
func main() => integer
begin
    for attempt = 0 to 3 do
        ResetProfileState();
        SelectExecutionContext(0, 2);
        SetCurrentACR(0);
        WriteTPC(Zeros{PTO_XLEN} + 0x100);
        BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
            Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x180,
            Zeros{PTO_XLEN}, FALSE);
        EnterBundleBody();
        WriteGPR(3, Zeros{PTO_XLEN} + 0x333);
        WriteGPR(5, Zeros{PTO_XLEN} + 0x555);
        let encoding = if attempt == 0 then Zeros{48} + 0x0262903b else
            if attempt == 1 then Zeros{48} + 0x0262a1bb else
            if attempt == 2 then Zeros{48} + 0x0262903b000e else
            Zeros{48} + 0x802001bb;
        let width = if attempt == 2 then 48 else 32;
        let status = ExecuteScalarInstruction(encoding, width as integer {16,32,48});
        assert status == ScalarExecution_Rejected;
        assert _LastFault == Fault_IllegalInstruction;
        assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x333;
        assert ReadGPR(5) == Zeros{PTO_XLEN} + 0x555;
        assert _TrapContexts[[0]].valid;
        assert _TrapContexts[[0]].tpc == Zeros{PTO_XLEN} + 0x180;
        assert !_TQueueValid[[0]];
        assert !_UQueueValid[[0]];
        let identity = ReadSystemRegister(SystemRegister_THREAD_ID);
        assert identity == Zeros{PTO_XLEN} + 2;
    end;
    return 0;
end;
