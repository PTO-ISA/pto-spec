// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-HINT-DUPLICATE-001","source":"asl/block/lifecycle/B.HINT.asl","requirements":["PTO-INST-BLOCK-B-HINT"],"kind":"fault","summary":"An ordinary block header accepts at most one B.HINT.","pass_condition":"The second ordinary B.HINT raises Fault_BundleControl and preserves the first decoded hint.","related_sources":["asl/block/model/dispatch/commands.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    let started = ExecuteCommandInstruction(Zeros{64} + 0x00011181, 32);
    assert started == CommandExecution_Executed;

    var first = Zeros{64} + 0x00000033;
    first[15] = '1';
    first[16] = '1';
    first[18:17] = '11';
    first[31:20] = Zeros{12} + 64;
    let accepted = ExecuteCommandInstruction(first, 32);
    assert accepted == CommandExecution_Executed;
    let saved = _LastBundleHintPayload;

    var second = Zeros{64} + 0x00000033;
    second[15] = '1';
    second[18:17] = '01';
    let rejected = ExecuteCommandInstruction(second, 32);
    assert rejected == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert _LastBundleHintPayload == saved;
    return 0;
end;
