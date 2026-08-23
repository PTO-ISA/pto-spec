// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-SHARED-001","source":"asl/block/execution/BSTART.TLOAD.asl","requirements":["PTO-INST-BLOCK-BSTART-TLOAD","PTO-INST-TILE-TLOAD"],"kind":"execution","summary":"Shared TLOAD uses the selected PE-private base and byte-stride GPRs and updates only selected quarters.","pass_condition":"Mask 0011 loads quarters zero and one from PE0 and PE1 while the other Shared quarters remain uninitialized.","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/tile/model/memory/shared-movement.asl"]}
pure func TLoadSharedStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 25;
    return instruction;
end;

pure func TLoadSharedDestination(shared_tile_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_tile_id;
    instruction[18:15] = '0011';
    instruction[11:9] = '101';
    return instruction;
end;

pure func TLoadSharedIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let shared_tile_id = (Zeros{6} + 31) as SharedTileID;
    WritePEGPR(0, 2, Zeros{PTO_XLEN});
    WritePEGPR(1, 2, Zeros{PTO_XLEN} + 0x200);
    WritePEGPR(0, 3, Zeros{PTO_XLEN} + 128);
    WritePEGPR(1, 3, Zeros{PTO_XLEN} + 160);
    _Memory[[0]] = Zeros{8} + 0x11;
    _Memory[[0x2a0]] = Zeros{8} + 0x22;

    let start_status = ExecuteCommandInstruction(TLoadSharedStart(), 32);
    assert start_status == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 32);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 32);
    let destination_status = ExecuteCommandInstruction(
        TLoadSharedDestination(shared_tile_id), 32);
    assert destination_status == CommandExecution_Executed;
    let ior_status = ExecuteCommandInstruction(TLoadSharedIOR(), 32);
    assert ior_status == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed;

    let shared = SharedTileRecord(shared_tile_id);
    assert shared.descriptor_valid;
    assert shared.allocation_mask == '1100';
    assert shared.initialized_mask == '1100';
    assert ReadSharedTileWord(shared_tile_id, 0) == Zeros{PTO_XLEN} + 0x11;
    assert ReadSharedTileWord(shared_tile_id, 32 as PackedTileElementIndex) ==
        Zeros{PTO_XLEN} + 0x22;
    assert ReadSharedTileWord(shared_tile_id, 64 as PackedTileElementIndex) ==
        UndefinedSharedTileWord(shared_tile_id, 64 as PackedTileElementIndex);
    return 0;
end;
