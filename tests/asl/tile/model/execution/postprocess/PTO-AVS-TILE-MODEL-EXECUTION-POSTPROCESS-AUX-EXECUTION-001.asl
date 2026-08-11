// PTO-TEST: {"id":"PTO-AVS-TILE-MODEL-EXECUTION-POSTPROCESS-AUX-EXECUTION-001","source":"asl/tile/model/execution/postprocess.asl","requirements":[],"kind":"execution","summary":"matrix postprocess publishes D, RowMaxOut, and GroupMaxOut as one complete-bundle result","pass_condition":"enabled auxiliary outputs are allocated and observe the same full-K result as D","related_sources":[]}

pure func PostProcessTestCUBEStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00031181;
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func PostProcessTestFPATR() => bits(64)
begin
    return Zeros{64} + 0x00002023;
end;

pure func PostProcessTestSharedBinding(shared_id: bits(8)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = '1111';
    instruction[11:9] = '000';
    return instruction;
end;

pure func PostProcessTestTwoSourceDestination(source0: bits(6), source1: bits(6),
                                              destination: bits(2), last: boolean)
                                              => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[11:9] = '001';
    instruction[8:7] = destination;
    instruction[18:15] = '1111';
    instruction[25:20] = source0;
    instruction[31:26] = source1;
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

pure func PostProcessTestDestination(destination: bits(2), last: boolean)
                                     => bits(64)
begin
    var instruction = Zeros{64} + 0x00006013;
    instruction[11:9] = '001';
    instruction[8:7] = destination;
    instruction[18:15] = '1111';
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(3, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(4, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 36);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 9);

    // Install a decoded CUBE operation and a present B.FPATR, then bind
    // D, RowMaxOut==RowMaxIn, and GroupMaxOut before invoking the owner.
    let start = ExecuteCommandInstruction(PostProcessTestCUBEStart(), 32);
    let fpatr = ExecuteCommandInstruction(PostProcessTestFPATR(), 32);
    assert start == CommandExecution_Executed;
    assert fpatr == CommandExecution_Executed;
    _BundleFixedPointAttributes.group_n_code = '0111';
    _BundleFixedPointAttributes.row_max_en = TRUE;
    _BundleFixedPointAttributes.group_max_en = TRUE;
    _BundleFixedPointAttributes.row_max_init = TRUE;

    _BundleTileBindings[[0]].valid = TRUE;
    _BundleTileBindings[[0]].destination_valid = TRUE;
    _BundleTileBindings[[0]].destination = 1;
    _BundleTileBindings[[0]].source0_valid = TRUE;
    _BundleTileBindings[[0]].source0 = 0;
    _BundleTileBindings[[0]].source1_valid = TRUE;
    _BundleTileBindings[[0]].source1 = 0;
    _BundleTileBindings[[1]].valid = TRUE;
    _BundleTileBindings[[1]].destination_valid = TRUE;
    _BundleTileBindings[[1]].destination = 4;
    _BundleTileBindings[[1]].source0_valid = TRUE;
    _BundleTileBindings[[1]].source0 = 4;
    _BundleTileBindings[[2]].valid = TRUE;
    _BundleTileBindings[[2]].destination_valid = TRUE;
    _BundleTileBindings[[2]].destination = 3;

    CommitMatrixResult(1, _Tiles[[0]]);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 36;
    assert ReadTileElement(4, 0, 0) == Zeros{PTO_XLEN} + 36;
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 36;
    // Profile ownership is executable and deterministic: the PTO-v0
    // post-process hook preserves raw carriers, while MaxAbs reuses the
    // registered ABS and MAX hooks for multi-element folding.
    let raw = Zeros{PTO_XLEN} + 0x1234;
    var processed = TileProfileMatrixPostProcess(raw, Zeros{6}, Zeros{3}, Zeros{4},
        TileDataType_U64, Zeros{PTO_XLEN}, Zeros{PTO_XLEN},
        DefaultNumericExecutionControl());
    assert processed == raw;
    var reduced = TileProfileMatrixReductionStep(Zeros{PTO_XLEN} + 3,
        Zeros{PTO_XLEN} + 7, FALSE, TileDataType_U64);
    assert reduced == Zeros{PTO_XLEN} + 7;
    var reduced_abs = TileProfileMatrixReductionStep(Zeros{PTO_XLEN} + 3,
        Zeros{PTO_XLEN} + 7, TRUE, TileDataType_U64);
    assert reduced_abs == Zeros{PTO_XLEN} + 7;
    return 0;
end;
