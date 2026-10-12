// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-PACKED-EVEN-N-TRANSPOSE-048","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-TMATMUL-CONTRACT-001","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"execution","summary":"Even-N packed Shared primaries execute under all transpose pairs.","pass_condition":"Decoded all-Shared E2M1X2 TMATMUL at M=17,N=4,K=6 completes for all TransA/TransB pairs with exact source shapes, even physical pitch, and defined exact-shape FP32 output.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl","asl/tile/model/definedness/packed-boundary.asl"]}

func PreparePackedEvenN(index: TileIndex, shared_tile_id: SharedTileID,
                       left: boolean, transpose: boolean)
begin
    let logical_rows = if left then 17 else 6;
    let logical_columns = if left then 6 else 4;
    let source_rows = if left then
        (if transpose then 6 else 17)
        else (if transpose then 6 else 4);
    let source_columns = if left then
        (if transpose then 17 else 6)
        else (if transpose then 4 else 6);
    let pitch = if left && transpose then 32 else 8;
    let physical_rows = DerivedTileRows(128, pitch, TileDataType_E2M1X2);
    ConfigureTileForMask(index, 128, physical_rows, pitch,
        source_rows, source_columns, TileDataType_E2M1X2,
        TileLayout_RowMajor, '1111');
    MarkTileValidRegionDefined(index);
    for row = 0 to source_rows - 1 looplimit 32 do
        for column = 0 to source_columns - 1 looplimit 32 do
            let logical_row = if left then
                (if transpose then column else row)
                else (if transpose then row else column);
            let logical_column = if left then
                (if transpose then row else column)
                else (if transpose then column else row);
            WriteTileElement(index, row, column,
                Zeros{PTO_XLEN} +
                ((logical_row + 2 * logical_column) MOD 8));
        end;
    end;
    InstallSharedTile(shared_tile_id, _Tiles[[index]], '1111');
end;

func main() => integer
begin
    for controls = 0 to 3 looplimit 4 do
        ResetProfileState();
        let trans_a = controls MOD 2 == 1;
        let trans_b = controls >= 2;
        PreparePackedEvenN(10, (Zeros{6} + 40) as SharedTileID,
            TRUE, trans_a);
        PreparePackedEvenN(11, (Zeros{6} + 41) as SharedTileID,
            FALSE, trans_b);

        var start: bits(64) = Zeros{64} + 0x00031181;
        start[31:27] = Zeros{5} + 11;
        let started = ExecuteCommandInstruction(start, 32);
        assert started == CommandExecution_Executed;
        SetBundleFixedPointAttributeState(
            Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE,
            trans_a, trans_b);
        SetBundleDimension(0, Zeros{PTO_XLEN} + 17);
        SetBundleDimension(1, Zeros{PTO_XLEN} + 4);
        SetBundleDimension(2, Zeros{PTO_XLEN} + 6);
        BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
        BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
        AddBundleTileBinding(
            TRUE, 0, 3, '1111', FALSE, FALSE, 0, 0, TRUE);

        assert BundleMatrixSharedLeftPrimarySchemaLegal(
            0, 17, 6, TileDataType_E2M1X2, trans_a);
        assert BundleMatrixSharedBPrimarySchemaLegal(
            1, 6, 4, TileDataType_E2M1X2, trans_b);
        let completed = ExecuteBundleTileOperation();
        assert completed && _LastFault == Fault_None;
        let destination = BundleMatrixDestinationAt(0);
        assert _Tiles[[destination]].contents_defined;
        assert _Tiles[[destination]].layout == TileLayout_CUBE_M16;
        assert _Tiles[[destination]].data_type == TileDataType_FP32;
        assert _Tiles[[destination]].valid_rows == 16;
        assert _Tiles[[destination]].valid_columns == 4;
        assert _BundleSharedBindings[[0]].consumed;
        assert _BundleSharedBindings[[1]].consumed;
    end;
    return 0;
end;
