// PTO-TEST: {"id":"PTO-AVS-TILE-MATRIX-BIAS-DESC-001","source":"asl/tile/model/legality/matrix-operands.asl","requirements":["PTO-CUBE-AUX-CELLREG-001"],"kind":"boundary","summary":"Matrix bias is an accumulator-typed CUBE_N8 row broadcast across N","pass_condition":"a 1 by N CUBE_N8 bias passes across an N8 CELL boundary while RowMajor and M-layout descriptors reject","related_sources":["asl/tile/model/legality/matrix-shape.asl","asl/tile/model/shape/cube-cell.asl"]}

func main() => integer
begin
    ResetProfileState();
    let n8_configured = ConfigureCubeTile(0, 256, 1, 9, TileDataType_FP32,
        TileLayout_CUBE_N8);
    assert n8_configured;
    ConfigureTile(1, 256, 1, 16, 1, 9,
        TileDataType_FP32, TileLayout_RowMajor);
    let m16_configured = ConfigureCubeTile(2, 1024, 1, 9, TileDataType_FP32,
        TileLayout_CUBE_M16);
    assert m16_configured;
    let m32_configured = ConfigureCubeTile(3, 2048, 1, 9, TileDataType_FP32,
        TileLayout_CUBE_M32);
    assert m32_configured;
    for column = 0 to 8 looplimit 9 do
        WriteTileElement(0, 0, column as integer {0..65535},
            Zeros{PTO_XLEN});
        WriteTileElement(1, 0, column as integer {0..65535},
            Zeros{PTO_XLEN});
        WriteTileElement(2, 0, column as integer {0..65535},
            Zeros{PTO_XLEN});
        WriteTileElement(3, 0, column as integer {0..65535},
            Zeros{PTO_XLEN});
    end;

    assert TileMatrixLocalBiasSchemaLegal(0, 9, TileDataType_FP32);
    assert !TileMatrixLocalBiasSchemaLegal(1, 9, TileDataType_FP32);
    assert !TileMatrixLocalBiasSchemaLegal(2, 9, TileDataType_FP32);
    assert !TileMatrixLocalBiasSchemaLegal(3, 9, TileDataType_FP32);
    return 0;
end;
