// PTO-TEST: {"id":"PTO-AVS-BLOCK-MGATHER-CAS-ZERO-001","source":"asl/block/execution/BSTART.MGATHER.CAS.asl","requirements":["PTO-BSTART-MGATHER-CAS-SCHEMA-001"],"kind":"boundary","summary":"MGATHER.CAS PE_MASK zero is a strict no-op.","pass_condition":"Zero-mask B.IOT commands complete successfully despite absent sources, dimensions, and B.IOR and create no allocation, event, memory, or fault effect.","related_sources":["asl/block/model/dispatch/tlsu-mgather-cas.asl","asl/block/model/operands/tile-bindings.asl"]}
pure func ZeroCasStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00811181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func ZeroCasInputs() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[25:20] = Zeros{6} + 63;
    instruction[31:26] = Zeros{6} + 63;
    instruction[18:15] = '0000';
    return instruction;
end;

pure func ZeroCasOutput() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + 63;
    instruction[19] = '1';
    instruction[18:15] = '0000';
    instruction[11:9] = '111';
    instruction[8:7] = '11';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(ZeroCasStart(), 32);
    assert started == CommandExecution_Executed;
    let inputs = ExecuteCommandInstruction(ZeroCasInputs(), 32);
    assert inputs == CommandExecution_Executed;
    let output = ExecuteCommandInstruction(ZeroCasOutput(), 32);
    assert output == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    assert BundleTileBindingCount() == 0;
    assert _MemoryEventCount == 0;
    assert CoreTileCapacityInUse() == 0;
    StopMemoryEventCapture();
    return 0;
end;
