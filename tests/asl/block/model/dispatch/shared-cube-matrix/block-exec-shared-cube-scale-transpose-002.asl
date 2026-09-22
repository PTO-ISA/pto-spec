// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-CUBE-SCALE-TRANSPOSE-002","source":"asl/block/model/dispatch/shared-cube-matrix.asl","requirements":["PTO-CUBE-MATRIX-SCALE-001","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"execution","summary":"Shared Matrix transpose changes only primary data while canonical non-uniform scales remain K-group-major for non-square dimensions.","pass_condition":"TransA=TransB=1 accepts transposed A [K,M] and B [K,N] primaries with M=4, N=4, canonical physical ScaleA [M,G_A] and ScaleB [N,G_B], and axis-sensitive values produce the exact 4x4 result with axis-sensitive values.","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl"]}

func main() => integer
begin
    ResetProfileState();
    ConfigureTileForMask(10, 512, 128, 4, 64, 4,
        TileDataType_E4M3, TileLayout_RowMajor, '1111');
    ConfigureTileForMask(11, 128, 64, 2, 4, 2,
        TileDataType_E8M0, TileLayout_RowMajor, '1111');
    ConfigureTileForMask(12, 512, 128, 4, 64, 4,
        TileDataType_E5M2, TileLayout_RowMajor, '1111');
    ConfigureTileForMask(13, 128, 64, 2, 4, 2,
        TileDataType_E8M0, TileLayout_RowMajor, '1111');
    for row = 0 to 63 looplimit 64 do
        for column = 0 to 3 looplimit 4 do
            // Transposed A primary is physically [K,M].
            WriteTileElement(10, row, column, Zeros{PTO_XLEN} + 1);
        end;
        // Transposed B primary is physically [K,N].
        for column = 0 to 3 looplimit 4 do
            WriteTileElement(12, row, column, Zeros{PTO_XLEN} + 1);
        end;
    end;
    // Shared ScaleA is always physically [M,G_A] with M=4 and G_A=2.
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(11, 0, 1, Zeros{PTO_XLEN} + 3);
    WriteTileElement(11, 1, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(11, 1, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(11, 2, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(11, 2, 1, Zeros{PTO_XLEN} + 5);
    WriteTileElement(11, 3, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(11, 3, 1, Zeros{PTO_XLEN} + 6);
    // Shared ScaleB is always physically [N,G_B], representing ScaleB[g,n],
    // with N=4 and G_B=2.
    WriteTileElement(13, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(13, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(13, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(13, 1, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(13, 2, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(13, 2, 1, Zeros{PTO_XLEN} + 6);
    WriteTileElement(13, 3, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(13, 3, 1, Zeros{PTO_XLEN} + 8);

    InstallSharedTile((Zeros{6} + 44) as SharedTileID, _Tiles[[10]], '1111');
    InstallSharedTile((Zeros{6} + 45) as SharedTileID, _Tiles[[11]], '1111');
    InstallSharedTile((Zeros{6} + 46) as SharedTileID, _Tiles[[12]], '1111');
    InstallSharedTile((Zeros{6} + 47) as SharedTileID, _Tiles[[13]], '1111');

    var start: bits(64) = Zeros{64} + 0x00431181;
    start[31:27] = Zeros{5} + 7;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 8, Zeros{5}, Zeros{2}, Zeros{3}, Zeros{3},
        FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE,
        TRUE, TRUE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 64);
    BindBundleSharedIO((Zeros{6} + 44) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 45) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 46) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 47) as SharedTileID, 0, '1111');
    AddBundleTileBinding(
        TRUE, 0, 2, '1111', FALSE, FALSE, 0, 0, TRUE);
    assert BundleMatrixSharedSourcesReady(4);
    assert BundleMatrixSharedSchemasLegal(
        4, TileDataType_E4M3, TileDataType_E5M2, 4, 4, 64, 4);
    let debug_left = MaterializeBundleSharedMatrixLeftPrimary(
        0, 4, 64, TileDataType_E4M3, TRUE, 0);
    let debug_left_scale = MaterializeBundleSharedMatrixLeftScale(
        1, 4, 64, TileDataType_E4M3, 0);
    let debug_right = MaterializeBundleSharedMatrixPrimary(
        2, 64, 4, TileDataType_E5M2, TRUE, 0);
    let debug_right_scale = MaterializeBundleSharedMatrixPrimary(
        3, 2, 4, TileDataType_E8M0, FALSE, 0);
    assert TileMatrixInfoOptionalScalesLegal(
        debug_left, debug_left_scale, TRUE,
        debug_right, debug_right_scale, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = BundleMatrixDestinationAt(0);
    assert _Tiles[[destination]].valid_rows == 4;
    assert _Tiles[[destination]].valid_columns == 4;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 224;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 480;
    assert ReadTileElement(destination, 0, 2) == Zeros{PTO_XLEN} + 736;
    assert ReadTileElement(destination, 0, 3) == Zeros{PTO_XLEN} + 992;
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 320;
    assert ReadTileElement(destination, 1, 1) == Zeros{PTO_XLEN} + 704;
    assert ReadTileElement(destination, 1, 2) == Zeros{PTO_XLEN} + 1088;
    assert ReadTileElement(destination, 1, 3) == Zeros{PTO_XLEN} + 1472;
    assert ReadTileElement(destination, 2, 0) == Zeros{PTO_XLEN} + 416;
    assert ReadTileElement(destination, 2, 1) == Zeros{PTO_XLEN} + 928;
    assert ReadTileElement(destination, 2, 2) == Zeros{PTO_XLEN} + 1440;
    assert ReadTileElement(destination, 2, 3) == Zeros{PTO_XLEN} + 1952;

    assert ReadTileElement(destination, 3, 0) == Zeros{PTO_XLEN} + 512;
    assert ReadTileElement(destination, 3, 1) == Zeros{PTO_XLEN} + 1152;
    assert ReadTileElement(destination, 3, 2) == Zeros{PTO_XLEN} + 1792;
    assert ReadTileElement(destination, 3, 3) == Zeros{PTO_XLEN} + 2432;
    assert SharedTileRecord((Zeros{6} + 44) as SharedTileID).published;
    assert SharedTileRecord((Zeros{6} + 45) as SharedTileID).published;
    return 0;
end;
