// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-PACKED-TYPES-049","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-TMATMUL-CONTRACT-001","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"execution","summary":"Every ordinary four-bit Shared primary type executes at odd M/N with even K.","pass_condition":"Decoded all-Shared ordinary TMATMUL succeeds for E1M2X2, S4X2, and U4X2 at M=17,N=1,K=2 with even physical pitches and defined exact-shape outputs; E2M1X2 positive coverage remains in the all-transpose witness.","related_sources":["asl/tile/model/legality/matrix-shape.asl","asl/block/model/dispatch/shared-cube-matrix.asl"]}

func main() => integer
begin
    for type_case = 0 to 2 looplimit 3 do
        ResetProfileState();
        let data_type = if type_case == 0 then TileDataType_E1M2X2
            else if type_case == 1 then TileDataType_S4X2
            else TileDataType_U4X2;
        let rows = DerivedTileRows(128, 2, data_type);
        ConfigureTileForMask(10, 128, rows, 2, 17, 2,
            data_type, TileLayout_RowMajor, '1111');
        ConfigureTileForMask(11, 128, rows, 2, 1, 2,
            data_type, TileLayout_RowMajor, '1111');
        MarkTileValidRegionDefined(10);
        MarkTileValidRegionDefined(11);
        for row = 0 to 16 looplimit 17 do
            WriteTileElement(10, row, 0, Zeros{PTO_XLEN} + 1);
            WriteTileElement(10, row, 1, Zeros{PTO_XLEN} + 2);
        end;
        WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 3);
        WriteTileElement(11, 0, 1, Zeros{PTO_XLEN} + 4);
        assert TileDataTypeIsFourBit(data_type);
        InstallSharedTile((Zeros{6} + 40) as SharedTileID,
            _Tiles[[10]], '1111');
        InstallSharedTile((Zeros{6} + 41) as SharedTileID,
            _Tiles[[11]], '1111');

        var start: bits(64) = Zeros{64} + 0x00031181;
        start[31:27] = TileDataTypeToEncoding(data_type);
        let started = ExecuteCommandInstruction(start, 32);
        assert started == CommandExecution_Executed;
        SetBundleDataAttributeState(TileDataTypeToEncoding(data_type),
            Zeros{5}, Zeros{2}, Zeros{3}, Zeros{3}, FALSE, FALSE);
        _BundleDataAttributesPresent = TRUE;
        SetBundleFixedPointAttributeState(
            Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
        SetBundleDimension(0, Zeros{PTO_XLEN} + 17);
        SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
        SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
        BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
        BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
        AddBundleTileBinding(
            TRUE, 0, 1, '1111', FALSE, FALSE, 0, 0, TRUE);
        assert BundleTMATMULDimensionsLegal(2);
        assert BundleMatrixSharedSchemasLegal(
            11, data_type, data_type, 17, 1, 2, 2);
        let completed = ExecuteBundleTileOperation();
        assert _LastFault == Fault_None;
        assert completed;
        let destination = BundleMatrixDestinationAt(0);
        assert _Tiles[[destination]].contents_defined;
        assert _Tiles[[destination]].data_type ==
            TileOrdinaryMatrixAccumulatorType(data_type, data_type);
        assert _Tiles[[destination]].valid_rows == 16;
        assert _Tiles[[destination]].valid_columns == 1;
        assert _BundleSharedBindings[[0]].consumed;
        assert _BundleSharedBindings[[1]].consumed;
    end;
    return 0;
end;
