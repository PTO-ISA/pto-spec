// PTO-TEST: {"id":"PTO-AVS-TILE-TCOLSUM-COLUMNS-001","source":"asl/tile/reduce-and-expand/column-reduction/TCOLSUM.asl","requirements":["PTO-INST-TILE-TCOLSUM"],"kind":"execution","summary":"TCOLSUM folds each column in increasing-row order.","pass_condition":"The two columns reduce independently to four and six.","related_sources":["asl/tile/model/execution/reduction.asl"]}
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
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN} + 4);

    ExecuteTileReduction(
        TileReduction_SUM,
        TileAxis_Column,
        1,
        0);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 4;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 6;
    return 0;
end;
