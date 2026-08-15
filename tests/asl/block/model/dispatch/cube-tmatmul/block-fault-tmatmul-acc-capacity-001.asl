// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-ACC-CAP-001","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":[],"kind":"fault","summary":"ReLU alone does not relax the TMATMUL.ACC source and destination capacity match","pass_condition":"a larger accumulator rejects with Fault_TileLegality before destination allocation","related_sources":["asl/tile/model/execution/cube.asl"]}

pure func MatrixAccumulatorReluStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00431181;
    instruction[31:27] = Zeros{5} + 2;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 256, 1, 1, 1, 1, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(2, 128, 1, 1, 1, 1, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Matrix);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);

    let started = ExecuteCommandInstruction(MatrixAccumulatorReluStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3} + 1, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    assert !TileMatrixInfoAccumulatorSchemaLegal(
        0, 1, 1, TileDataType_FP32, 128);
    AddBundleTileBinding(
        TRUE, 3, 1, '1111', TRUE, TRUE, 0, 1, FALSE);
    AddBundleTileBinding(
        FALSE, 0, 0, '1111', TRUE, FALSE, 2, 0, TRUE);

    assert !_Tiles[[48]].allocated;
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_Tiles[[48]].allocated;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 7;
    return 0;
end;
