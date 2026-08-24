// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-CUBE-DIMENSIONS-003","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-LOCAL-MATRIX-001","PTO-CUBE-GROUP-M-DISTRIBUTION-001"],"kind":"boundary","summary":"Local M stays arbitrary positive while cooperative LB0 is Core-total group M.","pass_condition":"Local M3 N9 K17 remains legal; cooperative group_M accepts non-power-of-two values through 128 with power-of-two N/K and rejects zero or 129.","related_sources":["asl/tile/model/legality/matrix-shape.asl"]}
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

    ResetBundleControlState();
    SetBundleDimension(0, Zeros{PTO_XLEN} + 17);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 8);
    assert BundleTMATMULDimensionsLegal(1);

    ResetBundleControlState();
    SetBundleDimension(0, Zeros{PTO_XLEN} + 128);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 8);
    assert BundleTMATMULDimensionsLegal(1);

    ResetBundleControlState();
    SetBundleDimension(0, Zeros{PTO_XLEN} + 129);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 8);
    assert !BundleTMATMULDimensionsLegal(1);
    return 0;
end;
