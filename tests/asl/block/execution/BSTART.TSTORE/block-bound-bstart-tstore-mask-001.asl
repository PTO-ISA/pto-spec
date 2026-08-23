// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSTORE-MASK-001","source":"asl/block/execution/BSTART.TSTORE.asl","requirements":["PTO-INST-BLOCK-BSTART-TSTORE"],"kind":"boundary","summary":"Decoded Function 1 accepts all-PE Shared TSTORE, rejects partial masks, and Function 14 accepts them","pass_condition":"Function 1 mode111 writes the undefined Shared value, Function 1 mode001 faults before GM effects, and Function 14 mode001 completes","related_sources":["asl/block/model/dispatch/shared-tlsu.asl"]}
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
    let rejected_start = ExecuteCommandInstruction(
        TStoreMaskStart('00001', Zeros{5} + 24), 32);
    let rejected_source = ExecuteCommandInstruction(
        TStoreMaskShared(Zeros{6} + 7, '001'), 32);
    assert rejected_start == CommandExecution_Executed;
    assert rejected_source == CommandExecution_Executed;
    let rejected_completed = ExecuteBundleTileOperation();
    assert !rejected_completed;
    assert _LastFault == Fault_TileLegality;
    assert _Memory[[0]] == Zeros{8} + 0x55;

    ResetProfileState();
    let partial_start = ExecuteCommandInstruction(
        TStoreMaskStart('01110', Zeros{5} + 24), 32);
    let partial_source = ExecuteCommandInstruction(
        TStoreMaskShared(Zeros{6} + 7, '001'), 32);
    assert partial_start == CommandExecution_Executed;
    assert partial_source == CommandExecution_Executed;
    let partial_completed = ExecuteBundleTileOperation();
    assert partial_completed;
    assert _LastFault == Fault_None;
    assert _Memory[[0]] ==
        UndefinedSharedTileWord((Zeros{6} + 7) as SharedTileID, 0)[7:0];
    assert !SharedTileRecord((Zeros{6} + 7) as SharedTileID).descriptor_valid;
    return 0;
end;
