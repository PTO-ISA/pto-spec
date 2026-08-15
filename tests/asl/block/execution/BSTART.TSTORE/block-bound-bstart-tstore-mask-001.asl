// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSTORE-MASK-001","source":"asl/block/execution/BSTART.TSTORE.asl","requirements":["PTO-INST-BLOCK-BSTART-TSTORE"],"kind":"boundary","summary":"Function 1 rejects partial Shared masks while Function 14 accepts them","pass_condition":"the full form faults before GM effects and the SPART form completes for the same partial mask","related_sources":["asl/block/model/dispatch/shared-tlsu.asl"]}
pure func TStoreMaskStart(function: bits(5), data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = function;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func TStoreMaskShared(shared_id: bits(8), pe_mask: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = pe_mask;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    _Memory[[0]] = Zeros{8} + 0x55;
    let full_start = ExecuteCommandInstruction(
        TStoreMaskStart('00001', Zeros{5} + 24), 32);
    let full_source = ExecuteCommandInstruction(
        TStoreMaskShared(Zeros{8} + 7, '0001'), 32);
    assert full_start == CommandExecution_Executed;
    assert full_source == CommandExecution_Executed;
    let full_completed = ExecuteBundleTileOperation();
    assert !full_completed;
    assert _LastFault == Fault_TileLegality;
    assert _Memory[[0]] == Zeros{8} + 0x55;

    ResetProfileState();
    let partial_start = ExecuteCommandInstruction(
        TStoreMaskStart('01110', Zeros{5} + 24), 32);
    let partial_source = ExecuteCommandInstruction(
        TStoreMaskShared(Zeros{8} + 7, '0001'), 32);
    assert partial_start == CommandExecution_Executed;
    assert partial_source == CommandExecution_Executed;
    let partial_completed = ExecuteBundleTileOperation();
    assert partial_completed;
    assert _LastFault == Fault_None;
    assert _Memory[[0]] == UndefinedSharedTileWord(Zeros{8} + 7, 0)[7:0];
    assert !SharedTileRecord(Zeros{8} + 7).descriptor_valid;
    return 0;
end;
