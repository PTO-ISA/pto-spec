// PTO-TEST: {"id":"PTO-AVS-TILE-POSTPROCESS-GROUP-LARGE-004","source":"asl/tile/model/execution/postprocess.asl","requirements":["PTO-MATRIX-POSTPROCESS-BITEXACT-001"],"kind":"execution","summary":"matrix GroupMax executes one partial group when GroupN exceeds N","pass_condition":"a one by three U32 accumulator with GroupN eight publishes one maximum value","related_sources":["asl/block/model/dispatch/destination-shape.asl"]}
pure func MatrixLargeGroupStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00031181;
    instruction[31:27] = Zeros{5} + 25;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 4, 1, 3, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 1, 4, 1, 3, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 5);
    WriteTileElement(0, 0, 2, Zeros{PTO_XLEN} + 4);

    let started = ExecuteCommandInstruction(MatrixLargeGroupStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, '0001', FALSE, TRUE, FALSE, FALSE);
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

    CommitMatrixResult(1, _Tiles[[0]]);
    assert ReadTileElement(1, 0, 2) == Zeros{PTO_XLEN} + 4;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 5;
    return 0;
end;
