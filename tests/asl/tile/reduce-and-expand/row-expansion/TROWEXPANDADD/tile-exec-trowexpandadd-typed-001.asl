// PTO-TEST: {"id":"PTO-AVS-TILE-TROWEXPANDADD-TYPED-001","source":"asl/tile/reduce-and-expand/row-expansion/TROWEXPANDADD.asl","requirements":["PTO-TROWEXPANDADD-CONTRACT-001","PTO-INST-TILE-TROWEXPANDADD"],"kind":"execution","summary":"TROWEXPANDADD applies its exact ADD semantics with row broadcasting.","pass_condition":"The selected element equals the typed ADD result and every source remains persistent.","related_sources":["asl/tile/model/execution/expansion.asl","asl/tile/model/legality/reduction-and-expansion.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        1, 128, 32, 4, 2, 3, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 2 looplimit 3 do
            WriteTileElement(1, row, column, Zeros{PTO_XLEN} + 250);
        end;
    end;
    ConfigureTile(
        2, 128, 128, 1,
        2, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    for row = 0 to 1 looplimit 2 do
        WriteTileElement(2, row, 0, Zeros{PTO_XLEN} + 10);
    end;
    ConfigureTile(
        3, 128, 32, 4, 2, 3, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ExecuteTileExpand(
        TileExpand_ADD,
        TileAxis_Row,
        3,
        1,
        2);
    assert ReadTileElement(3, 1, 2) == Zeros{PTO_XLEN} + 4;
    assert ReadTileElement(2, 1, 0) == Zeros{PTO_XLEN} + 10;
    return 0;
end;
