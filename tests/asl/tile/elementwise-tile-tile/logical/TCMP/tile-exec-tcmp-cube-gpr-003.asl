// PTO-TEST: {"id":"PTO-AVS-TILE-TCMP-CUBE-GPR-003","source":"asl/tile/elementwise-tile-tile/logical/TCMP.asl","requirements":["PTO-TCMP-CONTRACT-001"],"kind":"execution","summary":"Decoded CUBE TCMP publishes one complete GPR predicate carrier","pass_condition":"FP32 CUBE_M32 equality writes valid predicate bits and predicate Max tail bits atomically to the selected 64-bit GPR","related_sources":["asl/block/model/dispatch/comparison-schema.asl","asl/block/model/dispatch/tile-execution.asl","asl/tile/model/execution/comparison.asl"]}
pure func TCMPGPRStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = '00';
    instruction[24:20] = Zeros{5} + 13;
    instruction[31:27] = Zeros{5} + 1;
    return instruction;
end;

pure func TCMPGPRSources(source0: bits(6), source1: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = source1;
    instruction[25:20] = source0;
    instruction[19] = '1';
    instruction[11:9] = '001';
    return instruction;
end;

pure func TCMPGPRDestination(destination: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[11:7] = destination;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let left_ready = ConfigureCubeTile(
        10, 256, 1, 2, TileDataType_FP32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let right_ready = ConfigureCubeTile(
        11, 256, 1, 2, TileDataType_FP32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    assert left_ready && right_ready;
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(11, 0, 1, Zeros{PTO_XLEN} + 3);
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);

    let started = ExecuteCommandInstruction(TCMPGPRStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        DTYPE_NONE, Zeros{5}, '01', Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    let sources = ExecuteCommandInstruction(
        TCMPGPRSources(Zeros{6} + 10, Zeros{6} + 11), 32);
    let destination = ExecuteCommandInstruction(
        TCMPGPRDestination(Zeros{5} + 5), 32);
    assert sources == CommandExecution_Executed;
    assert destination == CommandExecution_Executed;

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let result = ReadGPR(5);
    assert result[0] == '1';
    assert result[32] == '0';
    assert result[1] == '1';
    assert result[33] == '1';
    assert !TileCubePredicateDataTypeSupported(TileDataType_FP64);
    assert !TileCubePredicateDataTypeSupported(TileDataType_S64);
    assert !TileCubePredicateDataTypeSupported(TileDataType_U64);
    return 0;
end;
