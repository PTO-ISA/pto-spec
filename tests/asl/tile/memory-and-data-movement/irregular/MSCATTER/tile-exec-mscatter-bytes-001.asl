// PTO-TEST: {"id":"PTO-AVS-TILE-MSCATTER-BYTES-001","source":"asl/tile/memory-and-data-movement/irregular/MSCATTER.asl","requirements":["PTO-MSCATTER-BYTE-DISPLACEMENT-001","PTO-INST-TILE-MSCATTER"],"kind":"execution","summary":"MSCATTER uses unsigned byte displacements and preserves both source Tiles.","pass_condition":"Displacements zero and four store two U32 values at Base plus zero and Base plus four without changing either source.","related_sources":["asl/tile/model/memory/addressing.asl","asl/tile/model/memory/gather-scatter.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor);
    ConfigureTile(1, 128, 1, 2, 1, 2, TileDataType_S64,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x21212121);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0x54545454);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 4);

    StartMemoryEventCapture(0);
    MSCATTER(Zeros{PTO_XLEN} + 0x240,
        0, 1);

    assert _MemoryEventCount == 2;
    let first = LoadUnsigned(Zeros{PTO_XLEN} + 0x240, 4);
    let second = LoadUnsigned(Zeros{PTO_XLEN} + 0x244, 4);
    assert first == Zeros{PTO_XLEN} + 0x21212121;
    assert second == Zeros{PTO_XLEN} + 0x54545454;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 0x54545454;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 4;
    StopMemoryEventCapture();
    return 0;
end;
