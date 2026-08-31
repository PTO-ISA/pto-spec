// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-HINT-TRACE-PREDECESSOR-TAKEN-002","source":"asl/block/lifecycle/B.HINT.asl","requirements":["PTO-B-HINT-LIFECYCLE-001"],"kind":"state-transition","summary":"B.HINT TRACE preserves a non-sequential predecessor-selected continuation.","pass_condition":"Taken conditional, direct, and return predecessors skip sequential TRACE without changing hint payload or epoch.","related_sources":["asl/block/model/dispatch/commands.asl","asl/block/model/commit/validation.asl"]}
func main() => integer
begin
    ResetProfileState();
    BeginBundleAt(
        Zeros{PTO_XLEN} + 0x100,
        BundleKind_Standard,
        BundleTransfer_Conditional,
        Zeros{PTO_XLEN} + 0x80,
        Zeros{PTO_XLEN} + 0x104,
        Zeros{PTO_XLEN},
        FALSE);
    EnterBundleBody();
    ExecuteSetCommit(ScalarCondition_EQ, Zeros{PTO_XLEN}, Zeros{PTO_XLEN});
    _LastBundleHintPayload = Zeros{PTO_XLEN} + 0xa5;
    _BundleHintEpoch = 7;
    let after_conditional = ExecuteCommandInstruction(
        Zeros{64} + 0x00009033, 32);
    assert after_conditional == CommandExecution_Executed;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x80;
    assert !BundleIsActive();
    assert _LastBundleHintPayload == Zeros{PTO_XLEN} + 0xa5;
    assert _BundleHintEpoch == 7;

    ResetProfileState();
    BeginBundleAt(
        Zeros{PTO_XLEN} + 0x200,
        BundleKind_Standard,
        BundleTransfer_Direct,
        Zeros{PTO_XLEN} + 0x180,
        Zeros{PTO_XLEN} + 0x204,
        Zeros{PTO_XLEN},
        TRUE);
    let after_direct = ExecuteCommandInstruction(
        Zeros{64} + 0x00009033, 32);
    assert after_direct == CommandExecution_Executed;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x180;
    assert !BundleIsActive();

    ResetProfileState();
    BeginBundleAt(
        Zeros{PTO_XLEN} + 0x300,
        BundleKind_Standard,
        BundleTransfer_Return,
        Zeros{PTO_XLEN} + 0x280,
        Zeros{PTO_XLEN} + 0x304,
        Zeros{PTO_XLEN},
        TRUE);
    let after_return = ExecuteCommandInstruction(
        Zeros{64} + 0x00009033, 32);
    assert after_return == CommandExecution_Executed;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x280;
    assert !BundleIsActive();
    return 0;
end;
