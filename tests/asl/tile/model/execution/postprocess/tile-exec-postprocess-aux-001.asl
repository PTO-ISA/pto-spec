// PTO-TEST: {"id":"PTO-AVS-TILE-MODEL-EXECUTION-POSTPROCESS-AUX-EXECUTION-001","source":"asl/tile/model/execution/postprocess.asl","requirements":["PTO-MATRIX-POSTPROCESS-BITEXACT-001"],"kind":"execution","summary":"matrix postprocess computes raw D RowMaxOut and partial GroupMaxOut before one publication","pass_condition":"legal U32 outputs observe raw values RowMaxIn and exact full plus partial groups","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl"]}

pure func MatrixPostProcessStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00031181;
    instruction[31:27] = Zeros{5} + 25;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 512, 1, 16, 1, 9, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(4, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 512, 1, 16, 1, 9, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(3, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    for column = 0 to 8 looplimit 9 do
        WriteTileElement(0, 0, column,
            Zeros{PTO_XLEN} + column + 1);
    end;
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 10);

    let started = ExecuteCommandInstruction(MatrixPostProcessStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, '0001', TRUE, TRUE, TRUE, FALSE);

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
    assert ReadTileElement(1, 0, 8) == Zeros{PTO_XLEN} + 9;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 10;
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 8;
    assert ReadTileElement(3, 0, 1) == Zeros{PTO_XLEN} + 9;
    return 0;
end;
