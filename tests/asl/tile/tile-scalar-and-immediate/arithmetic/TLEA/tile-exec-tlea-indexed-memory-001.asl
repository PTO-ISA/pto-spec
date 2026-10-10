// PTO-TEST: {"id":"PTO-AVS-TILE-TLEA-INDEXED-MEMORY-001","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TLEA.asl","requirements":["PTO-TLEA-CONTRACT-001","PTO-MGATHER-BYTE-DISPLACEMENT-001","PTO-MSCATTER-BYTE-DISPLACEMENT-001"],"kind":"execution","summary":"TLEA composes with indexed TLSU by scaling logical indices exactly once.","pass_condition":"U32 logical indices one and two become byte offsets four and eight; MGATHER reads and MSCATTER writes Base plus those offsets without relying on event order.","related_sources":["asl/tile/model/execution/lea.asl","asl/tile/model/memory/gather-scatter.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 16, 2, 1, 2,
        TileDataType_U32, TileLayout_RowMajor);
    ConfigureTile(1, 128, 8, 2, 1, 2,
        TileDataType_U64, TileLayout_RowMajor);
    ConfigureTile(2, 128, 16, 2, 1, 2,
        TileDataType_U32, TileLayout_RowMajor);
    ConfigureTile(3, 128, 16, 2, 1, 2,
        TileDataType_U32, TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 0x31313131);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 0x72727272);
    Store(Zeros{PTO_XLEN} + 0x304, 4, Zeros{PTO_XLEN} + 0x14141414);
    Store(Zeros{PTO_XLEN} + 0x308, 4, Zeros{PTO_XLEN} + 0x28282828);

    StartMemoryEventCapture(0);
    TLEA(1, 0, Zeros{PTO_XLEN} + 32);
    assert _MemoryEventCount == 0;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 4;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 8;

    MGATHER(2, Zeros{PTO_XLEN} + 0x300, 1, TilePad_Null);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 0x14141414;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN} + 0x28282828;

    MSCATTER(Zeros{PTO_XLEN} + 0x380, 3, 1);
    assert _MemoryEventCount == 4;
    StopMemoryEventCapture();
    let first = LoadUnsigned(Zeros{PTO_XLEN} + 0x384, 4);
    let second = LoadUnsigned(Zeros{PTO_XLEN} + 0x388, 4);
    assert first == Zeros{PTO_XLEN} + 0x31313131;
    assert second == Zeros{PTO_XLEN} + 0x72727272;
    return 0;
end;
