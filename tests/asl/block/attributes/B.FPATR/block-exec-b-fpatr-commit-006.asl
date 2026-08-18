// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-FPATR-COMMIT-006","source":"asl/block/attributes/B.FPATR.asl","requirements":["PTO-INST-BLOCK-B-FPATR"],"kind":"execution","summary":"B.FPATR complete commit publishes converted D and sticky numeric status together","pass_condition":"scalar FP32-to-S8 post-processing routes its B.IOR parameter, converts both elements, and records overflow only at commit","related_sources":["asl/tile/model/execution/postprocess.asl","asl/arch/state/numeric-status.asl"]}
pure func MatrixPostProcessCommitStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00031181;
    instruction[31:27] = Zeros{5} + 1;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(1, 128, 1, 2, 1, 2, TileDataType_S8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x3fc00000);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0x428c0000);

    let started = ExecuteCommandInstruction(
        MatrixPostProcessCommitStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        '011000', Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
    let parameter = MatrixQuantParameter(
        FP32ToFP19(Zeros{PTO_XLEN} + 0x40000000),
        Zeros{PTO_XLEN}, 9);
    WriteGPR(7, parameter);
    SetBundleScalarBinding(0, 0, 7, 0, 0, 1);
    _BundleTileBindings[[0]].valid = TRUE;
    _BundleTileBindings[[0]].destination_valid = TRUE;
    _BundleTileBindings[[0]].destination = 1;

    assert NumericStatusFlags() == Zeros{5};
    CommitMatrixResult(1, _Tiles[[0]]);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(1, 0, 1) ==
        Zeros{PTO_XLEN} + 0xffffffffffffff8c;
    assert NumericStatusFlags() == Zeros{5} + 0x14;
    return 0;
end;
