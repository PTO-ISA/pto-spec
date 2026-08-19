// PTO-TEST: {"id":"PTO-AVS-TILE-MATRIX-PARAMS-002","source":"asl/tile/model/legality/matrix-postprocess.asl","requirements":["PTO-MATRIX-POSTPROCESS-BITEXACT-001","PTO-FP19-PARAMETER-CARRIER-001"],"kind":"boundary","summary":"Matrix vector parameter preflight rejects subnormal FP19 carriers","pass_condition":"normal quantization and activation carriers pass while subnormal and nonzero-unused-bit words reject","related_sources":["asl/block/attributes/B.FPATR.asl","asl/arch/data-types/fp19.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);

    let normal_scale = MatrixQuantParameter(
        Zeros{19} + 0x400, Zeros{PTO_XLEN}, 9);
    let subnormal_scale = MatrixQuantParameter(
        Zeros{19} + 1, Zeros{PTO_XLEN}, 9);
    WriteTileElement(0, 0, 0, normal_scale);
    WriteTileElement(0, 0, 1, normal_scale);
    assert TileMatrixVectorQuantContentsLegal(0, Zeros{6} + 2);
    WriteTileElement(0, 0, 1, subnormal_scale);
    assert !TileMatrixVectorQuantContentsLegal(0, Zeros{6} + 2);

    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x400);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN});
    assert TileMatrixVectorReluContentsLegal(0);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 1);
    assert !TileMatrixVectorReluContentsLegal(0);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0x80000);
    assert !TileMatrixVectorReluContentsLegal(0);
    return 0;
end;
