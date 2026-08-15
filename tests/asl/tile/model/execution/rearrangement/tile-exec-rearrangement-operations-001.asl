// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-TILE-TESTTILEREARRANGEMENT-EXECUTION-001","source":"asl/tile/model/execution/rearrangement.asl","requirements":[],"kind":"execution","summary":"Covers Tile Rearrangement.","pass_condition":"TestTileRearrangement completes without assertion failure","related_sources":[]}
func ConfigureTwoByTwo(index: TileIndex)
begin
    ConfigureTile(index, 256, 2, 2, 2, 2, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
end;

func TestTileRearrangement()
begin
    ConfigureTwoByTwo(16);
    WriteTileElement(16, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(16, 0, 1, Zeros{PTO_XLEN} + 20);
    WriteTileElement(16, 1, 0, Zeros{PTO_XLEN} + 30);
    WriteTileElement(16, 1, 1, Zeros{PTO_XLEN} + 40);

    ConfigureTile(17, 256, 1, 2, 1, 2, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    TEXTRACT(17, 16, 1, 0);
    assert ReadTileElement(17, 0, 0) == Zeros{PTO_XLEN} + 30;
    assert ReadTileElement(17, 0, 1) == Zeros{PTO_XLEN} + 40;

    ConfigureTwoByTwo(18);
    TTRANS(18, 16);
    assert ReadTileElement(18, 0, 1) == Zeros{PTO_XLEN} + 30;
    assert ReadTileElement(18, 1, 0) == Zeros{PTO_XLEN} + 20;

    ConfigureTile(19, 256, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(19, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(19, 0, 1, Zeros{PTO_XLEN});
    ConfigureTile(20, 256, 1, 2, 1, 2, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    TGATHER(20, 16, 19);
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 30;
    assert ReadTileElement(20, 0, 1) == Zeros{PTO_XLEN} + 20;

end;
func main() => integer
begin
    ResetProfileState();
    TestTileRearrangement();
    return 0;
end;
