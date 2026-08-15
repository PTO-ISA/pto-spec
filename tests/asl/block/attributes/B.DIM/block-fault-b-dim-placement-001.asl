// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-DIM-PLACEMENT-001","source":"asl/block/attributes/B.DIM.asl","requirements":["PTO-INST-BLOCK-B-DIM"],"kind":"fault","summary":"B.DIM is accepted only in an active block header.","pass_condition":"Standalone and block-body B.DIM executions raise Fault_BundleControl before changing an LB.","related_sources":["asl/block/model/dispatch/commands.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    var instruction = Zeros{64} + 0x43;
    instruction[31:20] = Zeros{12} + 7;
    let standalone = ExecuteCommandInstruction(instruction, 32);
    assert standalone == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert _BundleDimensions[[0]] == Zeros{PTO_XLEN};

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
    assert _BundleDimensions[[0]] == Zeros{PTO_XLEN};
    return 0;
end;
