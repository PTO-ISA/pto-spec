// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOS-STREAM-LIMIT-001","source":"asl/block/operands/B.IOS.asl","requirements":["PTO-INST-BLOCK-B-IOS"],"kind":"fault","summary":"B.IOS provides one ordered four-entry stream with unique Shared IDs.","pass_condition":"A duplicate or fifth effective Shared binding raises Fault_BundleControl and preserves the prior stream.","related_sources":["asl/block/model/operands/shared-bindings.asl"]}
pure func SharedBindingInstruction(id: bits(8)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[27:20] = id;
    instruction[18:15] = '0000';
    instruction[11:9] = '111';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(Zeros{64} + 0x00019181, 32);
    assert started == CommandExecution_Executed;
    let first = ExecuteCommandInstruction(SharedBindingInstruction(Zeros{8}), 32);
    assert first == CommandExecution_Executed;
    let duplicate = ExecuteCommandInstruction(
        SharedBindingInstruction(Zeros{8}), 32);
    assert duplicate == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert BundleSharedBindingCount() == 1;

    ResetProfileState();
    let restarted = ExecuteCommandInstruction(Zeros{64} + 0x00019181, 32);
    assert restarted == CommandExecution_Executed;
    for id = 0 to 3 do
        let status = ExecuteCommandInstruction(
            SharedBindingInstruction(Zeros{8} + id), 32);
        assert status == CommandExecution_Executed;
    end;
    let fifth = ExecuteCommandInstruction(
        SharedBindingInstruction(Zeros{8} + 4), 32);
    assert fifth == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert BundleSharedBindingCount() == 4;
    return 0;
end;
