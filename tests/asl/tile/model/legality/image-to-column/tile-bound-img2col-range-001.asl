// PTO-TEST: {"id":"PTO-AVS-TILE-IMG2COL-RANGE-001","source":"asl/tile/model/legality/image-to-column.asl","requirements":["PTO-TIMG2COL-CONTRACT-001"],"kind":"boundary","summary":"Image-to-column legality rejects a destination window beyond the logical matrix extent.","pass_condition":"The origin window is legal and an equal-width window starting at posK one is rejected.","related_sources":["asl/tile/model/state/feature-map-descriptors.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        2, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(
        3, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Matrix);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 5);
    ConfigureTileFeatureMapDescriptor(
        2, TileFeatureMapLayout_NC1HWC0,
        1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1,
        0, 0, 0, 0,
        1, Zeros{PTO_XLEN}, FALSE);

    assert TileOperandsLegal_TIMG2COL(3, 2, 0, 0);
    assert !TileOperandsLegal_TIMG2COL(3, 2, 0, 1);
    return 0;
end;
