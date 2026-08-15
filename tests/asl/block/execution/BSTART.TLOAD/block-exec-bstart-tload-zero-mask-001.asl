// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-ZERO-MASK-001","source":"asl/block/execution/BSTART.TLOAD.asl","requirements":["PTO-INST-BLOCK-BSTART-TLOAD","PTO-INST-TILE-TLOAD"],"kind":"execution","summary":"A zero PE mask makes TLOAD a strict no-op.","pass_condition":"No GPR, allocation, memory, event, descriptor, payload, or fault effect occurs.","related_sources":["asl/block/model/dispatch/tile-execution.asl"]}
pure func TLoadZeroMaskStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func TLoadZeroMaskDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = Zeros{4};
    instruction[19] = '1';
    instruction[11:9] = '001';
    return instruction;
end;

pure func TLoadZeroMaskShared(shared_id: bits(8)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '001';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let capacity_before = CoreTileCapacityInUse();
    let local_start_status = ExecuteCommandInstruction(
        TLoadZeroMaskStart(), 32);
    assert local_start_status == CommandExecution_Executed;
    let local_destination_status = ExecuteCommandInstruction(
        TLoadZeroMaskDestination(), 32);
    assert local_destination_status == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let local_completed = ExecuteBundleTileOperation();
    assert local_completed;
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 0;
    assert CoreTileCapacityInUse() == capacity_before;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    StopMemoryEventCapture();

    ResetProfileState();
    let shared_id = Zeros{8} + 77;
    let shared_start_status = ExecuteCommandInstruction(
        TLoadZeroMaskStart(), 32);
    assert shared_start_status == CommandExecution_Executed;
    let shared_destination_status = ExecuteCommandInstruction(
        TLoadZeroMaskShared(shared_id), 32);
    assert shared_destination_status == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let shared_completed = ExecuteBundleTileOperation();
    assert shared_completed;
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 0;
    assert !SharedTileRecord(shared_id).descriptor_valid;
    StopMemoryEventCapture();
    return 0;
end;
