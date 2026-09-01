// PTO-TEST: {"id":"PTO-AVS-TILE-TSEL-CUBE-M16-GPR-006","source":"asl/tile/elementwise-tile-tile/logical/TSEL.asl","requirements":["PTO-TSEL-CONTRACT-001"],"kind":"execution","summary":"Decoded CUBE_M16 TSEL consumes one four-quarter GPR predicate mask","pass_condition":"bits row plus column-times-16 select S16 values across the first and fourth quarters while Max defines physical row padding","related_sources":["asl/block/model/dispatch/comparison-schema.asl","asl/block/model/dispatch/tile-execution.asl","asl/tile/model/execution/predicate-carriers.asl"]}
pure func TSELM16GPRStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[24:20] = Zeros{5} + 26;
    instruction[31:27] = Zeros{5} + 18;
    return instruction;
end;

pure func TSELM16GPRTiles(source_true: bits(6), source_false: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = source_false;
    instruction[25:20] = source_true;
    instruction[19] = '1';
    instruction[18:15] = Zeros{4} + 1;
    instruction[11:9] = '001';
    return instruction;
end;

pure func TSELM16GPRMask(source: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = source;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let true_ready = ConfigureCubeTile(
        10, 128, 2, 4, TileDataType_S16,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    let false_ready = ConfigureCubeTile(
        11, 128, 2, 4, TileDataType_S16,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    assert true_ready && false_ready;
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 3 looplimit 4 do
            let index = row * 4 + column;
            WriteTileElement(10, row, column, Zeros{PTO_XLEN} + 10 + index);
            WriteTileElement(11, row, column, Zeros{PTO_XLEN} + 20 + index);
        end;
    end;
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);
    var predicate = Zeros{PTO_XLEN};
    predicate[0] = '1';
    predicate[49] = '1';
    WriteGPR(2, predicate);

    let started = ExecuteCommandInstruction(TSELM16GPRStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        DTYPE_NONE, Zeros{5}, '01', Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    let tiles = ExecuteCommandInstruction(
        TSELM16GPRTiles(Zeros{6} + 10, Zeros{6} + 11), 32);
    let mask = ExecuteCommandInstruction(
        TSELM16GPRMask(Zeros{5} + 2), 32);
    assert tiles == CommandExecution_Executed;
    assert mask == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M16;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 10;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 21;
    assert ReadTileElement(destination, 1, 3) == Zeros{PTO_XLEN} + 17;
    assert TileElementDefined(destination, 2, 0);
    assert ReadTileElement(destination, 2, 0) == Zeros{PTO_XLEN} + 0x7fff;
    return 0;
end;
