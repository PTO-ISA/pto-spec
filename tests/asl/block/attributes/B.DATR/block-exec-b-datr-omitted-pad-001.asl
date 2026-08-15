// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-DATR-OMITTED-PAD-001","source":"asl/block/attributes/B.DATR.asl","requirements":["PTO-INST-BLOCK-B-DATR"],"kind":"execution","summary":"Omitted and explicitly encoded zero PadValue are distinct.","pass_condition":"Omitted B.DATR supplies Null padding while an explicit all-zero B.DATR supplies Zero padding.","related_sources":["asl/block/model/dispatch/tile-schema.asl","asl/block/model/state/descriptor-state.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    let omitted_start = ExecuteCommandInstruction(
        Zeros{64} + 0x00011181, 32);
    assert omitted_start == CommandExecution_Executed;
    assert !_BundleDataAttributesPresent;
    assert CurrentBundlePadValue() == TilePad_Null;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x140);
    let explicit_start = ExecuteCommandInstruction(
        Zeros{64} + 0x00011181, 32);
    let explicit = ExecuteCommandInstruction(Zeros{64} + 0x00001023, 32);
    assert explicit_start == CommandExecution_Executed;
    assert explicit == CommandExecution_Executed;
    assert _BundleDataAttributesPresent;
    assert CurrentBundlePadValue() == TilePad_Zero;
    return 0;
end;
