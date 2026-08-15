// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTOP-CLEAR-001","source":"asl/block/lifecycle/BSTOP.asl","requirements":["PTO-INST-BLOCK-BSTOP"],"kind":"state-transition","summary":"Successful block retirement clears all block-private state.","pass_condition":"After commit, dimensions, operand streams, attributes, and active/header state are cleared.","related_sources":["asl/block/model/lifecycle/enter-stop.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    let started = ExecuteCommandInstruction(Zeros{64} + 0x00000011, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 7);
    SetBundleScalarBinding(0, 1, 2, 3, 4, 3);
    _BundleHint.present = TRUE;
    let committed = CompleteBundleAt(Zeros{PTO_XLEN} + 0x380);
    assert committed;
    assert !_BundleActive && !_BundleBodyActive;
    assert !_BundleDimensionPresent[[0]];
    assert !_BundleScalarBindings[[0]].valid;
    assert !_BundleHint.present;
    assert !_BundleOperation.valid;
    return 0;
end;
