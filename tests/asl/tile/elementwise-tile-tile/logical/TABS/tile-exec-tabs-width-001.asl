// PTO-TEST: {"id":"PTO-AVS-TILE-TABS-WIDTH-001","source":"asl/tile/elementwise-tile-tile/logical/TABS.asl","requirements":["PTO-TABS-CONTRACT-001"],"kind":"execution","summary":"TABS computes absolute value at the selected integer element width","pass_condition":"S8 negative one produces zero-extended positive one","related_sources":["asl/tile/model/execution/elementwise.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 1 looplimit 2 do
        ConfigureTile(
            index as TileIndex,
            128,
            1,
            1,
            1,
            1,
            TileDataType_S8,
            TileLayout_RowMajor,
            TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xff);

    ExecuteTileUnary(TileUnary_ABS, 1, 0);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 1;
    return 0;
end;
