// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-COND-SETC-001","source":"asl/block/lifecycle/BSTART.asl","requirements":["PTO-INST-BLOCK-BSTART"],"kind":"state-transition","summary":"SETC updates a conditional block's deferred commit decision.","pass_condition":"BSTART COND initializes TAKEN false and a later true SETC makes commit select BPCN.","related_sources":["asl/scalar/model/bru/semantics.asl","asl/block/model/lifecycle/enter-stop.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    var conditional = Zeros{64} + 0x00000021;
    conditional[31:7] = Zeros{25} + 4;
    let status = ExecuteCommandInstruction(conditional, 32);
    assert status == CommandExecution_Executed;
    ExecuteSetCommit(ScalarCondition_EQ,
        Zeros{PTO_XLEN} + 1, Zeros{PTO_XLEN} + 1);
    let committed = CompleteBundleAt(Zeros{PTO_XLEN} + 0x280);
    assert committed;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x208;
    return 0;
end;
