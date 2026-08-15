// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-TILE-TESTTILEGENERATION-EXECUTION-001","source":"asl/tile/model/execution/generation.asl","requirements":[],"kind":"execution","summary":"Covers Tile Generation.","pass_condition":"TestTileGeneration completes without assertion failure","related_sources":[]}
func ConfigureTwoByTwo(index: TileIndex)
begin
    ConfigureTile(index, 256, 2, 2, 2, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
end;

func TestTileGeneration()
begin
    ConfigureTwoByTwo(14);
    TCI(14, Zeros{PTO_XLEN} + 5, FALSE);
    assert ReadTileElement(14, 0, 0) == Zeros{PTO_XLEN} + 5;
    assert ReadTileElement(14, 1, 1) == Zeros{PTO_XLEN} + 8;

    TTRI(14, FALSE, 0);
    assert ReadTileElement(14, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(14, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(14, 1, 1) == Zeros{PTO_XLEN} + 1;

    ConfigureTile(15, 256, 3, 4, 3, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    TFILLPAD(15, 14, Zeros{PTO_XLEN} + 9);
    assert ReadTileElement(15, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(15, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(15, 2, 2) == Zeros{PTO_XLEN} + 9;
end;
func main() => integer
begin
    ResetProfileState();
    TestTileGeneration();
    return 0;
end;
