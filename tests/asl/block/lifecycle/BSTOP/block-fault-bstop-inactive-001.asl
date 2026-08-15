// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTOP-INACTIVE-001","source":"asl/block/lifecycle/BSTOP.asl","requirements":["PTO-INST-BLOCK-BSTOP"],"kind":"fault","summary":"BSTOP rejects when no block is active.","pass_condition":"The exact BSTOP encoding raises Fault_BundleControl before installing or clearing block state.","related_sources":["asl/block/model/commit/validation.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x180);
    let status = ExecuteCommandInstruction(Zeros{64} + 0x00000001, 32);
    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert !_BundleActive;
    return 0;
end;
