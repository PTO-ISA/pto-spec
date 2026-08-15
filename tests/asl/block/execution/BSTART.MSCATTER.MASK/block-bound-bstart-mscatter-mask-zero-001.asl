// PTO-TEST: {"id":"PTO-AVS-BLOCK-MSCATTER-MASK-ZERO-001","source":"asl/block/execution/BSTART.MSCATTER.MASK.asl","requirements":["PTO-BSTART-MSCATTER-MASK-SCHEMA-001"],"kind":"boundary","summary":"MSCATTER.MASK honors PE_MASK zero before all schema and predicate checks.","pass_condition":"Two zero-mask records succeed with absent sources, dimensions, and B.IOR and create no event, write, or fault.","related_sources":["asl/block/model/dispatch/tlsu-mscatter-mask.asl"]}
func main() => integer
begin
    ResetProfileState();
    var start: bits(64) = Zeros{64} + 0x00711181;
    start[31:27] = Zeros{5} + 27;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    AddBundleTileBinding(FALSE, 0, 0, '0000', TRUE, TRUE, 60, 61, FALSE);
    AddBundleTileBinding(FALSE, 0, 0, '0000', TRUE, FALSE, 62, 0, TRUE);
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 0;
    assert CoreTileCapacityInUse() == 0;
    StopMemoryEventCapture();
    return 0;
end;
