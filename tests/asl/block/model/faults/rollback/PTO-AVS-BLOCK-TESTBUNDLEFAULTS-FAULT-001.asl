// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-BLOCK-TESTBUNDLEFAULTS-FAULT-001","source":"asl/block/model/faults/rollback.asl","requirements":[],"kind":"fault","summary":"migrated independent behavior point for TestBundleFaults","pass_condition":"TestBundleFaults completes without assertion failure","related_sources":[]}
func TestBundleFaults()
begin
    ResetBundleControlState();
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    ClearFault();
    StopBundle();
    assert _LastFault == Fault_BundleControl;
    assert _ACRTrapNumber[[CurrentACR()]] == Zeros{6} + 5;

    ResetBundleControlState();
    ClearFault();
    BeginBundle(BundleKind_Standard, BundleTransfer_Direct,
        Zeros{PTO_XLEN} + 0x401, Zeros{PTO_XLEN} + 0x304,
        Zeros{PTO_XLEN} + 0x304, TRUE);
    assert _LastFault == Fault_InstructionPC;
    assert !BundleIsActive();
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleFaults();
    return 0;
end;
