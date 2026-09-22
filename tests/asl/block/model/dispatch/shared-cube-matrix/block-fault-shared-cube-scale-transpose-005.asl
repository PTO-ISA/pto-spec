// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-CUBE-SCALE-TRANSPOSE-005","source":"asl/block/model/dispatch/shared-cube-matrix.asl","requirements":["PTO-CUBE-MATRIX-SCALE-001","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"fault","summary":"Shared Matrix rejects transpose-selected legacy scale physical shapes before allocation.","pass_condition":"For M=N=3 and G_A=G_B=2, TransA=TransB=1 accepts the [K,M] and [K,N] primary descriptors but rejects legacy ScaleA [G_A,M] and ScaleB [G_B,N] source shapes with Fault_TileLegality before destination allocation.","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl","asl/tile/model/legality/matrix-functions.asl"]}

func main() => integer
begin
    ResetProfileState();
    ConfigureTileForMask(10, 512, 64, 4, 64, 3,
        TileDataType_E4M3, TileLayout_RowMajor, '1111');
    // Legacy transpose-selected ScaleA [G_A,M] = [2,3].
    ConfigureTileForMask(11, 128, 2, 4, 2, 3,
        TileDataType_E8M0, TileLayout_RowMajor, '1111');
    ConfigureTileForMask(12, 512, 64, 4, 64, 3,
        TileDataType_E5M2, TileLayout_RowMajor, '1111');
    // Legacy transpose-selected ScaleB [G_B,N] = [2,3].
    ConfigureTileForMask(13, 128, 2, 4, 2, 3,
        TileDataType_E8M0, TileLayout_RowMajor, '1111');
    for row = 0 to 63 looplimit 64 do
        for column = 0 to 2 looplimit 3 do
            WriteTileElement(10, row, column, Zeros{PTO_XLEN} + 1);
            WriteTileElement(12, row, column, Zeros{PTO_XLEN} + 1);
        end;
    end;
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 2 looplimit 3 do
            WriteTileElement(11, row, column, Zeros{PTO_XLEN} + 1);
            WriteTileElement(13, row, column, Zeros{PTO_XLEN} + 1);
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
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 64);
    BindBundleSharedIO((Zeros{6} + 44) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 45) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 46) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 47) as SharedTileID, 0, '1111');
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', FALSE, FALSE, 0, 0, TRUE);

    assert BundleMatrixSharedPrimarySchemaLegal(
        0, 3, 64, TileDataType_E4M3, TRUE);
    assert BundleMatrixSharedBPrimarySchemaLegal(
        2, 64, 3, TileDataType_E5M2, TRUE);
    assert !BundleMatrixSharedPrimarySchemaLegal(
        1, 3, 2, TileDataType_E8M0, FALSE);
    assert !BundleMatrixSharedBPrimarySchemaLegal(
        3, 2, 3, TileDataType_E8M0, FALSE);
    assert !BundleMatrixSharedSchemasLegal(
        4, TileDataType_E4M3, TileDataType_E5M2,
        3, 3, 64, 4);

    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[4]].destination_allocated_by_bundle;
    assert SharedTileRecord((Zeros{6} + 44) as SharedTileID).published;
    assert SharedTileRecord((Zeros{6} + 45) as SharedTileID).published;
    return 0;
end;
