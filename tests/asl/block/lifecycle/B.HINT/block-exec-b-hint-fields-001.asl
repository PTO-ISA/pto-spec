// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-HINT-FIELDS-001","source":"asl/block/lifecycle/B.HINT.asl","requirements":["PTO-INST-BLOCK-B-HINT"],"kind":"execution","summary":"The ordinary B.HINT fields are decoded into explicit pending hint state.","pass_condition":"V, L/UL, temperature, and prefetch-size retain their exact encoded meanings.","related_sources":["asl/block/model/state/types.asl","asl/block/model/state/control-state.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x180);
    let started = ExecuteCommandInstruction(Zeros{64} + 0x00011181, 32);
    assert started == CommandExecution_Executed;

    var instruction = Zeros{64} + 0x00000033;
    instruction[15] = '1';
    instruction[16] = '1';
    instruction[18:17] = '10';
    instruction[31:20] = Ones{12};
    let status = ExecuteCommandInstruction(instruction, 32);
    assert status == CommandExecution_Executed;
    assert _BundleHint.present;
    assert !_BundleHint.trace;
    assert _BundleHint.branch_valid;
    assert _BundleHint.branch_likely;
    assert _BundleHint.temperature == '10';
    assert _BundleHint.prefetch_size == Ones{12};
    return 0;
end;
