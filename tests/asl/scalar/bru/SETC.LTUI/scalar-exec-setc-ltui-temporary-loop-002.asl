// PTO-TEST: {"id":"PTO-AVS-BRU-SETC-LTUI-TEMPORARY-LOOP-002","source":"asl/scalar/bru/SETC.LTUI.asl","requirements":["PTO-INST-SCALAR-SETC-LTUI"],"kind":"execution","summary":"SETC.LTUI consumes a T#1 source and selects a backward conditional block target.","pass_condition":"The decoded T#1 comparison sets BARG.TAKEN and the following BSTART commits to the loop target.","related_sources":["asl/block/model/dispatch/start.asl","asl/scalar/model/types/operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    BeginBundleAt(
        Zeros{PTO_XLEN} + 0x100,
        BundleKind_Standard,
        BundleTransfer_Conditional,
        Zeros{PTO_XLEN} + 0x100,
        Zeros{PTO_XLEN} + 0x120,
        Zeros{PTO_XLEN},
        FALSE);
    EnterBundleBody();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN});

    let condition = ExecuteScalarInstruction(
        Zeros{48} + 0x3ffc6075, 32);
    assert condition == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert _CommitArgument == Zeros{PTO_XLEN} + 1;
    assert _BARG.taken;

    let boundary = ExecuteCommandInstruction(Zeros{64} + 0x3800, 16);
    assert boundary == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x100;
    assert !BundleIsActive();
    return 0;
end;
