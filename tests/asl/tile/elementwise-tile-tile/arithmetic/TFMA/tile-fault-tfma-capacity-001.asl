// PTO-TEST: {"id":"PTO-AVS-TILE-TFMA-CAPACITY-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl","requirements":["PTO-TFMA-CONTRACT-001"],"kind":"fault","summary":"TFMA validates the complete destination shape against per-PE TSize.","pass_condition":"A two-row by 128-column U64 result rejects TSize code one before allocation or source access.","related_sources":["asl/block/model/dispatch/destination-shape.asl"]}
func main() => integer
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(
        Zeros{64} + 0xc1c19181, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 128);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 128);
    AddBundleTileBinding(
        FALSE, 0, 0, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 3, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileAllocation;
    assert !_BundleTileBindings[[1]].destination_allocated_by_bundle;
    assert !_Tiles[[0]].allocated;
    return 0;
end;
