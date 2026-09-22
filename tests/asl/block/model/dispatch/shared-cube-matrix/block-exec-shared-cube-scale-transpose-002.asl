// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-CUBE-SCALE-TRANSPOSE-002","source":"asl/block/model/dispatch/shared-cube-matrix.asl","requirements":["PTO-CUBE-MATRIX-SCALE-001","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"execution","summary":"Shared Matrix transpose changes only primary data while canonical non-uniform scales remain K-group-major.","pass_condition":"TransA=TransB=1 accepts transposed A [K,M] and B [K,N] primaries together with canonical physical ScaleA [M,G_A] and ScaleB [N,G_B]; distinct scale values produce the exact 2x2 result [[224,480],[320,704]] without mutating Shared state.","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl"]}

func main() => integer
begin
    ResetProfileState();
    ConfigureTileForMask(10, 128, 64, 2, 64, 2,
        TileDataType_E4M3, TileLayout_RowMajor, '1111');
    ConfigureTileForMask(11, 128, 2, 2, 2, 2,
        TileDataType_E8M0, TileLayout_RowMajor, '1111');
    ConfigureTileForMask(12, 128, 64, 2, 64, 2,
        TileDataType_E5M2, TileLayout_RowMajor, '1111');
    ConfigureTileForMask(13, 128, 2, 2, 2, 2,
        TileDataType_E8M0, TileLayout_RowMajor, '1111');
    for row = 0 to 63 looplimit 64 do
        for column = 0 to 1 looplimit 2 do
            // Transposed primaries are physically [K,M] and [K,N].
            WriteTileElement(10, row, column, Zeros{PTO_XLEN} + 1);
            WriteTileElement(12, row, column, Zeros{PTO_XLEN} + 1);
        end;
    end;
    // Shared ScaleA is always physically [M,G_A].
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(11, 0, 1, Zeros{PTO_XLEN} + 3);
    WriteTileElement(11, 1, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(11, 1, 1, Zeros{PTO_XLEN} + 4);
    // Shared ScaleB is always physically [N,G_B], representing ScaleB[g,n].
    WriteTileElement(13, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(13, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(13, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(13, 1, 1, Zeros{PTO_XLEN} + 4);
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
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 64);
    BindBundleSharedIO((Zeros{6} + 44) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 45) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 46) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 47) as SharedTileID, 0, '1111');
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', FALSE, FALSE, 0, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = BundleMatrixDestinationAt(0);
    assert _Tiles[[destination]].valid_rows == 2;
    assert _Tiles[[destination]].valid_columns == 2;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 224;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 480;
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 320;
    assert ReadTileElement(destination, 1, 1) == Zeros{PTO_XLEN} + 704;
    assert SharedTileRecord((Zeros{6} + 44) as SharedTileID).published;
    assert SharedTileRecord((Zeros{6} + 45) as SharedTileID).published;
    return 0;
end;
