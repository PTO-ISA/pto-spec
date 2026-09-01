// PTO-TEST: {"id":"PTO-AVS-TILE-TCMPS-CUBE-SCALAR-WIDTH-004","source":"asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl","requirements":["PTO-TCMPS-CONTRACT-001"],"kind":"execution","summary":"CUBE TCMPS normalizes the scalar GPR to the selected element width","pass_condition":"FP32 equality ignores nonzero upper GPR bits and publishes a true GPR predicate bit","related_sources":["asl/block/model/dispatch/tile-scalar-schema.asl","asl/tile/model/execution/predicate-carriers.asl"]}
pure func TCMPSGPRStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = '01';
    instruction[24:20] = Zeros{5} + 13;
    instruction[31:27] = Zeros{5} + 1;
    return instruction;
end;

pure func TCMPSGPRSource(source: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = source;
    instruction[19] = '1';
    instruction[11:9] = '001';
    return instruction;
end;

pure func TCMPSGPRBinding(destination: bits(5), scalar: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[11:7] = destination;
    instruction[19:15] = scalar;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        10, 128, 1, 1, TileDataType_FP32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    assert source_ready;
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
    MarkTileValidRegionDefined(10);
    WriteGPR(4, Zeros{PTO_XLEN} + 0x123456783f800000);

    let started = ExecuteCommandInstruction(TCMPSGPRStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    let source = ExecuteCommandInstruction(
        TCMPSGPRSource(Zeros{6} + 10), 32);
    let binding = ExecuteCommandInstruction(
        TCMPSGPRBinding(Zeros{5} + 5, Zeros{5} + 4), 32);
    assert source == CommandExecution_Executed;
    assert binding == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    assert ReadGPR(5)[0] == '1';
    return 0;
end;
