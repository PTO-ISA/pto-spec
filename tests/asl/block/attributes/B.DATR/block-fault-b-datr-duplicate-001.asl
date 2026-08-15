// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-DATR-DUPLICATE-001","source":"asl/block/attributes/B.DATR.asl","requirements":["PTO-INST-BLOCK-B-DATR"],"kind":"fault","summary":"B.DATR may appear at most once in one block.","pass_condition":"A second B.DATR raises Fault_BundleControl before replacing the first attribute state.","related_sources":["asl/block/model/state/control-state.asl"]}
pure func BundleDataAttributeInstruction(data_type: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = data_type;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    BeginBundle(BundleKind_Standard, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN} + 0x104, Zeros{PTO_XLEN} + 0x104,
        Zeros{PTO_XLEN} + 0x104, TRUE);
    let first = ExecuteCommandInstruction(
        BundleDataAttributeInstruction(Zeros{5} + 24), 32);
    assert first == CommandExecution_Executed;
    assert CurrentBundleDataTypeCode() == Zeros{5} + 24;

    ClearFault();
    let second = ExecuteCommandInstruction(
        BundleDataAttributeInstruction(Zeros{5} + 1), 32);
    assert second == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert CurrentBundleDataTypeCode() == Zeros{5} + 24;
    return 0;
end;
