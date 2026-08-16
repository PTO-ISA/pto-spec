// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-DATR-PLACEMENT-001","source":"asl/block/attributes/B.DATR.asl","requirements":["PTO-INST-BLOCK-B-DATR"],"kind":"fault","summary":"B.DATR is accepted only in an active block header.","pass_condition":"Standalone and block-body B.DATR executions raise Fault_BundleControl before changing data attributes.","related_sources":["asl/block/model/dispatch/commands.asl"]}
func main() => integer
begin
    let instruction = Zeros{64} + 0x01801023;
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    let standalone = ExecuteCommandInstruction(instruction, 32);
    assert standalone == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert CurrentBundleDataTypeCode() == DTYPE_NONE;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    BeginBundle(BundleKind_Standard, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN} + 0x204, Zeros{PTO_XLEN} + 0x204,
        Zeros{PTO_XLEN} + 0x204, TRUE);
    EnterBundleBody();
    ClearFault();
    let body = ExecuteCommandInstruction(instruction, 32);
    assert body == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert CurrentBundleDataTypeCode() == DTYPE_NONE;
    return 0;
end;
