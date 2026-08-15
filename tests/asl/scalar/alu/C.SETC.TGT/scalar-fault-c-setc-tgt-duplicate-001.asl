// PTO-TEST: {"id":"PTO-AVS-SCALAR-C-SETC-TGT-DUP-001","source":"asl/scalar/alu/C.SETC.TGT.asl","requirements":["PTO-INST-SCALAR-C-SETC-TGT"],"kind":"fault","summary":"A block accepts only one successful C.SETC.TGT","pass_condition":"the second occurrence raises Fault_BundleControl before checking an unavailable source and preserves the first target","related_sources":["asl/scalar/model/dispatch/top-level.asl","asl/scalar/model/sys/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    BeginBundleAt(
        ReadTPC(),
        BundleKind_Standard,
        BundleTransfer_Conditional,
        Zeros{PTO_XLEN} + 0x500,
        Zeros{PTO_XLEN} + 0x302,
        Zeros{PTO_XLEN} + 0x302,
        FALSE);
    WriteGPR(1, Zeros{PTO_XLEN} + 0xa00);

    var first: bits(48) = Zeros{48} + 0x001c;
    first[10:6] = Zeros{5} + 1;
    let first_status = ExecuteScalarInstruction(first, 16);
    assert first_status == ScalarExecution_Executed;

    var duplicate: bits(48) = Zeros{48} + 0x001c;
    duplicate[10:6] = Zeros{5} + 27;
    let status = ExecuteScalarInstruction(duplicate, 16);
    assert status == ScalarExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert _TrapContexts[[0]].barg.bpcn == Zeros{PTO_XLEN} + 0xa00;
    assert _TrapContexts[[0]].bundle_commit_target_set;
    assert !_TrapContexts[[0]].t_queue_valid[[0]];
    return 0;
end;
