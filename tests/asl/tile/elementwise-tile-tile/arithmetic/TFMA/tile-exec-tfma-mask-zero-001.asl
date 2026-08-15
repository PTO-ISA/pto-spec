// PTO-TEST: {"id":"PTO-AVS-TILE-TFMA-MASK-ZERO-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl","requirements":["PTO-TFMA-CONTRACT-001"],"kind":"execution","summary":"TFMA treats PE_MASK zero as a strict no-op.","pass_condition":"A zero-mask TFMA returns before schema, source, allocation, arithmetic, padding, or flag effects.","related_sources":["asl/block/model/dispatch/tile-execution.asl"]}
func main() => integer
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(
        Zeros{64} + 0xc1c19181, 32);
    assert started == CommandExecution_Executed;
    AddBundleTileBinding(
        FALSE, 0, 0, Zeros{4}, FALSE, FALSE, 0, 0, FALSE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    assert !_Tiles[[0]].allocated;
    assert ScalarFPFlags() == Zeros{5};
    return 0;
end;
