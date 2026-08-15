// PTO-TEST: {"id":"PTO-AVS-BLOCK-MSCATTER-ZERO-001","source":"asl/block/execution/BSTART.MSCATTER.asl","requirements":["PTO-BSTART-MSCATTER-SCHEMA-001"],"kind":"boundary","summary":"MSCATTER honors PE_MASK zero before all schema and source checks.","pass_condition":"A zero-mask source binding succeeds with absent sources, B.IOR, and dimensions and creates no event, write, or fault.","related_sources":["asl/block/model/dispatch/tlsu-mscatter.asl"]}
func main() => integer
begin
    ResetProfileState();
    var start: bits(64) = Zeros{64} + 0x00511181;
    start[31:27] = Zeros{5} + 27;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    AddBundleTileBinding(FALSE, 0, 0, '0000', TRUE, TRUE, 62, 63, TRUE);
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 0;
    assert CoreTileCapacityInUse() == 0;
    StopMemoryEventCapture();
    return 0;
end;
