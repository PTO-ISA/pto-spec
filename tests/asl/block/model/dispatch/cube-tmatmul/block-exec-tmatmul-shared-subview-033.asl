// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-SUBVIEW-033","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-SHARED-TRANSPOSE-001","PTO-B-SUBVIEW-SHARED-PER-PE-001"],"kind":"execution","summary":"A full-row Shared B CELL subview participates in TMATMUL after metadata preflight.","pass_condition":"A one-CELL Shared B view of physical N x K=4x8 materializes as logical K x N=8x4 and produces an exact 2x4 result without mutating its parent.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl","asl/block/model/operands/shared-generation.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTileForMask(10, 128, 8, 8, 2, 8,
        TileDataType_U16, TileLayout_RowMajor,
        TileLocation_Matrix, '1111');
    ConfigureTileForMask(11, 256, 16, 8, 4, 8,
        TileDataType_U16, TileLayout_RowMajor,
        TileLocation_Matrix, '1111');
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 7 looplimit 8 do
            WriteTileElement(10, row, column, Zeros{PTO_XLEN} + 1);
        end;
    end;
    for row = 0 to 3 looplimit 4 do
        for column = 0 to 7 looplimit 8 do
            WriteTileElement(11, row, column, Zeros{PTO_XLEN} + 1);
        end;
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
    SetBundleDimension(1, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 8);
    BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
    AddBundleTileBinding(
        TRUE, 0, 2, '1111', FALSE, FALSE, 0, 0, TRUE);
    _BundleSharedBindings[[1]].source0_subview.valid = TRUE;
    _BundleSharedBindings[[1]].source0_subview.reg_src = 2;
    _BundleSharedBindings[[1]].source0_subview.uimm11 = Zeros{11};
    _BundleSharedBindings[[1]].source0_subview.size_code = 1;
    let before = SharedTileRecord((Zeros{6} + 41) as SharedTileID);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = BundleMatrixDestinationAt(0);
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 8;
    assert ReadTileElement(destination, 0, 3) == Zeros{PTO_XLEN} + 8;
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 8;
    assert ReadTileElement(destination, 1, 3) == Zeros{PTO_XLEN} + 8;
    let after = SharedTileRecord((Zeros{6} + 41) as SharedTileID);
    assert after.tile.payload[[0]] == before.tile.payload[[0]];
    assert after.tile.valid_rows == before.tile.valid_rows;
    assert after.tile.valid_columns == before.tile.valid_columns;
    return 0;
end;
