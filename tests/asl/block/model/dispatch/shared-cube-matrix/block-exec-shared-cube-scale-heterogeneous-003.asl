// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-CUBE-SCALE-HETEROGENEOUS-003","source":"asl/block/model/dispatch/shared-cube-matrix.asl","requirements":["PTO-CUBE-MATRIX-SCALE-001","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"execution","summary":"Shared MX control zero maps unequal E4M3 and HiF4X2 scale groups by their own majors.","pass_condition":"TransA=TransB=0 with A E4M3 G_A=2 and B HiF4X2 G_B=1 accepts physical A [M,K], AScale [M,G_A], B [N,K], and BScale [N,G_B]; non-uniform scale payloads materialize to the independently expected [1,2],[3,4] and [5,6] values without deriving expectations from the mapping helper.","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl","asl/tile/model/legality/matrix-functions.asl"]}
func main() => integer
begin
    ResetProfileState();
    // A is E4M3 with G_A=2 for K=64; B is HiF4X2 with G_B=1.
    ConfigureTileForMask(10, 128, 2, 64, 2, 64,
        TileDataType_E4M3, TileLayout_RowMajor, '1111');
    ConfigureTileForMask(11, 128, 2, 2, 2, 2,
        TileDataType_E8M0, TileLayout_RowMajor, '1111');
    ConfigureTileForMask(12, 128, 4, 64, 2, 64,
        TileDataType_HiF4X2, TileLayout_RowMajor, '1111');
    ConfigureTileForMask(13, 128, 2, 1, 2, 1,
        TileDataType_U32, TileLayout_RowMajor, '1111');

    for row = 0 to 1 looplimit 2 do
        for inner = 0 to 63 looplimit 64 do
            WriteTileElement(10, row, inner, Zeros{PTO_XLEN} + 1);
            WriteTileElement(12, row, inner, Zeros{PTO_XLEN} + 1);
        end;
    end;
    // A scale is physically [M,G_A] for control zero.
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(11, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(11, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(11, 1, 1, Zeros{PTO_XLEN} + 4);
    // B scale is physically [N,G_B] for control zero and G_B=1.
    WriteTileElement(13, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(13, 1, 0, Zeros{PTO_XLEN} + 6);

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
        Zeros{5} + 14, Zeros{5}, Zeros{2}, Zeros{3}, Zeros{3},
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
    assert TileMXScaleGroupCount(64, TileDataType_E4M3) == 2;
    assert TileMXScaleGroupCount(64, TileDataType_HiF4X2) == 1;
    assert BundleMatrixSharedSchemasLegal(
        4, TileDataType_E4M3, TileDataType_HiF4X2,
        2, 2, 64, 4);
    assert BundleMatrixSharedPrimarySchemaLegal(
        0, 2, 64, TileDataType_E4M3, FALSE);
    assert BundleMatrixSharedBPrimarySchemaLegal(
        2, 64, 2, TileDataType_HiF4X2, FALSE);
    let mapped_left_scale = MaterializeBundleSharedMatrixLeftScale(
        1, 2, 64, TileDataType_E4M3, FALSE, 0);
    let mapped_right_scale = MaterializeBundleSharedMatrixPrimary(
        3, 1, 2, TileDataType_U32, FALSE, 0);
    assert TileReadLogicalElement(mapped_left_scale,
        TileLogicalLinearIndex(mapped_left_scale, 0, 0)) ==
        Zeros{PTO_XLEN} + 1;
    assert TileReadLogicalElement(mapped_left_scale,
        TileLogicalLinearIndex(mapped_left_scale, 0, 1)) ==
        Zeros{PTO_XLEN} + 2;
    assert TileReadLogicalElement(mapped_left_scale,
        TileLogicalLinearIndex(mapped_left_scale, 1, 0)) ==
        Zeros{PTO_XLEN} + 3;
    assert TileReadLogicalElement(mapped_left_scale,
        TileLogicalLinearIndex(mapped_left_scale, 1, 1)) ==
        Zeros{PTO_XLEN} + 4;
    assert TileReadLogicalElement(mapped_right_scale,
        TileLogicalLinearIndex(mapped_right_scale, 0, 0)) ==
        Zeros{PTO_XLEN} + 5;
    assert TileReadLogicalElement(mapped_right_scale,
        TileLogicalLinearIndex(mapped_right_scale, 0, 1)) ==
        Zeros{PTO_XLEN} + 6;
    return 0;
end;
