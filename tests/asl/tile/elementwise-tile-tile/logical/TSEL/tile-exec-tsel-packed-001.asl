// PTO-TEST: {"id":"PTO-AVS-TILE-TSEL-PACKED-001","source":"asl/tile/elementwise-tile-tile/logical/TSEL.asl","requirements":["PTO-INST-TILE-TSEL"],"kind":"execution","summary":"TSEL consumes packed predicate bits and supports destination aliasing","pass_condition":"alternating packed bits select exact source encodings after both data sources are snapshotted","related_sources":["asl/tile/model/execution/comparison.asl","asl/tile/model/definedness/elements.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigurePredicateTile(0, 128, 16, 8, 1, 4);
    ConfigureTile(1, 128, 16, 8, 1, 4,
        TileDataType_U8, TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 16, 8, 1, 4,
        TileDataType_U8, TileLayout_RowMajor, TileLocation_Any);
    for column = 0 to 3 looplimit 4 do
        WriteTilePredicateBit(0, 0, column, column MOD 2 == 0);
        WriteTileElement(1, 0, column, Zeros{PTO_XLEN} + 10 + column);
        WriteTileElement(2, 0, column, Zeros{PTO_XLEN} + 20 + column);
    end;

    ExecuteTileSelect(1, 0, 1, 2);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 10;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 21;
    assert ReadTileElement(1, 0, 2) == Zeros{PTO_XLEN} + 12;
    assert ReadTileElement(1, 0, 3) == Zeros{PTO_XLEN} + 23;
    return 0;
end;
