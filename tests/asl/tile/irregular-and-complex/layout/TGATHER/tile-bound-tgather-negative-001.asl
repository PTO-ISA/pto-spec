// PTO-TEST: {"id":"PTO-AVS-TILE-TGATHER-NEGATIVE-001","source":"asl/tile/irregular-and-complex/layout/TGATHER.asl","requirements":["PTO-TGATHER-CONTRACT-001"],"kind":"boundary","summary":"TGATHER rejects a negative signed row index before destination effects.","pass_condition":"S32 minus one is illegal and the destination payload remains unchanged.","related_sources":["asl/tile/model/legality/indexed-rearrangement.asl"]}

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        40, 128, 2, 1, 2, 1, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        41, 128, 1, 1, 1, 1, TileDataType_S32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        42, 128, 1, 1, 1, 1, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(40, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(40, 1, 0, Zeros{PTO_XLEN} + 8);
    WriteTileElement(41, 0, 0, Zeros{PTO_XLEN} + 4294967295);
    WriteTileElement(42, 0, 0, Zeros{PTO_XLEN} + 99);

    assert !TileOperandsLegal_TGATHER(42, 40, 41);
    assert ReadTileElement(42, 0, 0) == Zeros{PTO_XLEN} + 99;
    return 0;
end;
