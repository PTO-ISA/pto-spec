// PTO-TEST: {"id":"PTO-AVS-TILE-MATRIX-FN-BOUND-001","source":"asl/tile/model/legality/matrix-functions.asl","requirements":["PTO-CUBE-MATRIX-SCALE-001"],"kind":"boundary","summary":"CUBE Matrix function and side-specific scale tables are closed.","pass_condition":"All twelve functions are assigned; HiF4X2 is Matrix-MX-only with group-64 U32 scale, while MX FP8/FP4 retain group-32 E8M0 scale.","related_sources":[]}
func main() => integer
begin
    assert TileMatrixFunctionAssigned(0);
    assert TileMatrixFunctionAssigned(6);
    assert TileMatrixFunctionAssigned(16);
    assert TileMatrixFunctionAssigned(22);
    assert !TileMatrixFunctionAssigned(3);
    assert !TileMatrixFunctionAssigned(19);
    assert !TileMatrixFunctionAssigned(23);
    assert TileMatrixFunctionIsGEMV(16);
    assert TileMatrixFunctionIsGEMV(22);
    assert !TileMatrixFunctionIsGEMV(19);

    assert TileMatrixMathematicalSourceCount(
        4, TileDataType_FP16, TileDataType_BF16) == 2;
    assert TileMatrixMathematicalSourceCount(
        5, TileDataType_E4M3, TileDataType_BF16) == 4;
    assert TileMatrixMathematicalSourceCount(
        6, TileDataType_E4M3, TileDataType_E1M2X2) == 5;
    assert TileMXInputTypeSupported(TileDataType_HiF4X2);
    assert TileMXScaleGroupSize(TileDataType_E4M3) == 32;
    assert TileMXScaleCarrierType(TileDataType_E4M3) == TileDataType_E8M0;
    assert TileMXScaleGroupCount(33, TileDataType_E4M3) == 2;
    assert TileMXScaleGroupSize(TileDataType_HiF4X2) == 64;
    assert TileMXScaleCarrierType(TileDataType_HiF4X2) == TileDataType_U32;
    assert TileMXScaleGroupCount(65, TileDataType_HiF4X2) == 2;

    // Ordinary TMATMUL accepts no Shared source, the right matrix only, or
    // both matrix sides.  Bias/accumulator operands remain Local.
    assert TileMatrixSharedSourceCountLegal(
        1, TileDataType_FP16, TileDataType_BF16, 0);
    assert TileMatrixSharedSourceCountLegal(
        1, TileDataType_FP16, TileDataType_BF16, 1);
    assert TileMatrixSharedSourceCountLegal(
        1, TileDataType_FP16, TileDataType_BF16, 2);
    assert !TileMatrixSharedSourceCountLegal(
        1, TileDataType_FP16, TileDataType_BF16, 3);
    assert TileMatrixLocalMathematicalSourceCount(
        1, TileDataType_FP16, TileDataType_BF16, 1) == 2;

    // MX scale sources belong to their matrix side.  Here only the right
    // E4M3 side needs a scale, so right-only Shared has two records and the
    // remaining Local stream is just the unscaled left matrix.
    assert TileMatrixSharedSourceCountLegal(
        4, TileDataType_FP16, TileDataType_E4M3, 2);
    assert TileMatrixSharedSourceCountLegal(
        4, TileDataType_FP16, TileDataType_E4M3, 3);
    assert !TileMatrixSharedSourceCountLegal(
        4, TileDataType_FP16, TileDataType_E4M3, 1);
    assert TileMatrixLocalMathematicalSourceCount(
        4, TileDataType_FP16, TileDataType_E4M3, 2) == 1;

    // TGEMV is Local-only for every ordinary and MX function.
    assert TileMatrixSharedSourceCountLegal(
        16, TileDataType_FP16, TileDataType_BF16, 0);
    assert !TileMatrixSharedSourceCountLegal(
        16, TileDataType_FP16, TileDataType_BF16, 1);
    assert !TileMatrixSharedSourceCountLegal(
        20, TileDataType_E4M3, TileDataType_E5M2, 4);
    return 0;
end;
