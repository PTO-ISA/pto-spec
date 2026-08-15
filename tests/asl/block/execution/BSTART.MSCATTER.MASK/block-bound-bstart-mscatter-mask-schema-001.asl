// PTO-TEST: {"id":"PTO-AVS-BLOCK-MSCATTER-MASK-SCHEMA-001","source":"asl/block/execution/BSTART.MSCATTER.MASK.asl","requirements":["PTO-BSTART-MSCATTER-MASK-SCHEMA-001"],"kind":"boundary","summary":"MSCATTER.MASK rejects incomplete source streams and missing scalar input before effects.","pass_condition":"A non-terminating two-record source stream without B.IOR raises TileLegality and emits no event.","related_sources":["asl/block/model/dispatch/tlsu-mscatter-mask.asl"]}
func main() => integer
begin
    ResetProfileState();
    var start: bits(64) = Zeros{64} + 0x00711181;
    start[31:27] = Zeros{5} + 27;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(FALSE, 0, 0, '0001', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(FALSE, 0, 0, '0001', TRUE, FALSE, 3, 0, FALSE);
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    return 0;
end;
