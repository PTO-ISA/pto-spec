// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-TRANSPOSE-030","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-SHARED-TRANSPOSE-001","PTO-CUBE-GROUP-M-DISTRIBUTION-001"],"kind":"execution","summary":"Non-square Shared A and B physical-major maps produce all four transpose results.","pass_condition":"M=2, N=4, K=8 succeeds for every TransA/TransB combination with exact Shared physical valid shapes [M,K]/[K,M] and [N,K]/[K,N] and the same 2x4 result.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl","asl/block/attributes/B.FPATR.asl"]}
func PrepareNonSquareShared(index: TileIndex, shared_tile_id: bits(6),
                            left: boolean, transpose: boolean)
begin
    let physical_rows = if left then
        (if transpose then 8 else 2) else (if transpose then 8 else 4);
    let physical_columns = if left then
        (if transpose then 2 else 8) else (if transpose then 4 else 8);
    let physical_pitch = if left then
        (if transpose then 4 else 16) else (if transpose then 8 else 16);
    ConfigureTileForMask(index, 256,
        DerivedTileRows(256, physical_pitch, TileDataType_U16),
        physical_pitch, physical_rows, physical_columns,
        TileDataType_U16, TileLayout_RowMajor,
        TileLocation_Matrix, '1111');
    for row = 0 to physical_rows - 1 looplimit 8 do
        for column = 0 to physical_columns - 1 looplimit 8 do
            let logical_row = if left then
                (if transpose then column else row)
                else (if transpose then row else column);
            let logical_column = if left then
                (if transpose then row else column)
                else (if transpose then column else row);
            let value = if left then logical_row + 1
                else logical_column + 1;
            WriteTileElement(index, row, column,
                Zeros{PTO_XLEN} + value);
        end;
    end;
    InstallSharedTile(shared_tile_id as SharedTileID, _Tiles[[index]], '1111');
end;

func main() => integer
begin
    for controls = 0 to 3 do
        ResetProfileState();
        let trans_a = controls MOD 2 == 1;
        let trans_b = controls >= 2;
        PrepareNonSquareShared(10, Zeros{6} + 40, TRUE, trans_a);
        PrepareNonSquareShared(11, Zeros{6} + 41, FALSE, trans_b);
        var start: bits(64) = Zeros{64} + 0x00031181;
        start[31:27] = Zeros{5} + 26;
        let started = ExecuteCommandInstruction(start, 32);
        assert started == CommandExecution_Executed;
        SetBundleFixedPointAttributeState(
            Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE,
            trans_a, trans_b);
        SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
        SetBundleDimension(1, Zeros{PTO_XLEN} + 4);
        SetBundleDimension(2, Zeros{PTO_XLEN} + 8);
        BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
        BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
        AddBundleTileBinding(
            TRUE, 0, 2, '1111', FALSE, FALSE, 0, 0, TRUE);
        let completed = ExecuteBundleTileOperation();
        assert completed && _LastFault == Fault_None;
        let destination = BundleMatrixDestinationAt(0);
        assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 8;
        assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 16;
        assert ReadTileElement(destination, 0, 2) == Zeros{PTO_XLEN} + 24;
        assert ReadTileElement(destination, 0, 3) == Zeros{PTO_XLEN} + 32;
        assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 16;
        assert ReadTileElement(destination, 1, 1) == Zeros{PTO_XLEN} + 32;
        assert ReadTileElement(destination, 1, 2) == Zeros{PTO_XLEN} + 48;
        assert ReadTileElement(destination, 1, 3) == Zeros{PTO_XLEN} + 64;
    end;
    return 0;
end;
