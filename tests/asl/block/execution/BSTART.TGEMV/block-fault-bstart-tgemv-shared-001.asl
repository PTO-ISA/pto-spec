// PTO-TEST: {"id":"PTO-AVS-BLOCK-TGEMV-SHARED-001","source":"asl/block/execution/BSTART.TGEMV.asl","requirements":["PTO-TMATMUL-CONTRACT-001","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"fault","summary":"TGEMV rejects every participating Shared operand binding","pass_condition":"one B.IOS source raises Fault_TileLegality before Shared consumption","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl"]}
func main() => integer
begin
    ResetProfileState();
    var start: bits(64) = Zeros{64} + 0x01031181;
    start[31:27] = Zeros{5} + 26;
    let start_result = ExecuteCommandInstruction(start, 32);
    assert start_result == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
    BindBundleSharedIO(Zeros{8} + 50, 0, '1111');

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleSharedBindings[[0]].consumed;
    return 0;
end;
