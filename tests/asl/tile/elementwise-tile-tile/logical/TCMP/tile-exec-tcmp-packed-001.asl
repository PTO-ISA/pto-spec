// PTO-TEST: {"id":"PTO-AVS-TILE-TCMP-PACKED-001","source":"asl/tile/elementwise-tile-tile/logical/TCMP.asl","requirements":["PTO-INST-TILE-TCMP","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"Direct TCMP fallback uses the left backing with independently compatible RowMajor sources","pass_condition":"a U8 left backing and S8 right backing compare through the direct-call left-backing fallback and pack ten results","related_sources":["asl/tile/model/execution/comparison.asl","asl/tile/model/definedness/elements.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 8, 16, 1, 10,
        TileDataType_U8, TileLayout_RowMajor);
    ConfigureTile(1, 128, 8, 16, 1, 10,
        TileDataType_S8, TileLayout_RowMajor);
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
