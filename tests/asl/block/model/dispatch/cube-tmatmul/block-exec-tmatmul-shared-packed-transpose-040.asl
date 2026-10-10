// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-PACKED-TRANSPOSE-040","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-TMATMUL-CONTRACT-001","PTO-CUBE-SHARED-TRANSPOSE-001","PTO-CUBE-GROUP-M-DISTRIBUTION-001"],"kind":"execution","summary":"Packed Shared primaries accept even non-power K with odd valid M/N across all transpose pairs and padded even pitch.","pass_condition":"M=17,N=3,K=6 completes for all four transpose pairs using E2M1X2 Shared primaries, exact logical shapes, even padded original pitch, independent packed-coordinate witnesses, and defined exact-shape output.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl","asl/tile/model/definedness/packed-boundary.asl"]}

func PreparePackedShared(index: TileIndex, shared_tile_id: bits(6),
                        left: boolean, transpose: boolean)
begin
    let logical_rows = if left then 17 else 6;
    let logical_columns = if left then 6 else 3;
    let physical_rows = if left then
        (if transpose then 8 else 32)
        else (if transpose then 64 else 32);
    let physical_pitch = if left then
        (if transpose then 32 else 8)
        else (if transpose then 4 else 8);
    let capacity = 128;
    let rows = DerivedTileRows(
        capacity, physical_pitch, TileDataType_E2M1X2);
    assert rows >= physical_rows;
    let stored_rows = if left then
        (if transpose then logical_columns else logical_rows)
        else (if transpose then logical_rows else logical_columns);
    let stored_columns = if left then
        (if transpose then logical_rows else logical_columns)
        else (if transpose then logical_columns else logical_rows);
    ConfigureTileForMask(index, capacity, rows, physical_pitch,
        stored_rows, stored_columns, TileDataType_E2M1X2,
        TileLayout_RowMajor, '1111');
    for row = 0 to stored_rows - 1 looplimit 32 do
        for column = 0 to stored_columns - 1 looplimit 32 do
            let logical_row = if left then
                (if transpose then column else row)
                else (if transpose then row else column);
            let logical_column = if left then
                (if transpose then row else column)
                else (if transpose then column else row);
            let value = if left then
                (logical_row + 2 * logical_column) MOD 8
                else (logical_row + 3 * logical_column) MOD 8;
            WriteTileElement(index, row, column,
                Zeros{PTO_XLEN} + value);
        end;
        // A padded nibble next to the valid region must not be read as data.
        WriteTileElement(index, row, stored_columns,
            Zeros{PTO_XLEN} + 15);
    end;

    let witness_row = if left then
        (if transpose then 5 else 16)
        else (if transpose then 4 else 2);
    let witness_column = if left then
        (if transpose then 16 else 5)
        else (if transpose then 2 else 4);
    let witness_value = if left then 13 else 5;
    WriteTileElement(index, witness_row, witness_column - 1,
        Zeros{PTO_XLEN} + 3);
    WriteTileElement(index, witness_row, witness_column,
        Zeros{PTO_XLEN} + witness_value);
    let expected_nibble_index = witness_row * physical_pitch +
        witness_column;
    let element = TileLogicalLinearIndex(
        _Tiles[[index]], witness_row, witness_column);
    assert element == expected_nibble_index;
    assert TilePackedCarrierIndex(TileDataType_E2M1X2, element) ==
        expected_nibble_index DIVRM 16;
    assert TilePackedLaneIndex(TileDataType_E2M1X2, element) ==
        expected_nibble_index MOD 16;
    let adjacent_element = TileLogicalLinearIndex(
        _Tiles[[index]], witness_row, witness_column - 1);
    assert adjacent_element + 1 == element;
    assert TilePackedCarrierIndex(TileDataType_E2M1X2, adjacent_element) ==
        (expected_nibble_index - 1) DIVRM 16;
    assert TilePackedLaneIndex(TileDataType_E2M1X2, adjacent_element) ==
        (expected_nibble_index - 1) MOD 16;
    assert TileReadLogicalElement(_Tiles[[index]], adjacent_element) ==
        Zeros{PTO_XLEN} + 3;
    assert TileReadLogicalElement(_Tiles[[index]], element) ==
        Zeros{PTO_XLEN} + witness_value;
    assert ReadTileElement(index, 0, stored_columns) ==
        Zeros{PTO_XLEN} + 15;
    InstallSharedTile(shared_tile_id as SharedTileID,
        _Tiles[[index]], '1111');
end;

func main() => integer
begin
    for controls = 0 to 3 looplimit 4 do
        ResetProfileState();
        let trans_a = controls MOD 2 == 1;
        let trans_b = controls >= 2;
        PreparePackedShared(10, Zeros{6} + 40, TRUE, trans_a);
        PreparePackedShared(11, Zeros{6} + 41, FALSE, trans_b);

        var start: bits(64) = Zeros{64} + 0x00031181;
        start[31:27] = Zeros{5} + 11;
        let started = ExecuteCommandInstruction(start, 32);
        assert started == CommandExecution_Executed;
        SetBundleFixedPointAttributeState(
            Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE,
            trans_a, trans_b);
        SetBundleDimension(0, Zeros{PTO_XLEN} + 17);
        SetBundleDimension(1, Zeros{PTO_XLEN} + 3);
        SetBundleDimension(2, Zeros{PTO_XLEN} + 6);
        BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
        BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
        AddBundleTileBinding(
            TRUE, 0, 2, '1111', FALSE, FALSE, 0, 0, TRUE);
        assert TileOrdinaryMatrixInputTypesSameClass(
            TileDataType_E2M1X2, TileDataType_E2M1X2);
        assert BundleMatrixSharedLeftPrimarySchemaLegal(
            0, 17, 6, TileDataType_E2M1X2, trans_a);
        assert BundleMatrixSharedBPrimarySchemaLegal(
            1, 6, 3, TileDataType_E2M1X2, trans_b);
        assert BundleTMATMULDimensionsLegal(2);

        let completed = ExecuteBundleTileOperation();
        assert completed && _LastFault == Fault_None;
        let destination = BundleMatrixDestinationAt(0);
        assert _Tiles[[destination]].contents_defined;
        assert _Tiles[[destination]].layout == TileLayout_CUBE_M16;
        assert _Tiles[[destination]].data_type == TileDataType_FP32;
        assert _Tiles[[destination]].valid_columns == 3;
        assert _Tiles[[destination]].valid_rows ==
            BundleMatrixCooperativeValidM(17, _CurrentMemoryAgent);
        assert _BundleSharedBindings[[0]].consumed;
        assert _BundleSharedBindings[[1]].consumed;
    end;
    return 0;
end;
