// PTO-TEST: {"id":"PTO-AVS-BLOCK-TGPR2T-CLASS-BOUND-001","source":"asl/block/model/dispatch/scalar-schema.asl","requirements":[],"kind":"boundary","summary":"TGPR2T selection rejects valid non-Tile operation descriptors without entering Tile-family decode","pass_condition":"Control and FixedPoint descriptors return false without evaluating BundleTileDecodeFamily","related_sources":["asl/block/model/dispatch/descriptor-legality.asl"]}
func main() => integer
begin
    ResetProfileState();
    _BundleOperation.valid = TRUE;
    _BundleOperation.operation_class = BundleOperation_Control;
    assert !BundleTGPR2TSelected();
    _BundleOperation.operation_class = BundleOperation_FixedPoint;
    assert !BundleTGPR2TSelected();
    return 0;
end;
