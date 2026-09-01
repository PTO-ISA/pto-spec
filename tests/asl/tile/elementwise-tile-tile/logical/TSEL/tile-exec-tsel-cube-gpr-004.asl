// PTO-TEST: {"id":"PTO-AVS-TILE-TSEL-CUBE-GPR-004","source":"asl/tile/elementwise-tile-tile/logical/TSEL.asl","requirements":["PTO-TSEL-CONTRACT-001"],"kind":"execution","summary":"Decoded U8 CUBE TSEL consumes its complete two-GPR mask","pass_condition":"independent low/high mask words select true only for column zero and publish a newly allocated CUBE_M32 destination","related_sources":["asl/block/model/dispatch/comparison-schema.asl","asl/block/model/dispatch/tile-execution.asl","asl/tile/model/execution/predicate-carriers.asl"]}
pure func TSELGPRStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = '00';
    instruction[24:20] = Zeros{5} + 26;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func TSELGPRTiles(source_true: bits(6), source_false: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = source_false;
    instruction[25:20] = source_true;
    instruction[19] = '1';
    instruction[18:15] = Zeros{4} + 1;
    instruction[11:9] = '001';
    return instruction;
end;

pure func TSELGPRMask(low: bits(5), high: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = low;
    instruction[24:20] = high;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let true_ready = ConfigureCubeTile(
        10, 128, 1, 4, TileDataType_U8,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let false_ready = ConfigureCubeTile(
        11, 128, 1, 4, TileDataType_U8,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    assert true_ready && false_ready;
    for column = 0 to 3 looplimit 4 do
        WriteTileElement(10, 0, column, Zeros{PTO_XLEN} + 10 + column);
        WriteTileElement(11, 0, column, Zeros{PTO_XLEN} + 20 + column);
    end;
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);
    WriteGPR(2, Zeros{PTO_XLEN} + 1);
    WriteGPR(3, Zeros{PTO_XLEN});

    let started = ExecuteCommandInstruction(TSELGPRStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    let tiles = ExecuteCommandInstruction(
        TSELGPRTiles(Zeros{6} + 10, Zeros{6} + 11), 32);
    let mask = ExecuteCommandInstruction(
        TSELGPRMask(Zeros{5} + 2, Zeros{5} + 3), 32);
    assert tiles == CommandExecution_Executed;
    assert mask == CommandExecution_Executed;

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M32;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 10;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 21;
    assert ReadTileElement(destination, 0, 2) == Zeros{PTO_XLEN} + 22;
    assert ReadTileElement(destination, 0, 3) == Zeros{PTO_XLEN} + 23;
    return 0;
end;
