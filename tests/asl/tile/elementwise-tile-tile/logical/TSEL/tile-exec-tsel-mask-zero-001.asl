// PTO-TEST: {"id":"PTO-AVS-TILE-TSEL-MASK-ZERO-001","source":"asl/tile/elementwise-tile-tile/logical/TSEL.asl","requirements":["PTO-TSEL-CONTRACT-001"],"kind":"execution","summary":"TSEL PE_MASK zero is a strict no-op before source or destination checks","pass_condition":"an otherwise unresolved two-binding schema completes without allocation, source reads, or faults","related_sources":["asl/block/model/dispatch/tile-execution.asl"]}
func main() => integer
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0xc1a19181,
        32);
    assert started == CommandExecution_Executed;
    AddBundleTileBinding(
        FALSE,
        0,
        0,
        '0000',
        TRUE,
        TRUE,
        1,
        2,
        FALSE);
    AddBundleTileBinding(
        TRUE,
        0,
        1,
        '0000',
        TRUE,
        FALSE,
        3,
        0,
        TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    assert !_BundleTileBindings[[1]].destination_allocated_by_bundle;
    assert !_Tiles[[0]].allocated;
    return 0;
end;
