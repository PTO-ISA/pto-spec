// PTO-TEST: {"id":"PTO-AVS-TILE-MATRIX-VPRELU-DESC-001","source":"asl/tile/model/legality/matrix-postprocess.asl","requirements":[],"kind":"boundary","summary":"vector PReLU uses one finite nonnegative FP19 value per output column","pass_condition":"zero and positive one pass while a nonzero bit above the low nineteen-bit carrier rejects","related_sources":["asl/block/attributes/B.FPATR.asl"]}

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x0001fc00);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN});

    assert TileMatrixVectorReluContentsLegal(0);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x00080000);
    assert !TileMatrixVectorReluContentsLegal(0);
    return 0;
end;
