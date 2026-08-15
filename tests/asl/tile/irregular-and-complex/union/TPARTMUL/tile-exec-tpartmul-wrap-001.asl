// PTO-TEST: {"id":"PTO-AVS-TILE-TPARTMUL-WRAP-001","source":"asl/tile/irregular-and-complex/union/TPARTMUL.asl","requirements":["PTO-INST-TILE-TPARTMUL"],"kind":"execution","summary":"TPARTMUL applies element-width multiplication only in the overlap","pass_condition":"U8 16 times 16 wraps to zero while the full-source tail is copied unchanged","related_sources":["asl/tile/model/execution/complex.asl","asl/tile/model/legality/indexed-layout.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(20, 128, 32, 4, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(21, 128, 32, 4, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(22, 128, 64, 2, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(21, 0, 0, Zeros{PTO_XLEN} + 16);
    WriteTileElement(21, 0, 1, Zeros{PTO_XLEN} + 9);
    WriteTileElement(22, 0, 0, Zeros{PTO_XLEN} + 16);

    ExecuteTilePartial(TilePartial_MUL, 20, 21, 22);
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(20, 0, 1) == Zeros{PTO_XLEN} + 9;
    return 0;
end;
