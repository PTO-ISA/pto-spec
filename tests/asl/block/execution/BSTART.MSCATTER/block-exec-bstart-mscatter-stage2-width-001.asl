// PTO-TEST: {"id":"PTO-AVS-BLOCK-MSCATTER-STAGE2-WIDTH-001","source":"asl/block/execution/BSTART.MSCATTER.asl","requirements":["PTO-BSTART-MSCATTER-SCHEMA-001","PTO-INDEXED-TLSU-STRIDE-001","PTO-MSCATTER-BYTE-DISPLACEMENT-001","PTO-INST-TILE-MSCATTER","PTO-INST-BLOCK-BSTART-MSCATTER"],"kind":"execution","summary":"decoded MSCATTER accepts the S32/U32 index common subset and preserves raw transfer carriers","pass_condition":"U32 and S32 row indices execute, and a raw invalid TF32 carrier is stored unchanged","related_sources":["asl/block/model/dispatch/tlsu-mscatter.asl","asl/tile/model/memory/gather-scatter.asl","asl/tile/model/memory/addressing.asl"]}

pure func MscatterStage2Start(data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00511181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func MscatterStage2Binding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 2;
    instruction[25:20] = Zeros{6} + 1;
    instruction[19] = '1';
    instruction[18:15] = '0000';
    instruction[11:9] = '001';
    return instruction;
end;

pure func MscatterStage2IOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 3;
    instruction[24:20] = Zeros{5} + 4;
    return instruction;
end;

func PrepareMscatterStage2(source_type: TileDataType,
                           index_type: TileDataType,
                           index_value: Word,
                           data_type: bits(5))
begin
    ResetProfileState();
    ConfigureTile(
        1,
        128,
        1,
        1,
        1,
        1,
        source_type,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        2,
        128,
        1,
        1,
        1,
        1,
        index_type,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x1122334455667788);
    WriteTileElement(2, 0, 0, index_value);
    WritePEGPR(0, 3, Zeros{PTO_XLEN} + 0x100);
    let started = ExecuteCommandInstruction(
        MscatterStage2Start(data_type),
        32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    WritePEGPR(0, 4, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let bound = ExecuteCommandInstruction(MscatterStage2Binding(), 32);
    assert bound == CommandExecution_Executed;
    let scalar = ExecuteCommandInstruction(MscatterStage2IOR(), 32);
    assert scalar == CommandExecution_Executed;
end;

func main() => integer
begin
    let target = Zeros{PTO_XLEN} + 0x100;
    let source_value = Zeros{PTO_XLEN} + 0x1122334455667788;
    PrepareMscatterStage2(
        TileDataType_U64,
        TileDataType_U32,
        Zeros{PTO_XLEN},
        Zeros{5} + 24);
    WriteTileElement(1, 0, 0, source_value);
    Store(target, 8, Zeros{PTO_XLEN} + 0xdeadbeefdeadbeef);
    StartMemoryEventCapture(0);
    let wide_completed = ExecuteBundleTileOperation();
    assert wide_completed;
    let stored_u64 = LoadUnsigned(target, 8);
    assert stored_u64 == source_value;
    assert _MemoryEventCount > 0;
    assert _MemoryEvents[[0]].address == target;
    assert _MemoryEvents[[0]].size_bytes == 8;
    assert ReadTileElement(1, 0, 0) == source_value;
    StopMemoryEventCapture();

    PrepareMscatterStage2(
        TileDataType_U64,
        TileDataType_S32,
        Zeros{PTO_XLEN},
        Zeros{5} + 24);
    Store(target, 8, Zeros{PTO_XLEN} + 0xdeadbeefdeadbeef);
    StartMemoryEventCapture(0);
    let narrow_completed = ExecuteBundleTileOperation();
    assert narrow_completed;
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 1;
    let stored_with_narrow_index = LoadUnsigned(target, 8);
    assert stored_with_narrow_index == source_value;
    StopMemoryEventCapture();

    PrepareMscatterStage2(
        TileDataType_TF32,
        TileDataType_U32,
        Zeros{PTO_XLEN},
        Zeros{5} + 2);
    let invalid_tf32 = Zeros{PTO_XLEN} + 0x3f800001;
    WriteTileElement(1, 0, 0, invalid_tf32);
    Store(target, 4, Zeros{PTO_XLEN});
    let raw_completed = ExecuteBundleTileOperation();
    assert raw_completed;
    let raw_stored = LoadUnsigned(target, 4);
    assert raw_stored == invalid_tf32;
    return 0;
end;
