// PTO-TEST: {"id":"PTO-AVS-TILE-TROWEXPAND-COPY-001","source":"asl/tile/reduce-and-expand/row-expansion/TROWEXPAND.asl","requirements":["PTO-TROWEXPAND-CONTRACT-001","PTO-INST-TILE-TROWEXPAND"],"kind":"execution","summary":"TROWEXPAND applies its exact COPY semantics with row broadcasting.","pass_condition":"The selected element equals the typed COPY result and every source remains persistent.","related_sources":["asl/tile/model/execution/expansion.asl","asl/tile/model/legality/reduction-and-expansion.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        1, 128, 128, 1,
        2, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    for row = 0 to 1 looplimit 2 do
        WriteTileElement(1, row, 0, Zeros{PTO_XLEN} + 7);
    end;
    ConfigureTile(
        2, 128, 32, 4, 2, 3, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ExecuteTileExpand(
        TileExpand_COPY,
        TileAxis_Row,
        2,
        1,
        1);
    assert ReadTileElement(2, 1, 2) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(1, 1, 0) == Zeros{PTO_XLEN} + 7;
    return 0;
end;
