// PTO-TEST: {"id":"PTO-AVS-BLOCK-TGPR2T-ZERO-MASK-002","source":"asl/block/model/dispatch/commands.asl","requirements":["PTO-TGPR2T-CONTRACT-001","PTO-BLOCK-MODEL-DISPATCH-TGPR2T-SCHEMA-001"],"kind":"execution","summary":"TGPR2T zero participation precedes carrier ordering and completeness checks","pass_condition":"a zero-mask destination B.IOT remains a strict no-op with missing, partial, or complete 3+1 B.IOR state through decoded BSTOP and next-BSTART completion boundaries","related_sources":["asl/block/model/dispatch/tgpr2t-schema.asl","asl/block/model/dispatch/tile-execution.asl"]}
pure func TGPR2TZeroStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = Zeros{2} + 3;
    instruction[24:20] = Zeros{5} + 30;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func TGPR2TZeroSources(
    source0: bits(5), source1: bits(5), source2: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = source0;
    instruction[24:20] = source1;
    instruction[31:27] = source2;
    return instruction;
end;

pure func TGPR2TZeroLastSource(source0: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = source0;
    return instruction;
end;

pure func TGPR2TZeroDestination() => bits(64)
begin
    var instruction = Zeros{64} + 0x00006013;
    instruction[18:15] = Zeros{4} + 1;
    instruction[11:9] = '000';
    instruction[19] = '1';
    return instruction;
end;

func CompleteTGPR2TZeroMask() => boolean
begin
    let destination = ExecuteCommandInstruction(TGPR2TZeroDestination(), 32);
    assert destination == CommandExecution_Executed;
    let completed = ExecuteCommandInstruction(Zeros{64} + 1, 32);
    assert completed == CommandExecution_Executed &&
           _LastFault == Fault_None;
    assert BundleTileBindingCount() == 0;
    assert TileCapacityInUse() == 0;
    return completed == CommandExecution_Executed;
end;

func main() => integer
begin
    ResetProfileState();
    let missing_start = ExecuteCommandInstruction(TGPR2TZeroStart(), 32);
    assert missing_start == CommandExecution_Executed;
    let missing_completed = CompleteTGPR2TZeroMask();
    assert missing_completed;

    ResetProfileState();
    let partial_start = ExecuteCommandInstruction(TGPR2TZeroStart(), 32);
    let partial = ExecuteCommandInstruction(TGPR2TZeroSources(
        Zeros{5} + 2, Zeros{5} + 3, Zeros{5} + 4), 32);
    assert partial_start == CommandExecution_Executed;
    assert partial == CommandExecution_Executed;
    let partial_destination = ExecuteCommandInstruction(
        TGPR2TZeroDestination(), 32);
    assert partial_destination == CommandExecution_Executed;
    let next_start = ExecuteCommandInstruction(TGPR2TZeroStart(), 32);
    assert next_start == CommandExecution_Executed &&
           _LastFault == Fault_None;
    assert BundleTileBindingCount() == 0;
    assert TileCapacityInUse() == 0;

    ResetProfileState();
    let complete_start = ExecuteCommandInstruction(TGPR2TZeroStart(), 32);
    let first = ExecuteCommandInstruction(TGPR2TZeroSources(
        Zeros{5} + 2, Zeros{5} + 3, Zeros{5} + 4), 32);
    let second = ExecuteCommandInstruction(
        TGPR2TZeroLastSource(Zeros{5} + 5), 32);
    assert complete_start == CommandExecution_Executed;
    assert first == CommandExecution_Executed;
    assert second == CommandExecution_Executed;
    let complete_completed = CompleteTGPR2TZeroMask();
    assert complete_completed;
    return 0;
end;
