// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOT-LAST-ORDER-001","source":"asl/block/operands/B.IOT.asl","requirements":["PTO-INST-BLOCK-B-IOT"],"kind":"fault","summary":"L terminates the current block's effective B.IOT sequence.","pass_condition":"A nonzero-mask B.IOT after the L-marked binding raises Fault_BundleControl and preserves the terminated sequence.","related_sources":["asl/block/model/operands/tile-bindings.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x180);
    let started = ExecuteCommandInstruction(Zeros{64} + 0x00019181, 32);
    assert started == CommandExecution_Executed;

    var source = Zeros{64} + 0x00005013;
    source[18:15] = '0001';
    source[19] = '1';
    source[25:20] = Zeros{6} + 3;
    let first = ExecuteCommandInstruction(source, 32);
    assert first == CommandExecution_Executed;
    assert BundleTileBindingStreamTerminated();

    var destination = Zeros{64} + 0x00006013;
    destination[11:9] = '001';
    destination[18:15] = '0001';
    let second = ExecuteCommandInstruction(destination, 32);
    assert second == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert BundleTileBindingCount() == 1;
    assert BundleTileBindingStreamTerminated();
    return 0;
end;
