// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-HINT-TRACE-PREDECESSOR-SEQUENTIAL-003","source":"asl/block/lifecycle/B.HINT.asl","requirements":["PTO-B-HINT-LIFECYCLE-001"],"kind":"state-transition","summary":"B.HINT TRACE opens when the predecessor selects the fetched trace boundary.","pass_condition":"Fallthrough and untaken conditional predecessors install the TRACE.end empty block and record its hint state.","related_sources":["asl/block/model/dispatch/commands.asl","asl/block/model/lifecycle/begin.asl"]}
func main() => integer
begin
    ResetProfileState();
    BeginBundleAt(
        Zeros{PTO_XLEN} + 0x100,
        BundleKind_Standard,
        BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN} + 0x104,
        Zeros{PTO_XLEN} + 0x104,
        Zeros{PTO_XLEN},
        TRUE);
    let after_fallthrough = ExecuteCommandInstruction(
        Zeros{64} + 0x00009033, 32);
    assert after_fallthrough == CommandExecution_Executed;
    assert BundleIsActive();
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x104;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x108;
    assert _BundleHint.present;
    assert _BundleHint.trace;
    assert _BundleHint.trace_end;
    assert _BundleHintEpoch == 1;

    ResetProfileState();
    BeginBundleAt(
        Zeros{PTO_XLEN} + 0x200,
        BundleKind_Standard,
        BundleTransfer_Conditional,
        Zeros{PTO_XLEN} + 0x180,
        Zeros{PTO_XLEN} + 0x204,
        Zeros{PTO_XLEN},
        FALSE);
    let after_untaken = ExecuteCommandInstruction(
        Zeros{64} + 0x00009033, 32);
    assert after_untaken == CommandExecution_Executed;
    assert BundleIsActive();
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x204;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x208;
    assert _BundleHint.trace_end;
    return 0;
end;
