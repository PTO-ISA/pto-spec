// PTO-TEST: {"id":"PTO-AVS-TILE-TPARTADD-OVERLAP-001","source":"asl/tile/irregular-and-complex/union/TPARTADD.asl","requirements":["PTO-INST-TILE-TPARTADD"],"kind":"execution","summary":"TPARTADD adds the overlap and copies the source-only tail","pass_condition":"S16 overlap addition is typed while the uncovered-right-source tail is copied bit-for-bit","related_sources":["asl/tile/model/execution/complex.asl","asl/tile/model/legality/indexed-layout.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(20, 128, 16, 4, 1, 3, TileDataType_S16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(21, 128, 16, 4, 1, 3, TileDataType_S16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(22, 128, 32, 2, 1, 2, TileDataType_S16,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(21, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(21, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(21, 0, 2, Zeros{PTO_XLEN} + 7);
    WriteTileElement(22, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(22, 0, 1, Zeros{PTO_XLEN} + 4);

    ExecuteTilePartial(TilePartial_ADD, 20, 21, 22);
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 4;
    assert ReadTileElement(20, 0, 1) == Zeros{PTO_XLEN} + 6;
    assert ReadTileElement(20, 0, 2) == Zeros{PTO_XLEN} + 7;
    return 0;
end;
