// PTO-TEST: {"id":"PTO-AVS-TILE-THISTOGRAM-U32-PREFIX-001","source":"asl/tile/irregular-and-complex/initialization/THISTOGRAM.asl","requirements":["PTO-INST-TILE-THISTOGRAM"],"kind":"execution","summary":"U32 ByteId0 consumes a three-byte global prefix before histogramming the low byte","pass_condition":"only values matching filter rows zero through two in high-to-low order contribute to the cumulative low-byte histogram","related_sources":["asl/tile/model/execution/complex.asl","asl/tile/model/legality/indexed-layout.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0,
        1024,
        1,
        256,
        1,
        256,
        TileDataType_U32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1,
        128,
        8,
        4,
        1,
        4,
        TileDataType_U32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        2,
        128,
        16,
        2,
        3,
        1,
        TileDataType_U8,
        TileLayout_ColumnMajor,
        TileLocation_Any);

    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0xaabbcc01);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0xaabbcc02);
    WriteTileElement(1, 0, 2, Zeros{PTO_XLEN} + 0xaabbdd01);
    WriteTileElement(1, 0, 3, Zeros{PTO_XLEN} + 0x11223301);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0xaa);
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN} + 0xbb);
    WriteTileElement(2, 2, 0, Zeros{PTO_XLEN} + 0xcc);

    THISTOGRAM(0, 1, 2, 0);

    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(0, 0, 2) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(0, 0, 255) == Zeros{PTO_XLEN} + 2;
    return 0;
end;
