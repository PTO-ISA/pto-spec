// PTO-TEST: {"id":"PTO-AVS-TILE-TCOLARGMIN-TIE-001","source":"asl/tile/reduce-and-expand/column-reduction/TCOLARGMIN.asl","requirements":["PTO-INST-TILE-TCOLARGMIN"],"kind":"execution","summary":"TCOLARGMIN returns the lowest row index among equal minima.","pass_condition":"Both columns report the first winning row as U32 indices.","related_sources":["asl/tile/model/execution/reduction.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0, 128, 4, 2, 3, 2,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1, 128, 1, 2, 1, 2,
        TileDataType_U32,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 7);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN} + 3);
    WriteTileElement(0, 2, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(0, 2, 1, Zeros{PTO_XLEN} + 3);

    ExecuteTileReduction(
        TileReduction_ARGMIN,
        TileAxis_Column,
        1,
        0);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 1;
    return 0;
end;
