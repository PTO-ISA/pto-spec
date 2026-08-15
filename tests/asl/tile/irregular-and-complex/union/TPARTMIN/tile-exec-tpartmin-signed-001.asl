// PTO-TEST: {"id":"PTO-AVS-TILE-TPARTMIN-S8-001","source":"asl/tile/irregular-and-complex/union/TPARTMIN.asl","requirements":["PTO-INST-TILE-TPARTMIN"],"kind":"execution","summary":"TPARTMIN uses signed ordering for S8 overlap values","pass_condition":"S8 minus one is selected below S8 positive one and uses the model's sign-extended Word carrier","related_sources":["asl/tile/model/execution/complex.asl","asl/tile/model/legality/indexed-layout.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(20, 128, 32, 4, 1, 1, TileDataType_S8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(21, 128, 32, 4, 1, 1, TileDataType_S8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(22, 128, 64, 2, 1, 1, TileDataType_S8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(21, 0, 0, Zeros{PTO_XLEN} + 0xff);
    WriteTileElement(22, 0, 0, Zeros{PTO_XLEN} + 1);

    ExecuteTilePartial(TilePartial_MIN, 20, 21, 22);
    assert ReadTileElement(20, 0, 0) == Ones{PTO_XLEN};
    return 0;
end;
