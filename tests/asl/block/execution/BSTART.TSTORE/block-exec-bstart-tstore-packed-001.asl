// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSTORE-PACKED-001","source":"asl/block/execution/BSTART.TSTORE.asl","requirements":["PTO-INST-BLOCK-BSTART-TSTORE","PTO-INST-TILE-TSTORE"],"kind":"execution","summary":"Packed U4X2 TSTORE applies a byte row stride before column-based nibble selection.","pass_condition":"Two byte-strided rows update the expected low and high nibbles without changing skipped bytes.","related_sources":["asl/tile/model/memory/addressing.asl","asl/tile/model/memory/load-store.asl"]}
pure func TStorePackedStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 28;
    return instruction;
end;

pure func TStorePackedSource(tile: TileIndex) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + tile;
    instruction[18:15] = '0000';
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

pure func TStorePackedIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 4, 2, 2, 2, TileDataType_U4X2,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN} + 4);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x320);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    let start_status = ExecuteCommandInstruction(TStorePackedStart(), 32);
    assert start_status == CommandExecution_Executed;
    let source_status = ExecuteCommandInstruction(TStorePackedSource(0), 32);
    assert source_status == CommandExecution_Executed;
    let ior_status = ExecuteCommandInstruction(TStorePackedIOR(), 32);
    assert ior_status == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _Memory[[0x320]] == Zeros{8} + 0x21;
    assert _Memory[[0x324]] == Zeros{8} + 0x43;

    // One packed column has a one-byte dense pitch. Omitted B.IOR/LB2 must
    // place row one in the next byte and preserve both sibling high nibbles.
    ResetProfileState();
    ConfigureTile(0, 128, 2, 1, 2, 1, TileDataType_U4X2,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 7);
    _Memory[[0]] = Zeros{8} + 0xa0;
    _Memory[[1]] = Zeros{8} + 0xb0;
    let omitted_start = ExecuteCommandInstruction(TStorePackedStart(), 32);
    assert omitted_start == CommandExecution_Executed;
    let omitted_source = ExecuteCommandInstruction(TStorePackedSource(0), 32);
    assert omitted_source == CommandExecution_Executed;
    let omitted_completed = ExecuteBundleTileOperation();
    assert omitted_completed;
    assert _Memory[[0]] == Zeros{8} + 0xa5;
    assert _Memory[[1]] == Zeros{8} + 0xb7;
    return 0;
end;
