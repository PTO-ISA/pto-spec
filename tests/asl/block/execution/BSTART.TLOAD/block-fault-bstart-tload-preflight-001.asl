// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-PREFLIGHT-001","source":"asl/block/execution/BSTART.TLOAD.asl","requirements":["PTO-INST-BLOCK-BSTART-TLOAD","PTO-INST-TILE-TLOAD"],"kind":"fault","summary":"TLOAD preflights the complete footprint before publishing its destination.","pass_condition":"A fault on the second element records no load event and rolls back the new Local destination allocation.","related_sources":["asl/tile/model/memory/load-store.asl","asl/block/model/dispatch/destination-shape.asl"]}
pure func TLoadFaultStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func TLoadFaultDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[11:9] = '001';
    instruction[18:15] = '0001';
    instruction[19] = '1';
    return instruction;
end;

pure func TLoadFaultIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    Store(Zeros{PTO_XLEN} + 4088, 8, Zeros{PTO_XLEN} + 0xaa);
    WriteGPR(2, Zeros{PTO_XLEN} + 4088);
    WriteGPR(3, Zeros{PTO_XLEN} + 2);
    let start_status = ExecuteCommandInstruction(TLoadFaultStart(), 32);
    assert start_status == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    let destination_status = ExecuteCommandInstruction(
        TLoadFaultDestination(), 32);
    assert destination_status == CommandExecution_Executed;
    let ior_status = ExecuteCommandInstruction(TLoadFaultIOR(), 32);
    assert ior_status == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 0;
    assert CoreTileCapacityInUse() == 0;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    StopMemoryEventCapture();
    return 0;
end;
