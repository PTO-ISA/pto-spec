// PTO-TEST: {"id":"PTO-AVS-BLOCK-TGEMV-EXEC-001","source":"asl/block/execution/BSTART.TGEMV.asl","requirements":["PTO-BSTART-TGEMV-CONTRACT-001","PTO-INST-BLOCK-BSTART-TGEMV"],"kind":"execution","summary":"TGEMV executes the Local M=1 matrix-vector specialization.","pass_condition":"A=2 and B=3 publish one Local FP32 1x1 destination containing 6.","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl"]}
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
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x4000);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x4200);

    var start: bits(64) = Zeros{64} + 0x01031181;
    start[31:27] = Zeros{5} + 4;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = BundleMatrixDestinationAt(0);
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x40c00000;
    return 0;
end;
