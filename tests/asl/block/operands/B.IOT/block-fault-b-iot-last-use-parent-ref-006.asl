// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOT-LAST-USE-PARENT-REF-006","source":"asl/block/operands/B.IOT.asl","requirements":["PTO-B-IOT-STREAM-001","PTO-INST-BLOCK-B-IOT","PTO-INST-BLOCK-B-ASSEMBLE"],"kind":"fault","summary":"A Local B.ASSEMBLE ParentRef must encode reuse rather than last-use.","pass_condition":"Reclassifying a last-use source as ParentRef raises TileLegality before changing the source carrier or destination-assemble state.","related_sources":["asl/block/model/operands/range-modifiers.asl"]}
func main() => integer
begin
    ResetProfileState();
    AddBundleTileBindingWithReuse(FALSE, 0, 0, '1000',
        TRUE, FALSE, 0, 0, FALSE, TRUE, TRUE);
    OpenBundleRangeTileGroup(FALSE, TRUE, FALSE, FALSE);

    RecordBundleRangeAssemble(FALSE, TRUE, 0, Zeros{11}, 1,
        Zeros{PTO_XLEN});
    assert _LastFault == Fault_TileLegality;
    assert _BundleTileBindings[[0]].source0_valid;
    assert !_BundleTileBindings[[0]].parent_ref_valid;
    assert !_BundleTileBindings[[0]].destination_assemble.valid;
    return 0;
end;
