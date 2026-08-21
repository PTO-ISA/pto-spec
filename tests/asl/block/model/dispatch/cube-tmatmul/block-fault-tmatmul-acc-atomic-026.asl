// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-ACC-ATOMIC-026","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-ACCUMULATOR-OUTPUT-001"],"kind":"fault","summary":"ACC destination group rejects an undersized late auxiliary atomically","pass_condition":"invalid GroupMax capacity publishes no D RowMax GroupMax allocation status or source change","related_sources":["asl/block/model/dispatch/cube-destination.asl","asl/block/model/faults/rollback.asl"]}
func main() => integer
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(4, 128, 32, 1,
        TileDataType_FP16, TileLayout_CUBE_M32,
        TileLocation_Matrix, '1111');
    let b_ready = ConfigureCubeTileForMask(5, 256, 1, 16,
        TileDataType_FP16, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    let c_ready = ConfigureCubeTileForMask(6, 2048, 32, 16,
        TileDataType_FP32, TileLayout_CUBE_M32,
        TileLocation_Matrix, '1111');
    assert a_ready && b_ready && c_ready;
    MarkTileValidRegionDefined(4);
    MarkTileValidRegionDefined(5);
    MarkTileValidRegionDefined(6);
    let c_before = ReadTileElement(6, 0, 0);
    let capacity_before = CoreTileCapacityInUse();
    let status_before = NumericStatusFlags();

    var start: bits(64) = Zeros{64} + 0x00231181;
    start[31:27] = Zeros{5} + 4;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4} + 1,
        TRUE, TRUE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 32);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 16);
    AddBundleTileBinding(
        TRUE, 0, 5, '1111', TRUE, TRUE, 6, 4, FALSE);
    AddBundleTileBinding(
        TRUE, 1, 1, '1111', TRUE, FALSE, 5, 0, FALSE);
    AddBundleTileBinding(
        TRUE, 2, 1, '1111', FALSE, FALSE, 0, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileAllocation;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert !_BundleTileBindings[[1]].destination_allocated_by_bundle;
    assert !_BundleTileBindings[[2]].destination_allocated_by_bundle;
    assert CoreTileCapacityInUse() == capacity_before;
    assert NumericStatusFlags() == status_before;
    assert ReadTileElement(6, 0, 0) == c_before;
    return 0;
end;
