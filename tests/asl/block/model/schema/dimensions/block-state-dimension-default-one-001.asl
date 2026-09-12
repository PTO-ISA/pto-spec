// PTO-TEST: {"id":"PTO-AVS-BLOCK-MODEL-SCHEMA-DIMENSIONS-DEFAULT-001","source":"asl/block/model/schema/dimensions.asl","requirements":["PTO-BUNDLE-DIMENSION-DEFAULT-001"],"kind":"state-transition","summary":"Every omitted block dimension has effective value one while explicit writes remain distinct","pass_condition":"reset and header clear leave LB0..LB2 at value one with presence false, then an explicit zero replaces LB1 and sets only its presence bit","related_sources":["asl/block/model/lifecycle/reset.asl","asl/block/model/state/descriptor-state.asl"]}
func main() => integer
begin
    ResetProfileState();
    for dimension = 0 to PTO_BUNDLE_DIMENSION_COUNT - 1 do
        assert !_BundleDimensionPresent[[dimension]];
        assert _BundleDimensions[[dimension]] == Zeros{PTO_XLEN} + 1;
    end;

    BeginBundle(BundleKind_Standard, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN} + 4, Zeros{PTO_XLEN} + 4,
        Zeros{PTO_XLEN} + 4, TRUE);
    SetBundleDimension(1, Zeros{PTO_XLEN});
    assert _BundleDimensions[[0]] == Zeros{PTO_XLEN} + 1;
    assert _BundleDimensions[[1]] == Zeros{PTO_XLEN};
    assert _BundleDimensions[[2]] == Zeros{PTO_XLEN} + 1;
    assert !_BundleDimensionPresent[[0]];
    assert _BundleDimensionPresent[[1]];
    assert !_BundleDimensionPresent[[2]];

    ClearBundleHeaderState();
    for dimension = 0 to PTO_BUNDLE_DIMENSION_COUNT - 1 do
        assert !_BundleDimensionPresent[[dimension]];
        assert _BundleDimensions[[dimension]] == Zeros{PTO_XLEN} + 1;
    end;
    return 0;
end;
