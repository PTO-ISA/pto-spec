// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-BPCN-ALIGN-001","source":"asl/block/lifecycle/BSTART.asl","requirements":["PTO-INST-BLOCK-BSTART"],"kind":"fault","summary":"Commit validates the final BARG.BPCN after SETC.TGT updates.","pass_condition":"An odd selected BPCN raises Fault_InstructionPC before the active BARG is cleared or block effects commit.","related_sources":["asl/block/model/commit/validation.asl","asl/scalar/model/sys/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    BeginBundleAt(ReadTPC(), BundleKind_Standard, BundleTransfer_Direct,
        Zeros{PTO_XLEN} + 0x500, Zeros{PTO_XLEN} + 0x304,
        Zeros{PTO_XLEN}, TRUE);
    SetCommitTarget(Zeros{PTO_XLEN} + 0x501);
    let committed = CompleteBundleAt(Zeros{PTO_XLEN} + 0x304);
    assert !committed;
    assert _LastFault == Fault_InstructionPC;
    assert _TrapContexts[[0]].barg.bpcn == Zeros{PTO_XLEN} + 0x501;
    assert _TrapContexts[[0]].bundle_active;
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 0x501;
    return 0;
end;
