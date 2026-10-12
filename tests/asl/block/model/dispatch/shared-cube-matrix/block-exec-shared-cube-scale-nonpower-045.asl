// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-CUBE-SCALE-NONPOWER-045","source":"asl/block/model/dispatch/shared-cube-matrix.asl","requirements":["PTO-CUBE-MATRIX-SCALE-001","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"execution","summary":"Even non-power K=18/66/162/194 preserves independent Shared MX groups and typed scale addresses.","pass_condition":"Decoded TMATMULMX with Shared E2M1X2 A and HiF4X2 B succeeds at M=17,N=3 for all transpose pairs at K=18/66/162/194; fixed ScaleA/ScaleB shapes use G_A=1/3/6/7 and G_B=1/2/3/4, and distinct row/group sentinels verify private logical views at each group transition and last group without checking scaled arithmetic results.","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl","asl/tile/model/execution/matrix-scale.asl"]}

pure func Issue374ScaleAToken(
    row: integer {0..31}, group: integer {0..7}) => Word
begin
    return Zeros{PTO_XLEN} + 1 + row * 8 + group;
end;

pure func Issue374ScaleBToken(
    row: integer {0..7}, group: integer {0..7}) => Word
begin
    return Zeros{PTO_XLEN} + 128 + row * 8 + group;
end;

func FillIssue374ScaleSentinels(
    index: TileIndex,
    rows: integer {1..32},
    groups: integer {1..8},
    right_scale: boolean)
begin
    for row = 0 to rows - 1 looplimit 32 do
        for group = 0 to groups - 1 looplimit 8 do
            let element = TileLogicalLinearIndex(
                _Tiles[[index]], row as integer {0..31},
                group as integer {0..7});
            _Tiles[[index]].payload[[element]] = if right_scale then
                Issue374ScaleBToken(
                    row as integer {0..7}, group as integer {0..7})
            else
                Issue374ScaleAToken(
                    row as integer {0..31}, group as integer {0..7});
        end;
    end;
end;

func AssertIssue374PrivateScaleAddresses(k: integer {18,66,162,194})
begin
    let left_groups = TileMXScaleGroupCount(k, TileDataType_E2M1X2);
    let right_groups = TileMXScaleGroupCount(k, TileDataType_HiF4X2);
    assert _Tiles[[11]].valid_rows == 17;
    assert _Tiles[[11]].valid_columns == left_groups;
    assert _Tiles[[13]].valid_rows == 3;
    assert _Tiles[[13]].valid_columns == right_groups;

    let left_pe0 = MaterializeBundleSharedMatrixLeftScale(
        1, 17, k, TileDataType_E2M1X2, 0 as MemoryAgentId);
    let left_pe1 = MaterializeBundleSharedMatrixLeftScale(
        1, 17, k, TileDataType_E2M1X2, 1 as MemoryAgentId);
    assert left_pe0.rows == 16 && left_pe0.columns == left_groups;
    assert left_pe1.rows == 1 && left_pe1.columns == left_groups;
    let left_group_size = TileMXScaleGroupSize(TileDataType_E2M1X2);
    for group = 0 to left_groups - 1 looplimit 8 do
        let first_inner = group * left_group_size;
        let last_inner = if first_inner + left_group_size > k then
            k - 1 else first_inner + (left_group_size - 1);
        for sample = 0 to 2 looplimit 3 do
            let local_row = if sample == 0 then 0
                else if sample == 1 then 15 else 0;
            let global_row = if sample == 2 then 16 else local_row;
            let scale_view = if sample == 2 then left_pe1 else left_pe0;
            for edge = 0 to 1 looplimit 2 do
                let inner = if edge == 0 then first_inner else last_inner;
                let element = MatrixLeftScaleElement(
                    scale_view, TileDataType_E2M1X2,
                    local_row as integer {0..31},
                    inner as integer {0..65535});
                assert TileReadLogicalElement(scale_view, element) ==
                    Issue374ScaleAToken(
                        global_row as integer {0..31},
                        group as integer {0..7});
            end;
        end;
    end;

    let right_view = MaterializeBundleSharedMatrixPrimary(
        3, right_groups, 3, TileDataType_U32, FALSE,
        0 as MemoryAgentId);
    assert right_view.rows == right_groups && right_view.columns == 3;
    assert right_view.layout == TileLayout_RowMajor;
    let right_group_size = TileMXScaleGroupSize(TileDataType_HiF4X2);
    for group = 0 to right_groups - 1 looplimit 8 do
        let first_inner = group * right_group_size;
        let last_inner = if first_inner + right_group_size > k then
            k - 1 else first_inner + (right_group_size - 1);
        for column = 0 to 2 looplimit 3 do
            for edge = 0 to 1 looplimit 2 do
                let inner = if edge == 0 then first_inner else last_inner;
                let element = MatrixRightScaleElement(
                    right_view, TileDataType_HiF4X2,
                    column as integer {0..2}, inner as integer {0..65535});
                assert TileReadLogicalElement(right_view, element) ==
                    Issue374ScaleBToken(
                        column as integer {0..7}, group as integer {0..7});
            end;
        end;
    end;
end;

func main() => integer
begin
    for shape_case = 0 to 3 looplimit 4 do
      let k = if shape_case == 0 then 18
          else if shape_case == 1 then 66
          else if shape_case == 2 then 162 else 194;
      for controls = 0 to 3 looplimit 4 do
        ResetProfileState();
        let trans_a = controls MOD 2 == 1;
        let trans_b = controls >= 2;
        let left_groups = TileMXScaleGroupCount(k, TileDataType_E2M1X2);
        let right_groups = TileMXScaleGroupCount(k, TileDataType_HiF4X2);
        let a_pitch = if trans_a then 32 else 256;
        let a_valid_columns = if trans_a then 17 else k;
        let a_stored_rows = if trans_a then k else 17;
        ConfigureTileForMask(10, 4096,
            DerivedTileRows(4096, a_pitch, TileDataType_E2M1X2),
            a_pitch, a_stored_rows, a_valid_columns,
            TileDataType_E2M1X2, TileLayout_RowMajor, '1111');
        MarkTileValidRegionDefined(10);

        ConfigureTileForMask(11, 256,
            DerivedTileRows(256, 8, TileDataType_E8M0), 8,
            17, left_groups, TileDataType_E8M0, TileLayout_RowMajor, '1111');
        MarkTileValidRegionDefined(11);
        FillIssue374ScaleSentinels(
            11, 17, left_groups as integer {1..8}, FALSE);

        let b_pitch = if trans_b then 4 else 256;
        let b_valid_rows = if trans_b then k else 3;
        let b_valid_columns = if trans_b then 3 else k;
        let b_stored_rows = if trans_b then k else 3;
        ConfigureTileForMask(12, 1024,
            DerivedTileRows(1024, b_pitch, TileDataType_HiF4X2),
            b_pitch, b_stored_rows, b_valid_columns,
            TileDataType_HiF4X2, TileLayout_RowMajor, '1111');
        MarkTileValidRegionDefined(12);

        ConfigureTileForMask(13, 128,
            DerivedTileRows(128, 4, TileDataType_U32), 4,
            3, right_groups, TileDataType_U32, TileLayout_RowMajor, '1111');
        MarkTileValidRegionDefined(13);
        FillIssue374ScaleSentinels(
            13, 3, right_groups as integer {1..8}, TRUE);

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
        SetBundleDimension(2, Zeros{PTO_XLEN} + k);
        BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
        BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
        BindBundleSharedIO((Zeros{6} + 42) as SharedTileID, 0, '1111');
        BindBundleSharedIO((Zeros{6} + 43) as SharedTileID, 0, '1111');
        AddBundleTileBinding(
            TRUE, 0, 3, '1111', FALSE, FALSE, 0, 0, TRUE);
        assert TileMXScaleGroupCount(18, TileDataType_E2M1X2) == 1;
        assert TileMXScaleGroupCount(66, TileDataType_E2M1X2) == 3;
        assert TileMXScaleGroupCount(162, TileDataType_E2M1X2) == 6;
        assert TileMXScaleGroupCount(194, TileDataType_E2M1X2) == 7;
        assert TileMXScaleGroupCount(18, TileDataType_HiF4X2) == 1;
        assert TileMXScaleGroupCount(66, TileDataType_HiF4X2) == 2;
        assert TileMXScaleGroupCount(162, TileDataType_HiF4X2) == 3;
        assert TileMXScaleGroupCount(194, TileDataType_HiF4X2) == 4;
        assert TileMXScaleGroupCount(k, TileDataType_E2M1X2) == left_groups;
        assert TileMXScaleGroupCount(k, TileDataType_HiF4X2) == right_groups;
        AssertIssue374PrivateScaleAddresses(k);
        assert BundleMatrixSharedSchemasLegal(
            4, TileDataType_E2M1X2, TileDataType_HiF4X2,
            17, 3, k, 4);

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
    end;
    return 0;
end;
