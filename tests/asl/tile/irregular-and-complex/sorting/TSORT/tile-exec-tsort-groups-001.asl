// PTO-TEST: {"id":"PTO-AVS-TILE-TSORT-GROUPS-001","source":"asl/tile/irregular-and-complex/sorting/TSORT.asl","requirements":["PTO-INST-TILE-TSORT"],"kind":"execution","summary":"TSORT sorts width-bounded groups independently within each logical row","pass_condition":"each row is grouped from column zero and reports stable group-local indices","related_sources":["asl/tile/model/execution/complex.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        60, 256, 2, 4, 2, 4,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        61, 256, 2, 4, 2, 4,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        62, 256, 2, 4, 2, 4,
        TileDataType_U32,
        TileLayout_RowMajor,
        TileLocation_Any);

    WriteTileElement(60, 0, 0, Zeros{PTO_XLEN} + 0x40400000);
    WriteTileElement(60, 0, 1, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(60, 0, 2, Zeros{PTO_XLEN} + 0x40000000);
    WriteTileElement(60, 0, 3, Zeros{PTO_XLEN});
    WriteTileElement(60, 1, 0, Zeros{PTO_XLEN} + 0x40c00000);
    WriteTileElement(60, 1, 1, Zeros{PTO_XLEN} + 0x40800000);
    WriteTileElement(60, 1, 2, Zeros{PTO_XLEN} + 0x40a00000);
    WriteTileElement(60, 1, 3, Zeros{PTO_XLEN} + 0x40e00000);

    TSORT(61, 62, 60, 3, FALSE);

    assert ReadTileElement(61, 0, 0) == Zeros{PTO_XLEN} + 0x3f800000;
    assert ReadTileElement(61, 0, 2) == Zeros{PTO_XLEN} + 0x40400000;
    assert ReadTileElement(61, 0, 3) == Zeros{PTO_XLEN};
    assert ReadTileElement(61, 1, 0) == Zeros{PTO_XLEN} + 0x40800000;
    assert ReadTileElement(61, 1, 1) == Zeros{PTO_XLEN} + 0x40a00000;
    assert ReadTileElement(61, 1, 2) == Zeros{PTO_XLEN} + 0x40c00000;
    assert ReadTileElement(62, 1, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(62, 1, 1) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(62, 1, 2) == Zeros{PTO_XLEN};
    assert ReadTileElement(62, 1, 3) == Zeros{PTO_XLEN};
    return 0;
end;
