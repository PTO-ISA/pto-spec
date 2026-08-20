// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-ROLLBACK-019","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"fault","summary":"Late cooperative CUBE destination failure rolls back every output effect","pass_condition":"an undersized D rejects after complete Shared readiness without allocation consumption Shared mutation or numeric status","related_sources":["asl/block/model/dispatch/cube-destination.asl","asl/block/model/faults/rollback.asl"]}
func PrepareRollbackShared(index: TileIndex, shared_id: bits(8),
                           rows: integer {1..65535},
                           columns: integer {1..65535})
begin
    ConfigureTileForMask(index, 128,
        DerivedTileRows(128, columns, TileDataType_U16),
        columns, rows, columns, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Matrix, '1111');
    MarkTileValidRegionDefined(index);
    InstallSharedTile(shared_id, _Tiles[[index]], '1111');
end;

func main() => integer
begin
    ResetProfileState();
    PrepareRollbackShared(10, Zeros{8} + 62, 16, 1);
    PrepareRollbackShared(11, Zeros{8} + 63, 1, 16);
    let left_before = SharedTileRecord(Zeros{8} + 62);
    let right_before = SharedTileRecord(Zeros{8} + 63);
    let capacity_before = CoreTileCapacityInUse();
    let status_before = NumericStatusFlags();

    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 26;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 16);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 16);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    BindBundleSharedIO(Zeros{8} + 62, 0, '1111');
    BindBundleSharedIO(Zeros{8} + 63, 0, '1111');
    AddBundleTileBinding(
        TRUE, 0, 3, '1111', FALSE, FALSE, 0, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileAllocation;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert !_BundleSharedBindings[[0]].consumed;
    assert !_BundleSharedBindings[[1]].consumed;
    assert CoreTileCapacityInUse() == capacity_before;
    assert NumericStatusFlags() == status_before;
    let left_after = SharedTileRecord(Zeros{8} + 62);
    let right_after = SharedTileRecord(Zeros{8} + 63);
    assert left_after.allocation_mask == left_before.allocation_mask;
    assert left_after.initialized_mask == left_before.initialized_mask;
    assert left_after.tile.payload[[0]] == left_before.tile.payload[[0]];
    assert right_after.allocation_mask == right_before.allocation_mask;
    assert right_after.initialized_mask == right_before.initialized_mask;
    assert right_after.tile.payload[[0]] == right_before.tile.payload[[0]];
    return 0;
end;
