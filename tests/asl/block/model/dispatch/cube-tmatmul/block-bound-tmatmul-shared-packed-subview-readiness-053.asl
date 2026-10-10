// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-PACKED-SUBVIEW-READINESS-053","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-B-SHARED-WHOLE-PARENT-READY-001","PTO-CUBE-SHARED-TRANSPOSE-001","PTO-B-SUBVIEW-SHARED-PER-PE-001"],"kind":"boundary","summary":"Packed Shared B subviews wait for published whole-parent readiness without destination effects.","pass_condition":"A valid 1x194 packed B CELL view over an unpublished 8x256 parent causes TMATMUL to wait with no fault, destination allocation, Shared consumption, payload mutation, or readiness/generation-state change.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl","asl/block/model/operands/shared-generation.asl","asl/tile/model/state/shared-registers.asl"]}

func main() => integer
begin
    ResetProfileState();
    ConfigureTileForMask(10, 4096, 32, 256, 17, 194,
        TileDataType_E2M1X2, TileLayout_RowMajor, '1111');
    ConfigureTileForMask(11, 1024, 8, 256, 8, 194,
        TileDataType_E2M1X2, TileLayout_RowMajor, '1111');
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);
    WriteTileElement(11, 0, 193, Zeros{PTO_XLEN} + 12);
    InstallSharedTile((Zeros{6} + 40) as SharedTileID,
        _Tiles[[10]], '1111');
    InstallSharedTile((Zeros{6} + 41) as SharedTileID,
        _Tiles[[11]], '0011');
    let parent_before = SharedTileRecord((Zeros{6} + 41) as SharedTileID);
    assert !parent_before.whole_parent_ready && !parent_before.published;

    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = TileDataTypeToEncoding(TileDataType_E2M1X2);
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 17);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 194);
    BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', FALSE, FALSE, 0, 0, TRUE);
    _BundleSharedBindings[[1]].source0_subview.valid = TRUE;
    _BundleSharedBindings[[1]].source0_subview.reg_src = 2;
    _BundleSharedBindings[[1]].source0_subview.uimm11 = Zeros{11};
    _BundleSharedBindings[[1]].source0_subview.size_code = 1;
    for pe = 0 to 3 looplimit 4 do
        WritePEGPR(pe as MemoryAgentId, 2, Zeros{PTO_XLEN} + pe);
    end;

    let generation_index = SharedTileArrayIndex(
        (Zeros{6} + 41) as SharedTileID);
    let generation_before = _SharedGenerations[[generation_index]];
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_None;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert !_BundleSharedBindings[[0]].consumed;
    assert !_BundleSharedBindings[[1]].consumed;
    let parent_after = SharedTileRecord((Zeros{6} + 41) as SharedTileID);
    assert parent_after.descriptor_valid == parent_before.descriptor_valid;
    assert parent_after.allocation_mask == parent_before.allocation_mask;
    assert parent_after.initialized_mask == parent_before.initialized_mask;
    assert parent_after.whole_parent_ready == parent_before.whole_parent_ready;
    assert parent_after.published == parent_before.published;
    assert parent_after.tile.payload[[0]] == parent_before.tile.payload[[0]];
    assert parent_after.tile.payload[[12]] == parent_before.tile.payload[[12]];
    assert TileLogicalElementDefined(parent_after.tile,
        TileLogicalLinearIndex(parent_after.tile, 0, 193));
    let generation_after = _SharedGenerations[[generation_index]];
    assert generation_after.open == generation_before.open;
    assert generation_after.closed == generation_before.closed;
    assert generation_after.published == generation_before.published;
    assert generation_after.shared_tile_id == generation_before.shared_tile_id;
    assert generation_after.participant_mask == generation_before.participant_mask;
    assert generation_after.parent_size_code == generation_before.parent_size_code;
    assert generation_after.parent_cell_count == generation_before.parent_cell_count;
    assert generation_after.covered_cells == generation_before.covered_cells;
    assert generation_after.ready_cells == generation_before.ready_cells;
    assert generation_after.arrived_participants == generation_before.arrived_participants;
    assert generation_after.working_valid == generation_before.working_valid;
    return 0;
end;
