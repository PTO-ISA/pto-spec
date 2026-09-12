// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-TSTORE-CUBE-DIMENSIONS-001","source":"asl/block/model/dispatch/tlsu-layout-conversion.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001","PTO-BUNDLE-DIMENSION-DEFAULT-001"],"kind":"boundary","summary":"CUBE TLOAD and TSTORE consume value-one defaults for omitted dimensions","pass_condition":"all dimensions omitted and explicit LB2 one are legal, while explicit zero LB0/LB1 or nondefault LB2 reject","related_sources":["asl/block/execution/BSTART.TLOAD.asl","asl/block/execution/BSTART.TSTORE.asl"]}
func main() => integer
begin
    ResetProfileState();
    assert BundleCubeTransportDimensionsLegal();

    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    assert BundleCubeTransportDimensionsLegal();

    ResetProfileState();
    SetBundleDimension(0, Zeros{PTO_XLEN});
    assert !BundleCubeTransportDimensionsLegal();

    ResetProfileState();
    SetBundleDimension(1, Zeros{PTO_XLEN});
    assert !BundleCubeTransportDimensionsLegal();

    ResetProfileState();
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    assert !BundleCubeTransportDimensionsLegal();
    return 0;
end;
