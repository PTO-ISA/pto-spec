// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOT-PLACEMENT-001","source":"asl/block/operands/B.IOT.asl","requirements":["PTO-INST-BLOCK-B-IOT"],"kind":"fault","summary":"A participating B.IOT is legal only in an active block header.","pass_condition":"Standalone and body-phase nonzero-mask B.IOT instructions raise Fault_BundleControl without recording a binding.","related_sources":["asl/block/model/dispatch/commands.asl"]}
func main() => integer
begin
    var source = Zeros{64} + 0x00005013;
    source[18:15] = '0001';
    source[11:9] = '111';
    source[19] = '1';

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    let standalone = ExecuteCommandInstruction(source, 32);
    assert standalone == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert BundleTileBindingCount() == 0;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x240);
    let started = ExecuteCommandInstruction(Zeros{64} + 0x00019181, 32);
    assert started == CommandExecution_Executed;
    EnterBundleBody();
    let body = ExecuteCommandInstruction(source, 32);
    assert body == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert BundleTileBindingCount() == 0;
    return 0;
end;
