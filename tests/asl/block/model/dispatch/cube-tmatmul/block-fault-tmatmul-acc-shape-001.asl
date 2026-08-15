// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-ACC-SHAPE-001","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":[],"kind":"fault","summary":"TMATMUL.ACC rejects an accumulator whose valid shape differs from M x N before destination allocation","pass_condition":"the attempt reports Fault_TileLegality and leaves the candidate destination unallocated","related_sources":["asl/tile/model/legality/matrix-shape.asl"]}

pure func MatrixAccumulatorStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00431181;
    instruction[31:27] = Zeros{5} + 2;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(2, 128, 1, 1, 1, 1, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Matrix);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    assert !TileMatrixInfoAccumulatorSchemaLegal(
        0, 1, 1, TileDataType_FP32, 128);

    let started = ExecuteCommandInstruction(MatrixAccumulatorStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
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
