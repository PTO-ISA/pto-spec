// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-TILE-TESTTILEEXPANSION-EXECUTION-001","source":"asl/tile/model/execution/expansion.asl","requirements":[],"kind":"execution","summary":"Covers Tile Expansion.","pass_condition":"TestTileExpansion completes without assertion failure","related_sources":[]}
func ConfigureTwoByTwo(index: TileIndex)
begin
    ConfigureTile(index, 256, 2, 2, 2, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
end;

func TestTileExpansion()
begin
    ConfigureTwoByTwo(11);
    ConfigureTile(12, 256, 2, 1, 2, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTwoByTwo(13);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(11, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(11, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(11, 1, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(12, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(12, 1, 0, Zeros{PTO_XLEN} + 20);

    ExecuteTileExpand(TileExpand_ADD, TileAxis_Row, 13, 11, 12);
    assert ReadTileElement(13, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(13, 0, 1) == Zeros{PTO_XLEN} + 12;
    assert ReadTileElement(13, 1, 0) == Zeros{PTO_XLEN} + 23;
    assert ReadTileElement(13, 1, 1) == Zeros{PTO_XLEN} + 24;

    WriteTileElement(12, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(12, 1, 0, Zeros{PTO_XLEN} + 4);
    ExecuteTileExpand(TileExpand_DIV, TileAxis_Row, 13, 11, 12);
    assert ReadTileElement(13, 0, 1) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(13, 1, 1) == Zeros{PTO_XLEN} + 1;
end;
func main() => integer
begin
    ResetProfileState();
    TestTileExpansion();
    return 0;
end;
