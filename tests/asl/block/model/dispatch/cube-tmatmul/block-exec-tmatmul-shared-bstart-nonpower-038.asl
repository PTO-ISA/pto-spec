// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-BSTART-NONPOWER-038","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-BSTART-TMATMUL-CONTRACT-001","PTO-BSTART-TMATMUL-ACC-CONTRACT-001","PTO-BSTART-TMATMUL-BIAS-CONTRACT-001","PTO-BSTART-TMATMULMX-CONTRACT-001","PTO-BSTART-TMATMULMX-ACC-CONTRACT-001","PTO-BSTART-TMATMULMX-BIAS-CONTRACT-001","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"execution","summary":"Every decoded BSTART TMATMUL form executes non-power N and K with both primaries Shared.","pass_condition":"M=2, N=3, K=5 completes through each of the six BSTART selectors with Shared FP16 A/B, required Local C or Bias auxiliaries, and a defined FP32 M16 destination of exact valid shape.","related_sources":["asl/block/execution/BSTART.TMATMUL.asl","asl/block/execution/BSTART.TMATMUL.ACC.asl","asl/block/execution/BSTART.TMATMUL.BIAS.asl","asl/block/execution/BSTART.TMATMULMX.asl","asl/block/execution/BSTART.TMATMULMX.ACC.asl","asl/block/execution/BSTART.TMATMULMX.BIAS.asl","asl/block/model/dispatch/shared-cube-matrix.asl"]}

func main() => integer
begin
    for variant = 0 to 5 looplimit 6 do
        ResetProfileState();
        let uses_accumulator = variant == 1 || variant == 4;
        let uses_bias = variant == 2 || variant == 5;
        let start_opcode = if variant == 0 then 0x00031181
            else if variant == 1 then 0x00231181
            else if variant == 2 then 0x00131181
            else if variant == 3 then 0x00431181
            else if variant == 4 then 0x00631181
            else 0x00531181;

        ConfigureTileForMask(10, 256, DerivedTileRows(256, 8,
            TileDataType_FP16), 8, 2, 5, TileDataType_FP16,
            TileLayout_RowMajor, '1111');
        ConfigureTileForMask(11, 256, DerivedTileRows(256, 8,
            TileDataType_FP16), 8, 3, 5, TileDataType_FP16,
            TileLayout_RowMajor, '1111');
        for row = 0 to 1 looplimit 2 do
            for column = 0 to 4 looplimit 5 do
                WriteTileElement(10, row, column, Zeros{PTO_XLEN});
            end;
        end;
        for row = 0 to 2 looplimit 3 do
            for column = 0 to 4 looplimit 5 do
                WriteTileElement(11, row, column, Zeros{PTO_XLEN});
            end;
        end;
        InstallSharedTile((Zeros{6} + 40) as SharedTileID,
            _Tiles[[10]], '1111');
        InstallSharedTile((Zeros{6} + 41) as SharedTileID,
            _Tiles[[11]], '1111');

        if uses_accumulator then
            let c_ready = ConfigureCubeTileForMask(3, 256, 2, 3,
                TileDataType_FP32, TileLayout_CUBE_M16, '1111');
            assert c_ready;
            for row = 0 to 1 looplimit 2 do
                for column = 0 to 2 looplimit 3 do
                    WriteTileElement(3, row, column, Zeros{PTO_XLEN});
                end;
            end;
        end;
        if uses_bias then
            let bias_ready = ConfigureCubeTileForMask(4, 128, 1, 3,
                TileDataType_FP32, TileLayout_CUBE_N8, '1111');
            assert bias_ready;
            for column = 0 to 2 looplimit 3 do
                WriteTileElement(4, 0, column, Zeros{PTO_XLEN});
            end;
        end;

        var start: bits(64) = Zeros{64} + start_opcode;
        start[31:27] = Zeros{5} + 4;
        let started = ExecuteCommandInstruction(start, 32);
        assert started == CommandExecution_Executed;
        SetBundleFixedPointAttributeState(
            Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE,
            FALSE, FALSE, FALSE);
        SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
        SetBundleDimension(1, Zeros{PTO_XLEN} + 3);
        SetBundleDimension(2, Zeros{PTO_XLEN} + 5);
        BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
        BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
        if uses_accumulator then
            AddBundleTileBinding(
                TRUE, 0, 2, '1111', TRUE, FALSE, 3, 0, TRUE);
        elsif uses_bias then
            AddBundleTileBinding(
                TRUE, 0, 2, '1111', TRUE, FALSE, 4, 0, TRUE);
        else
            AddBundleTileBinding(
                TRUE, 0, 2, '1111', FALSE, FALSE, 0, 0, TRUE);
        end;

        let completed = ExecuteBundleTileOperation();
        assert completed && _LastFault == Fault_None;
        let destination = BundleMatrixDestinationAt(0);
        assert _Tiles[[destination]].contents_defined;
        assert _Tiles[[destination]].layout == TileLayout_CUBE_M16;
        assert _Tiles[[destination]].data_type == TileDataType_FP32;
        assert _Tiles[[destination]].valid_rows == 2;
        assert _Tiles[[destination]].valid_columns == 3;
        assert TileCubeDescriptorLegal(_Tiles[[destination]]);
        assert _BundleSharedBindings[[0]].consumed;
        assert _BundleSharedBindings[[1]].consumed;
    end;
    return 0;
end;
