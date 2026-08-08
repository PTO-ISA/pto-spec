// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-BLOCK-TESTBUNDLESHAREDBINDINGV5-EXECUTION-001","source":"asl/block/operands/B.IOS.asl","requirements":["PTO-INST-BLOCK-B-IOS"],"kind":"execution","summary":"migrated independent behavior point for TestBundleSharedBindingV5","pass_condition":"TestBundleSharedBindingV5 completes without assertion failure","related_sources":[]}
pure func BundleTestSharedBinding(shared_id: bits(8)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = '1111';
    instruction[11:9] = '000';
    return instruction;
end;

func TestBundleSharedBindingV5()
begin
    ResetProfileState();
    let first = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 0x12), 32);
    assert first == CommandExecution_Executed;
    assert _BundleSharedBindings[[0]].valid;
    assert _BundleSharedBindings[[0]].shared_id == Zeros{8} + 0x12;
    assert !_BundleSharedBindings[[0]].consumed;

    let duplicate = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 0x12), 32);
    assert duplicate == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleSharedBindings[[1]].valid;

    ResetProfileState();
    for shared_id = 0 to 3 do
        let accepted = ExecuteCommandInstruction(
            BundleTestSharedBinding(Zeros{8} + shared_id), 32);
        assert accepted == CommandExecution_Executed;
        assert _BundleSharedBindings[[shared_id]].valid;
        assert _BundleSharedBindings[[shared_id]].shared_id ==
            Zeros{8} + shared_id;
    end;
    let overflow = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 4), 32);
    assert overflow == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleSharedBindingV5();
    return 0;
end;
