// PTO-TEST: {"id":"PTO-AVS-BLOCK-C-BSTART-FP-IND-SOURCE-001","source":"asl/block/encoding/C.BSTART.FP.asl","requirements":["PTO-INST-BLOCK-C-BSTART-FP"],"kind":"fault","summary":"C.BSTART.FP IND requires a retiring standard-or-floating BARG target","pass_condition":"without an eligible retiring BARG, IND raises Fault_BundleControl before opening an FP block","related_sources":["asl/block/model/dispatch/start.asl","asl/block/model/state/barg.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x900);
    let status = ExecuteCommandInstruction(Zeros{64} + 0x2880, 16);
    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x900;
    assert !_BundleActive;
    return 0;
end;
