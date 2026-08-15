// PTO-TEST: {"id":"PTO-AVS-TILE-TSEL-MASK-001","source":"asl/tile/elementwise-tile-tile/logical/TSEL.asl","requirements":["PTO-INST-TILE-TSEL"],"kind":"fault","summary":"TSEL rejects an ordinary numeric Tile used as its predicate mask","pass_condition":"operand legality accepts packed predicate storage and rejects an otherwise shape-matched numeric mask","related_sources":["asl/tile/model/legality/operand-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 16, 8, 1, 2,
        TileDataType_U8, TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 16, 8, 1, 2,
        TileDataType_U8, TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 16, 8, 1, 2,
        TileDataType_U8, TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(3, 128, 16, 8, 1, 2,
        TileDataType_U8, TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 4);
    assert !TileOperandsLegal_ExecuteTileSelect(3, 0, 1, 2);

    ConfigurePredicateTile(0, 128, 16, 8, 1, 2);
    WriteTilePredicateBit(0, 0, 0, FALSE);
    WriteTilePredicateBit(0, 0, 1, TRUE);
    assert TileOperandsLegal_ExecuteTileSelect(3, 0, 1, 2);
    return 0;
end;
