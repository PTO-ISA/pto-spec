// PTO-TEST: {"id":"PTO-AVS-TILE-MODEL-EXECUTION-POSTPROCESS-AUX-EXECUTION-001","source":"asl/tile/model/execution/postprocess.asl","requirements":[],"kind":"execution","summary":"matrix postprocess prepares D RowMaxOut and GroupMaxOut before publishing the complete output group","pass_condition":"all enabled outputs observe the same precommit matrix result and RowMaxIn contribution","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl"]}

pure func MatrixPostProcessStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00031181;
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(4, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(3, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 36);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 9);

    let started = ExecuteCommandInstruction(MatrixPostProcessStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, '0111', TRUE, TRUE, TRUE, FALSE);

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
    _BundleTileBindings[[1]].source0_valid = TRUE;
    _BundleTileBindings[[1]].source0 = 4;
    _BundleTileBindings[[2]].valid = TRUE;
    _BundleTileBindings[[2]].destination_valid = TRUE;
    _BundleTileBindings[[2]].destination = 3;

    CommitMatrixResult(1, _Tiles[[0]]);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 36;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 36;
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 36;
    return 0;
end;
