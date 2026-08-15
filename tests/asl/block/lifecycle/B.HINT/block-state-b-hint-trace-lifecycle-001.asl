// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-HINT-TRACE-LIFECYCLE-001","source":"asl/block/lifecycle/B.HINT.asl","requirements":["PTO-INST-BLOCK-B-HINT"],"kind":"state-transition","summary":"B.HINT TRACE starts an empty block and does not terminate it.","pass_condition":"TRACE.begin opens an active empty block with sequential header PC, and BSTOP later terminates it.","related_sources":["asl/block/model/lifecycle/begin.asl","asl/block/model/dispatch/commands.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    let traced = ExecuteCommandInstruction(Zeros{64} + 0x00001033, 32);
    assert traced == CommandExecution_Executed;
    assert _BundleActive;
    assert !_BundleBodyActive;
    assert _BundleHint.present;
    assert _BundleHint.trace;
    assert !_BundleHint.trace_end;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x304;

    let stopped = ExecuteCommandInstruction(Zeros{64} + 0x00000001, 32);
    assert stopped == CommandExecution_Executed;
    assert !_BundleActive;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x308;
    return 0;
end;
