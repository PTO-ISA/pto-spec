// PTO-TEST: {"id":"PTO-AVS-TILE-TROWMAX-U64-001","source":"asl/tile/reduce-and-expand/row-reduction/TROWMAX.asl","requirements":["PTO-INST-TILE-TROWMAX"],"kind":"execution","summary":"TROWMAX compares U64 values as unsigned elements.","pass_condition":"The all-ones U64 value is selected over one.","related_sources":["asl/tile/model/execution/reduction.asl"]}
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
        TileDataType_U64,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1,
        128,
        1,
        1,
        1,
        1,
        TileDataType_U64,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(0, 0, 0, Ones{PTO_XLEN});
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 1);

    ExecuteTileReduction(
        TileReduction_MAX,
        TileAxis_Row,
        1,
        0);

    assert ReadTileElement(1, 0, 0) == Ones{PTO_XLEN};
    return 0;
end;
