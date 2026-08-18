// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSTORE-STRIDE-001","source":"asl/block/execution/BSTART.TSTORE.asl","requirements":["PTO-INST-BLOCK-BSTART-TSTORE","PTO-INST-TILE-TSTORE"],"kind":"execution","summary":"TSTORE distinguishes explicit, omitted, and encoded-zero logical row strides.","pass_condition":"Explicit B.IOR addresses use RegSrc0/RegSrc1, omission uses base zero and LB2, and encoded zero aliases rows.","related_sources":["asl/block/model/dispatch/tile-schema.asl","asl/tile/model/memory/load-store.asl"]}
pure func TStoreStrideStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 25;
    return instruction;
end;

pure func TStoreStrideSource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[18:15] = '1111';
    instruction[19] = '1';
    return instruction;
end;

pure func TStoreStrideIOR(source0: bits(5), source1: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = source0;
    instruction[24:20] = source1;
    return instruction;
end;

func ConfigureTStoreSource(first: integer, second: integer,
                           third: integer, fourth: integer)
begin
    ConfigureTile(0, 128, 2, 2, 2, 2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + first);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + second);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + third);
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN} + fourth);
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTStoreSource(11, 12, 13, 14);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x200);
    WriteGPR(3, Zeros{PTO_XLEN} + 3);
    let explicit_start_status = ExecuteCommandInstruction(
        TStoreStrideStart(), 32);
    assert explicit_start_status == CommandExecution_Executed;
    let explicit_source_status = ExecuteCommandInstruction(
        TStoreStrideSource(), 32);
    assert explicit_source_status == CommandExecution_Executed;
    let explicit_ior_status = ExecuteCommandInstruction(
        TStoreStrideIOR(Zeros{5} + 2, Zeros{5} + 3), 32);
    assert explicit_ior_status == CommandExecution_Executed;
    let explicit_completed = ExecuteBundleTileOperation();
    assert explicit_completed;
    assert _Memory[[0x200]] == Zeros{8} + 11;
    assert _Memory[[0x204]] == Zeros{8} + 12;
    assert _Memory[[0x20c]] == Zeros{8} + 13;
    assert _Memory[[0x210]] == Zeros{8} + 14;

    ResetProfileState();
    ConfigureTStoreSource(15, 16, 17, 18);
    let omitted_start_status = ExecuteCommandInstruction(
        TStoreStrideStart(), 32);
    assert omitted_start_status == CommandExecution_Executed;
    SetBundleDimension(2, Zeros{PTO_XLEN} + 3);
    let omitted_source_status = ExecuteCommandInstruction(
        TStoreStrideSource(), 32);
    assert omitted_source_status == CommandExecution_Executed;
    let omitted_completed = ExecuteBundleTileOperation();
    assert omitted_completed;
    assert _Memory[[0]] == Zeros{8} + 15;
    assert _Memory[[4]] == Zeros{8} + 16;
    assert _Memory[[12]] == Zeros{8} + 17;
    assert _Memory[[16]] == Zeros{8} + 18;

    ResetProfileState();
    ConfigureTStoreSource(19, 20, 21, 22);
    let zero_start_status = ExecuteCommandInstruction(
        TStoreStrideStart(), 32);
    assert zero_start_status == CommandExecution_Executed;
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let zero_source_status = ExecuteCommandInstruction(
        TStoreStrideSource(), 32);
    assert zero_source_status == CommandExecution_Executed;
    let zero_ior_status = ExecuteCommandInstruction(
        TStoreStrideIOR(Zeros{5}, Zeros{5}), 32);
    assert zero_ior_status == CommandExecution_Executed;
    let zero_completed = ExecuteBundleTileOperation();
    assert zero_completed;
    assert _Memory[[0]] == Zeros{8} + 21;
    assert _Memory[[4]] == Zeros{8} + 22;
    return 0;
end;
