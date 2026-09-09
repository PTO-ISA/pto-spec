// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-CUBE-SCALE-TRANSPOSE-002","source":"asl/block/model/dispatch/shared-cube-matrix.asl","requirements":["PTO-CUBE-MATRIX-SCALE-001","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"execution","summary":"Shared Matrix transpose normalizes each independently bound primary and non-uniform scale.","pass_condition":"Stored transposed A, AScale, B, and BScale shapes normalize to group_MxK, group_MxG, KxN, and GxN; distinct scale values produce the exact 2x2 result [[224,320],[480,704]] without mutating Shared state.","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl"]}

func main() => integer
begin
    ResetProfileState();
    ConfigureTileForMask(10, 128, 64, 2, 64, 2,
        TileDataType_E4M3, TileLayout_RowMajor,
        TileLocation_Matrix, '1111');
    ConfigureTileForMask(11, 128, 64, 2, 2, 2,
        TileDataType_E8M0, TileLayout_RowMajor,
        TileLocation_Matrix, '1111');
    ConfigureTileForMask(12, 128, 64, 2, 64, 2,
        TileDataType_E5M2, TileLayout_RowMajor,
        TileLocation_Matrix, '1111');
    ConfigureTileForMask(13, 128, 64, 2, 2, 2,
        TileDataType_E8M0, TileLayout_RowMajor,
        TileLocation_Matrix, '1111');
    for row = 0 to 63 looplimit 64 do
        for column = 0 to 1 looplimit 2 do
            WriteTileElement(10, row, column, Zeros{PTO_XLEN} + 1);
        end;
    end;
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 1 looplimit 2 do
            // A TransA=1 is physically [G,M], so write the transpose of the
            // normalized logical [M,G] scale matrix.
            let left_scale = if row == 0 then
                (if column == 0 then 1 else 3)
                else (if column == 0 then 2 else 4);
            let right_scale = if row == 0 then
                (if column == 0 then 1 else 2)
                else (if column == 0 then 3 else 4);
            WriteTileElement(11, row, column,
                Zeros{PTO_XLEN} + left_scale);
            WriteTileElement(13, row, column,
                Zeros{PTO_XLEN} + right_scale);
        end;
    end;
    for row = 0 to 63 looplimit 64 do
        for column = 0 to 1 looplimit 2 do
            WriteTileElement(12, row, column, Zeros{PTO_XLEN} + 1);
        end;
    end;
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
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 320;
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 480;
    assert ReadTileElement(destination, 1, 1) == Zeros{PTO_XLEN} + 704;
    assert SharedTileRecord((Zeros{6} + 44) as SharedTileID).published;
    assert SharedTileRecord((Zeros{6} + 45) as SharedTileID).published;
    return 0;
end;
