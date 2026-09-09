// PTO-TEST: {"id":"PTO-AVS-TILE-TCMP-CUBE-U8-GPR-CROSS-001","source":"asl/tile/elementwise-tile-tile/logical/TCMP.asl","requirements":["PTO-TCMP-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"E4M3-backed CUBE_M16 TCMP uses operation-typed U8 Low and High GPR halves","pass_condition":"the U8 operation accepts E4M3 sources and Low/High select different four-column predicate halves in the output GPR","related_sources":["asl/block/model/dispatch/comparison-schema.asl","asl/block/model/dispatch/tile-execution.asl","asl/tile/model/execution/predicate-carriers.asl"]}
pure func TCMPU8M16GPRStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = '00';
    instruction[24:20] = Zeros{5} + 13;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func TCMPU8GPRSources(source0: bits(6), source1: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = source1;
    instruction[25:20] = source0;
    instruction[19] = '1';
    instruction[11:9] = '001';
    return instruction;
end;

pure func TCMPU8GPRDestination(destination: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[11:7] = destination;
    return instruction;
end;

func RunTCMPU8GPRCase(high: boolean)
begin
    ResetProfileState();
    let left_ready = ConfigureCubeTile(
        10, 128, 1, 8, TileDataType_E4M3,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    let right_ready = ConfigureCubeTile(
        11, 128, 1, 8, TileDataType_E4M3,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    assert left_ready && right_ready;
    for column = 0 to 7 looplimit 8 do
        let left = Zeros{PTO_XLEN} + column + 1;
        let equal = if column < 4 then column MOD 2 == 0
                    else column MOD 2 == 1;
        WriteTileElement(10, 0, column, left);
        WriteTileElement(11, 0, column,
            if equal then left else left + 1);
    end;
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);

    let started = ExecuteCommandInstruction(TCMPU8M16GPRStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        DTYPE_NONE, Zeros{5}, '00', Zeros{3}, Zeros{3}, high, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 8);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    let sources = ExecuteCommandInstruction(
        TCMPU8GPRSources(Zeros{6} + 10, Zeros{6} + 11), 32);
    let destination = ExecuteCommandInstruction(
        TCMPU8GPRDestination(Zeros{5} + 5), 32);
    assert sources == CommandExecution_Executed;
    assert destination == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
end;

func main() => integer
begin
    RunTCMPU8GPRCase(FALSE);
    let low = ReadGPR(5);
    assert low[0] == '1' && low[16] == '0' &&
        low[32] == '1' && low[48] == '0';

    RunTCMPU8GPRCase(TRUE);
    let high = ReadGPR(5);
    assert high[0] == '0' && high[16] == '1' &&
        high[32] == '0' && high[48] == '1';
    return 0;
end;
