// PTO-TEST: {"id":"PTO-AVS-TILE-MATRIX-ROWMAX-DESC-001","source":"asl/tile/model/legality/matrix-postprocess.asl","requirements":[],"kind":"boundary","summary":"RowMaxIn uses an M by 1 Local accumulator descriptor","pass_condition":"the exact descriptor passes while a shorter valid-row extent rejects","related_sources":["asl/block/attributes/B.FPATR.asl"]}

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 2, 1, 2, 1, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 2, 1, 1, 1, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});

    assert TileMatrixAuxiliarySourceSchemaLegal(
        0, 2, 1, TileDataType_FP32);
    assert !TileMatrixAuxiliarySourceSchemaLegal(
        1, 2, 1, TileDataType_FP32);
    return 0;
end;
