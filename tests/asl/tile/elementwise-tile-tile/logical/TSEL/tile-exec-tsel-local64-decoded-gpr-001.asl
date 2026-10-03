// PTO-TEST: {"id":"PTO-AVS-TILE-TSEL-LOCAL64-DECODED-GPR-001","source":"asl/tile/elementwise-tile-tile/logical/TSEL.asl","requirements":["PTO-TSEL-CONTRACT-001","PTO-CUBE-M32-B64-DOUBLE-CELL-001"],"kind":"execution","summary":"Decoded M32 TSEL reaches its GPR carrier with full-width 64-bit operands.","pass_condition":"Decoded binder, datatype, predicate and destination allocation paths preserve logical predicate coordinates and both halves of selected 64-bit elements.","related_sources":["asl/block/model/dispatch/comparison-schema.asl","asl/block/model/dispatch/tile-execution.asl","asl/tile/model/execution/predicate-carriers.asl"]}
pure func TSELGPRStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = '00';
    instruction[24:20] = Zeros{5} + 26;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U64);
    return instruction;
end;

pure func TSELGPRTiles(source_true: bits(6), source_false: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = source_false;
    instruction[25:20] = source_true;
    instruction[19] = '1';
    instruction[18:15] = Zeros{4} + 3;
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
        10, 512, 1, 2, TileDataType_U64,
        TileLayout_CUBE_M32);
    let false_ready = ConfigureCubeTile(
        11, 512, 1, 2, TileDataType_U64,
        TileLayout_CUBE_M32);
    assert true_ready && false_ready;
    for column = 0 to 1 looplimit 2 do
        WriteTileElement(10, 0, column, Zeros{PTO_XLEN} + 0x112233440000000a + column);
        WriteTileElement(11, 0, column, Zeros{PTO_XLEN} + 0xaabbccdd00000014 + column);
    end;
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);
    WriteGPR(2, Zeros{PTO_XLEN} + 1);
    WriteGPR(3, Zeros{PTO_XLEN});

    let started = ExecuteCommandInstruction(TSELGPRStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    let tiles = ExecuteCommandInstruction(
        TSELGPRTiles(Zeros{6} + 10, Zeros{6} + 11), 32);
    let mask = ExecuteCommandInstruction(
        TSELGPRMask(Zeros{5} + 2, Zeros{5}), 32);
    assert tiles == CommandExecution_Executed;
    assert mask == CommandExecution_Executed;

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M32;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0x112233440000000a;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 0xaabbccdd00000015;
    return 0;
end;
