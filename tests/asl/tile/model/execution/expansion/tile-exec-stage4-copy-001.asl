// PTO-TEST: {"id":"PTO-AVS-TILE-STAGE4-COPY-001","source":"asl/tile/model/execution/expansion.asl","requirements":[],"kind":"execution","summary":"assigned expansion copy and scalar initialization preserve raw carriers","pass_condition":"TF32 COPY preserves raw internally invalid encodings and U8 scalar fill retains the low physical-width payload","related_sources":["asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/generation.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 2, 1, 2, 1, TileDataType_TF32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 2, 2, 2, 2, TileDataType_TF32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x3f800001);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 0x3f800002);
    assert !TileNumericEncodingValid(
        TileDataType_TF32, Zeros{PTO_XLEN} + 0x3f800001);
    assert TileOperandsLegal_ExecuteTileExpand(
        TileExpand_COPY, TileAxis_Row, 1, 0, 0);
    ExecuteTileExpand(TileExpand_COPY, TileAxis_Row, 1, 0, 0);
    assert _Tiles[[1]].data_type == TileDataType_TF32;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0x3f800001;
    assert ReadTileElement(1, 1, 0) == Zeros{PTO_XLEN} + 0x3f800002;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 0x3f800001;
    assert ReadTileElement(1, 1, 1) == Zeros{PTO_XLEN} + 0x3f800002;

    ConfigureTile(2, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    assert TileOperandsLegal_ExecuteTileFillScalar(
        2, Zeros{PTO_XLEN} + 0xff);
    ExecuteTileFillScalar(2, Zeros{PTO_XLEN} + 0x1ff);
    assert _Tiles[[2]].data_type == TileDataType_U8;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 0xff;
    return 0;
end;
