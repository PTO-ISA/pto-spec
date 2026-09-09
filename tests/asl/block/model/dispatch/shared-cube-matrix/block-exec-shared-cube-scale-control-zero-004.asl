// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-CUBE-SCALE-CONTROL-ZERO-004","source":"asl/block/model/dispatch/shared-cube-matrix.asl","requirements":["PTO-CUBE-MATRIX-SCALE-001","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"execution","summary":"Shared Matrix-MX control zero maps independently bound scale majors.","pass_condition":"TransA=TransB=0 with E4M3/E5M2 K=64 and non-uniform [M,G] and [N,G] scales produces the independently expected FP32 matrix [[160,352],[352,800]].","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTileForMask(10, 128, 2, 64, 2, 64,
        TileDataType_E4M3, TileLayout_RowMajor,
        TileLocation_Matrix, '1111');
    ConfigureTileForMask(11, 128, 2, 2, 2, 2,
        TileDataType_E8M0, TileLayout_RowMajor,
        TileLocation_Matrix, '1111');
    ConfigureTileForMask(12, 128, 2, 64, 2, 64,
        TileDataType_E5M2, TileLayout_RowMajor,
        TileLocation_Matrix, '1111');
    ConfigureTileForMask(13, 128, 2, 2, 2, 2,
        TileDataType_E8M0, TileLayout_RowMajor,
        TileLocation_Matrix, '1111');
    for row = 0 to 1 looplimit 2 do
        for inner = 0 to 63 looplimit 64 do
            WriteTileElement(10, row, inner, Zeros{PTO_XLEN} + 1);
            WriteTileElement(12, row, inner, Zeros{PTO_XLEN} + 1);
        end;
    end;
    // Control zero stores AScale and BScale in their [major,group] forms.
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(11, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(11, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(11, 1, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(13, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(13, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(13, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(13, 1, 1, Zeros{PTO_XLEN} + 4);
    InstallSharedTile((Zeros{6} + 44) as SharedTileID,
        _Tiles[[10]], '1111');
    InstallSharedTile((Zeros{6} + 45) as SharedTileID,
        _Tiles[[11]], '1111');
    InstallSharedTile((Zeros{6} + 46) as SharedTileID,
        _Tiles[[12]], '1111');
    InstallSharedTile((Zeros{6} + 47) as SharedTileID,
        _Tiles[[13]], '1111');

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
        FALSE, FALSE, FALSE);
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
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 160;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 352;
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 352;
    assert ReadTileElement(destination, 1, 1) == Zeros{PTO_XLEN} + 800;
    return 0;
end;
