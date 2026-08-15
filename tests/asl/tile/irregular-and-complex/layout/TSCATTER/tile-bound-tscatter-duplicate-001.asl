// PTO-TEST: {"id":"PTO-AVS-TILE-TSCATTER-DUP-001","source":"asl/tile/irregular-and-complex/layout/TSCATTER.asl","requirements":["PTO-TSCATTER-CONTRACT-001"],"kind":"boundary","summary":"TSCATTER rejects duplicate destination coordinates before effects.","pass_condition":"Two source elements selecting the same destination row and column make legality false and preserve the destination.","related_sources":["asl/tile/model/legality/indexed-rearrangement.asl"]}

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        40, 128, 2, 1, 2, 1, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        41, 128, 2, 1, 2, 1, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        42, 128, 4, 1, 3, 1, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(40, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(40, 1, 0, Zeros{PTO_XLEN} + 20);
    WriteTileElement(41, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(41, 1, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(42, 0, 0, Zeros{PTO_XLEN} + 99);
    MarkTileValidRegionDefined(42);

    assert !TileOperandsLegal_TSCATTER(42, 40, 41);
    assert ReadTileElement(42, 0, 0) == Zeros{PTO_XLEN} + 99;
    return 0;
end;
