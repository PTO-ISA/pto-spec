// PTO-TEST: {"id":"PTO-AVS-BLOCK-ASSEMBLE-DYNAMIC-DOMAIN-002","source":"asl/block/model/operands/portable-carriers.asl","requirements":["PTO-B-ASSEMBLE-SPECULATION-001"],"kind":"state-transition","summary":"Repeated executions of one static BSTART receive distinct dynamic domain identities.","pass_condition":"Two decoded attempts at the same BSTART address retain the same BPC but receive unequal monotonic execution-domain tokens.","related_sources":["asl/block/model/lifecycle/begin.asl","asl/block/model/state/control-state.asl"]}
pure func DynamicDomainStart() => bits(64)
begin
    return Zeros{64} + 0x00019181;
end;

func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x400);
    let first = ExecuteCommandInstruction(DynamicDomainStart(), 32);
    assert first == CommandExecution_Executed;
    let first_bpc = ReadBPC();
    let first_domain = _BundleExecutionDomainToken;

    ClearBundleHeaderState();
    WriteTPC(Zeros{PTO_XLEN} + 0x400);
    let second = ExecuteCommandInstruction(DynamicDomainStart(), 32);
    assert second == CommandExecution_Executed;
    let second_bpc = ReadBPC();
    let second_domain = _BundleExecutionDomainToken;

    assert first_bpc == second_bpc;
    assert first_domain != second_domain;
    assert second_domain == first_domain + 1;
    return 0;
end;
