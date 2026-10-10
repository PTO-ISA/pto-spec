// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-CUBE-SCALE-NONPOWER-045","source":"asl/block/model/dispatch/shared-cube-matrix.asl","requirements":["PTO-CUBE-MATRIX-SCALE-001","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"execution","summary":"K=194 accepts independent shared MX scale groups G_A=7 and G_B=4 with fixed scale shapes under all transpose pairs.","pass_condition":"Decoded TMATMULMX with Shared E2M1X2 A and HiF4X2 B succeeds at M=17,N=3,K=194 for all transpose pairs; ScaleA remains [17,7], ScaleB [3,4], and original pitched scale coordinates are independently checked.","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl","asl/tile/model/execution/matrix-scale.asl"]}

func main() => integer
begin
    for controls = 0 to 3 looplimit 4 do
        ResetProfileState();
        let trans_a = controls MOD 2 == 1;
        let trans_b = controls >= 2;
        let a_pitch = if trans_a then 32 else 256;
        let a_valid_rows = if trans_a then 194 else 17;
        let a_valid_columns = if trans_a then 17 else 194;
        ConfigureTileForMask(10, 4096,
            DerivedTileRows(4096, a_pitch, TileDataType_E2M1X2),
            a_pitch, a_valid_rows, a_valid_columns,
            TileDataType_E2M1X2, TileLayout_RowMajor, '1111');
        MarkTileValidRegionDefined(10);

        ConfigureTileForMask(11, 256,
            DerivedTileRows(256, 8, TileDataType_E8M0), 8,
            17, 7, TileDataType_E8M0, TileLayout_RowMajor, '1111');
        MarkTileValidRegionDefined(11);

        let b_pitch = if trans_b then 4 else 256;
        let b_valid_rows = if trans_b then 194 else 3;
        let b_valid_columns = if trans_b then 3 else 194;
        ConfigureTileForMask(12, 1024,
            DerivedTileRows(1024, b_pitch, TileDataType_HiF4X2),
            b_pitch, b_valid_rows, b_valid_columns,
            TileDataType_HiF4X2, TileLayout_RowMajor, '1111');
        MarkTileValidRegionDefined(12);

        ConfigureTileForMask(13, 128,
            DerivedTileRows(128, 4, TileDataType_U32), 4,
            3, 4, TileDataType_U32, TileLayout_RowMajor, '1111');
        MarkTileValidRegionDefined(13);

        // These coordinates are in the original fixed-major Shared scale
        // descriptors. K=193 maps to A group 6 and B group 3 independently.
        assert TileMXScaleGroupCount(194, TileDataType_E2M1X2) == 7;
        assert TileMXScaleGroupCount(194, TileDataType_HiF4X2) == 4;
        assert TileLogicalLinearIndex(_Tiles[[11]], 16, 6) == 134;
        assert TileLogicalElementDefined(_Tiles[[11]],
            TileLogicalLinearIndex(_Tiles[[11]], 16, 6));
        assert TileLogicalLinearIndex(_Tiles[[13]], 2, 3) == 11;
        assert TileLogicalElementDefined(_Tiles[[13]],
            TileLogicalLinearIndex(_Tiles[[13]], 2, 3));

        InstallSharedTile((Zeros{6} + 40) as SharedTileID,
            _Tiles[[10]], '1111');
        InstallSharedTile((Zeros{6} + 41) as SharedTileID,
            _Tiles[[11]], '1111');
        InstallSharedTile((Zeros{6} + 42) as SharedTileID,
            _Tiles[[12]], '1111');
        InstallSharedTile((Zeros{6} + 43) as SharedTileID,
            _Tiles[[13]], '1111');

        var start: bits(64) = Zeros{64} + 0x00431181;
        start[31:27] = Zeros{5} + 11;
        let started = ExecuteCommandInstruction(start, 32);
        assert started == CommandExecution_Executed;
        SetBundleDataAttributeState(
            Zeros{5} + 14, Zeros{5}, Zeros{2}, Zeros{3}, Zeros{3},
            FALSE, FALSE);
        _BundleDataAttributesPresent = TRUE;
        SetBundleFixedPointAttributeState(
            Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE,
            trans_a, trans_b);
        SetBundleDimension(0, Zeros{PTO_XLEN} + 17);
        SetBundleDimension(1, Zeros{PTO_XLEN} + 3);
        SetBundleDimension(2, Zeros{PTO_XLEN} + 194);
        BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
        BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
        BindBundleSharedIO((Zeros{6} + 42) as SharedTileID, 0, '1111');
        BindBundleSharedIO((Zeros{6} + 43) as SharedTileID, 0, '1111');
        AddBundleTileBinding(
            TRUE, 0, 3, '1111', FALSE, FALSE, 0, 0, TRUE);
        assert BundleMatrixSharedSchemasLegal(
            4, TileDataType_E2M1X2, TileDataType_HiF4X2,
            17, 3, 194, 4);

        let completed = ExecuteBundleTileOperation();
        assert completed && _LastFault == Fault_None;
        let destination = BundleMatrixDestinationAt(0);
        assert _Tiles[[destination]].contents_defined;
        assert _Tiles[[destination]].data_type == TileDataType_FP32;
        assert _Tiles[[destination]].valid_columns == 3;
        assert _Tiles[[destination]].valid_rows ==
            BundleMatrixCooperativeValidM(17, _CurrentMemoryAgent);
        assert _BundleSharedBindings[[0]].consumed;
        assert _BundleSharedBindings[[1]].consumed;
        assert _BundleSharedBindings[[2]].consumed;
        assert _BundleSharedBindings[[3]].consumed;
    end;
    return 0;
end;
