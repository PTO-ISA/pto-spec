// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-TILE-TESTTILEELEMENTWISEANDALIASING-EXECUTION-001","source":"asl/tile/model/execution/elementwise.asl","requirements":[],"kind":"execution","summary":"Covers Tile Elementwise And Aliasing.","pass_condition":"TestTileElementwiseAndAliasing completes without assertion failure","related_sources":[]}
func ConfigureTwoByTwo(index: TileIndex)
begin
    ConfigureTile(index, 256, 2, 2, 2, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
end;

func TestTileElementwiseAndAliasing()
begin
    ConfigureTwoByTwo(0);
    ConfigureTwoByTwo(1);
    ConfigureTwoByTwo(2);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 20);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 30);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 40);

    ExecuteTileBinary(TileBinary_ADD, 2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(2, 1, 1) == Zeros{PTO_XLEN} + 44;

    // Destination aliases source_left. Both sources are snapshotted first.
    ExecuteTileBinary(TileBinary_ADD, 0, 0, 1);
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 22;
    assert ReadTileElement(0, 1, 1) == Zeros{PTO_XLEN} + 44;

    ExecuteTileBinary(TileBinary_DIV, 2, 1, 0);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN};
    ExecuteTileFillScalar(2, Zeros{PTO_XLEN} + 3);
    ConfigureTwoByTwo(3);
    ExecuteTileFillScalar(3, Zeros{PTO_XLEN} + 5);
    TFMA(2, 0, 1, 3);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 115;
    assert ReadTileElement(2, 1, 1) == Zeros{PTO_XLEN} + 1765;
end;
func main() => integer
begin
    ResetProfileState();
    TestTileElementwiseAndAliasing();
    return 0;
end;
