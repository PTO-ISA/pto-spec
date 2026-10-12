// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-CUBE-DIMENSIONS-003","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-LOCAL-MATRIX-001","PTO-CUBE-GROUP-M-DISTRIBUTION-001","PTO-TMATMUL-CONTRACT-001"],"kind":"boundary","summary":"Local dimensions remain positive while cooperative Matrix dimensions use explicit bounded positive ranges.","pass_condition":"Local M3 N9 K17 remains legal; cooperative group_M accepts 1..128 and N/K accept 1..65535 without power-of-two restrictions; zero and out-of-range values reject.","related_sources":["asl/tile/model/legality/matrix-shape.asl"]}
func main() => integer
begin
    ResetBundleControlState();
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 9);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 17);
    assert BundleTMATMULDimensionsLegal(0);
    assert BundleTMATMULDimensionsLegal(1);

    ResetBundleControlState();
    assert BundleTMATMULDimensionsLegal(0);
    assert BundleTMATMULDimensionsLegal(1);
    assert BundleMatrixCooperativeValidM(128, 0) == 32;
    assert BundleMatrixCooperativeValidM(128, 1) == 32;
    assert BundleMatrixCooperativeValidM(128, 2) == 32;
    assert BundleMatrixCooperativeValidM(128, 3) == 32;

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
    SetBundleDimension(1, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 193);
    assert BundleTMATMULDimensionsLegal(1);

    ResetBundleControlState();
    SetBundleDimension(0, Zeros{PTO_XLEN} + 128);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 65535);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 65535);
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

    ResetBundleControlState();
    SetBundleDimension(1, Zeros{PTO_XLEN});
    assert !BundleTMATMULDimensionsLegal(1);

    ResetBundleControlState();
    SetBundleDimension(2, Zeros{PTO_XLEN} + 65536);
    assert !BundleTMATMULDimensionsLegal(1);

    for boundary = 0 to 5 looplimit 6 do
        ResetBundleControlState();
        let group_m = if boundary == 0 then 1
            else if boundary == 1 then 17
            else if boundary == 2 then 48
            else if boundary == 3 then 64
            else if boundary == 4 then 65 else 128;
        SetBundleDimension(0, Zeros{PTO_XLEN} + group_m);
        SetBundleDimension(1, Zeros{PTO_XLEN} + 3);
        SetBundleDimension(2, Zeros{PTO_XLEN} + 17);
        assert BundleTMATMULDimensionsLegal(1);
    end;

    ResetBundleControlState();
    SetBundleDimension(0, Zeros{PTO_XLEN});
    SetBundleDimension(1, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 17);
    assert !BundleTMATMULDimensionsLegal(1);

    ResetBundleControlState();
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 65536);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    assert !BundleTMATMULDimensionsLegal(1);

    ResetBundleControlState();
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN});
    assert !BundleTMATMULDimensionsLegal(1);
    return 0;
end;
