// PTO-TEST: {"id":"PTO-AVS-TILE-TMRGSORT-STABLE-001","source":"asl/tile/irregular-and-complex/sorting/TMRGSORT.asl","requirements":["PTO-INST-TILE-TMRGSORT"],"kind":"execution","summary":"TMRGSORT treats signed zeros as equal and chooses the left stream first","pass_condition":"positive zero from the left precedes negative zero from the right","related_sources":["asl/tile/model/execution/complex.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        30, 256, 1, 2, 1, 2,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        31, 256, 1, 2, 1, 2,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        32, 256, 1, 4, 1, 4,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(30, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(30, 0, 1, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(31, 0, 0, Zeros{PTO_XLEN} + 0x80000000);
    WriteTileElement(31, 0, 1, Zeros{PTO_XLEN} + 0x40000000);

    TMRGSORT(32, 30, 31, FALSE);

    assert ReadTileElement(32, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(32, 0, 1) == Zeros{PTO_XLEN} + 0x80000000;
    assert ReadTileElement(32, 0, 2) == Zeros{PTO_XLEN} + 0x3f800000;
    assert ReadTileElement(32, 0, 3) == Zeros{PTO_XLEN} + 0x40000000;
    return 0;
end;
