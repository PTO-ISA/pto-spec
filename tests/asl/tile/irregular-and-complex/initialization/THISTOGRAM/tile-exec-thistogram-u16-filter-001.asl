// PTO-TEST: {"id":"PTO-AVS-TILE-THISTOGRAM-U16-FILTER-001","source":"asl/tile/irregular-and-complex/initialization/THISTOGRAM.asl","requirements":["PTO-INST-TILE-THISTOGRAM"],"kind":"execution","summary":"U16 ByteId0 applies one high-byte filter independently to each logical row","pass_condition":"only elements whose high byte equals that row's U8 filter contribute their low byte to the cumulative histogram","related_sources":["asl/tile/model/execution/complex.asl","asl/tile/model/legality/indexed-layout.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0,
        2048,
        2,
        256,
        2,
        256,
        TileDataType_U32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1,
        128,
        16,
        4,
        2,
        2,
        TileDataType_U16,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        2,
        128,
        16,
        1,
        2,
        1,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);

    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0xaa01);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0xbb02);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 0xbb03);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 0xaa04);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0xaa);
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN} + 0xbb);

    THISTOGRAM(0, 1, 2, 0);

    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(0, 0, 255) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(0, 1, 2) == Zeros{PTO_XLEN};
    assert ReadTileElement(0, 1, 3) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(0, 1, 255) == Zeros{PTO_XLEN} + 1;
    return 0;
end;
