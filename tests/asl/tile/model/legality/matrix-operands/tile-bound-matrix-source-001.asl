// PTO-TEST: {"id":"PTO-AVS-TILE-MATRIX-SOURCE-DESC-001","source":"asl/tile/model/legality/matrix-operands.asl","requirements":[],"kind":"boundary","summary":"a mathematical Matrix source has exact logical extents type layout and placement","pass_condition":"the exact Matrix descriptor passes while Any placement rejects","related_sources":["asl/tile/model/legality/matrix-shape.asl"]}

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(1, 128, 1, 2, 1, 2, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Any);
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
