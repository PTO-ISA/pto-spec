// PTO-TEST: {"id":"PTO-AVS-TILE-TCONCAT-COLUMNS-001","source":"asl/tile/layout-and-rearrangement/layout/TCONCAT.asl","requirements":["PTO-TCONCAT-CONTRACT-001","PTO-INST-TILE-TCONCAT"],"kind":"execution","summary":"TCONCAT appends the right source after the left source along columns.","pass_condition":"Each row contains the complete left row followed by the complete right row.","related_sources":["asl/tile/model/execution/rearrangement.asl","asl/tile/model/legality/operand-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        1, 128, 64, 2, 2, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        2, 128, 128, 1, 2, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        3, 128, 32, 4, 2, 3, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN} + 6);
    TCONCAT(3, 1, 2);
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(3, 0, 2) == Zeros{PTO_XLEN} + 5;
    assert ReadTileElement(3, 1, 1) == Zeros{PTO_XLEN} + 4;
    assert ReadTileElement(3, 1, 2) == Zeros{PTO_XLEN} + 6;
    return 0;
end;
