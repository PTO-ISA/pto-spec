// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSTORE-UNDEF-001","source":"asl/block/execution/BSTART.TSTORE.asl","requirements":["PTO-INST-BLOCK-BSTART-TSTORE"],"kind":"execution","summary":"an unallocated Shared source uses a minimum-capacity temporary descriptor without allocating Sx","pass_condition":"the undefined-register value reaches GM and the Shared descriptor remains absent","related_sources":["asl/tile/model/state/shared-registers.asl","asl/tile/model/memory/shared-movement.asl"]}
pure func TStoreUndefinedStart(function: bits(5), data_type: bits(5))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = function;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func TStoreUndefinedShared(shared_tile_id: bits(6), pe_mode: bits(3))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_tile_id;
    instruction[18:15] = '0000';
    instruction[11:9] = pe_mode;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let shared_tile_id = (Zeros{6} + 42) as SharedTileID;
    assert MinimumTileCapacityBytesForShape(
        1, 1, 1, TileDataType_U8) == 128;
    assert !SharedTileRecord(shared_tile_id).descriptor_valid;
    let start = ExecuteCommandInstruction(
        TStoreUndefinedStart('00001', Zeros{5} + 24), 32);
    let source = ExecuteCommandInstruction(
        TStoreUndefinedShared(shared_tile_id, '111'), 32);
    assert start == CommandExecution_Executed;
    assert source == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    assert _Memory[[0]] == UndefinedSharedTileWord(shared_tile_id, 0)[7:0];
    assert !SharedTileRecord(shared_tile_id).descriptor_valid;
    assert _BundleSharedBindings[[0]].consumed;
    return 0;
end;
