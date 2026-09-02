// PTO-TEST: {"id":"PTO-AVS-BLOCK-MSCATTER-SCATTER-001","source":"asl/block/execution/BSTART.MSCATTER.asl","requirements":["PTO-INDEXED-TLSU-STRIDE-001","PTO-BSTART-MSCATTER-SCHEMA-001","PTO-MSCATTER-BYTE-DISPLACEMENT-001","PTO-INST-TILE-MSCATTER","PTO-INST-BLOCK-BSTART-MSCATTER"],"kind":"execution","summary":"MSCATTER writes each source row to the GM row selected by its signed S32 relative index.","pass_condition":"A 2x2 U8 source and 1x2 S32 IndexTile write two adjacent elements in each selected GM row and leave both source descriptors unchanged.","related_sources":["asl/block/model/dispatch/tlsu-mscatter.asl","asl/tile/model/memory/gather-scatter.asl"]}
pure func ScatterStart(data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00511181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func ScatterBinding(source: bits(6), indices: bits(6), pe_mode: bits(3))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[31:26] = indices;
    instruction[25:20] = source;
    instruction[19] = '1';
    instruction[18:15] = Zeros{4};
    instruction[11:9] = pe_mode;
    return instruction;
end;

pure func ScatterIOR(register: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = register;
    instruction[24:20] = Zeros{5} + 4;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 2, 4, 2, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 1, 2, 1, 2, TileDataType_S32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x11);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x22);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 0x33);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 0x44);
    WriteTileElement(2, 0, 0, Ones{PTO_XLEN});
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 2);
    WritePEGPR(0, 3, Zeros{PTO_XLEN} + 0x122);
    let started = ExecuteCommandInstruction(
        ScatterStart(Zeros{5} + 27), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    WritePEGPR(0, 4, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let tiles = ExecuteCommandInstruction(
        ScatterBinding(Zeros{6} + 1, Zeros{6} + 2, '001'), 32);
    assert tiles == CommandExecution_Executed;
    let scalar = ExecuteCommandInstruction(ScatterIOR(Zeros{5} + 3), 32);
    assert scalar == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _MemoryEventCount == 4;
    StopMemoryEventCapture();
    let value0 = LoadUnsigned(Zeros{PTO_XLEN} + 0x120, 1);
    let value1 = LoadUnsigned(Zeros{PTO_XLEN} + 0x121, 1);
    let value2 = LoadUnsigned(Zeros{PTO_XLEN} + 0x126, 1);
    let value3 = LoadUnsigned(Zeros{PTO_XLEN} + 0x127, 1);
    assert value0 == Zeros{PTO_XLEN} + 0x11;
    assert value1 == Zeros{PTO_XLEN} + 0x22;
    assert value2 == Zeros{PTO_XLEN} + 0x33;
    assert value3 == Zeros{PTO_XLEN} + 0x44;
    assert _Tiles[[1]].allocated && _Tiles[[1]].contents_defined;
    assert _Tiles[[2]].allocated && _Tiles[[2]].contents_defined;
    assert ReadTileElement(1, 1, 1) == Zeros{PTO_XLEN} + 0x44;
    return 0;
end;
