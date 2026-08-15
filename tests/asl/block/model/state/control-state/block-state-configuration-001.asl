// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-BLOCK-TESTBUNDLECONFIGURATIONSTATE-STATE-TRANSITION-001","source":"asl/block/model/state/control-state.asl","requirements":[],"kind":"state-transition","summary":"Covers Bundle Configuration State.","pass_condition":"TestBundleConfigurationState completes without assertion failure","related_sources":[]}
func TestBundleConfigurationState()
begin
    ResetBundleControlState();
    WriteGPR(2, Zeros{PTO_XLEN} + 33);
    SetBundleDimension(1, ReadScalarRegisterOperand(2) + (Zeros{PTO_XLEN} + 7));
    assert _BundleDimensions[[1]] == Zeros{PTO_XLEN} + 40;

    SetBundleScalarBinding(0, 5, 2, 3, 4, 3);
    assert _BundleScalarBindings[[0]].valid;
    assert _BundleScalarBindings[[0]].destination == 5;
    assert _BundleScalarBindings[[0]].source2 == 4;

    SetBundleTileBinding(0, TRUE, 2, 7, '1111', TRUE, TRUE, 10, 11,
        TRUE);
    assert _BundleTileBindings[[0]].valid;
    assert _BundleTileBindings[[0]].destination_valid;
    assert _BundleTileBindings[[0]].destination == 2;
    assert _BundleTileBindings[[0]].source0 == 10;
    assert _BundleTileBindings[[0]].pe_mask == '1111';
    assert _BundleTileBindings[[0]].last;
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleConfigurationState();
    return 0;
end;
