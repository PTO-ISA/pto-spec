// PTO-TEST: {"id":"PTO-AVS-TILE-TROWMIN-S8-001","source":"asl/tile/reduce-and-expand/row-reduction/TROWMIN.asl","requirements":["PTO-INST-TILE-TROWMIN"],"kind":"execution","summary":"TROWMIN compares signed elements at their declared width.","pass_condition":"Signed S8 negative one is selected over positive one.","related_sources":["asl/tile/model/execution/reduction.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0, 128, 1, 2, 1, 2,
        TileDataType_S8,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1, 128, 1, 1, 1, 1,
        TileDataType_S8,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xff);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 1);

    ExecuteTileReduction(
        TileReduction_MIN,
        TileAxis_Row,
        1,
        0);

    assert ReadTileElement(1, 0, 0) == Ones{PTO_XLEN};
    return 0;
end;
