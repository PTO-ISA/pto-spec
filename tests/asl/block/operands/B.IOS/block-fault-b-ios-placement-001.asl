// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOS-PLACEMENT-001","source":"asl/block/operands/B.IOS.asl","requirements":["PTO-INST-BLOCK-B-IOS"],"kind":"fault","summary":"A participating B.IOS is legal only in an active block header.","pass_condition":"Standalone and body-phase nonzero-mask B.IOS instructions raise Fault_BundleControl without recording a binding.","related_sources":["asl/block/model/dispatch/commands.asl"]}
func main() => integer
begin
    var source = Zeros{64} + 0x00001013;
    source[18:15] = '0001';

    ResetProfileState();
    let standalone = ExecuteCommandInstruction(source, 32);
    assert standalone == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert BundleSharedBindingCount() == 0;

    ResetProfileState();
    let started = ExecuteCommandInstruction(Zeros{64} + 0x00019181, 32);
    assert started == CommandExecution_Executed;
    EnterBundleBody();
    let body = ExecuteCommandInstruction(source, 32);
    assert body == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert BundleSharedBindingCount() == 0;
    return 0;
end;
