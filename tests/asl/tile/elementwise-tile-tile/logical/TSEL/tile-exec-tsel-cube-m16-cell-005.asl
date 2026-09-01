// PTO-TEST: {"id":"PTO-AVS-TILE-TSEL-CUBE-M16-CELL-005","source":"asl/tile/elementwise-tile-tile/logical/TSEL.asl","requirements":["PTO-TSEL-CONTRACT-001"],"kind":"execution","summary":"Decoded CUBE_M16 TSEL consumes a basis-matched PredicateCell","pass_condition":"canonical S16-basis PredicateCell bytes select true and false values and publish a new M16 destination","related_sources":["asl/block/model/dispatch/comparison-schema.asl","asl/block/model/dispatch/predicate-destination.asl","asl/tile/model/legality/predicate-carriers.asl"]}
pure func TSELM16CellStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[24:20] = Zeros{5} + 26;
    instruction[31:27] = Zeros{5} + 18;
    return instruction;
end;

pure func TSELM16CellInputs(mask: bits(6), source_true: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = source_true;
    instruction[25:20] = mask;
    instruction[11:9] = '001';
    return instruction;
end;

pure func TSELM16CellResult(source_false: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = source_false;
    instruction[19] = '1';
    instruction[18:15] = Zeros{4} + 1;
    instruction[11:9] = '001';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let predicate_ready = ConfigurePredicateCell(
        8, 128, 2, 4, TileDataType_S16, TileLayout_CUBE_M16);
    let true_ready = ConfigureCubeTile(
        10, 128, 2, 4, TileDataType_S16,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    let false_ready = ConfigureCubeTile(
        11, 128, 2, 4, TileDataType_S16,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    assert predicate_ready && true_ready && false_ready;
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 3 looplimit 4 do
            let index = row * 4 + column;
            WriteTileElement(8, row, column, Zeros{PTO_XLEN});
            WriteTileElement(10, row, column, Zeros{PTO_XLEN} + 10 + index);
            WriteTileElement(11, row, column, Zeros{PTO_XLEN} + 20 + index);
        end;
    end;
    WriteTileElement(8, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(8, 1, 3, Zeros{PTO_XLEN} + 1);
    _Tiles[[8]].contents_defined = TRUE;
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);

    let started = ExecuteCommandInstruction(TSELM16CellStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    let inputs = ExecuteCommandInstruction(
        TSELM16CellInputs(Zeros{6} + 8, Zeros{6} + 10), 32);
    let result = ExecuteCommandInstruction(
        TSELM16CellResult(Zeros{6} + 11), 32);
    assert inputs == CommandExecution_Executed;
    assert result == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[1]].destination;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M16;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 10;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 21;
    assert ReadTileElement(destination, 1, 3) == Zeros{PTO_XLEN} + 17;
    return 0;
end;
