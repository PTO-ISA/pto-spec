// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-CALL-ROLLBACK-001","source":"asl/block/execution/BSTART.CALL.asl","requirements":["PTO-INST-BLOCK-BSTART-CALL"],"kind":"fault","summary":"A failed retiring-block commit cannot publish direct-call state.","pass_condition":"The saved fault context and live ra retain the retiring BARG and old return register; no candidate call BARG is installed.","related_sources":["asl/block/model/dispatch/start.asl"]}
func main() => integer
begin
    ResetProfileState();
    SetCurrentACR(0);
    WriteTPC(Zeros{PTO_XLEN} + 0x400);
    BeginBundleAt(ReadTPC(), BundleKind_Standard, BundleTransfer_Direct,
        Zeros{PTO_XLEN} + 0x600, Zeros{PTO_XLEN} + 0x404,
        Zeros{PTO_XLEN}, TRUE);
    WriteGPR(10, Zeros{PTO_XLEN} + 0xdead);
    _BundleOperation.valid = TRUE;
    _BundleOperation.operation_class = BundleOperation_FixedPoint;

    let status = ExecuteCommandInstruction(Zeros{64} + 0x50160002, 32);
    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 0xdead;
    assert _TrapContexts[[0]].valid;
    assert _TrapContexts[[0]].bpc == Zeros{PTO_XLEN} + 0x400;
    assert _TrapContexts[[0]].barg.bpcn == Zeros{PTO_XLEN} + 0x600;
    assert _TrapContexts[[0]].barg.transfer_type == BundleTransfer_Direct;
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 0x600;
    return 0;
end;
