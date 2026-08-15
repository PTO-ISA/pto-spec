// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOR-PLACEMENT-001","source":"asl/block/operands/B.IOR.asl","requirements":["PTO-INST-BLOCK-B-IOR"],"kind":"fault","summary":"B.IOR is legal only in an active BSTART block header.","pass_condition":"Standalone and block-body B.IOR instructions raise Fault_BundleControl before changing scalar bindings.","related_sources":["asl/block/model/dispatch/commands.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    let standalone = ExecuteCommandInstruction(Zeros{64} + 0x00000013, 32);
    assert standalone == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert !_BundleScalarBindings[[0]].valid;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x140);
    let started = ExecuteCommandInstruction(Zeros{64} + 0x00011181, 32);
    assert started == CommandExecution_Executed;
    EnterBundleBody();
    let body = ExecuteDecodedBundleCommand(Zeros{64} + 0x00000013, 7, 32);
    assert body == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert !_BundleScalarBindings[[0]].valid;
    return 0;
end;
