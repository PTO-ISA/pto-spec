// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-CATR-DUPLICATE-001","source":"asl/block/attributes/B.CATR.asl","requirements":["PTO-INST-BLOCK-B-CATR"],"kind":"fault","summary":"B.CATR may appear at most once in one block.","pass_condition":"A second B.CATR raises Fault_BundleControl before replacing the first control state.","related_sources":["asl/block/model/schema/attributes.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    BeginBundle(BundleKind_TileElement, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN} + 0x104, Zeros{PTO_XLEN} + 0x104,
        Zeros{PTO_XLEN} + 0x104, TRUE);
    let first = ExecuteCommandInstruction(Zeros{64} + 0x00008023, 32);
    assert first == CommandExecution_Executed;
    assert _BundleControlAttributes.release;

    ClearFault();
    let second = ExecuteCommandInstruction(Zeros{64} + 0x00010023, 32);
    assert second == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert _BundleControlAttributes.release;
    assert !_BundleControlAttributes.acquire;
    return 0;
end;
