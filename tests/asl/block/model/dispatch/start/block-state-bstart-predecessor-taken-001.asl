// PTO-TEST: {"id":"PTO-AVS-BSTART-PREDECESSOR-TAKEN-001","source":"asl/block/model/dispatch/start.asl","requirements":["PTO-REQ-BSTART-PREDECESSOR-TRANSFER-001"],"kind":"state-transition","summary":"A following BSTART preserves taken predecessor transfers and does not install the untaken-path block.","pass_condition":"Taken DIRECT, conditional, and RET commits publish their selected TPC with no replacement BARG.","related_sources":["asl/block/model/commit/validation.asl","asl/block/model/lifecycle/enter-stop.asl"]}
func main() => integer
begin
    let next_start = Zeros{64} + 0x00001001;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    var direct = Zeros{64} + 0x00000011;
    direct[31:7] = Zeros{25} + 0x20;
    let direct_start = ExecuteCommandInstruction(direct, 32);
    let after_direct = ExecuteCommandInstruction(next_start, 32);
    assert direct_start == CommandExecution_Executed;
    assert after_direct == CommandExecution_Executed;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x140;
    assert !BundleIsActive();

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    var conditional = Zeros{64} + 0x00000021;
    conditional[31:7] = Zeros{25} + 0x20;
    let conditional_start = ExecuteCommandInstruction(conditional, 32);
    EnterBundleBody();
    ExecuteSetCommit(ScalarCondition_EQ, Zeros{PTO_XLEN}, Zeros{PTO_XLEN});
    let after_conditional = ExecuteCommandInstruction(next_start, 32);
    assert conditional_start == CommandExecution_Executed;
    assert after_conditional == CommandExecution_Executed;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x240;
    assert !BundleIsActive();

    ResetProfileState();
    _ReturnAddress = Zeros{PTO_XLEN} + 0x380;
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    let return_start = ExecuteCommandInstruction(Zeros{64} + 0x00007001, 32);
    let after_return = ExecuteCommandInstruction(next_start, 32);
    assert return_start == CommandExecution_Executed;
    assert after_return == CommandExecution_Executed;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x380;
    assert !BundleIsActive();
    return 0;
end;
