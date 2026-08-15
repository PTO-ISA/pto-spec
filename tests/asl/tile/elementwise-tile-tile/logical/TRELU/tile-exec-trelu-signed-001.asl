// PTO-TEST: {"id":"PTO-AVS-TILE-TRELU-SIGNED-001","source":"asl/tile/elementwise-tile-tile/logical/TRELU.asl","requirements":["PTO-TRELU-CONTRACT-001"],"kind":"execution","summary":"TRELU classifies signed integers at their selected element width","pass_condition":"S8 negative one produces zero instead of being treated as positive XLEN 255","related_sources":["asl/tile/model/execution/elementwise.asl"]}
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

    ExecuteTileUnary(TileUnary_RELU, 1, 0);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN};
    return 0;
end;
