// PTO-TEST: {"id":"PTO-AVS-TILE-MATRIX-SOURCE-DESC-001","source":"asl/tile/model/legality/matrix-operands.asl","requirements":[],"kind":"boundary","summary":"a mathematical Matrix source has exact logical extents, type, and layout","pass_condition":"the exact Matrix descriptor passes while a CUBE-layout source rejects","related_sources":["asl/tile/model/legality/matrix-shape.asl"]}

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_FP16,
        TileLayout_RowMajor);
    let cube_configured = ConfigureCubeTile(1, 128, 1, 2,
        TileDataType_FP16, TileLayout_CUBE_M16);
    assert cube_configured;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN});

    assert TileMatrixLocalOperandSchemaLegal(
        0, 1, 2, TileDataType_FP16);
    assert !TileMatrixLocalOperandSchemaLegal(
        1, 1, 2, TileDataType_FP16);
    return 0;
end;
