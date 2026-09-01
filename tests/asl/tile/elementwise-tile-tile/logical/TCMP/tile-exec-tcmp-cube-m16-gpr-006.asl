// PTO-TEST: {"id":"PTO-AVS-TILE-TCMP-CUBE-M16-GPR-006","source":"asl/tile/elementwise-tile-tile/logical/TCMP.asl","requirements":["PTO-TCMP-CONTRACT-001"],"kind":"execution","summary":"Decoded CUBE_M16 TCMP packs four 16-row predicate quarters into one GPR","pass_condition":"S16 equality maps row plus column-times-16 into bits 0..63 and Max fills invalid row bits","related_sources":["asl/block/model/dispatch/comparison-schema.asl","asl/block/model/dispatch/tile-execution.asl","asl/tile/model/execution/comparison.asl"]}
pure func TCMPM16GPRStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[24:20] = Zeros{5} + 13;
    instruction[31:27] = Zeros{5} + 18;
    return instruction;
end;

pure func TCMPM16GPRSources(source0: bits(6), source1: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = source1;
    instruction[25:20] = source0;
    instruction[19] = '1';
    instruction[11:9] = '001';
    return instruction;
end;

pure func TCMPM16GPRDestination(destination: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[11:7] = destination;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let left_ready = ConfigureCubeTile(
        10, 128, 2, 4, TileDataType_S16,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    let right_ready = ConfigureCubeTile(
        11, 128, 2, 4, TileDataType_S16,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    assert left_ready && right_ready;
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 3 looplimit 4 do
            let value = Zeros{PTO_XLEN} + row * 4 + column + 1;
            WriteTileElement(10, row, column, value);
            WriteTileElement(11, row, column, value);
        end;
    end;
    WriteTileElement(11, 1, 3, Zeros{PTO_XLEN} + 99);
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);

    let started = ExecuteCommandInstruction(TCMPM16GPRStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        DTYPE_NONE, Zeros{5}, '01', Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    let sources = ExecuteCommandInstruction(
        TCMPM16GPRSources(Zeros{6} + 10, Zeros{6} + 11), 32);
    let destination = ExecuteCommandInstruction(
        TCMPM16GPRDestination(Zeros{5} + 5), 32);
    assert sources == CommandExecution_Executed;
    assert destination == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let result = ReadGPR(5);
    assert result[0] == '1';
    assert result[49] == '0';
    assert result[2] == '1';
    assert result[63] == '1';
    return 0;
end;
