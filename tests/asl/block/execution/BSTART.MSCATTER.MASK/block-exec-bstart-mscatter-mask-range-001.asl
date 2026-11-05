// PTO-TEST: {"id":"PTO-AVS-BLOCK-I414-MSCATTER-MASK-RANGE-001","source":"asl/block/execution/BSTART.MSCATTER.MASK.asl","requirements":["PTO-INDEXED-TLSU-RANGE-BINDING-001","PTO-MSCATTER-MASK-PREDICATE-001","PTO-MSCATTER-BYTE-DISPLACEMENT-001","PTO-BSTART-MSCATTER-MASK-SCHEMA-001","PTO-INST-TILE-MSCATTER-MASK","PTO-INST-BLOCK-BSTART-MSCATTER-MASK"],"kind":"execution","summary":"Decoded MSCATTER.MASK bounds only the active byte-displacement stores and preserves its independent predicate Tile.","pass_condition":"The exact-one mask selects indices 0 and 4 within [0,5), the disabled invalid index is not accessed, and only the two selected byte addresses are written.","related_sources":["asl/block/model/dispatch/indexed-tlsu-range-schema.asl","asl/block/model/dispatch/tlsu-mscatter-mask.asl","asl/tile/model/memory/addressing.asl","asl/tile/model/memory/gather-scatter.asl"]}
pure func RangeMaskedScatterStart(data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00711181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func RangeMaskedScatterFirst(source: bits(6), indices: bits(6))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[31:26] = indices;
    instruction[25:20] = source;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '001';
    return instruction;
end;

pure func RangeMaskedScatterLast(mask: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = mask;
    instruction[19] = '1';
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '001';
    return instruction;
end;

pure func RangeMaskedScatterIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 1, 4, 1, 3, TileDataType_U8,
        TileLayout_RowMajor);
    ConfigureTile(2, 128, 1, 8, 1, 3, TileDataType_S32,
        TileLayout_RowMajor);
    ConfigureTile(3, 128, 1, 4, 1, 3, TileDataType_U8,
        TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x11);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x22);
    WriteTileElement(1, 0, 2, Zeros{PTO_XLEN} + 0x33);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 5000);
    WriteTileElement(2, 0, 2, Zeros{PTO_XLEN} + 4);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(3, 0, 2, Zeros{PTO_XLEN} + 1);
    Store(Zeros{PTO_XLEN} + 0x202, 1, Zeros{PTO_XLEN});
    Store(Zeros{PTO_XLEN} + 0x206, 1, Zeros{PTO_XLEN});
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x202);
    WritePEGPR(0, 3, Zeros{64});
    WritePEGPR(0, 4, Zeros{64} + 4);
    let started = ExecuteCommandInstruction(
        RangeMaskedScatterStart(TileDataTypeToEncoding(TileDataType_U8)), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    WritePEGPR(0, 5, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let first = ExecuteCommandInstruction(
        RangeMaskedScatterFirst(Zeros{6} + 1, Zeros{6} + 2), 32);
    let last = ExecuteCommandInstruction(
        RangeMaskedScatterLast(Zeros{6} + 3), 32);
    let scalar = ExecuteCommandInstruction(RangeMaskedScatterIOR(), 32);
    assert first == CommandExecution_Executed;
    assert last == CommandExecution_Executed;
    assert scalar == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x202;
    assert _MemoryEvents[[1]].address == Zeros{PTO_XLEN} + 0x206;
    StopMemoryEventCapture();
    let observed_1 = LoadUnsigned(Zeros{PTO_XLEN} + 0x202, 1);
    assert observed_1 == Zeros{PTO_XLEN} + 0x11;
    let observed_2 = LoadUnsigned(Zeros{PTO_XLEN} + 0x206, 1);
    assert observed_2 == Zeros{PTO_XLEN} + 0x33;
    assert _Tiles[[1]].contents_defined && _Tiles[[2]].contents_defined &&
           _Tiles[[3]].contents_defined;
    return 0;
end;
