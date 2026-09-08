// PTO-TEST: {"id":"PTO-AVS-ARCH-PROFILE-LINX-RUNTIME-COMPAT-ACRC-003","source":"asl/arch/profile/linx-runtime-compat.asl","requirements":[],"kind":"fault","summary":"portable profile keeps ACRC restricted to SYS blocks","pass_condition":"ACRC in a standard block rejects before terminal state is published","related_sources":["asl/scalar/sys/ACRC.asl","asl/scalar/model/sys/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    SetCurrentACR(0);
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    BeginBundle(BundleKind_Standard, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x204,
        Zeros{PTO_XLEN} + 0x204, FALSE);
    EnterBundleBody();
    let status = ExecuteScalarInstruction(
        Zeros{48} + 0x0010302b, 32);
    assert status == ScalarExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert !_SystemBlockTerminalPending;
    return 0;
end;
