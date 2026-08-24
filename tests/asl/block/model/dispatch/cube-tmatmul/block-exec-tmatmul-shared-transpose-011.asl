// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-TRANSPOSE-011","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"execution","summary":"Shared A and B transpose controls normalize ordinary descriptors before CUBE computation","pass_condition":"all four TransA and TransB combinations produce the same exact logical two-by-two matrix product","related_sources":["asl/tile/model/state/shared-registers.asl","asl/block/attributes/B.FPATR.asl"]}
func PrepareSharedTransposeOperand(index: TileIndex, shared_tile_id: bits(6),
                                   left: boolean, transpose: boolean)
begin
    let physical_rows = 2;
    let physical_columns = 2;
    ConfigureTileForMask(index, 128,
        DerivedTileRows(128, physical_columns, TileDataType_U16),
        physical_columns, physical_rows, physical_columns,
        TileDataType_U16, TileLayout_RowMajor,
        TileLocation_Matrix, '1111');
    if left then
        if transpose then
            WriteTileElement(index, 0, 0, Zeros{PTO_XLEN} + 1);
            WriteTileElement(index, 1, 0, Zeros{PTO_XLEN} + 2);
            WriteTileElement(index, 0, 1, Zeros{PTO_XLEN} + 3);
            WriteTileElement(index, 1, 1, Zeros{PTO_XLEN} + 4);
        else
            WriteTileElement(index, 0, 0, Zeros{PTO_XLEN} + 1);
            WriteTileElement(index, 0, 1, Zeros{PTO_XLEN} + 2);
            WriteTileElement(index, 1, 0, Zeros{PTO_XLEN} + 3);
            WriteTileElement(index, 1, 1, Zeros{PTO_XLEN} + 4);
        end;
    else
        WriteTileElement(index, 0, 0, Zeros{PTO_XLEN} + 5);
        WriteTileElement(index, 0, 1,
            Zeros{PTO_XLEN} + (if transpose then 7 else 6));
        WriteTileElement(index, 1, 0,
            Zeros{PTO_XLEN} + (if transpose then 6 else 7));
        WriteTileElement(index, 1, 1, Zeros{PTO_XLEN} + 8);
    end;
    InstallSharedTile(shared_tile_id as SharedTileID, _Tiles[[index]], '1111');
end;

func main() => integer
begin
    for controls = 0 to 3 do
        ResetProfileState();
        let trans_a = controls MOD 2 == 1;
        let trans_b = controls >= 2;
        PrepareSharedTransposeOperand(
            10, Zeros{6} + 40, TRUE, trans_a);
        PrepareSharedTransposeOperand(
            11, Zeros{6} + 41, FALSE, trans_b);

        var start: bits(64) = Zeros{64} + 0x00031181;
        start[31:27] = Zeros{5} + 26;
        let started = ExecuteCommandInstruction(start, 32);
        assert started == CommandExecution_Executed;
        SetBundleFixedPointAttributeState(
            Zeros{6}, Zeros{3}, Zeros{4},
            FALSE, FALSE, FALSE, FALSE, trans_a, trans_b);
        SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
        SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
        SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
        BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
        BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
        AddBundleTileBinding(
            TRUE, 0, 1, '1111', FALSE, FALSE, 0, 0, TRUE);

        let completed = ExecuteBundleTileOperation();
        assert completed;
        let destination = BundleMatrixDestinationAt(0);
        assert _Tiles[[destination]].layout == TileLayout_CUBE_M16;
        assert ReadTileElement(destination, 0, 0) ==
            Zeros{PTO_XLEN} + 19;
        assert ReadTileElement(destination, 0, 1) ==
            Zeros{PTO_XLEN} + 22;
        assert ReadTileElement(destination, 1, 0) ==
            Zeros{PTO_XLEN} + 43;
        assert ReadTileElement(destination, 1, 1) ==
            Zeros{PTO_XLEN} + 50;
    end;
    return 0;
end;
