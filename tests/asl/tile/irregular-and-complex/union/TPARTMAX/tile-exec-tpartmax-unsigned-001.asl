// PTO-TEST: {"id":"PTO-AVS-TILE-TPARTMAX-U8-001","source":"asl/tile/irregular-and-complex/union/TPARTMAX.asl","requirements":["PTO-INST-TILE-TPARTMAX"],"kind":"execution","summary":"TPARTMAX uses unsigned ordering for U8 overlap values","pass_condition":"U8 250 is selected over U8 5 instead of being treated as a negative signed byte","related_sources":["asl/tile/model/execution/complex.asl","asl/tile/model/legality/indexed-layout.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(20, 128, 32, 4, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(21, 128, 32, 4, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(22, 128, 64, 2, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(21, 0, 0, Zeros{PTO_XLEN} + 250);
    WriteTileElement(22, 0, 0, Zeros{PTO_XLEN} + 5);

    ExecuteTilePartial(TilePartial_MAX, 20, 21, 22);
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 250;
    return 0;
end;
