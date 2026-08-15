// PTO-TEST: {"id":"PTO-AVS-TILE-TCOLEXPANDDIV-SIGNED-001","source":"asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDDIV.asl","requirements":["PTO-TCOLEXPANDDIV-CONTRACT-001","PTO-INST-TILE-TCOLEXPANDDIV"],"kind":"execution","summary":"TCOLEXPANDDIV applies its exact DIV semantics with column broadcasting.","pass_condition":"The selected element equals the typed DIV result and every source remains persistent.","related_sources":["asl/tile/model/execution/expansion.asl","asl/tile/model/legality/reduction-and-expansion.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        1, 128, 32, 4, 2, 3, TileDataType_S8,
        TileLayout_RowMajor, TileLocation_Any);
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 2 looplimit 3 do
            WriteTileElement(1, row, column, Zeros{PTO_XLEN} + 248);
        end;
    end;
    ConfigureTile(
        2, 128, 32, 4,
        1, 3, TileDataType_S8,
        TileLayout_RowMajor, TileLocation_Any);
    for column = 0 to 2 looplimit 3 do
        WriteTileElement(2, 0, column, Zeros{PTO_XLEN} + 2);
    end;
    ConfigureTile(
        3, 128, 32, 4, 2, 3, TileDataType_S8,
        TileLayout_RowMajor, TileLocation_Any);
    ExecuteTileExpand(
        TileExpand_DIV,
        TileAxis_Column,
        3,
        1,
        2);
    assert ReadTileElement(3, 1, 2) == Ones{PTO_XLEN} - 3;
    assert ReadTileElement(2, 0, 2) == Zeros{PTO_XLEN} + 2;
    return 0;
end;
