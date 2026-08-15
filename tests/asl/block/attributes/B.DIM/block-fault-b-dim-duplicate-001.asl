// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-DIM-DUPLICATE-001","source":"asl/block/attributes/B.DIM.asl","requirements":["PTO-INST-BLOCK-B-DIM"],"kind":"fault","summary":"Each bundle-local dimension register is written at most once per block.","pass_condition":"A second write to the same LB raises Fault_BundleControl before replacing the first value.","related_sources":["asl/block/model/schema/dimensions.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    BeginBundle(BundleKind_Standard, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN} + 0x104, Zeros{PTO_XLEN} + 0x104,
        Zeros{PTO_XLEN} + 0x104, TRUE);
    var first = Zeros{64} + 0x43;
    first[31:20] = Zeros{12} + 3;
    let first_status = ExecuteCommandInstruction(first, 32);
    assert first_status == CommandExecution_Executed;
    assert _BundleDimensions[[0]] == Zeros{PTO_XLEN} + 3;

    ClearFault();
    var second = Zeros{64} + 0x43;
    second[31:20] = Zeros{12} + 9;
    let status = ExecuteCommandInstruction(second, 32);
    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert _BundleDimensions[[0]] == Zeros{PTO_XLEN} + 3;
    return 0;
end;
