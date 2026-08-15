// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-CATR-PLACEMENT-001","source":"asl/block/attributes/B.CATR.asl","requirements":["PTO-INST-BLOCK-B-CATR"],"kind":"fault","summary":"B.CATR is accepted only in an active block header.","pass_condition":"Standalone and block-body B.CATR executions raise Fault_BundleControl before changing pending attributes.","related_sources":["asl/block/model/dispatch/commands.asl"]}
func main() => integer
begin
    let instruction = Zeros{64} + 0x00008023;
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    let standalone = ExecuteCommandInstruction(instruction, 32);
    assert standalone == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert !_BundleControlAttributes.present;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    BeginBundle(BundleKind_TileElement, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN} + 0x204, Zeros{PTO_XLEN} + 0x204,
        Zeros{PTO_XLEN} + 0x204, TRUE);
    EnterBundleBody();
    ClearFault();
    let body = ExecuteCommandInstruction(instruction, 32);
    assert body == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert !_BundleControlAttributes.present;
    return 0;
end;
