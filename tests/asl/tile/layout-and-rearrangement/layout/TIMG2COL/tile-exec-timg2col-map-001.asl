// PTO-TEST: {"id":"PTO-AVS-TILE-TIMG2COL-MAP-001","source":"asl/tile/layout-and-rearrangement/layout/TIMG2COL.asl","requirements":["PTO-TIMG2COL-CONTRACT-001","PTO-INST-TILE-TIMG2COL"],"kind":"execution","summary":"TIMG2COL maps one NC1HWC0 feature-map window into standard Left matrix order.","pass_condition":"The destination row contains the source patch in packed C1/filter-row/filter-column/C0 order.","related_sources":["asl/tile/model/state/feature-map-descriptors.asl","asl/tile/model/legality/image-to-column.asl","asl/tile/model/execution/image-to-column.asl"]}

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        40,
        128,
        1,
        4,
        1,
        4,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Matrix);
    ConfigureTile(
        41,
        128,
        1,
        4,
        1,
        4,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Matrix);

    WriteTileElement(40, 0, 0, Zeros{PTO_XLEN} + 11);
    WriteTileElement(40, 0, 1, Zeros{PTO_XLEN} + 12);
    WriteTileElement(40, 0, 2, Zeros{PTO_XLEN} + 13);
    WriteTileElement(40, 0, 3, Zeros{PTO_XLEN} + 14);
    MarkTileValidRegionDefined(40);
    ConfigureTileFeatureMapDescriptor(
        40,
        TileFeatureMapLayout_NC1HWC0,
        1,
        1,
        1,
        2,
        2,
        1,
        2,
        2,
        1,
        1,
        1,
        1,
        0,
        0,
        0,
        0,
        1,
        Zeros{PTO_XLEN} + 99,
        FALSE);

    assert TileOperandsLegal_TIMG2COL(41, 40, 0, 0);
    TIMG2COL(41, 40, 0, 0);

    assert ReadTileElement(41, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(41, 0, 1) == Zeros{PTO_XLEN} + 12;
    assert ReadTileElement(41, 0, 2) == Zeros{PTO_XLEN} + 13;
    assert ReadTileElement(41, 0, 3) == Zeros{PTO_XLEN} + 14;
    assert _Tiles[[40]].contents_defined;
    return 0;
end;
