// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-ACC-INDEX-021","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-ACCUMULATOR-OUTPUT-001"],"kind":"fault","summary":"Decoded ACC rejects equal C relative selector and D destination hand","pass_condition":"selector one and DstTile one fault before rename allocation source payload or numeric status","related_sources":["asl/block/operands/B.IOT.asl","asl/block/model/operands/tile-bindings.asl"]}
pure func EqualIndexAccumulatorBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + 1;
    instruction[18:15] = '1111';
    instruction[11:9] = '001';
    instruction[8:7] = '01';
    return instruction;
end;

pure func EqualIndexPrimaryBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[25:20] = Zeros{6} + 2;
    instruction[31:26] = Zeros{6} + 3;
    instruction[19] = '1';
    instruction[18:15] = '1111';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let c_ready = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_FP32, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let a_ready = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let b_ready = ConfigureCubeTileForMask(3, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    assert c_ready && a_ready && b_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 3);
    let c_before = _Tiles[[1]].payload[[TileStorageIndex(
        _Tiles[[1]], 0, 0)]];
    let status_before = NumericStatusFlags();

    var start: bits(64) = Zeros{64} + 0x00231181;
    start[31:27] = Zeros{5} + 4;
    let started = ExecuteCommandInstruction(start, 32);
    let attributes = ExecuteCommandInstruction(
        Zeros{64} + 0x00002023, 32);
    let accumulator = ExecuteCommandInstruction(
        EqualIndexAccumulatorBinding(), 32);
    let primaries = ExecuteCommandInstruction(
        EqualIndexPrimaryBinding(), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    assert accumulator == CommandExecution_Executed;
    assert primaries == CommandExecution_Executed;

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert _Tiles[[1]].payload[[TileStorageIndex(
        _Tiles[[1]], 0, 0)]] == c_before;
    assert NumericStatusFlags() == status_before;
    return 0;
end;
