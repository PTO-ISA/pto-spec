// PTO-TEST: {"id":"PTO-AVS-ARCH-PROFILE-LINX-RUNTIME-COMPAT-SSR-002","source":"asl/arch/profile/linx-runtime-compat.asl","requirements":[],"kind":"fault","summary":"portable profile does not assign the Linx PEID SSR alias","pass_condition":"the unselected PEID alias remains unavailable and does not change GPR state","related_sources":["asl/scalar/model/sys/registers.asl"]}
func main() => integer
begin
    ResetProfileState();
    SetCurrentACR(0);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x104,
        Zeros{PTO_XLEN} + 0x104, FALSE);
    EnterBundleBody();
    WriteGPR(2, Zeros{PTO_XLEN} + 0x222);
    var instruction: bits(48) = Zeros{48} + 0x0000003b;
    instruction[11:7] = Zeros{5} + 2;
    instruction[31:20] = Zeros{12} + 0x0802;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0x222;
    return 0;
end;
