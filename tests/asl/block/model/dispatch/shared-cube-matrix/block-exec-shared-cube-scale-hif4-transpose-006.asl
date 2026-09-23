// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-CUBE-SCALE-HIF4-TRANSPOSE-006","source":"asl/block/model/dispatch/shared-cube-matrix.asl","requirements":["PTO-CUBE-MATRIX-SCALE-001","PTO-CUBE-SHARED-TRANSPOSE-001","PTO-CUBE-HIF4-SCALE-001"],"kind":"execution","summary":"Shared HiF4X2 ScaleB remains group-64 and fixed physical [N,G_B] under TransB=1.","pass_condition":"A shared Matrix-MX operation with K=128, HiF4X2 B, G_B=2, TransB=1, physical B [K,N]=[128,1], and physical ScaleB [N,G_B]=[1,2] executes without a legality fault; distinct scale words materialize in canonical group order and only the B primary is transpose-sensitive.","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl","asl/tile/model/legality/matrix-functions.asl"]}

func main() => integer
begin
    ResetProfileState();
    // A is E4M3 with G_A=4 for K=128; B is HiF4X2 with G_B=2.
    ConfigureTileForMask(10, 128, 1, 128, 1, 128,
        TileDataType_E4M3, TileLayout_RowMajor, '1111');
    ConfigureTileForMask(11, 128, 1, 4, 1, 4,
        TileDataType_E8M0, TileLayout_RowMajor, '1111');
    // TransB=1 makes the Shared B primary physical [K,N]=[128,1].
    ConfigureTileForMask(12, 128, 128, 1, 128, 1,
        TileDataType_HiF4X2, TileLayout_RowMajor, '1111');
    // Shared ScaleB is fixed physical [N,G_B]=[1,2], not [G_B,N].
    ConfigureTileForMask(13, 128, 1, 2, 1, 2,
        TileDataType_U32, TileLayout_RowMajor, '1111');

    for inner = 0 to 127 looplimit 128 do
        WriteTileElement(10, 0, inner, Zeros{PTO_XLEN} + 1);
        WriteTileElement(12, inner, 0, Zeros{PTO_XLEN} + 1);
    end;
    for group = 0 to 3 looplimit 4 do
        WriteTileElement(11, 0, group, Zeros{PTO_XLEN} + 1);
    end;
    WriteTileElement(13, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(13, 0, 1, Zeros{PTO_XLEN} + 2);

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
        FALSE, TRUE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 128);
    BindBundleSharedIO((Zeros{6} + 44) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 45) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 46) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 47) as SharedTileID, 0, '1111');
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', FALSE, FALSE, 0, 0, TRUE);

    assert TileMXScaleGroupCount(128, TileDataType_HiF4X2) == 2;
    assert BundleMatrixSharedSchemasLegal(
        4, TileDataType_E4M3, TileDataType_HiF4X2,
        1, 1, 128, 4);
    assert BundleMatrixSharedBPrimarySchemaLegal(
        2, 128, 1, TileDataType_HiF4X2, TRUE);
    assert BundleMatrixSharedBPrimarySchemaLegal(
        3, 2, 1, TileDataType_U32, FALSE);
    let mapped_right_scale = MaterializeBundleSharedMatrixPrimary(
        3, 2, 1, TileDataType_U32, FALSE, 0);
    assert TileReadLogicalElement(mapped_right_scale,
        TileLogicalLinearIndex(mapped_right_scale, 0, 0)) ==
        Zeros{PTO_XLEN} + 1;
    assert TileReadLogicalElement(mapped_right_scale,
        TileLogicalLinearIndex(mapped_right_scale, 1, 0)) ==
        Zeros{PTO_XLEN} + 2;

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = BundleMatrixDestinationAt(0);
    assert _Tiles[[destination]].valid_rows == 1;
    assert _Tiles[[destination]].valid_columns == 1;
    return 0;
end;
