// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TLSU-BYTE-STRIDE-EXECUTION-007","source":"asl/block/model/dispatch/shared-tlsu.asl","requirements":["PTO-ARCH-GM-ACCESS-001","PTO-INST-TILE-TSTORE"],"kind":"execution","summary":"Shared full and partial TSTORE use explicit or omitted byte row strides","pass_condition":"Function 1 derives a dense byte pitch and Function 14 honors explicit and omitted byte pitches across two rows","related_sources":["asl/tile/model/memory/shared-movement.asl","asl/block/execution/BSTART.TSTORE.asl"]}
pure func SharedByteStrideStart(function: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = function;
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func SharedByteStrideSource(shared_id: bits(8), pe_mask: bits(4))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = pe_mask;
    return instruction;
end;

pure func SharedByteStrideIOR(source0: bits(5), source1: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = source0;
    instruction[24:20] = source1;
    return instruction;
end;

func AssertSharedByteStrideStore(base_address: Word, row_stride_bytes: Word)
begin
    let value00 = LoadUnsigned(base_address, 8);
    let value01 = LoadUnsigned(base_address + 8, 8);
    let value10 = LoadUnsigned(base_address + row_stride_bytes, 8);
    let value11 = LoadUnsigned(base_address + row_stride_bytes + 8, 8);
    assert value00 == Zeros{PTO_XLEN} + 1;
    assert value01 == Zeros{PTO_XLEN} + 2;
    assert value10 == Zeros{PTO_XLEN} + 3;
    assert value11 == Zeros{PTO_XLEN} + 4;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 2, 2, 2, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN} + 4);
    InstallSharedTile(Zeros{8} + 7, _Tiles[[0]], '1111');

    // Function 1 with no B.IOR/LB2 inherits two physical U64 columns and
    // therefore uses a dense sixteen-byte row pitch.
    let full_start = ExecuteCommandInstruction(
        SharedByteStrideStart('00001'), 32);
    let full_source = ExecuteCommandInstruction(
        SharedByteStrideSource(Zeros{8} + 7, '1111'), 32);
    assert full_start == CommandExecution_Executed;
    assert full_source == CommandExecution_Executed;
    let full_completed = ExecuteBundleTileOperation();
    assert full_completed;
    AssertSharedByteStrideStore(Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 16);

    // Function 14 reads the same per-PE selectors but permits a nonzero subset.
    ResetBundleControlState();
    WriteGPR(2, Zeros{PTO_XLEN} + 0x100);
    WriteGPR(3, Zeros{PTO_XLEN} + 24);
    let partial_start = ExecuteCommandInstruction(
        SharedByteStrideStart('01110'), 32);
    let partial_source = ExecuteCommandInstruction(
        SharedByteStrideSource(Zeros{8} + 7, '0001'), 32);
    let partial_ior = ExecuteCommandInstruction(
        SharedByteStrideIOR(Zeros{5} + 2, Zeros{5} + 3), 32);
    assert partial_start == CommandExecution_Executed;
    assert partial_source == CommandExecution_Executed;
    assert partial_ior == CommandExecution_Executed;
    let partial_completed = ExecuteBundleTileOperation();
    assert partial_completed;
    AssertSharedByteStrideStore(
        Zeros{PTO_XLEN} + 0x100, Zeros{PTO_XLEN} + 24);

    // Function 14 omission uses the same descriptor-derived dense byte pitch.
    ResetBundleControlState();
    Store(Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN});
    Store(Zeros{PTO_XLEN} + 8, 8, Zeros{PTO_XLEN});
    Store(Zeros{PTO_XLEN} + 16, 8, Zeros{PTO_XLEN});
    Store(Zeros{PTO_XLEN} + 24, 8, Zeros{PTO_XLEN});
    let omitted_start = ExecuteCommandInstruction(
        SharedByteStrideStart('01110'), 32);
    let omitted_source = ExecuteCommandInstruction(
        SharedByteStrideSource(Zeros{8} + 7, '0001'), 32);
    assert omitted_start == CommandExecution_Executed;
    assert omitted_source == CommandExecution_Executed;
    let omitted_completed = ExecuteBundleTileOperation();
    assert omitted_completed;
    AssertSharedByteStrideStore(Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 16);
    return 0;
end;
