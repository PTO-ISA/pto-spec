// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-LARGE-SOURCE-044","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-TMATMUL-CONTRACT-001","PTO-CUBE-SHARED-TRANSPOSE-001","PTO-CUBE-GROUP-M-DISTRIBUTION-001"],"kind":"execution","summary":"128 and 256 KiB Shared sources execute through typed logical carrier reads with legal 64 KiB Local output.","pass_condition":"At group_M=65 PE2 executes N=256/K=256 and N=512/K=256 Shared U16 sources (128/256 KiB) using Local CUBE_M32 A and exact-shape U32 output no larger than 64 KiB.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl","asl/tile/model/definedness/packed-boundary.asl"]}

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
    let shared_input = TileWithValidRegionDefined(
        MaterializeSharedTileForReadSchemaAtCapacity(
            shared_id, n, 256, 256, TileDataType_U16,
            TileLayout_RowMajor, source_capacity));
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
