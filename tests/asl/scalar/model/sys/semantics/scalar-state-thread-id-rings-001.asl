// PTO-TEST: {"source":"asl/scalar/model/sys/semantics.asl","requirements":["PTO-THREAD-ID-PE-IDENTITY-001"],"kind":"state-transition","related_sources":["asl/arch/state/pe-execution-context.asl","asl/scalar/sys/SSRGET.asl"],"id":"PTO-AVS-THREAD-ID-RINGS-001","summary":"canonical identity is read-only at every ACR","pass_condition":"each ACR observes PE3 and no identity mutation occurs"}
func main() => integer
begin
    ResetProfileState();
    SelectExecutionContext(0, 3);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x180,
        Zeros{PTO_XLEN}, FALSE);
    EnterBundleBody();
    for ring = 0 to 15 do
        SetCurrentACR(ring as AccessControlRing);
        let short_status = ExecuteScalarInstruction(Zeros{48} + 0x026001bb, 32);
        assert short_status == ScalarExecution_Executed;
        assert ReadGPR(3) == Zeros{PTO_XLEN} + 3;
        let long_status = ExecuteScalarInstruction(Zeros{48} + 0x026001bb000e, 48);
        assert long_status == ScalarExecution_Executed;
        assert ReadGPR(3) == Zeros{PTO_XLEN} + 3;
        assert ReadTPC() == Zeros{PTO_XLEN} + 0x180 + (ring + 1) * 10;
        assert _LastFault == Fault_None;
        assert !SystemRegisterWritePermitted(Zeros{24} + 0x26);
        assert !SystemRegisterSwapPermitted(Zeros{24} + 0x26);
    end;
    return 0;
end;
