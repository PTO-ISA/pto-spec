// PTO-TEST: {"id":"PTO-AVS-BLOCK-I414-MGATHER-DEC-RANGE-001","kind":"execution","pass_condition":"The encoded Base/Min/Max selectors pass pre-effect legality, exactly two U32 atomic events use byte addresses 0x400 and 0x404, and the old-value Tile plus results match the operation.","related_sources":["asl/block/model/dispatch/indexed-tlsu-range-schema.asl","asl/block/model/dispatch/tlsu-gm-atom-red.asl","asl/tile/model/memory/gm-atom-red-execution.asl"],"requirements":["PTO-INDEXED-TLSU-RANGE-BINDING-001","PTO-B-IOR-BINDING-001","PTO-ATOM-RED-BODY-SCHEMA-001","PTO-ATOM-RED-ENCODING-001","PTO-ATOM-RED-ORDERING-001","PTO-INST-TILE-MGATHER-DEC","PTO-INST-BLOCK-BSTART-MGATHER-DEC"],"source":"asl/block/execution/BSTART.MGATHER.DEC.asl","summary":"Decoded MGATHER.DEC consumes per-PE S64 range selectors before its atomic indexed transactions."}
pure func RangeAtomRedStart(function: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[24:20] = function;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func RangeAtomRedAttributes() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 31;
    return instruction;
end;

pure func RangeAtomRedBinding(destination_valid: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 11;
    instruction[25:20] = Zeros{6} + 10;
    instruction[19] = '1';
    instruction[18:15] = if destination_valid then '0001' else '0000';
    instruction[11:9] = '001';
    instruction[8:7] = if destination_valid then '01' else '00';
    return instruction;
end;

pure func RangeAtomRedIOR() => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor);
    let indices_ready = ConfigureCubeTile(
        10, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert indices_ready;
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 4);
    let values_ready = ConfigureCubeTile(
        11, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert values_ready;
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 100);
    WriteTileElement(11, 0, 1, Zeros{PTO_XLEN} + 100);
    Store(Zeros{PTO_XLEN} + 0x400, 4, Zeros{PTO_XLEN} + 10);
    Store(Zeros{PTO_XLEN} + 0x404, 4, Zeros{PTO_XLEN} + 20);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x400);
    WritePEGPR(0, 3, Zeros{PTO_XLEN});
    WritePEGPR(0, 4, Zeros{PTO_XLEN} + 4);
    let started = ExecuteCommandInstruction(
        RangeAtomRedStart(Zeros{5} + 15), 32);
    let attributes = ExecuteCommandInstruction(RangeAtomRedAttributes(), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, NaturalToWord(_Tiles[[10]].columns));
    let binding = ExecuteCommandInstruction(
        RangeAtomRedBinding(TRUE), 32);
    let scalar = ExecuteCommandInstruction(RangeAtomRedIOR(), 32);
    assert binding == CommandExecution_Executed;
    assert scalar == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Atomic;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Atomic;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x400;
    assert _MemoryEvents[[1]].address == Zeros{PTO_XLEN} + 0x404;
    StopMemoryEventCapture();
    let destination = _BundleTileBindings[[0]].destination;
    assert destination != 0;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 10;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 20;
    let observed_1 = LoadUnsigned(Zeros{PTO_XLEN} + 0x400, 4);
    assert observed_1 == Zeros{PTO_XLEN} + 9;
    let observed_2 = LoadUnsigned(Zeros{PTO_XLEN} + 0x404, 4);
    assert observed_2 == Zeros{PTO_XLEN} + 19;
    return 0;
end;
