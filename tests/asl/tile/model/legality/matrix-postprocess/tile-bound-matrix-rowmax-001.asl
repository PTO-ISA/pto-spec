// PTO-TEST: {"id":"PTO-AVS-TILE-MATRIX-ROWMAX-DESC-001","source":"asl/tile/model/legality/matrix-postprocess.asl","requirements":["PTO-CUBE-AUX-CELLREG-001"],"kind":"boundary","summary":"RowMaxIn uses the resolved M-layout Local accumulator descriptor","pass_condition":"M16 and M32 descriptors pass with M by 1 shape while RowMajor and mismatched M layout reject","related_sources":["asl/block/attributes/B.FPATR.asl","asl/tile/model/shape/cube-cell.asl"]}

func main() => integer
begin
    ResetProfileState();
    let m16_configured = ConfigureCubeTile(0, 128, 2, 1, TileDataType_FP32,
        TileLayout_CUBE_M16);
    assert m16_configured;
    let m32_configured = ConfigureCubeTile(1, 128, 2, 1, TileDataType_FP32,
        TileLayout_CUBE_M32);
    assert m32_configured;
    ConfigureTile(2, 128, 2, 1, 2, 1,
        TileDataType_FP32, TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN});

    assert TileMatrixLocalRowMaxSchemaLegal(
        0, 2, TileDataType_FP32, TileLayout_CUBE_M16);
    assert TileMatrixLocalRowMaxSchemaLegal(
        1, 2, TileDataType_FP32, TileLayout_CUBE_M32);
    assert !TileMatrixLocalRowMaxSchemaLegal(
        2, 2, TileDataType_FP32, TileLayout_CUBE_M16);
    assert !TileMatrixLocalRowMaxSchemaLegal(
        1, 2, TileDataType_FP32, TileLayout_CUBE_M16);
    return 0;
end;
