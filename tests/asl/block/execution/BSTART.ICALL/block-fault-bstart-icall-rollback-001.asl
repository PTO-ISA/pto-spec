// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-ICALL-ROLLBACK-001","source":"asl/block/execution/BSTART.ICALL.asl","requirements":["PTO-INST-BLOCK-BSTART-ICALL"],"kind":"fault","summary":"A failed retiring-block commit cannot publish indirect-call state.","pass_condition":"The retiring BARG.BPCN is only a snapshot candidate; failed retirement preserves the old BARG and ra.","related_sources":["asl/block/model/dispatch/start.asl"]}
func main() => integer
begin
    ResetProfileState();
    SetCurrentACR(0);
    WriteTPC(Zeros{PTO_XLEN} + 0x500);
    BeginBundleAt(ReadTPC(), BundleKind_Standard, BundleTransfer_Direct,
        Zeros{PTO_XLEN} + 0x700, Zeros{PTO_XLEN} + 0x504,
        Zeros{PTO_XLEN}, TRUE);
    WriteGPR(10, Zeros{PTO_XLEN} + 0xbeef);
    _BundleOperation.valid = TRUE;
    _BundleOperation.operation_class = BundleOperation_FixedPoint;

    let status = ExecuteCommandInstruction(Zeros{64} + 0x50166001, 32);
    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 0xbeef;
    assert _TrapContexts[[0]].valid;
    assert _TrapContexts[[0]].bpc == Zeros{PTO_XLEN} + 0x500;
    assert _TrapContexts[[0]].barg.bpcn == Zeros{PTO_XLEN} + 0x700;
    assert _TrapContexts[[0]].barg.transfer_type == BundleTransfer_Direct;
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 0x700;
    return 0;
end;
