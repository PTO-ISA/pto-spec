// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-ICALL-SYS-SOURCE-001","source":"asl/block/execution/BSTART.ICALL.asl","requirements":["PTO-INST-BLOCK-BSTART-ICALL"],"kind":"fault","summary":"BSTART.ICALL cannot source an indirect target from a System block","pass_condition":"a retiring System BARG raises Fault_BundleControl before ra, TPC, or BARG publication","related_sources":["asl/block/model/dispatch/start.asl","asl/block/model/state/barg.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x600);
    BeginBundleAt(
        ReadTPC(),
        BundleKind_System,
        BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN},
        Zeros{PTO_XLEN} + 0x604,
        Zeros{PTO_XLEN},
        FALSE);
    WriteGPR(10, Zeros{PTO_XLEN} + 0xbeef);

    let status = ExecuteCommandInstruction(Zeros{64} + 0x50166001, 32);
    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 0xbeef;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x604;
    assert _BundleActive;
    assert _BARG.block_type == BundleKind_System;
    assert _BARG.bpcn == Zeros{PTO_XLEN};
    return 0;
end;
