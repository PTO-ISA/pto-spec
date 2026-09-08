// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-SUBVIEW-SINGLE-ROW-037","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-SHARED-TRANSPOSE-001","PTO-B-SUBVIEW-SHARED-PER-PE-001"],"kind":"execution","summary":"A legal one-CELL Shared B view materializes exactly one physical row.","pass_condition":"For M=2,N=1,K=64, a U16 Shared B parent with physical valid [1,64] and one-CELL size selects one complete row, produces two exact 64 results, and preserves the parent.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl","asl/block/model/operands/shared-generation.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTileForMask(10, 256, 2, 64, 2, 64,
        TileDataType_U16, TileLayout_RowMajor,
        TileLocation_Matrix, '1111');
    ConfigureTileForMask(11, 128, 1, 64, 1, 64,
        TileDataType_U16, TileLayout_RowMajor,
        TileLocation_Matrix, '1111');
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 63 looplimit 64 do
            WriteTileElement(10, row, column, Zeros{PTO_XLEN} + 1);
        end;
    end;
    for column = 0 to 63 looplimit 64 do
        WriteTileElement(11, 0, column, Zeros{PTO_XLEN} + 1);
    end;
    InstallSharedTile((Zeros{6} + 40) as SharedTileID,
        _Tiles[[10]], '1111');
    InstallSharedTile((Zeros{6} + 41) as SharedTileID,
        _Tiles[[11]], '1111');

    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 26;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 64);
    BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
    AddBundleTileBinding(
        TRUE, 0, 2, '1111', FALSE, FALSE, 0, 0, TRUE);
    _BundleSharedBindings[[1]].source0_subview.valid = TRUE;
    _BundleSharedBindings[[1]].source0_subview.reg_src = 2;
    _BundleSharedBindings[[1]].source0_subview.uimm11 = Zeros{11};
    _BundleSharedBindings[[1]].source0_subview.size_code = 1;

    let before = SharedTileRecord((Zeros{6} + 41) as SharedTileID);
    assert before.tile.valid_rows == 1;
    assert before.tile.valid_columns == 64;
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = BundleMatrixDestinationAt(0);
    assert _Tiles[[destination]].valid_rows == 2;
    assert _Tiles[[destination]].valid_columns == 1;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 64;
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 64;
    let after = SharedTileRecord((Zeros{6} + 41) as SharedTileID);
    assert after.tile.payload[[0]] == before.tile.payload[[0]];
    assert after.tile.valid_rows == before.tile.valid_rows;
    assert after.tile.valid_columns == before.tile.valid_columns;
    return 0;
end;
