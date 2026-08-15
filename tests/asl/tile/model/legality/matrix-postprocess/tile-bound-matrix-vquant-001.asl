// PTO-TEST: {"id":"PTO-AVS-TILE-MATRIX-VQUANT-DESC-001","source":"asl/tile/model/legality/matrix-postprocess.asl","requirements":[],"kind":"boundary","summary":"vector quantization uses a 1 by N Local U64 descriptor with mode-owned bits only","pass_condition":"an FP19 scale plus S9 offset passes and one reserved low bit rejects","related_sources":["asl/block/attributes/B.FPATR.asl"]}

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0,
        Zeros{PTO_XLEN} + 0x0000002000002000);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN});

    assert TileMatrixAuxiliarySourceSchemaLegal(
        0, 1, 2, TileDataType_U64);
    assert TileMatrixVectorQuantContentsLegal(0, Zeros{6} + 2);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 1);
    assert !TileMatrixVectorQuantContentsLegal(0, Zeros{6} + 2);
    return 0;
end;
