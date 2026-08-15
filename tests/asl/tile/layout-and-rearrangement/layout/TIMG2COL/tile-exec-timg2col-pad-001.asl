// PTO-TEST: {"id":"PTO-AVS-TILE-TIMG2COL-PAD-001","source":"asl/tile/layout-and-rearrangement/layout/TIMG2COL.asl","requirements":["PTO-TIMG2COL-CONTRACT-001"],"kind":"execution","summary":"TIMG2COL uses descriptor padding for packed channels outside the logical channel count.","pass_condition":"The assigned channel is copied and the unassigned packed channel receives the typed descriptor padding value.","related_sources":["asl/tile/model/state/feature-map-descriptors.asl","asl/tile/model/legality/image-to-column.asl","asl/tile/model/execution/image-to-column.asl"]}

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        42,
        128,
        1,
        2,
        1,
        2,
        TileDataType_S16,
        TileLayout_RowMajor,
        TileLocation_Matrix);
    ConfigureTile(
        43,
        128,
        1,
        2,
        1,
        2,
        TileDataType_S16,
        TileLayout_RowMajor,
        TileLocation_Matrix);

    WriteTileElement(42, 0, 0, Zeros{PTO_XLEN} + 21);
    ConfigureTileFeatureMapDescriptor(
        42,
        TileFeatureMapLayout_NC1HWC0,
        1,
        1,
        1,
        1,
        1,
        2,
        1,
        1,
        1,
        1,
        1,
        1,
        0,
        0,
        0,
        0,
        1,
        Zeros{PTO_XLEN} + 77,
        FALSE);

    assert TileOperandsLegal_TIMG2COL(43, 42, 0, 0);
    TIMG2COL(43, 42, 0, 0);

    assert ReadTileElement(43, 0, 0) == Zeros{PTO_XLEN} + 21;
    assert ReadTileElement(43, 0, 1) == Zeros{PTO_XLEN} + 77;
    assert _Tiles[[43]].contents_defined;
    return 0;
end;
