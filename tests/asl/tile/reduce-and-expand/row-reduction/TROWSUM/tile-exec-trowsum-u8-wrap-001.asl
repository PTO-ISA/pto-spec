// PTO-TEST: {"id":"PTO-AVS-TILE-TROWSUM-U8-WRAP-001","source":"asl/tile/reduce-and-expand/row-reduction/TROWSUM.asl","requirements":["PTO-INST-TILE-TROWSUM"],"kind":"execution","summary":"TROWSUM folds U8 elements in increasing-column order at U8 width.","pass_condition":"The two-element row sum wraps from 260 to four.","related_sources":["asl/tile/model/execution/reduction.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0,
        128,
        1,
        2,
        1,
        2,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1,
        128,
        1,
        1,
        1,
        1,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 250);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 10);

    ExecuteTileReduction(
        TileReduction_SUM,
        TileAxis_Row,
        1,
        0);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 4;
    return 0;
end;
