// PTO-TEST: {"id":"PTO-AVS-TILE-INDEXED-MAP-001","source":"asl/tile/model/execution/indexed-rearrangement.asl","requirements":[],"kind":"execution","summary":"Indexed rearrangement uses row indices without flattening columns.","pass_condition":"TGATHER reads source[index[row,column],column] for both destination columns.","related_sources":["asl/tile/irregular-and-complex/layout/TGATHER.asl"]}

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        40, 128, 2, 2, 2, 2, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        41, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        42, 128, 1, 2, 1, 2, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(40, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(40, 0, 1, Zeros{PTO_XLEN} + 11);
    WriteTileElement(40, 1, 0, Zeros{PTO_XLEN} + 20);
    WriteTileElement(40, 1, 1, Zeros{PTO_XLEN} + 21);
    WriteTileElement(41, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(41, 0, 1, Zeros{PTO_XLEN});

    TGATHER(42, 40, 41);
    assert ReadTileElement(42, 0, 0) == Zeros{PTO_XLEN} + 20;
    assert ReadTileElement(42, 0, 1) == Zeros{PTO_XLEN} + 11;
    return 0;
end;
