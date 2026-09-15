// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-B-PHYSICAL-SHAPE-031","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"fault","summary":"Shared B rejects both oversized and undersized physical valid shapes.","pass_condition":"With TransB=0 and logical B KxN=8x4, Shared B valid rows 5 or valid columns 7 instead of exact physical N x K=4x8 raises Fault_TileLegality before payload or destination effects.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl","asl/tile/model/state/shared-registers.asl"]}
func main() => integer
begin
    for shape_case = 0 to 1 do
        ResetProfileState();
        let b_valid_rows = if shape_case == 0 then 5 else 4;
        let b_valid_columns = if shape_case == 0 then 8 else 7;
        ConfigureTileForMask(10, 256, 8, 16, 2, 8,
            TileDataType_U16, TileLayout_RowMajor, '1111');
        ConfigureTileForMask(11, 256, 16, 8, b_valid_rows,
            b_valid_columns, TileDataType_U16, TileLayout_RowMajor, '1111');
        MarkTileValidRegionDefined(10);
        MarkTileValidRegionDefined(11);
        InstallSharedTile((Zeros{6} + 40) as SharedTileID,
            _Tiles[[10]], '1111');
        InstallSharedTile((Zeros{6} + 41) as SharedTileID,
            _Tiles[[11]], '1111');
        var start: bits(64) = Zeros{64} + 0x00031181;
        start[31:27] = Zeros{5} + 26;
        let started = ExecuteCommandInstruction(start, 32);
        assert started == CommandExecution_Executed;
        SetBundleFixedPointAttributeState(
            Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE,
            FALSE, FALSE);
        SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
        SetBundleDimension(1, Zeros{PTO_XLEN} + 4);
        SetBundleDimension(2, Zeros{PTO_XLEN} + 8);
        BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
        BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
        AddBundleTileBinding(
            TRUE, 0, 2, '1111', FALSE, FALSE, 0, 0, TRUE);
        let completed = ExecuteBundleTileOperation();
        assert !completed && _LastFault == Fault_TileLegality;
        assert !_BundleSharedBindings[[0]].consumed;
        assert !_BundleSharedBindings[[1]].consumed;
        assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    end;
    return 0;
end;
