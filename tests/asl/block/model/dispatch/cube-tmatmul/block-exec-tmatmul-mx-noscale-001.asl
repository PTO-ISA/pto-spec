// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-MX-NOSCALE-001","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-INST-TILE-TMATMUL-MX"],"kind":"execution","summary":"FP16 TMATMULMX omits both scale operands in the complete block schema","pass_condition":"a two-source Local binding computes and publishes the FP32 matrix result","related_sources":["asl/tile/model/legality/matrix-functions.asl","asl/tile/model/execution/cube.asl"]}
pure func MatrixNoScaleStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00431181;
    instruction[31:27] = '00100';
    return instruction;
end;

pure func MatrixNoScaleFPATR() => bits(64)
begin
    return Zeros{64} + 0x00002023;
end;

pure func MatrixNoScaleBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[11:9] = '111';
    instruction[8:7] = '10';
    instruction[18:15] = '0000';
    instruction[25:20] = Zeros{6};
    instruction[31:26] = Zeros{6} + 1;
    instruction[19] = '1';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(0, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let b_ready = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    assert a_ready && b_ready;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);

    let start = ExecuteCommandInstruction(MatrixNoScaleStart(), 32);
    let attributes = ExecuteCommandInstruction(MatrixNoScaleFPATR(), 32);
    let binding = ExecuteCommandInstruction(MatrixNoScaleBinding(), 32);
    assert start == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    assert binding == CommandExecution_Executed;

    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 6;
    assert _Tiles[[destination]].data_type == TileDataType_FP32;
    return 0;
end;
