// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSTORE-MASK-001","source":"asl/block/execution/BSTART.TSTORE.asl","requirements":["PTO-INST-BLOCK-BSTART-TSTORE"],"kind":"boundary","summary":"Decoded Function 1 accepts every nonzero Shared consumer mask and zero remains a strict no-op","pass_condition":"a full nonzero mask and a sparse nonzero mask complete without mask-legality faults; an unready Shared source performs no GM effect before payload access","related_sources":["asl/block/model/dispatch/shared-tlsu.asl"]}
pure func TStoreMaskStart(function: bits(5), data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = function;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func TStoreMaskShared(shared_tile_id: bits(6), pe_mode: bits(3)) => bits(64)
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
    _Memory[[0]] = Zeros{8} + 0x55;
    let full_start = ExecuteCommandInstruction(
        TStoreMaskStart('00001', Zeros{5} + 24), 32);
    let full_source = ExecuteCommandInstruction(
        TStoreMaskShared(Zeros{6} + 7, '111'), 32);
    assert full_start == CommandExecution_Executed;
    assert full_source == CommandExecution_Executed;
    let full_completed = ExecuteBundleTileOperation();
    assert full_completed;
    assert _LastFault == Fault_None;
    assert _Memory[[0]] ==
        UndefinedSharedTileWord((Zeros{6} + 7) as SharedTileID, 0)[7:0];

    ResetProfileState();
    _Memory[[0]] = Zeros{8} + 0x55;
    let sparse_start = ExecuteCommandInstruction(
        TStoreMaskStart('00001', Zeros{5} + 24), 32);
    let sparse_source = ExecuteCommandInstruction(
        TStoreMaskShared(Zeros{6} + 7, '001'), 32);
    assert sparse_start == CommandExecution_Executed;
    assert sparse_source == CommandExecution_Executed;
    let sparse_completed = ExecuteBundleTileOperation();
    assert sparse_completed;
    assert _LastFault == Fault_None;
    assert _Memory[[0]] == Zeros{8} + 0x55;
    assert !SharedTileRecord((Zeros{6} + 7) as SharedTileID).descriptor_valid;
    return 0;
end;
