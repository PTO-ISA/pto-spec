// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMOV-ZERO-001","source":"asl/block/execution/BSTART.TMOV.asl","requirements":["PTO-INST-BLOCK-BSTART-TMOV"],"kind":"boundary","summary":"a zero participation mask suppresses TMOV schema and state effects","pass_condition":"zero-mask Local and Shared binders complete without source reads, allocation, publication, or faults","related_sources":["asl/block/model/dispatch/tile-execution.asl"]}
pure func TMOVZeroStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00211181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func TMOVZeroLocal() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + 63;
    instruction[19] = '1';
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '000';
    return instruction;
end;

pure func TMOVZeroShared() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 63;
    instruction[18:15] = '0001';
    instruction[11:9] = '000';
    return instruction;
end;

func TMOVZeroExecute(instruction: bits(64))
begin
    let status = ExecuteCommandInstruction(instruction, 32);
    assert status == CommandExecution_Executed;
end;

func main() => integer
begin
    ResetProfileState();
    TMOVZeroExecute(TMOVZeroStart());
    TMOVZeroExecute(TMOVZeroLocal());
    TMOVZeroExecute(TMOVZeroShared());
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    assert BundleTileBindingCount() == 0;
    assert BundleSharedBindingCount() == 0;
    assert !SharedTileRecord((Zeros{6} + 63) as SharedTileID).descriptor_valid;
    return 0;
end;
