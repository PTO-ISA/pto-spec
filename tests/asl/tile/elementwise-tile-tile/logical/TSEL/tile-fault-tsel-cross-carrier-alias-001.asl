// PTO-TEST: {"id":"PTO-AVS-TILE-TSEL-CROSS-CARRIER-ALIAS-001","source":"asl/tile/elementwise-tile-tile/logical/TSEL.asl","requirements":["PTO-TSEL-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"fault","summary":"TSEL rejects an aliased cross-type destination that would require retagging the source","pass_condition":"a source/destination alias with S8 storage rejects under U8 operation typing before any payload effect","related_sources":["asl/tile/model/legality/operand-schema.asl","asl/tile/model/execution/comparison.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigurePredicateTile(0, 128, 8, 2, 1, 2);
    ConfigureTile(1, 128, 8, 2, 1, 2, TileDataType_S8,
        TileLayout_RowMajor);
    ConfigureTile(2, 128, 8, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor);
    WriteTilePredicateBit(0, 0, 0, TRUE);
    WriteTilePredicateBit(0, 0, 1, FALSE);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 11);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 20);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 21);
    assert !TileOperandsLegal_ExecuteTileSelectAs(
        1, 0, 1, 2, TileDataType_U8);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 10;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 11;
    return 0;
end;
