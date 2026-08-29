// PTO-TEST: {"id":"PTO-AVS-SCALAR-FIRST-BODY-ENTRY-001","source":"asl/scalar/model/dispatch/top-level.asl","requirements":["PTO-REQ-SCALAR-BODY-ENTRY-001"],"kind":"state-transition","summary":"The first decoded scalar form after BSTART enters the block body before applicability.","pass_condition":"A decoded ACRC form in a SYS header reaches its ASL semantic owner while an undecodable scalar-width value leaves the header phase unchanged.","related_sources":["asl/block/model/lifecycle/enter-stop.asl","asl/scalar/sys/ACRC.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    BeginBundle(
        BundleKind_System,
        BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN},
        Zeros{PTO_XLEN} + 0x104,
        Zeros{PTO_XLEN} + 0x104,
        FALSE);
    assert BundleIsActive() && !BundleBodyIsActive();

    let rejected = ExecuteScalarInstruction(
        Zeros{48} + 0x00000001,
        32);
    assert rejected == ScalarExecution_Rejected;
    assert !BundleBodyIsActive();

    ClearFault();
    let acrc = ExecuteScalarInstruction(
        Zeros{48} + 0x0010302b,
        32);
    assert BundleBodyIsActive();
    assert acrc == ScalarExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    return 0;
end;
