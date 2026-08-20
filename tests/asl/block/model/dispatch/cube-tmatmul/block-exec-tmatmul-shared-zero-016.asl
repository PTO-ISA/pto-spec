// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-ZERO-016","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"execution","summary":"Cooperative Matrix mask zero exits before every transpose and Shared readiness rule","pass_condition":"a zero-mask binding with missing attributes and invalid sources succeeds without allocation state fault or consumption","related_sources":["asl/block/model/dispatch/tile-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 26;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    AddBundleTileBinding(
        TRUE, 0, 7, '0000', TRUE, TRUE, 62, 63, TRUE);

    let completed = ExecuteBundleTileOperation();

    assert completed;
    assert _LastFault == Fault_None;
    assert CoreTileCapacityInUse() == 0;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    return 0;
end;
