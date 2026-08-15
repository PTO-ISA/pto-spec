// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-CATR-FIELDS-001","source":"asl/block/attributes/B.CATR.asl","requirements":["PTO-INST-BLOCK-B-CATR"],"kind":"state-transition","summary":"Every B.CATR bit has one independent pending-state meaning.","pass_condition":"trap, atomic, acquire, release, far, and dimension-reduction fields latch exactly once in an active header.","related_sources":["asl/block/model/schema/attributes.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    BeginBundle(BundleKind_TileElement, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN} + 0x104, Zeros{PTO_XLEN} + 0x104,
        Zeros{PTO_XLEN} + 0x104, TRUE);
    var instruction = Zeros{64} + 0x00000023;
    instruction[26] = '1';
    instruction[19:15] = '11111';
    let status = ExecuteCommandInstruction(instruction, 32);
    assert status == CommandExecution_Executed;
    assert _BundleControlAttributes.present;
    assert _BundleControlAttributes.trap_enabled;
    assert _BundleControlAttributes.atomic;
    assert _BundleControlAttributes.acquire;
    assert _BundleControlAttributes.release;
    assert _BundleControlAttributes.far;
    assert _BundleControlAttributes.dimension_reduction;
    return 0;
end;
