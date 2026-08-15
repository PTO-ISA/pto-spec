// PTO-TEST: {"id":"PTO-AVS-BLOCK-TGEMVMX-EXEC-001","source":"asl/block/execution/BSTART.TGEMVMX.asl","requirements":["PTO-BSTART-TGEMVMX-CONTRACT-001","PTO-INST-BLOCK-BSTART-TGEMVMX"],"kind":"execution","summary":"TGEMVMX accepts unscaled FP16 matrix sides.","pass_condition":"A=2 and B=3 omit both scale sources and publish one Local FP32 destination containing 6.","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(2, 128, 1, 1, 1, 1, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Matrix);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);

    var start: bits(64) = Zeros{64} + 0x01431181;
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
        Zeros{PTO_XLEN} + 6;
    return 0;
end;
