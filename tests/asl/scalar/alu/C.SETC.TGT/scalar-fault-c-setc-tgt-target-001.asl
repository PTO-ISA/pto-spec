// PTO-TEST: {"id":"PTO-AVS-SCALAR-C-SETC-TGT-TARGET-001","source":"asl/scalar/alu/C.SETC.TGT.asl","requirements":["PTO-INST-SCALAR-C-SETC-TGT"],"kind":"fault","summary":"C.SETC.TGT defers target alignment validation to block commit","pass_condition":"an odd target is snapshotted successfully and the later commit raises Fault_InstructionPC with the active block preserved in trap context","related_sources":["asl/block/model/lifecycle/enter-stop.asl","asl/block/model/state/barg.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x500);
    BeginBundleAt(
        ReadTPC(),
        BundleKind_Standard,
        BundleTransfer_Direct,
        Zeros{PTO_XLEN} + 0x900,
        Zeros{PTO_XLEN} + 0x502,
        Zeros{PTO_XLEN} + 0x502,
        TRUE);
    WriteGPR(1, Zeros{PTO_XLEN} + 0x901);

    var instruction: bits(48) = Zeros{48} + 0x001c;
    instruction[10:6] = Zeros{5} + 1;
    let status = ExecuteScalarInstruction(instruction, 16);
    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 0x901;

    StopBundleAt(Zeros{PTO_XLEN} + 0x504);
    assert _LastFault == Fault_InstructionPC;
    assert _FaultAddress == Zeros{PTO_XLEN} + 0x901;
    assert _TrapContexts[[0]].bundle_active;
    assert _TrapContexts[[0]].barg.bpcn == Zeros{PTO_XLEN} + 0x901;
    assert _TrapContexts[[0]].bundle_commit_target_set;
    return 0;
end;
