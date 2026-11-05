// PTO-TEST: {"id":"PTO-AVS-BLOCK-I414-MSCATTER-RANGE-001","source":"asl/block/execution/BSTART.MSCATTER.asl","requirements":["PTO-INDEXED-TLSU-RANGE-BINDING-001","PTO-MSCATTER-BYTE-DISPLACEMENT-001","PTO-MSCATTER-DUPLICATE-ORDER-001","PTO-BSTART-MSCATTER-SCHEMA-001","PTO-INST-TILE-MSCATTER","PTO-INST-BLOCK-BSTART-MSCATTER"],"kind":"execution","summary":"Decoded MSCATTER consumes a signed range while retaining byte-displacement writes and source Tiles.","pass_condition":"S64 byte displacements -4, 0, and 3 fit [0x1fc,0x204); exactly those three bytes are written and both source Tile payloads remain unchanged.","related_sources":["asl/block/model/dispatch/indexed-tlsu-range-schema.asl","asl/block/model/dispatch/tlsu-mscatter.asl","asl/tile/model/memory/addressing.asl","asl/tile/model/memory/gather-scatter.asl"]}
pure func RangeScatterStart(data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00511181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func RangeScatterBinding(source: bits(6), indices: bits(6))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[31:26] = indices;
    instruction[25:20] = source;
    instruction[19] = '1';
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '001';
    return instruction;
end;

pure func RangeScatterIOR() => bits(64)
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
    ConfigureTile(2, 128, 1, 8, 1, 3, TileDataType_S64,
        TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x11);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x27);
    WriteTileElement(1, 0, 2, Zeros{PTO_XLEN} + 0x44);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} - 4);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 2, Zeros{PTO_XLEN} + 3);
    Store(Zeros{PTO_XLEN} + 0x1fc, 1, Zeros{PTO_XLEN});
    Store(Zeros{PTO_XLEN} + 0x200, 1, Zeros{PTO_XLEN});
    Store(Zeros{PTO_XLEN} + 0x203, 1, Zeros{PTO_XLEN});
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x200);
    WritePEGPR(0, 3, Zeros{64} - 4);
    WritePEGPR(0, 4, Zeros{64} + 3);
    let started = ExecuteCommandInstruction(
        RangeScatterStart(TileDataTypeToEncoding(TileDataType_U8)), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let tiles = ExecuteCommandInstruction(
        RangeScatterBinding(Zeros{6} + 1, Zeros{6} + 2), 32);
    let scalar = ExecuteCommandInstruction(RangeScatterIOR(), 32);
    assert tiles == CommandExecution_Executed;
    assert scalar == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    assert _MemoryEventCount == 3;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x1fc;
    assert _MemoryEvents[[1]].address == Zeros{PTO_XLEN} + 0x200;
    assert _MemoryEvents[[2]].address == Zeros{PTO_XLEN} + 0x203;
    StopMemoryEventCapture();
    let observed_1 = LoadUnsigned(Zeros{PTO_XLEN} + 0x1fc, 1);
    assert observed_1 == Zeros{PTO_XLEN} + 0x11;
    let observed_2 = LoadUnsigned(Zeros{PTO_XLEN} + 0x200, 1);
    assert observed_2 == Zeros{PTO_XLEN} + 0x27;
    let observed_3 = LoadUnsigned(Zeros{PTO_XLEN} + 0x203, 1);
    assert observed_3 == Zeros{PTO_XLEN} + 0x44;
    assert _Tiles[[1]].contents_defined && _Tiles[[2]].contents_defined;
    assert ReadTileElement(1, 0, 2) == Zeros{PTO_XLEN} + 0x44;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} - 4;
    return 0;
end;
