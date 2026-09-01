// PTO-TEST: {"id":"PTO-AVS-TILE-MSCATTER-BYTES-001","source":"asl/tile/memory-and-data-movement/irregular/MSCATTER.asl","requirements":["PTO-INDEXED-TLSU-STRIDE-001","PTO-INST-TILE-MSCATTER"],"kind":"execution","summary":"MSCATTER applies a padded row stride to logical linear element indices and preserves both source Tiles.","pass_condition":"Indices zero and three with ValidCol two and stride three store two U8 values at base plus zero and base plus four without changing either source.","related_sources":["asl/tile/model/memory/addressing.asl","asl/tile/model/memory/gather-scatter.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 1, 2, 1, 2, TileDataType_S64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x21);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0x54);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 3);

    StartMemoryEventCapture(0);
    MSCATTER(Zeros{PTO_XLEN} + 0x240,
        Zeros{PTO_XLEN} + 3, 0, 1);

    assert _MemoryEventCount == 2;
    let first = LoadUnsigned(Zeros{PTO_XLEN} + 0x240, 1);
    let second = LoadUnsigned(Zeros{PTO_XLEN} + 0x244, 1);
    assert first == Zeros{PTO_XLEN} + 0x21;
    assert second == Zeros{PTO_XLEN} + 0x54;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 0x54;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 3;
    StopMemoryEventCapture();
    return 0;
end;
