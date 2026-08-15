// PTO-TEST: {"id":"PTO-AVS-TILE-TCOLEXPANDMAX-UNSIGNED-001","source":"asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDMAX.asl","requirements":["PTO-TCOLEXPANDMAX-CONTRACT-001","PTO-INST-TILE-TCOLEXPANDMAX"],"kind":"execution","summary":"TCOLEXPANDMAX applies its exact MAX semantics with column broadcasting.","pass_condition":"The selected element equals the typed MAX result and every source remains persistent.","related_sources":["asl/tile/model/execution/expansion.asl","asl/tile/model/legality/reduction-and-expansion.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        1, 128, 4, 4, 2, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 2 looplimit 3 do
            WriteTileElement(1, row, column, Zeros{PTO_XLEN} + 0x8000000000000000);
        end;
    end;
    ConfigureTile(
        2, 128, 4, 4,
        1, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    for column = 0 to 2 looplimit 3 do
        WriteTileElement(2, 0, column, Zeros{PTO_XLEN} + 1);
    end;
    ConfigureTile(
        3, 128, 4, 4, 2, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ExecuteTileExpand(
        TileExpand_MAX,
        TileAxis_Column,
        3,
        1,
        2);
    assert ReadTileElement(3, 1, 2) == Zeros{PTO_XLEN} + 0x8000000000000000;
    assert ReadTileElement(2, 0, 2) == Zeros{PTO_XLEN} + 1;
    return 0;
end;
