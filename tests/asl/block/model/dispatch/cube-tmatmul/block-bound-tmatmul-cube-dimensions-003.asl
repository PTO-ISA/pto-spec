// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-CUBE-DIMENSIONS-003","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-LOCAL-MATRIX-001"],"kind":"boundary","summary":"Local CUBE Matrix dimensions are arbitrary positive values independent of TSize","pass_condition":"M3 N9 K17 and omitted one defaults are legal explicit zero rejects and the deferred Shared path retains its prior power-of-two boundary","related_sources":["asl/tile/model/legality/matrix-shape.asl"]}
func main() => integer
begin
    ResetBundleControlState();
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 9);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 17);
    assert BundleTMATMULDimensionsLegal(0);
    assert !BundleTMATMULDimensionsLegal(1);

    ResetBundleControlState();
    assert BundleTMATMULDimensionsLegal(0);
    assert BundleTMATMULDimensionsLegal(1);

    ResetBundleControlState();
    SetBundleDimension(0, Zeros{PTO_XLEN});
    assert !BundleTMATMULDimensionsLegal(0);

    ResetBundleControlState();
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 8);
    assert BundleTMATMULDimensionsLegal(0);
    assert BundleTMATMULDimensionsLegal(1);
    return 0;
end;
