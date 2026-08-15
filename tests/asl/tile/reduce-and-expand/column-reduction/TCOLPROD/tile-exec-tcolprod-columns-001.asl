// PTO-TEST: {"id":"PTO-AVS-TILE-TCOLPROD-COLUMNS-001","source":"asl/tile/reduce-and-expand/column-reduction/TCOLPROD.asl","requirements":["PTO-INST-TILE-TCOLPROD"],"kind":"execution","summary":"TCOLPROD multiplies each column at the selected element width.","pass_condition":"The two columns reduce independently to eight and fifteen.","related_sources":["asl/tile/model/execution/reduction.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0, 128, 2, 2, 2, 2,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1, 128, 1, 2, 1, 2,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 3);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN} + 5);

    ExecuteTileReduction(
        TileReduction_PRODUCT,
        TileAxis_Column,
        1,
        0);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 8;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 15;
    return 0;
end;
