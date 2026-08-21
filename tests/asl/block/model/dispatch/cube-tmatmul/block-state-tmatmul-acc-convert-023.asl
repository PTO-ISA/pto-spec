// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-ACC-CONVERT-023","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-ACCUMULATOR-OUTPUT-001"],"kind":"state-transition","summary":"Converted D keeps C M layout but derives final dtype CELL geometry","pass_condition":"FP32 C remains two cells and unchanged while FP16 D publishes one cell for the same logical MxN","related_sources":["asl/block/model/dispatch/cube-destination.asl","asl/tile/model/execution/postprocess.asl"]}
func main() => integer
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(4, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let b_ready = ConfigureCubeTileForMask(5, 128, 1, 3,
        TileDataType_FP16, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    let c_ready = ConfigureCubeTileForMask(6, 256, 1, 3,
        TileDataType_FP32, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    assert a_ready && b_ready && c_ready;
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 2);
    for column = 0 to 2 do
        WriteTileElement(5, 0, column,
            Zeros{PTO_XLEN} + column + 1);
        WriteTileElement(6, 0, column,
            Zeros{PTO_XLEN} + 5);
    end;
    let c_before = _Tiles[[6]];

    var start: bits(64) = Zeros{64} + 0x00231181;
    start[31:27] = Zeros{5} + 4;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6} + 1, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 3);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 6, 0, FALSE);
    AddBundleTileBinding(
        FALSE, 0, 0, '1111', TRUE, TRUE, 4, 5, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = BundleMatrixDestinationAt(0);
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M16;
    assert _Tiles[[destination]].data_type == TileDataType_FP16;
    assert _Tiles[[destination]].cube_cell_count == 1;
    assert _Tiles[[destination]].cube_storage_bytes == 128;
    assert _Tiles[[6]].data_type == c_before.data_type;
    assert _Tiles[[6]].cube_cell_count == 2;
    assert _Tiles[[6]].cube_storage_bytes == 256;
    assert ReadTileElement(6, 0, 0) == c_before.payload[[
        TileStorageIndex(c_before, 0, 0)]];
    return 0;
end;
