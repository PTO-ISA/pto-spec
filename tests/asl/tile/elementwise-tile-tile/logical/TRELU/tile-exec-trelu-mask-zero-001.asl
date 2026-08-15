// PTO-TEST: {"id":"PTO-AVS-TILE-TRELU-MASK-ZERO-001","source":"asl/tile/elementwise-tile-tile/logical/TRELU.asl","requirements":["PTO-TRELU-CONTRACT-001"],"kind":"execution","summary":"TRELU treats PE_MASK zero as a strict no-op.","pass_condition":"A zero-mask binding completes before dimensions, source access, schema checks, or destination allocation for TRELU.","related_sources":["asl/block/model/dispatch/tile-execution.asl"]}
func main() => integer
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(
        Zeros{64} + 0xc1719181, 32);
    assert started == CommandExecution_Executed;
    var zero_mask = Zeros{64} + 0x00005013;
    zero_mask[25:20] = Ones{6};
    zero_mask[19] = '1';
    let bound = ExecuteCommandInstruction(zero_mask, 32);
    assert bound == CommandExecution_Executed;

    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    assert BundleTileBindingCount() == 0;
    assert SelectedBundleTileMaskIsZero();
    assert !_Tiles[[0]].allocated;
    return 0;
end;
