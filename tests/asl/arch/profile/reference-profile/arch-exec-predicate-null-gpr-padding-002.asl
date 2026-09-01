// PTO-TEST: {"id":"PTO-AVS-ARCH-PREDICATE-NULL-GPR-PADDING-002","source":"asl/arch/profile/reference-profile.asl","requirements":["PTO-TCMP-CONTRACT-001"],"kind":"execution","summary":"The PTO v0 profile selects zero for unspecified Null GPR predicate padding","pass_condition":"the registered profile hook supplies zero for Null while Zero and Min remain zero and Max remains all ones","related_sources":["asl/tile/model/execution/comparison.asl"]}
func main() => integer
begin
    ResetProfileState();
    assert TileProfilePredicateNullGPRPadding() == Zeros{PTO_XLEN};

    SetBundleDataAttributeState(
        DTYPE_NONE, Zeros{5}, '11', Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    assert TilePredicateGPRPaddingValue() == Zeros{PTO_XLEN};

    SetBundleDataAttributeState(
        DTYPE_NONE, Zeros{5}, '00', Zeros{3}, Zeros{3}, FALSE, FALSE);
    assert TilePredicateGPRPaddingValue() == Zeros{PTO_XLEN};

    SetBundleDataAttributeState(
        DTYPE_NONE, Zeros{5}, '10', Zeros{3}, Zeros{3}, FALSE, FALSE);
    assert TilePredicateGPRPaddingValue() == Zeros{PTO_XLEN};

    SetBundleDataAttributeState(
        DTYPE_NONE, Zeros{5}, '01', Zeros{3}, Zeros{3}, FALSE, FALSE);
    assert TilePredicateGPRPaddingValue() == Ones{PTO_XLEN};
    return 0;
end;
