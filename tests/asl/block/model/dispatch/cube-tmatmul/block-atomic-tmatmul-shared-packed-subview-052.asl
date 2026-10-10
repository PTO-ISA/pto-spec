// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-PACKED-SUBVIEW-ATOMICITY-052","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-SHARED-TRANSPOSE-001","PTO-B-SUBVIEW-SHARED-PER-PE-001"],"kind":"atomicity","summary":"Packed Shared B subview rejects capacity, rectangular crossing, wrong view shape, and odd original pitch before effects.","pass_condition":"W08 offset 8, an even-pitch 10x384 CELL crossing, K=192 against a 1x194 packed view, and a generic-legal odd-pitch parent each raise TileLegality without destination allocation, Shared consumption, parent mutation, or generation-state change.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl","asl/block/model/operands/shared-generation.asl","asl/tile/model/state/shared-registers.asl"]}

func RunPackedSubviewRejection(scenario: integer {0..3})
begin
    ResetProfileState();
    let k = if scenario == 2 then 192 else 194;
    ConfigureTileForMask(10, 4096, 32, 256, 17, k,
        TileDataType_E2M1X2, TileLayout_RowMajor, '1111');
    MarkTileValidRegionDefined(10);
    let parent_capacity = if scenario == 1 || scenario == 3 then 2048 else 1024;
    let parent_pitch = if scenario == 1 then 384
        else if scenario == 3 then 255 else 256;
    let parent_rows = if scenario == 1 || scenario == 3 then 10 else 8;
    let parent_valid_columns = if scenario == 1 then 384 else 194;
    let physical_rows = DerivedTileRows(
        parent_capacity, parent_pitch, TileDataType_E2M1X2);
    ConfigureTileForMask(11, parent_capacity, physical_rows,
        parent_pitch, parent_rows, parent_valid_columns,
        TileDataType_E2M1X2, TileLayout_RowMajor, '1111');
    MarkTileValidRegionDefined(11);
    WriteTileElement(11, 0, 192, Zeros{PTO_XLEN} + 3);
    WriteTileElement(11, 0, 193, Zeros{PTO_XLEN} + 12);
    assert TileInfoDescriptorLegal(_Tiles[[11]]);
    InstallSharedTile((Zeros{6} + 40) as SharedTileID,
        _Tiles[[10]], '1111');
    InstallSharedTile((Zeros{6} + 41) as SharedTileID,
        _Tiles[[11]], '1111');
    assert SharedTileDescriptorLegal((Zeros{6} + 41) as SharedTileID);

    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = TileDataTypeToEncoding(TileDataType_E2M1X2);
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 17);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + k);
    BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', FALSE, FALSE, 0, 0, TRUE);
    _BundleSharedBindings[[1]].source0_subview.valid = TRUE;
    _BundleSharedBindings[[1]].source0_subview.reg_src = 2;
    _BundleSharedBindings[[1]].source0_subview.uimm11 = Zeros{11};
    _BundleSharedBindings[[1]].source0_subview.size_code = 1;
    for pe = 0 to 3 looplimit 4 do
        let offset = if scenario == 0 && pe == 3 then 8
            else if scenario == 1 then 1 else pe;
        WritePEGPR(pe as MemoryAgentId, 2, Zeros{PTO_XLEN} + offset);
    end;

    let expected_columns = if scenario == 2 then 192 else 194;
    let invalid_pe = if scenario == 0 then 3 else 0;
    assert !BundleSharedSubviewMatrixMetadataLegalForPE(
        1, invalid_pe as MemoryAgentId, 1,
        expected_columns, expected_columns,
        TileDataType_E2M1X2);
    let before = SharedTileRecord((Zeros{6} + 41) as SharedTileID);
    let generation_index = SharedTileArrayIndex(
        (Zeros{6} + 41) as SharedTileID);
    let generation_before = _SharedGenerations[[generation_index]];
    let status_before = NumericStatusFlags();
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert !_BundleSharedBindings[[0]].consumed;
    assert !_BundleSharedBindings[[1]].consumed;
    let after = SharedTileRecord((Zeros{6} + 41) as SharedTileID);
    assert after.descriptor_valid == before.descriptor_valid;
    assert after.allocation_mask == before.allocation_mask;
    assert after.initialized_mask == before.initialized_mask;
    assert after.whole_parent_ready == before.whole_parent_ready;
    assert after.published == before.published;
    assert after.tile.capacity_bytes == before.tile.capacity_bytes;
    assert after.tile.rows == before.tile.rows;
    assert after.tile.columns == before.tile.columns;
    assert after.tile.valid_rows == before.tile.valid_rows;
    assert after.tile.valid_columns == before.tile.valid_columns;
    assert after.tile.payload[[0]] == before.tile.payload[[0]];
    assert after.tile.payload[[12]] == before.tile.payload[[12]];
    assert TileLogicalElementDefined(after.tile,
        TileLogicalLinearIndex(after.tile, 0, 193));
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
    assert NumericStatusFlags() == status_before;
end;

func main() => integer
begin
    for scenario = 0 to 3 looplimit 4 do
        RunPackedSubviewRejection(scenario);
    end;
    return 0;
end;
