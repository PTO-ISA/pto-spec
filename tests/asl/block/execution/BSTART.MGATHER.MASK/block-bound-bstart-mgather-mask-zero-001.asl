// PTO-TEST: {"id":"PTO-AVS-BLOCK-MGATHER-MASK-ZERO-001","source":"asl/block/execution/BSTART.MGATHER.MASK.asl","requirements":["PTO-BSTART-MGATHER-MASK-SCHEMA-001"],"kind":"boundary","summary":"MGATHER.MASK PE_MASK zero is a strict no-op.","pass_condition":"A zero-mask B.IOT completes successfully despite absent sources, dimensions, and B.IOR and creates no allocation, event, memory, or fault effect.","related_sources":["asl/block/model/dispatch/tlsu-mgather-mask.asl","asl/block/model/operands/tile-bindings.asl"]}
pure func ZeroMaskGatherStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00611181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func ZeroMaskGatherBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[25:20] = Zeros{6} + 63;
    instruction[31:26] = Zeros{6} + 63;
    instruction[19] = '1';
    instruction[18:15] = '0000';
    instruction[11:9] = '000';
    instruction[8:7] = '11';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(ZeroMaskGatherStart(), 32);
    assert started == CommandExecution_Executed;
    let bound = ExecuteCommandInstruction(ZeroMaskGatherBinding(), 32);
    assert bound == CommandExecution_Executed;
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
