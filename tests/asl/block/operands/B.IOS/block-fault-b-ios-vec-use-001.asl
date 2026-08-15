// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOS-VEC-USE-001","source":"asl/block/operands/B.IOS.asl","requirements":["PTO-INST-BLOCK-B-IOS"],"kind":"fault","summary":"a participating B.IOS source is not silently discarded by a VEC block","pass_condition":"the unconsumed Shared binding raises Fault_TileLegality before Shared state changes","related_sources":["asl/block/model/dispatch/tile-execution.asl"]}
func main() => integer
begin
    ResetProfileState();
    var start: bits(64) = Zeros{64} + 0x00019181;
    start[31:27] = Zeros{5} + 24;
    let start_result = ExecuteCommandInstruction(start, 32);
    assert start_result == CommandExecution_Executed;
    BindBundleSharedIO(Zeros{8} + 70, 0, '1111');

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleSharedBindings[[0]].consumed;
    return 0;
end;
