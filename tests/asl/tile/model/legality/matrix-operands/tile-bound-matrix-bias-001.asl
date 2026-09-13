// PTO-TEST: {"id":"PTO-AVS-TILE-MATRIX-BIAS-DESC-001","source":"asl/tile/model/legality/matrix-operands.asl","requirements":[],"kind":"boundary","summary":"Matrix bias is one accumulator-typed row broadcast across N in the resolved M layout","pass_condition":"a 1 by N FP32 bias passes in both M16 and M32 while an N by 1 descriptor rejects","related_sources":["asl/tile/model/legality/matrix-shape.asl"]}

func main() => integer
begin
    ResetProfileState();
    ConfigureCubeTile(0, 128, 1, 2, TileDataType_FP32,
        TileLayout_CUBE_M16);
    ConfigureCubeTile(1, 128, 2, 1, TileDataType_FP32,
        TileLayout_CUBE_M16);
    ConfigureCubeTile(2, 512, 1, 2, TileDataType_FP32,
        TileLayout_CUBE_M32);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN});

    assert TileMatrixLocalBiasSchemaLegal(
        0, 2, TileDataType_FP32, TileLayout_CUBE_M16);
    assert !TileMatrixLocalBiasSchemaLegal(
        1, 2, TileDataType_FP32, TileLayout_CUBE_M16);
    assert TileMatrixLocalBiasSchemaLegal(
        2, 2, TileDataType_FP32, TileLayout_CUBE_M32);
    return 0;
end;
