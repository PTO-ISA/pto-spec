// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-READINESS-012","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"fault","summary":"Cooperative Shared Matrix requires all four fixed quarters published and ready","pass_condition":"a partial Shared A allocation rejects before destination allocation binding consumption payload or numeric status","related_sources":["asl/tile/model/state/shared-registers.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(10, 128, 32, 2, 8, 2,
        TileDataType_U16, TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(11, 128, 32, 2, 2, 2,
        TileDataType_U16, TileLayout_RowMajor, TileLocation_Matrix);
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);
    InstallSharedTile((Zeros{6} + 42) as SharedTileID, _Tiles[[10]], '0011');
    InstallSharedTile((Zeros{6} + 43) as SharedTileID, _Tiles[[11]], '1111');
    let shared_before = SharedTileRecord((Zeros{6} + 42) as SharedTileID);
    let status_before = NumericStatusFlags();

    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 26;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    BindBundleSharedIO((Zeros{6} + 42) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 43) as SharedTileID, 0, '1111');
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', FALSE, FALSE, 0, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert !_BundleSharedBindings[[0]].consumed;
    let shared_after = SharedTileRecord((Zeros{6} + 42) as SharedTileID);
    assert shared_after.descriptor_valid == shared_before.descriptor_valid;
    assert shared_after.allocation_mask == shared_before.allocation_mask;
    assert shared_after.initialized_mask == shared_before.initialized_mask;
    assert shared_after.published == shared_before.published;
    assert shared_after.tile.payload[[0]] == shared_before.tile.payload[[0]];
    assert NumericStatusFlags() == status_before;
    return 0;
end;
