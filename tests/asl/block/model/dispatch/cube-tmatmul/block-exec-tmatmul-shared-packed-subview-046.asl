// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-PACKED-SUBVIEW-046","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-TMATMUL-CONTRACT-001","PTO-CUBE-SHARED-TRANSPOSE-001","PTO-B-SUBVIEW-SHARED-PER-PE-001"],"kind":"execution","summary":"Packed 128-byte per-PE CELL views preserve N=1,K=194 row selections through Shared TMATMUL.","pass_condition":"For group_M=17,N=1,K=194, even-pitch Shared E2M1X2 A and an 8x256 Shared E2M1X2 B parent with valid 8x194 select exact 1x194 views at CELL offsets 0/1/2/3; active PEs execute to defined exact-shape FP32 output while all four source views and the parent remain unchanged.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl","asl/block/model/operands/shared-generation.asl","asl/tile/model/definedness/packed-boundary.asl"]}

func main() => integer
begin
    for active_pe = 0 to 1 looplimit 2 do
        ResetProfileState();
        ConfigureTileForMask(10, 4096, 32, 256, 17, 194,
            TileDataType_E2M1X2, TileLayout_RowMajor, '1111');
        ConfigureTileForMask(11, 1024, 8, 256, 8, 194,
            TileDataType_E2M1X2, TileLayout_RowMajor, '1111');
        MarkTileValidRegionDefined(10);
        MarkTileValidRegionDefined(11);
        for row = 0 to 7 looplimit 8 do
            WriteTileElement(11, row, 0, Zeros{PTO_XLEN} + row + 1);
            WriteTileElement(11, row, 192, Zeros{PTO_XLEN} + 3);
            WriteTileElement(11, row, 193, Zeros{PTO_XLEN} + row + 8);
        end;
        InstallSharedTile((Zeros{6} + 40) as SharedTileID,
            _Tiles[[10]], '1111');
        InstallSharedTile((Zeros{6} + 41) as SharedTileID,
            _Tiles[[11]], '1111');

        var start: bits(64) = Zeros{64} + 0x00031181;
        start[31:27] = Zeros{5} + 11;
        let started = ExecuteCommandInstruction(start, 32);
        assert started == CommandExecution_Executed;
        SetBundleFixedPointAttributeState(
            Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
        SetBundleDimension(0, Zeros{PTO_XLEN} + 17);
        SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
        SetBundleDimension(2, Zeros{PTO_XLEN} + 194);
        BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
        BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
        AddBundleTileBinding(
            TRUE, 0, 1, '1111', FALSE, FALSE, 0, 0, TRUE);
        _BundleSharedBindings[[1]].source0_subview.valid = TRUE;
        _BundleSharedBindings[[1]].source0_subview.reg_src = 2;
        _BundleSharedBindings[[1]].source0_subview.uimm11 = Zeros{11};
        _BundleSharedBindings[[1]].source0_subview.size_code = 1;

        // Each offset is one 128-byte CELL, exactly one 256-column packed row.
        for pe = 0 to 3 looplimit 4 do
            WritePEGPR(pe as MemoryAgentId, 2, Zeros{PTO_XLEN} + pe);
        end;
        assert BundleSharedSubviewLegal(1);
        for pe = 0 to 3 looplimit 4 do
            let parent_element = TileLogicalLinearIndex(
                _Tiles[[11]], pe, 193);
            assert parent_element == pe * 256 + 193;
            assert TilePackedCarrierIndex(TileDataType_E2M1X2,
                parent_element) == (pe * 256 + 193) DIVRM 16;
            assert TilePackedLaneIndex(TileDataType_E2M1X2,
                parent_element) == (pe * 256 + 193) MOD 16;
            assert TileReadLogicalElement(_Tiles[[11]], parent_element) ==
                Zeros{PTO_XLEN} + pe + 8;
            let view = MaterializeBundleSharedSubviewForPE(
                1, pe as MemoryAgentId);
            assert view.valid_rows == 1 && view.valid_columns == 194;
            let last_view_element = TileLogicalLinearIndex(view, 0, 193);
            assert TileReadLogicalElement(view, last_view_element) ==
                Zeros{PTO_XLEN} + pe + 8;
        end;

        let before = SharedTileRecord((Zeros{6} + 41) as SharedTileID);
        _CurrentMemoryAgent = active_pe as MemoryAgentId;
        let completed = ExecuteBundleTileOperation();
        assert completed && _LastFault == Fault_None;
        let destination = BundleMatrixDestinationAt(0);
        assert _Tiles[[destination]].contents_defined;
        assert _Tiles[[destination]].data_type == TileDataType_FP32;
        assert _Tiles[[destination]].valid_rows ==
            BundleMatrixCooperativeValidM(17, _CurrentMemoryAgent);
        assert _Tiles[[destination]].valid_columns == 1;
        let after = SharedTileRecord((Zeros{6} + 41) as SharedTileID);
        assert after.tile.payload[[0]] == before.tile.payload[[0]];
        assert after.tile.payload[[124]] == before.tile.payload[[124]];
        assert TileLogicalElementDefined(after.tile,
            TileLogicalLinearIndex(after.tile, 7, 193));
        assert after.tile.valid_rows == before.tile.valid_rows;
        assert after.tile.valid_columns == before.tile.valid_columns;
        assert after.descriptor_valid == before.descriptor_valid;
        assert after.allocation_mask == before.allocation_mask;
        assert after.initialized_mask == before.initialized_mask;
        assert after.whole_parent_ready == before.whole_parent_ready;
        assert after.published == before.published;
    end;
    return 0;
end;
