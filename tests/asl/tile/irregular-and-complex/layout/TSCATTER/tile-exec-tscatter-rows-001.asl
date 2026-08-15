// PTO-TEST: {"id":"PTO-AVS-TILE-TSCATTER-ROWS-001","source":"asl/tile/irregular-and-complex/layout/TSCATTER.asl","requirements":["PTO-TSCATTER-CONTRACT-001","PTO-INST-TILE-TSCATTER"],"kind":"execution","summary":"TSCATTER writes source elements to selected destination rows and zero-initializes all other positions.","pass_condition":"Each source[r,c] reaches destination[index[r,c],c] and every unwritten valid or padding element is typed zero.","related_sources":["asl/tile/model/legality/indexed-rearrangement.asl","asl/tile/model/execution/indexed-rearrangement.asl"]}

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        40, 128, 2, 2, 2, 2, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        41, 128, 2, 2, 2, 2, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        42, 128, 4, 2, 4, 2, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(40, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(40, 0, 1, Zeros{PTO_XLEN} + 11);
    WriteTileElement(40, 1, 0, Zeros{PTO_XLEN} + 20);
    WriteTileElement(40, 1, 1, Zeros{PTO_XLEN} + 21);
    WriteTileElement(41, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(41, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(41, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(41, 1, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(42, 0, 0, Zeros{PTO_XLEN} + 99);
    MarkTileValidRegionDefined(42);

    assert TileOperandsLegal_TSCATTER(42, 40, 41);
    TSCATTER(42, 40, 41);
    assert ReadTileElement(42, 2, 0) == Zeros{PTO_XLEN} + 10;
    assert ReadTileElement(42, 0, 1) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(42, 3, 0) == Zeros{PTO_XLEN} + 20;
    assert ReadTileElement(42, 1, 1) == Zeros{PTO_XLEN} + 21;
    assert ReadTileElement(42, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(42, 3, 1) == Zeros{PTO_XLEN};
    return 0;
end;
