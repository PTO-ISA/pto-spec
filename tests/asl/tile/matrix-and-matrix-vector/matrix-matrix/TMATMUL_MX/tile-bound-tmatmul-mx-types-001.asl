// PTO-TEST: {"id":"PTO-AVS-TILE-TMATMUL-MX-TYPES-001","source":"asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX.asl","requirements":["PTO-INST-TILE-TMATMUL-MX"],"kind":"boundary","summary":"TMATMULMX accepts the six side types and derives scale presence per side","pass_condition":"FP16 and BF16 omit scales; four compact formats require E8M0 scales; HiF4X2 rejects","related_sources":["asl/tile/model/legality/matrix-shape.asl"]}
func main() => integer
begin
    assert TileMXInputTypeSupported(TileDataType_FP16);
    assert TileMXInputTypeSupported(TileDataType_BF16);
    assert TileMXInputTypeSupported(TileDataType_E4M3);
    assert TileMXInputTypeSupported(TileDataType_E5M2);
    assert TileMXInputTypeSupported(TileDataType_E2M1X2);
    assert TileMXInputTypeSupported(TileDataType_E1M2X2);

    assert !TileMXInputTypeNeedsScale(TileDataType_FP16);
    assert !TileMXInputTypeNeedsScale(TileDataType_BF16);
    assert TileMXInputTypeNeedsScale(TileDataType_E4M3);
    assert TileMXInputTypeNeedsScale(TileDataType_E5M2);
    assert TileMXInputTypeNeedsScale(TileDataType_E2M1X2);
    assert TileMXInputTypeNeedsScale(TileDataType_E1M2X2);

    assert TileMXOperandPairLegal(TileDataType_FP16, TileDataType_E4M3);
    assert TileMXOperandPairLegal(TileDataType_E1M2X2, TileDataType_BF16);
    assert !TileMXInputTypeSupported(TileDataType_HiF4X2);
    assert !TileMXOperandPairLegal(TileDataType_HiF4X2, TileDataType_E2M1X2);

    assert TileMatrixMathematicalSourceCount(
        4, TileDataType_FP16, TileDataType_BF16) == 2;
    assert TileMatrixMathematicalSourceCount(
        4, TileDataType_E4M3, TileDataType_BF16) == 3;
    assert TileMatrixMathematicalSourceCount(
        4, TileDataType_FP16, TileDataType_E1M2X2) == 3;
    assert TileMatrixMathematicalSourceCount(
        6, TileDataType_E4M3, TileDataType_E1M2X2) == 5;
    return 0;
end;
