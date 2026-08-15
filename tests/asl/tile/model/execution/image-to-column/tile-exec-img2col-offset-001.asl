// PTO-TEST: {"id":"PTO-AVS-TILE-IMG2COL-OFFSET-001","source":"asl/tile/model/execution/image-to-column.asl","requirements":["PTO-TIMG2COL-CONTRACT-001"],"kind":"execution","summary":"Image-to-column execution applies posK before decomposing packed columns.","pass_condition":"A one-column destination at posK one receives the second packed channel.","related_sources":["asl/tile/model/legality/image-to-column.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        4, 128, 1, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(
        5, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Matrix);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 31);
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN} + 32);
    ConfigureTileFeatureMapDescriptor(
        4, TileFeatureMapLayout_NC1HWC0,
        1, 1, 1, 1, 1, 2,
        1, 1, 1, 1, 1, 1,
        0, 0, 0, 0,
        2, Zeros{PTO_XLEN}, FALSE);

    TIMG2COL(5, 4, 0, 1);
    assert ReadTileElement(5, 0, 0) == Zeros{PTO_XLEN} + 32;
    return 0;
end;
