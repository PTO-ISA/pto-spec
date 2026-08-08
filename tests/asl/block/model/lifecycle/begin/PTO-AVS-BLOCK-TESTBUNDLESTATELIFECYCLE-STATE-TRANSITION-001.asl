// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-BLOCK-TESTBUNDLESTATELIFECYCLE-STATE-TRANSITION-001","source":"asl/block/model/lifecycle/begin.asl","requirements":[],"kind":"state-transition","summary":"migrated independent behavior point for TestBundleStateLifecycle","pass_condition":"TestBundleStateLifecycle completes without assertion failure","related_sources":[]}
func TestBundleStateLifecycle()
begin
    ResetBundleControlState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    ClearFault();
    BeginBundle(BundleKind_Standard, BundleTransfer_Direct,
        Zeros{PTO_XLEN} + 0x200, Zeros{PTO_XLEN} + 0x104,
        Zeros{PTO_XLEN} + 0x104, TRUE);
    assert _LastFault == Fault_None;
    assert BundleIsActive();
    assert !BundleBodyIsActive();
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x104;
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x200;

    EnterBundleBody();
    assert _LastFault == Fault_None;
    assert BundleBodyIsActive();

    StopBundle();
    assert _LastFault == Fault_None;
    assert !BundleIsActive();
    assert !BundleBodyIsActive();
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x104;
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleStateLifecycle();
    return 0;
end;
