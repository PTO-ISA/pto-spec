// PTO-TEST: {"source":"asl/scalar/model/sys/semantics.asl","requirements":["PTO-THREAD-ID-PE-IDENTITY-001"],"kind":"state-transition","related_sources":["asl/arch/state/pe-execution-context.asl","asl/scalar/sys/SSRGET.asl"],"id":"PTO-AVS-THREAD-ID-PLACEMENT-001","summary":"canonical THREAD_ID does not legalize SSRGET in Standard Blocks","pass_condition":"illegal placement rejects before destination and identity effects"}
func main() => integer
begin
    ResetProfileState();
    SelectExecutionContext(0, 1);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    BeginBundle(BundleKind_Standard, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x180,
        Zeros{PTO_XLEN}, FALSE);
    EnterBundleBody();
    WriteGPR(3, Zeros{PTO_XLEN} + 0x333);
    let status = ExecuteScalarInstruction(Zeros{48} + 0x026001bb, 32);
    assert status == ScalarExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x333;
    let identity = ReadSystemRegister(SystemRegister_THREAD_ID);
    assert identity == Zeros{PTO_XLEN} + 1;
    return 0;
end;
