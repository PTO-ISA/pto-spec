// PTO-TEST: {"id":"PTO-AVS-TILE-TROWEXPANDMIN-SIGNED-001","source":"asl/tile/reduce-and-expand/row-expansion/TROWEXPANDMIN.asl","requirements":["PTO-TROWEXPANDMIN-CONTRACT-001","PTO-INST-TILE-TROWEXPANDMIN"],"kind":"execution","summary":"TROWEXPANDMIN applies its exact MIN semantics with row broadcasting.","pass_condition":"The selected element equals the typed MIN result and every source remains persistent.","related_sources":["asl/tile/model/execution/expansion.asl","asl/tile/model/legality/reduction-and-expansion.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        1, 128, 32, 4, 2, 3, TileDataType_S8,
        TileLayout_RowMajor, TileLocation_Any);
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 2 looplimit 3 do
            WriteTileElement(1, row, column, Zeros{PTO_XLEN} + 255);
        end;
    end;
    ConfigureTile(
        2, 128, 128, 1,
        2, 1, TileDataType_S8,
        TileLayout_RowMajor, TileLocation_Any);
    for row = 0 to 1 looplimit 2 do
        WriteTileElement(2, row, 0, Zeros{PTO_XLEN} + 1);
    end;
    ConfigureTile(
        3, 128, 32, 4, 2, 3, TileDataType_S8,
        TileLayout_RowMajor, TileLocation_Any);
    ExecuteTileExpand(
        TileExpand_MIN,
        TileAxis_Row,
        3,
        1,
        2);
    assert ReadTileElement(3, 1, 2) == Ones{PTO_XLEN};
    assert ReadTileElement(2, 1, 0) == Zeros{PTO_XLEN} + 1;
    return 0;
end;
