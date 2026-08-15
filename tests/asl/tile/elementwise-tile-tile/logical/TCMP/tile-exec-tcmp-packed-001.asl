// PTO-TEST: {"id":"PTO-AVS-TILE-TCMP-PACKED-001","source":"asl/tile/elementwise-tile-tile/logical/TCMP.asl","requirements":["PTO-INST-TILE-TCMP"],"kind":"execution","summary":"TCMP packs predicate results from low logical indices into low byte bits","pass_condition":"ten comparisons occupy bits zero through seven of byte zero and bits zero through one of byte one","related_sources":["asl/tile/model/execution/comparison.asl","asl/tile/model/definedness/elements.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 8, 16, 1, 10,
        TileDataType_U8, TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 8, 16, 1, 10,
        TileDataType_U8, TileLayout_RowMajor, TileLocation_Any);
    ConfigurePredicateTile(2, 128, 8, 16, 1, 10);
    for column = 0 to 9 looplimit 10 do
        WriteTileElement(0, 0, column, Zeros{PTO_XLEN} + column);
        WriteTileElement(1, 0, column,
            Zeros{PTO_XLEN} + (if column MOD 2 == 0 then column else 0));
    end;

    ExecuteTileCompare(2, 0, 1, TileComparison_EQ);

    assert ReadTilePredicateByte(2, 0) == '01010101';
    assert ReadTilePredicateByte(2, 1) == '00000001';
    assert TilePredicateBitDefined(2, 0, 9);
    return 0;
end;
