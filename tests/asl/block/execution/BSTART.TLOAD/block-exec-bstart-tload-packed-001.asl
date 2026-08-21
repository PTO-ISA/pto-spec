// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-PACKED-001","source":"asl/block/execution/BSTART.TLOAD.asl","requirements":["PTO-INST-BLOCK-BSTART-TLOAD","PTO-INST-TILE-TLOAD"],"kind":"execution","summary":"Packed U4X2 TLOAD applies a byte row stride before column-based nibble selection.","pass_condition":"Two byte-strided rows load low and high nibbles from the expected containing bytes.","related_sources":["asl/tile/model/memory/addressing.asl","asl/tile/model/memory/load-store.asl"]}
pure func TLoadPackedStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 28;
    return instruction;
end;

pure func TLoadPackedDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = '0001';
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

pure func TLoadPackedIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    _Memory[[0x300]] = Zeros{8} + 0x21;
    _Memory[[0x304]] = Zeros{8} + 0x43;
    WriteGPR(2, Zeros{PTO_XLEN} + 0x300);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    let start_status = ExecuteCommandInstruction(TLoadPackedStart(), 32);
    assert start_status == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    let destination_status = ExecuteCommandInstruction(
        TLoadPackedDestination(), 32);
    assert destination_status == CommandExecution_Executed;
    let ior_status = ExecuteCommandInstruction(TLoadPackedIOR(), 32);
    assert ior_status == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed;
    let tile = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(tile, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(tile, 0, 1) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(tile, 1, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(tile, 1, 1) == Zeros{PTO_XLEN} + 4;

    // With one packed column and no B.IOR/LB2, the dense default is one byte.
    // Each row starts at a new low nibble rather than sharing a byte boundary.
    ResetProfileState();
    _Memory[[0]] = Zeros{8} + 0xa1;
    _Memory[[1]] = Zeros{8} + 0xb2;
    let omitted_start = ExecuteCommandInstruction(TLoadPackedStart(), 32);
    assert omitted_start == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    let omitted_destination = ExecuteCommandInstruction(
        TLoadPackedDestination(), 32);
    assert omitted_destination == CommandExecution_Executed;
    let omitted_completed = ExecuteBundleTileOperation();
    assert omitted_completed;
    let omitted_tile = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(omitted_tile, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(omitted_tile, 1, 0) == Zeros{PTO_XLEN} + 2;
    return 0;
end;
