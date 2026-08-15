// PTO-TEST: {"id":"PTO-AVS-TILE-TCOLEXPAND-COPY-001","source":"asl/tile/reduce-and-expand/column-expansion/TCOLEXPAND.asl","requirements":["PTO-TCOLEXPAND-CONTRACT-001","PTO-INST-TILE-TCOLEXPAND"],"kind":"execution","summary":"TCOLEXPAND applies its exact COPY semantics with column broadcasting.","pass_condition":"The selected element equals the typed COPY result and every source remains persistent.","related_sources":["asl/tile/model/execution/expansion.asl","asl/tile/model/legality/reduction-and-expansion.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        1, 128, 32, 4,
        1, 3, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    for column = 0 to 2 looplimit 3 do
        WriteTileElement(1, 0, column, Zeros{PTO_XLEN} + 7);
    end;
    ConfigureTile(
        2, 128, 32, 4, 2, 3, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ExecuteTileExpand(
        TileExpand_COPY,
        TileAxis_Column,
        2,
        1,
        1);
    assert ReadTileElement(2, 1, 2) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(1, 0, 2) == Zeros{PTO_XLEN} + 7;
    return 0;
end;
