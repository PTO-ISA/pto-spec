// PTO-TEST: {"id":"PTO-AVS-BLOCK-GMOV-ZERO-001","source":"asl/block/execution/BSTART.GMOV.asl","requirements":["PTO-BSTART-GMOV-COLLECTIVE-001"],"kind":"boundary","summary":"GMOV PE_MASK zero is a strict no-op before source access, readiness, peer validation, allocation, or events.","pass_condition":"A zero-mask binding with an invalid source selector and peer values completes without fault or state effects.","related_sources":["asl/block/model/dispatch/tile-execution.asl"]}
pure func GMOVZeroStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00d11181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func GMOVZeroBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = '111';
    instruction[18:15] = Zeros{4};
    instruction[19] = '1';
    instruction[25:20] = Ones{6};
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    for pe = 0 to 3 do
        WritePEGPR(pe as MemoryAgentId, 2, Ones{PTO_XLEN});
    end;
    let started = ExecuteCommandInstruction(GMOVZeroStart(), 32);
    let zero = ExecuteCommandInstruction(GMOVZeroBinding(), 32);
    assert started == CommandExecution_Executed;
    assert zero == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    assert CoreTileCapacityInUse() == 0;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    return 0;
end;
