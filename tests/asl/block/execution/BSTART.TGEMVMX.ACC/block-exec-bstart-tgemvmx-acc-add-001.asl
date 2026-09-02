// PTO-TEST: {"id":"PTO-AVS-BLOCK-TGEMVMX-ACC-EXEC-001","source":"asl/block/execution/BSTART.TGEMVMX.ACC.asl","requirements":["PTO-BSTART-TGEMVMX-ACC-CONTRACT-001","PTO-INST-BLOCK-BSTART-TGEMVMX-ACC"],"kind":"execution","summary":"TGEMVMX.ACC adds an explicit Local accumulator.","pass_condition":"C=5, A=2, and B=3 publish one Local FP32 destination containing 11.","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl"]}
func main() => integer
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let b_ready = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    let c_ready = ConfigureCubeTileForMask(3, 128, 1, 1,
        TileDataType_FP32, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    assert a_ready && b_ready && c_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x4000);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x4200);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 0x40a00000);

    var start: bits(64) = Zeros{64} + 0x01631181;
    start[31:27] = Zeros{5} + 4;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    AddBundleTileBinding(
        FALSE, 0, 0, '1111', TRUE, TRUE, 3, 1, FALSE);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 2, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = BundleMatrixDestinationAt(0);
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x41300000;
    return 0;
end;
