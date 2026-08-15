// PTO-TEST: {"id":"PTO-AVS-TILE-TCOLMIN-S8-001","source":"asl/tile/reduce-and-expand/column-reduction/TCOLMIN.asl","requirements":["PTO-INST-TILE-TCOLMIN"],"kind":"execution","summary":"TCOLMIN compares signed elements independently by column.","pass_condition":"The two S8 column minima are negative one and negative two.","related_sources":["asl/tile/model/execution/reduction.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0, 128, 2, 2, 2, 2,
        TileDataType_S8,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1, 128, 1, 2, 1, 2,
        TileDataType_S8,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xff);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 5);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN} + 0xfe);

    ExecuteTileReduction(
        TileReduction_MIN,
        TileAxis_Column,
        1,
        0);

    assert ReadTileElement(1, 0, 0) == Ones{PTO_XLEN};
    assert ReadTileElement(1, 0, 1) == Ones{PTO_XLEN} - 1;
    return 0;
end;
