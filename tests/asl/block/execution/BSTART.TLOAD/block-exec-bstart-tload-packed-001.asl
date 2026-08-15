// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-PACKED-001","source":"asl/block/execution/BSTART.TLOAD.asl","requirements":["PTO-INST-BLOCK-BSTART-TLOAD","PTO-INST-TILE-TLOAD"],"kind":"execution","summary":"Packed U4X2 TLOAD applies stride in logical elements before nibble selection.","pass_condition":"Two strided rows load low and high nibbles from the expected containing bytes.","related_sources":["asl/tile/model/memory/addressing.asl","asl/tile/model/memory/load-store.asl"]}
pure func TLoadPackedStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 28;
    return instruction;
end;

pure func TLoadPackedDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[11:9] = '001';
    instruction[18:15] = '1111';
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
    _Memory[[0x302]] = Zeros{8} + 0x43;
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
    return 0;
end;
