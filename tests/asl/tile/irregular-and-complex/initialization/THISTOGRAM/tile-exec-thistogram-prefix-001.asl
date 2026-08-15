// PTO-TEST: {"id":"PTO-AVS-TILE-THISTOGRAM-PREFIX-001","source":"asl/tile/irregular-and-complex/initialization/THISTOGRAM.asl","requirements":["PTO-INST-TILE-THISTOGRAM"],"kind":"execution","summary":"THISTOGRAM produces an inclusive U32 prefix histogram for the selected byte","pass_condition":"unfiltered U16 high bytes produce exact cumulative bins and leave physical padding undefined","related_sources":["asl/tile/model/execution/complex.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0,
        2048,
        2,
        256,
        1,
        256,
        TileDataType_U32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1,
        128,
        16,
        4,
        1,
        4,
        TileDataType_U16,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        2,
        128,
        128,
        1,
        1,
        1,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x0100);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x0200);
    WriteTileElement(1, 0, 2, Zeros{PTO_XLEN} + 0x0201);
    WriteTileElement(1, 0, 3, Zeros{PTO_XLEN} + 0xff00);

    THISTOGRAM(0, 1, 2, 1);

    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(0, 0, 2) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(0, 0, 254) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(0, 0, 255) == Zeros{PTO_XLEN} + 4;
    let padding = TileLinearIndex(_Tiles[[0]], 1, 0);
    assert _Tiles[[0]].defined_elements[padding] == '0';
    return 0;
end;
