// PTO-TEST: {"id":"PTO-AVS-TILE-TROWEXPANDSUB-TYPED-001","source":"asl/tile/reduce-and-expand/row-expansion/TROWEXPANDSUB.asl","requirements":["PTO-TROWEXPANDSUB-CONTRACT-001","PTO-INST-TILE-TROWEXPANDSUB"],"kind":"execution","summary":"TROWEXPANDSUB applies its exact SUB semantics with row broadcasting.","pass_condition":"The selected element equals the typed SUB result and every source remains persistent.","related_sources":["asl/tile/model/execution/expansion.asl","asl/tile/model/legality/reduction-and-expansion.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        1, 128, 32, 4, 2, 3, TileDataType_S8,
        TileLayout_RowMajor, TileLocation_Any);
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 2 looplimit 3 do
            WriteTileElement(1, row, column, Zeros{PTO_XLEN} + 2);
        end;
    end;
    ConfigureTile(
        2, 128, 128, 1,
        2, 1, TileDataType_S8,
        TileLayout_RowMajor, TileLocation_Any);
    for row = 0 to 1 looplimit 2 do
        WriteTileElement(2, row, 0, Zeros{PTO_XLEN} + 253);
    end;
    ConfigureTile(
        3, 128, 32, 4, 2, 3, TileDataType_S8,
        TileLayout_RowMajor, TileLocation_Any);
    ExecuteTileExpand(
        TileExpand_SUB,
        TileAxis_Row,
        3,
        1,
        2);
    assert ReadTileElement(3, 1, 2) == Zeros{PTO_XLEN} + 5;
    assert ReadTileElement(2, 1, 0) == Zeros{PTO_XLEN} + 253;
    return 0;
end;
