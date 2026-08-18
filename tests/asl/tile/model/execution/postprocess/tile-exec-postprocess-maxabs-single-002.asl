// PTO-TEST: {"id":"PTO-AVS-TILE-POST-MAXABS-SINGLE-002","source":"asl/tile/model/execution/postprocess.asl","requirements":["PTO-MATRIX-POSTPROCESS-BITEXACT-001"],"kind":"execution","summary":"single-element RowMax and GroupMax apply MaxAbs before publication","pass_condition":"a negative one-element S32 accumulator publishes its positive magnitude to both auxiliary outputs","related_sources":["asl/arch/profile/matrix-postprocess.asl"]}
pure func MatrixSingleMaxStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00031181;
    instruction[31:27] = Zeros{5} + 19;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_S32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_S32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 1, 1, 1, 1, TileDataType_S32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(3, 128, 1, 1, 1, 1, TileDataType_S32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0,
        Zeros{PTO_XLEN} + 0xfffffffffffffffd);

    let started = ExecuteCommandInstruction(MatrixSingleMaxStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, '0001', TRUE, TRUE, FALSE, TRUE);
    _BundleTileBindings[[0]].valid = TRUE;
    _BundleTileBindings[[0]].destination_valid = TRUE;
    _BundleTileBindings[[0]].destination = 1;
    _BundleTileBindings[[0]].source0_valid = TRUE;
    _BundleTileBindings[[0]].source0 = 0;
    _BundleTileBindings[[0]].source1_valid = TRUE;
    _BundleTileBindings[[0]].source1 = 0;
    _BundleTileBindings[[1]].valid = TRUE;
    _BundleTileBindings[[1]].destination_valid = TRUE;
    _BundleTileBindings[[1]].destination = 2;
    _BundleTileBindings[[2]].valid = TRUE;
    _BundleTileBindings[[2]].destination_valid = TRUE;
    _BundleTileBindings[[2]].destination = 3;

    CommitMatrixResult(1, _Tiles[[0]]);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 3;
    return 0;
end;
