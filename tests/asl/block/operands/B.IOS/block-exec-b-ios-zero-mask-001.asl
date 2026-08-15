// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOS-ZERO-MASK-001","source":"asl/block/operands/B.IOS.asl","requirements":["PTO-INST-BLOCK-B-IOS"],"kind":"execution","summary":"PE_MASK zero is a strict B.IOS no-op.","pass_condition":"A zero-mask B.IOS records no binding and bypasses placement and duplicate checks.","related_sources":["asl/block/model/operands/shared-bindings.asl"]}
func main() => integer
begin
    ResetProfileState();
    var source = Zeros{64} + 0x00001013;
    source[27:20] = Zeros{8} + 9;
    let standalone = ExecuteCommandInstruction(source, 32);
    assert standalone == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert BundleSharedBindingCount() == 0;

    let started = ExecuteCommandInstruction(Zeros{64} + 0x00019181, 32);
    assert started == CommandExecution_Executed;
    var destination = source;
    destination[11:9] = '111';
    let zero_destination = ExecuteCommandInstruction(destination, 32);
    assert zero_destination == CommandExecution_Executed;
    assert BundleSharedBindingCount() == 0;
    assert SelectedBundleTileMaskIsZero();
    return 0;
end;
