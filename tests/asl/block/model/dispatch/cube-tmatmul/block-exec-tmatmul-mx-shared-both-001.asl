// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-MX-SHARED-BOTH-001","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-TMATMUL-MX-CONTRACT-001"],"kind":"execution","summary":"TMATMULMX accepts complete Shared left and right matrix-scale groups","pass_condition":"four ordered Shared sources produce one FP32 Local destination and are consumed after commit","related_sources":["asl/tile/model/legality/matrix-functions.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(10, 512, 4, 32, 4, 32, TileDataType_E4M3,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(11, 128, 4, 1, 4, 1, TileDataType_E8M0,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(12, 512, 32, 1, 32, 1, TileDataType_E5M2,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(13, 128, 1, 1, 1, 1, TileDataType_E8M0,
        TileLayout_RowMajor, TileLocation_Matrix);
    for row = 0 to 3 do
        for inner = 0 to 31 looplimit 32 do
            WriteTileElement(10, row, inner, Zeros{PTO_XLEN} + 2);
        end;
        WriteTileElement(11, row, 0, Zeros{PTO_XLEN} + 1);
    end;
    for inner = 0 to 31 looplimit 32 do
        WriteTileElement(12, inner, 0, Zeros{PTO_XLEN} + 3);
    end;
    WriteTileElement(13, 0, 0, Zeros{PTO_XLEN} + 1);
    InstallSharedTile((Zeros{6} + 44) as SharedTileID, _Tiles[[10]], '1111');
    InstallSharedTile((Zeros{6} + 45) as SharedTileID, _Tiles[[11]], '1111');
    InstallSharedTile((Zeros{6} + 46) as SharedTileID, _Tiles[[12]], '1111');
    InstallSharedTile((Zeros{6} + 47) as SharedTileID, _Tiles[[13]], '1111');
    var start: bits(64) = Zeros{64} + 0x00431181;
    start[31:27] = Zeros{5} + 7;
    let start_result = ExecuteCommandInstruction(start, 32);
    assert start_result == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 8, Zeros{5}, Zeros{2}, Zeros{3}, Zeros{3},
        FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 32);
    BindBundleSharedIO((Zeros{6} + 44) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 45) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 46) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 47) as SharedTileID, 0, '1111');
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', FALSE, FALSE, 0, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = BundleMatrixDestinationAt(0);
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 192;
    return 0;
end;
