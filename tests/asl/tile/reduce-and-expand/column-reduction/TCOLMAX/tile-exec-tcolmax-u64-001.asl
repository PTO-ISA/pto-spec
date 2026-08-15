// PTO-TEST: {"id":"PTO-AVS-TILE-TCOLMAX-U64-001","source":"asl/tile/reduce-and-expand/column-reduction/TCOLMAX.asl","requirements":["PTO-INST-TILE-TCOLMAX"],"kind":"execution","summary":"TCOLMAX compares U64 elements as unsigned values.","pass_condition":"The all-ones value wins in each column regardless of row.","related_sources":["asl/tile/model/execution/reduction.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0, 128, 2, 2, 2, 2,
        TileDataType_U64,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1, 128, 1, 2, 1, 2,
        TileDataType_U64,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(0, 0, 0, Ones{PTO_XLEN});
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(0, 1, 1, Ones{PTO_XLEN});

    ExecuteTileReduction(
        TileReduction_MAX,
        TileAxis_Column,
        1,
        0);

    assert ReadTileElement(1, 0, 0) == Ones{PTO_XLEN};
    assert ReadTileElement(1, 0, 1) == Ones{PTO_XLEN};
    return 0;
end;
