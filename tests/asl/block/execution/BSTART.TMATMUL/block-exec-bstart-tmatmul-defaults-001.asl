// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-DEFAULT-001","source":"asl/block/execution/BSTART.TMATMUL.asl","requirements":["PTO-BSTART-TMATMUL-CONTRACT-001","PTO-TMATMUL-CONTRACT-001","PTO-INST-BLOCK-BSTART-TMATMUL"],"kind":"execution","summary":"TMATMUL independently defaults omitted M, N, K, and BType.","pass_condition":"With no B.DIM or B.DATR, one FP16 element multiplies one FP16 element into a new 1x1 FP32 destination.","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl"]}
func main() => integer
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let b_ready = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    assert a_ready && b_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 6);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 7);
    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 4;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_FP32;
    assert _Tiles[[destination]].valid_rows == 1;
    assert _Tiles[[destination]].valid_columns == 1;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 42;
    return 0;
end;
