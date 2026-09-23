// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-MX-SHARED-RIGHT-001","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-TMATMUL-MX-CONTRACT-001","PTO-CUBE-MATRIX-SCALE-001","PTO-CUBE-SHARED-TRANSPOSE-001","PTO-B-SUBVIEW-RANGE-001"],"kind":"execution","summary":"TMATMULMX preserves Local ScaleA while TransB changes only a non-square Shared B primary and scale subview.","pass_condition":"Local E4M3 A and ScaleA plus TransB=1 Shared E5M2 B with N=4 and physical ScaleB [N,G_B]=[4,1] produce four FP32 destination values of 32; the scale subview remains in its fixed K-group-major mapping and the Shared parent is preserved.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl","asl/tile/model/execution/matrix-scale.asl"]}
func main() => integer
begin
    ResetProfileState();
    let left_ready = ConfigureCubeTileForMask(0, 512, 1, 32,
        TileDataType_E4M3, TileLayout_CUBE_M16, '1111');
    assert left_ready;
    let left_scale_ready = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_E8M0, TileLayout_CUBE_M32, '1111');
    assert left_scale_ready;
    ConfigureTileForMask(10, 128, 32, 4, 32, 4, TileDataType_E5M2,
        TileLayout_RowMajor, '1111');
    ConfigureTileForMask(11, 128, 128, 1, 4, 1, TileDataType_E8M0,
        TileLayout_RowMajor, '1111');
    for inner = 0 to 31 looplimit 32 do
        WriteTileElement(0, 0, inner, Zeros{PTO_XLEN} + 1);
        for column = 0 to 3 looplimit 4 do
            WriteTileElement(10, inner, column, Zeros{PTO_XLEN} + 1);
        end;
    end;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(11, 1, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(11, 2, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(11, 3, 0, Zeros{PTO_XLEN} + 1);
    MarkTileValidRegionDefined(1);
    InstallSharedTile((Zeros{6} + 42) as SharedTileID, _Tiles[[10]], '1111');
    InstallSharedTile((Zeros{6} + 43) as SharedTileID, _Tiles[[11]], '1111');
    var start: bits(64) = Zeros{64} + 0x00431181;
    start[31:27] = Zeros{5} + 7;
    let start_result = ExecuteCommandInstruction(start, 32);
    assert start_result == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 8, Zeros{5}, Zeros{2}, Zeros{3}, Zeros{3},
        FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE,
        FALSE, TRUE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 32);
    BindBundleSharedIO((Zeros{6} + 42) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 43) as SharedTileID, 0, '1111');
    let scale_parent_before = SharedTileRecord(
        (Zeros{6} + 43) as SharedTileID);
    _BundleSharedBindings[[1]].source0_subview.valid = TRUE;
    _BundleSharedBindings[[1]].source0_subview.reg_src = 0;
    _BundleSharedBindings[[1]].source0_subview.uimm11 = Zeros{11};
    _BundleSharedBindings[[1]].source0_subview.size_code = 1;
    AddBundleTileBinding(
        TRUE, 0, 2, '1111', TRUE, TRUE, 0, 1, TRUE);
    assert SharedTileRecord((Zeros{6} + 43) as SharedTileID).tile.capacity_bytes == 128;
    assert SharedTileRecord((Zeros{6} + 43) as SharedTileID).tile.rows == 128;
    assert SharedTileRecord((Zeros{6} + 43) as SharedTileID).tile.columns == 1;
    assert SharedTileRecord((Zeros{6} + 43) as SharedTileID).tile.valid_rows == 4;
    assert SharedTileRecord((Zeros{6} + 43) as SharedTileID).tile.valid_columns == 1;
    assert BundleSharedSubviewOffsetRawForPE(1, 0) == Zeros{PTO_XLEN};
    assert BundleSharedSubviewMatrixMetadataLegalForPE(
        1, 0, 4, 1, 1, TileDataType_E8M0);

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = BundleMatrixDestinationAt(0);
    assert _Tiles[[destination]].valid_rows == 1;
    assert _Tiles[[destination]].valid_columns == 4;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 32;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 32;
    assert ReadTileElement(destination, 0, 2) == Zeros{PTO_XLEN} + 32;
    assert ReadTileElement(destination, 0, 3) == Zeros{PTO_XLEN} + 32;
    let scale_parent_after = SharedTileRecord(
        (Zeros{6} + 43) as SharedTileID);
    assert scale_parent_after.tile.capacity_bytes ==
        scale_parent_before.tile.capacity_bytes;
    assert scale_parent_after.tile.valid_rows ==
        scale_parent_before.tile.valid_rows;
    assert scale_parent_after.tile.valid_columns ==
        scale_parent_before.tile.valid_columns;
    return 0;
end;
