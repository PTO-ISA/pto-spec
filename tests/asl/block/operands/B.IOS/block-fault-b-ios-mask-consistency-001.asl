// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOS-MASK-CONSISTENCY-001","source":"asl/block/operands/B.IOS.asl","requirements":["PTO-INST-BLOCK-B-IOS"],"kind":"fault","summary":"All effective Local and Shared bindings use one nonzero PE_MASK.","pass_condition":"A Shared mask differing from a prior Local or Shared binding raises Fault_TileLegality before append.","related_sources":["asl/block/model/operands/shared-bindings.asl"]}
func main() => integer
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(Zeros{64} + 0x00019181, 32);
    assert started == CommandExecution_Executed;

    var local = Zeros{64} + 0x00005013;
    local[18:15] = '0011';
    local[19] = '1';
    let local_status = ExecuteCommandInstruction(local, 32);
    assert local_status == CommandExecution_Executed;

    var shared = Zeros{64} + 0x00001013;
    shared[18:15] = '0001';
    let mixed = ExecuteCommandInstruction(shared, 32);
    assert mixed == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert BundleSharedBindingCount() == 0;

    ResetProfileState();
    let restarted = ExecuteCommandInstruction(Zeros{64} + 0x00019181, 32);
    assert restarted == CommandExecution_Executed;
    shared[18:15] = '0011';
    let first = ExecuteCommandInstruction(shared, 32);
    assert first == CommandExecution_Executed;
    shared[27:20] = Zeros{8} + 1;
    shared[18:15] = '0001';
    let second = ExecuteCommandInstruction(shared, 32);
    assert second == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert BundleSharedBindingCount() == 1;
    return 0;
end;
