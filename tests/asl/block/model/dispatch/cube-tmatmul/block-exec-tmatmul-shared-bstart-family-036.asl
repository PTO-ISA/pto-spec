// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-BSTART-FAMILY-036","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-BSTART-TMATMUL-CONTRACT-001","PTO-BSTART-TMATMUL-ACC-CONTRACT-001","PTO-BSTART-TMATMUL-BIAS-CONTRACT-001","PTO-BSTART-TMATMULMX-CONTRACT-001","PTO-BSTART-TMATMULMX-ACC-CONTRACT-001","PTO-BSTART-TMATMULMX-BIAS-CONTRACT-001","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"execution","summary":"All six BSTART TMATMUL family selectors reach the Shared-B physical mapping path.","pass_condition":"A bounded selector table executes TMATMUL, TMATMUL.ACC, TMATMUL.BIAS, TMATMULMX, TMATMULMX.ACC, and TMATMULMX.BIAS with TransB=1 Shared B physical [K,N]=[1,2], and each publishes its independently expected result.","related_sources":["asl/block/execution/BSTART.TMATMUL.asl","asl/block/execution/BSTART.TMATMUL.ACC.asl","asl/block/execution/BSTART.TMATMUL.BIAS.asl","asl/block/execution/BSTART.TMATMULMX.asl","asl/block/execution/BSTART.TMATMULMX.ACC.asl","asl/block/execution/BSTART.TMATMULMX.BIAS.asl","asl/block/model/dispatch/shared-cube-matrix.asl"]}
func main() => integer
begin
    // 0..5 select the six BSTART TMATMUL family variants in contract order.
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

        let a_ready = ConfigureCubeTileForMask(1, 128, 1, 1,
            TileDataType_FP16, TileLayout_CUBE_M16, '1111');
        assert a_ready;
        ConfigureTileForMask(2, 128, 32, 2, 1, 2,
            TileDataType_FP16, TileLayout_RowMajor, '1111');
        // Independent FP16 carriers keep all six selector paths on the same
        // Shared-B physical mapping; expected results below are FP32 encodings.
        WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x4000);
        WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x4200);
        WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 0x4400);
        InstallSharedTile((Zeros{6} + 9) as SharedTileID,
            _Tiles[[2]], '1111');

        if uses_accumulator then
            let c_ready = ConfigureCubeTileForMask(3, 128, 1, 2,
                TileDataType_FP32, TileLayout_CUBE_M16, '1111');
            assert c_ready;
            WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
            WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 0x3f800000);
        end;
        if uses_bias then
            ConfigureTileForMask(4, 128, 16, 2, 1, 2,
                TileDataType_FP32, TileLayout_RowMajor, '1111');
            WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 0x40a00000);
            WriteTileElement(4, 0, 1, Zeros{PTO_XLEN} + 0x40e00000);
        end;

        var start: bits(64) = Zeros{64} + start_opcode;
        start[31:27] = Zeros{5} + 4;
        let started = ExecuteCommandInstruction(start, 32);
        assert started == CommandExecution_Executed;
        SetBundleFixedPointAttributeState(
            Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE,
            FALSE, TRUE, FALSE);
        SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
        SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
        SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
        BindBundleSharedIO((Zeros{6} + 9) as SharedTileID, 0, '1111');

        if uses_accumulator then
            // ACC places C before the mathematical A in the local stream.
            AddBundleTileBinding(
                FALSE, 0, 0, '1111', TRUE, FALSE, 3, 0, FALSE);
            if uses_bias then
                AddBundleTileBinding(
                    TRUE, 0, 1, '1111', TRUE, TRUE, 1, 4, TRUE);
            else
                AddBundleTileBinding(
                    TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);
            end;
        elsif uses_bias then
            AddBundleTileBinding(
                TRUE, 0, 1, '1111', TRUE, TRUE, 1, 4, TRUE);
        else
            AddBundleTileBinding(
                TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);
        end;

        let completed = ExecuteBundleTileOperation();
        assert completed && _LastFault == Fault_None;
        let destination = BundleMatrixDestinationAt(0);
        if uses_accumulator then
            assert ReadTileElement(destination, 0, 0) ==
                Zeros{PTO_XLEN} + 0x40e00000;
            assert ReadTileElement(destination, 0, 1) ==
                Zeros{PTO_XLEN} + 0x41100000;
        elsif uses_bias then
            assert ReadTileElement(destination, 0, 0) ==
                Zeros{PTO_XLEN} + 0x41300000;
            assert ReadTileElement(destination, 0, 1) ==
                Zeros{PTO_XLEN} + 0x41700000;
        else
            assert ReadTileElement(destination, 0, 0) ==
                Zeros{PTO_XLEN} + 0x40c00000;
            assert ReadTileElement(destination, 0, 1) ==
                Zeros{PTO_XLEN} + 0x41000000;
        end;
        assert _BundleSharedBindings[[0]].consumed;
    end;
    return 0;
end;
