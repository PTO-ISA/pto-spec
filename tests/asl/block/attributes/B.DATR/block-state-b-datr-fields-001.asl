// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-DATR-FIELDS-001","source":"asl/block/attributes/B.DATR.asl","requirements":["PTO-INST-BLOCK-B-DATR"],"kind":"state-transition","summary":"Every B.DATR field has one explicit pending-state meaning.","pass_condition":"The accepted DataType, PadValue, CMode, RMode, Sat, Canonicalize, and Layout values latch without reinterpretation.","related_sources":["asl/block/model/state/control-state.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    BeginBundle(BundleKind_TileElement, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN} + 0x104, Zeros{PTO_XLEN} + 0x104,
        Zeros{PTO_XLEN} + 0x104, TRUE);
    var instruction = Zeros{64} + 0x00001023;
    instruction[31:29] = Zeros{3} + 5;
    instruction[28:27] = '10';
    instruction[26] = '1';
    instruction[25] = '1';
    instruction[24:20] = Zeros{5} + 24;
    instruction[17:15] = '111';
    let status = ExecuteCommandInstruction(instruction, 32);
    assert status == CommandExecution_Executed;
    assert _BundleDataAttributesPresent;
    assert _BundleDataAttributes.data_type == Zeros{5} + 24;
    assert CurrentBundlePadValue() == TilePad_Min;
    assert _BundleDataAttributes.comparison_mode == Zeros{3} + 5;
    assert _BundleDataAttributes.rounding_mode == '111';
    assert _BundleDataAttributes.saturating;
    assert CurrentBundleCanonicalize();
    assert CurrentBundleDataLayout() == TileDataLayout_NORM;
    return 0;
end;
