// PTO-TEST: {"id":"PTO-AVS-TILE-MSCATTER-BYTES-001","source":"asl/tile/memory-and-data-movement/irregular/MSCATTER.asl","requirements":["PTO-INDEXED-TLSU-STRIDE-001","PTO-MSCATTER-BYTE-DISPLACEMENT-001","PTO-INST-TILE-MSCATTER"],"kind":"execution","summary":"MSCATTER applies a padded row stride to one relative index per source row and preserves both source Tiles.","pass_condition":"Row index one with ValidCol two and stride three stores two U8 values at base plus three and four without changing either source.","related_sources":["asl/tile/model/memory/addressing.asl","asl/tile/model/memory/gather-scatter.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_S32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x21);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0x54);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);

    StartMemoryEventCapture(0);
    MSCATTER(Zeros{PTO_XLEN} + 0x240,
        Zeros{PTO_XLEN} + 3, 0, 1);

    assert _MemoryEventCount == 2;
    let first = LoadUnsigned(Zeros{PTO_XLEN} + 0x243, 1);
    let second = LoadUnsigned(Zeros{PTO_XLEN} + 0x244, 1);
    assert first == Zeros{PTO_XLEN} + 0x21;
    assert second == Zeros{PTO_XLEN} + 0x54;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 0x54;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 1;
    StopMemoryEventCapture();
    return 0;
end;
