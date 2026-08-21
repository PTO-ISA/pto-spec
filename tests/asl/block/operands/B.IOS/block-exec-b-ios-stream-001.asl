// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOS-STREAM-001","source":"asl/block/operands/B.IOS.asl","requirements":["PTO-INST-BLOCK-B-IOS"],"kind":"execution","summary":"B.IOS records one ordered four-entry stream of unique Shared registers.","pass_condition":"A duplicate or fifth effective Shared binding rejects while preserving the accepted stream.","related_sources":["asl/block/model/operands/shared-bindings.asl"]}
pure func BundleTestSharedBinding(shared_id: bits(8)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = '0000';
    instruction[11:9] = '111';
    return instruction;
end;

func TestBundleSharedBindingStream()
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(Zeros{64} + 0x00019181, 32);
    assert started == CommandExecution_Executed;
    let first = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 0x12), 32);
    assert first == CommandExecution_Executed;
    assert _BundleSharedBindings[[0]].valid;
    assert _BundleSharedBindings[[0]].shared_id == Zeros{8} + 0x12;
    assert !_BundleSharedBindings[[0]].consumed;

    let duplicate = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 0x12), 32);
    assert duplicate == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert !_BundleSharedBindings[[1]].valid;

    ResetProfileState();
    let restarted = ExecuteCommandInstruction(Zeros{64} + 0x00019181, 32);
    assert restarted == CommandExecution_Executed;
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
    assert _LastFault == Fault_BundleControl;
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleSharedBindingStream();
    return 0;
end;
