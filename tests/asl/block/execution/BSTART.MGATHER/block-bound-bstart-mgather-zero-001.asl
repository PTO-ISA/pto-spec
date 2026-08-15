// PTO-TEST: {"id":"PTO-AVS-BLOCK-MGATHER-ZERO-001","source":"asl/block/execution/BSTART.MGATHER.asl","requirements":["PTO-BSTART-MGATHER-SCHEMA-001"],"kind":"boundary","summary":"MGATHER honors B.IOT PE_MASK zero before every downstream check.","pass_condition":"A zero-mask binding succeeds despite missing B.IOR, dimensions, and source Tile and creates no allocation, event, or fault.","related_sources":["asl/block/model/dispatch/tlsu-mgather.asl"]}
pure func ZeroGatherStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00411181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func ZeroGatherBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Ones{6};
    instruction[19] = '1';
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '001';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(ZeroGatherStart(), 32);
    assert started == CommandExecution_Executed;
    let tiles = ExecuteCommandInstruction(ZeroGatherBinding(), 32);
    assert tiles == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 0;
    assert CoreTileCapacityInUse() == 0;
    StopMemoryEventCapture();
    return 0;
end;
