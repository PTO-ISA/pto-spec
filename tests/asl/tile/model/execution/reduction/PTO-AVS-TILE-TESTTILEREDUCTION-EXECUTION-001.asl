// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-TILE-TESTTILEREDUCTION-EXECUTION-001","source":"asl/tile/model/execution/reduction.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for TestTileReduction","pass_condition":"TestTileReduction completes without assertion failure","related_sources":[]}
func ConfigureTwoByTwo(index: TileIndex)
begin
    ConfigureTile(index, 256, 2, 2, 2, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
end;

func TestTileReduction()
begin
    ConfigureTwoByTwo(8);
    ConfigureTile(9, 256, 2, 1, 2, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(10, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(8, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(8, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(8, 1, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(8, 1, 1, Zeros{PTO_XLEN} + 3);

    ExecuteTileReduction(TileReduction_SUM, TileAxis_Row, 9, 8);
    assert ReadTileElement(9, 0, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(9, 1, 0) == Zeros{PTO_XLEN} + 7;

    ExecuteTileReduction(TileReduction_ARGMAX, TileAxis_Column, 10, 8);
    assert ReadTileElement(10, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(10, 0, 1) == Zeros{PTO_XLEN} + 1;
end;
func main() => integer
begin
    ResetProfileState();
    TestTileReduction();
    return 0;
end;
