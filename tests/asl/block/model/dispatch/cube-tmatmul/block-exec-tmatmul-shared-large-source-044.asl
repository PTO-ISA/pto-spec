// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-LARGE-SOURCE-044","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-TMATMUL-CONTRACT-001","PTO-CUBE-SHARED-TRANSPOSE-001","PTO-CUBE-GROUP-M-DISTRIBUTION-001"],"kind":"execution","summary":"128 and 256 KiB Shared sources execute through typed logical carrier reads with legal 64 KiB Local output.","pass_condition":"At group_M=65 PE2 executes N=256/K=256 and N=512/K=256 Shared U16 sources (128/256 KiB) using Local CUBE_M32 A and exact-shape U32 output no larger than 64 KiB; distinct values across logical carrier 8192 and the final carrier are observed after publication and through canonical MatrixReadLogicalElement views.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl","asl/tile/model/definedness/packed-boundary.asl"]}

func RunLargeSharedSource(n: integer {256,512},
                          source_capacity: integer {131072,262144},
                          destination_size_code: integer {9,10})
begin
    ResetProfileState();
    SelectMemoryEventAgent(2);
    let active_m = BundleMatrixCooperativeValidM(65, 2);
    assert active_m == 1;
    let a_capacity = TileCubePhysicalRequiredBytes(
        TileLayout_CUBE_M32, 32, 256, TileDataType_U16);
    let a_ready = ConfigureCubeTileForMaskWithPhysical(
        1, a_capacity, 32, 256, active_m, 256,
        TileDataType_U16, TileLayout_CUBE_M32, '1111');
    assert a_ready;
    MarkTileValidRegionDefined(1);

    let shared_id = (Zeros{6} + 41) as SharedTileID;
    var shared_input = TileWithValidRegionDefined(
        MaterializeSharedTileForReadSchemaAtCapacity(
            shared_id, n, 256, 256, TileDataType_U16,
            TileLayout_RowMajor, source_capacity));
    // Pin values across the 32768-logical-element boundary and in adjacent
    // U16 lanes of one carrier, independently of the private-view mapping.
    let before_threshold = TileLogicalLinearIndex(shared_input, 127, 255);
    let threshold_lane0 = TileLogicalLinearIndex(shared_input, 128, 0);
    let threshold_lane1 = TileLogicalLinearIndex(shared_input, 128, 1);
    shared_input = TileInfoWithLogicalElement(
        shared_input, before_threshold, Zeros{PTO_XLEN} + 0xBEEF);
    shared_input = TileInfoWithLogicalElement(
        shared_input, threshold_lane0, Zeros{PTO_XLEN} + 0x1234);
    shared_input = TileInfoWithLogicalElement(
        shared_input, threshold_lane1, Zeros{PTO_XLEN} + 0x5678);
    // Distinct final adjacent lanes reach the last carrier in both source
    // capacities, including lane 3 at the 256 KiB bound.
    let final_lane2 = TileLogicalLinearIndex(shared_input, n - 1, 254);
    let final_lane3 = TileLogicalLinearIndex(shared_input, n - 1, 255);
    shared_input = TileInfoWithLogicalElement(
        shared_input, final_lane2, Zeros{PTO_XLEN} + 0x9ABC);
    shared_input = TileInfoWithLogicalElement(
        shared_input, final_lane3, Zeros{PTO_XLEN} + 0xDEF0);
    InstallSharedTile((Zeros{6} + 41) as SharedTileID,
        shared_input, '1111');
    assert SharedTileDescriptorLegal((Zeros{6} + 41) as SharedTileID);
    let shared_before = SharedTileRecord((Zeros{6} + 41) as SharedTileID);

    let source_element = TileLogicalLinearIndex(
        shared_before.tile, n - 1, 255);
    let expected_element = n * 256 - 1;
    assert source_element == expected_element;
    assert TilePackedCarrierIndex(
        TileDataType_U16, source_element) == expected_element DIVRM 4;
    assert TilePackedLaneIndex(
        TileDataType_U16, source_element) == expected_element MOD 4;
    assert TileLogicalElementDefined(shared_before.tile, source_element);
    let before_threshold_source = TileLogicalLinearIndex(
        shared_before.tile, 127, 255);
    let threshold_source0 = TileLogicalLinearIndex(
        shared_before.tile, 128, 0);
    let threshold_source1 = TileLogicalLinearIndex(
        shared_before.tile, 128, 1);
    assert before_threshold_source == 32767;
    assert TilePackedCarrierIndex(TileDataType_U16,
        before_threshold_source) == 8191;
    assert TilePackedLaneIndex(TileDataType_U16,
        before_threshold_source) == 3;
    assert threshold_source0 == 32768;
    assert TilePackedCarrierIndex(TileDataType_U16,
        threshold_source0) == 8192;
    assert TilePackedLaneIndex(TileDataType_U16,
        threshold_source0) == 0;
    assert threshold_source1 == 32769;
    assert TilePackedCarrierIndex(TileDataType_U16,
        threshold_source1) == 8192;
    assert TilePackedLaneIndex(TileDataType_U16,
        threshold_source1) == 1;
    assert TileReadLogicalElement(shared_before.tile, before_threshold_source) ==
        Zeros{PTO_XLEN} + 0xBEEF;
    assert TileReadLogicalElement(shared_before.tile, threshold_source0) ==
        Zeros{PTO_XLEN} + 0x1234;
    assert TileReadLogicalElement(shared_before.tile, threshold_source1) ==
        Zeros{PTO_XLEN} + 0x5678;
    let final_source_lane2 = TileLogicalLinearIndex(
        shared_before.tile, n - 1, 254);
    let final_source_lane3 = TileLogicalLinearIndex(
        shared_before.tile, n - 1, 255);
    assert final_source_lane3 == n * 256 - 1;
    assert TilePackedLaneIndex(TileDataType_U16, final_source_lane2) == 2;
    assert TilePackedLaneIndex(TileDataType_U16, final_source_lane3) == 3;
    assert TileReadLogicalElement(shared_before.tile, final_source_lane2) ==
        Zeros{PTO_XLEN} + 0x9ABC;
    assert TileReadLogicalElement(shared_before.tile, final_source_lane3) ==
        Zeros{PTO_XLEN} + 0xDEF0;

    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 26;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 65);
    SetBundleDimension(1, Zeros{PTO_XLEN} + n);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 256);
    BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
    AddBundleTileBinding(
        TRUE, 0, destination_size_code, '1111', TRUE, FALSE, 1, 0, TRUE);

    let right_private = MaterializeBundleSharedMatrixPrimary(
        0, 256, n, TileDataType_U16, FALSE, _CurrentMemoryAgent);
    assert BundleMatrixPrivateSharedViewLegal(
        right_private, 256, n, TileDataType_U16, FALSE);
    assert MatrixReadLogicalElement(right_private, 255, 127) ==
        Zeros{PTO_XLEN} + 0xBEEF;
    assert MatrixReadLogicalElement(right_private, 0, 128) ==
        Zeros{PTO_XLEN} + 0x1234;
    assert MatrixReadLogicalElement(right_private, 1, 128) ==
        Zeros{PTO_XLEN} + 0x5678;
    assert MatrixReadLogicalElement(right_private, 254, n - 1) ==
        Zeros{PTO_XLEN} + 0x9ABC;
    assert MatrixReadLogicalElement(right_private, 255, n - 1) ==
        Zeros{PTO_XLEN} + 0xDEF0;

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = BundleMatrixDestinationAt(0);
    assert _Tiles[[destination]].contents_defined;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M32;
    assert _Tiles[[destination]].data_type == TileDataType_U32;
    assert _Tiles[[destination]].capacity_bytes <= 65536;
    assert _Tiles[[destination]].valid_rows == active_m;
    assert _Tiles[[destination]].valid_columns == n;
    let shared_after = SharedTileRecord((Zeros{6} + 41) as SharedTileID);
    assert shared_after.tile.capacity_bytes == shared_before.tile.capacity_bytes;
    assert shared_after.tile.valid_rows == shared_before.tile.valid_rows;
    assert shared_after.tile.valid_columns == shared_before.tile.valid_columns;
    assert shared_after.tile.payload[[0]] == shared_before.tile.payload[[0]];
end;

func main() => integer
begin
    RunLargeSharedSource(256, 131072, 9);
    RunLargeSharedSource(512, 262144, 10);
    return 0;
end;
