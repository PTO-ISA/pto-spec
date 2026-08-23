// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-LOCAL-TRANSPOSE-013","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"fault","summary":"TransA is illegal when A is a Local CUBE primary","pass_condition":"a right-only Shared form with TransA set rejects before destination allocation source consumption or status","related_sources":["asl/tile/model/legality/matrix-operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    let left_ready = ConfigureCubeTileForMask(1, 128, 2, 2,
        TileDataType_U16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    assert left_ready;
    MarkTileValidRegionDefined(1);
    ConfigureTile(10, 128, 32, 2, 2, 2,
        TileDataType_U16, TileLayout_RowMajor, TileLocation_Matrix);
    MarkTileValidRegionDefined(10);
    InstallSharedTile((Zeros{6} + 44) as SharedTileID, _Tiles[[10]], '1111');
    let left_before = _Tiles[[1]];
    let shared_before = SharedTileRecord((Zeros{6} + 44) as SharedTileID);

    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 26;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE, TRUE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    BindBundleSharedIO((Zeros{6} + 44) as SharedTileID, 0, '1111');
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert _Tiles[[1]].allocated == left_before.allocated;
    assert _Tiles[[1]].capacity_bytes == left_before.capacity_bytes;
    assert _Tiles[[1]].layout == left_before.layout;
    assert _Tiles[[1]].payload[[0]] == left_before.payload[[0]];
    let shared_after = SharedTileRecord((Zeros{6} + 44) as SharedTileID);
    assert shared_after.descriptor_valid == shared_before.descriptor_valid;
    assert shared_after.allocation_mask == shared_before.allocation_mask;
    assert shared_after.initialized_mask == shared_before.initialized_mask;
    assert shared_after.published == shared_before.published;
    assert shared_after.tile.payload[[0]] == shared_before.tile.payload[[0]];
    assert !_BundleSharedBindings[[0]].consumed;
    return 0;
end;
