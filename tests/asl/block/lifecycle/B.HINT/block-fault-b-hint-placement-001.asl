// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-HINT-PLACEMENT-001","source":"asl/block/lifecycle/B.HINT.asl","requirements":["PTO-INST-BLOCK-B-HINT"],"kind":"fault","summary":"An ordinary B.HINT is legal only in an active block header.","pass_condition":"Standalone and block-body ordinary hints raise Fault_BundleControl without recording the hint.","related_sources":["asl/block/model/dispatch/commands.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    let standalone = ExecuteCommandInstruction(Zeros{64} + 0x00000033, 32);
    assert standalone == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert _BundleHintEpoch == 0;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x240);
    let started = ExecuteCommandInstruction(Zeros{64} + 0x00011181, 32);
    assert started == CommandExecution_Executed;
    EnterBundleBody();
    let body = ExecuteDecodedBundleCommand(Zeros{64} + 0x00000033, 5, 32);
    assert body == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert _BundleHintEpoch == 0;
    return 0;
end;
