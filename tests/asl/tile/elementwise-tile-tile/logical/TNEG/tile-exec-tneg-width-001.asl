// PTO-TEST: {"id":"PTO-AVS-TILE-TNEG-WIDTH-001","source":"asl/tile/elementwise-tile-tile/logical/TNEG.asl","requirements":["PTO-TNEG-CONTRACT-001"],"kind":"execution","summary":"TNEG negates modulo the selected integer element width","pass_condition":"U8 one produces zero-extended 0xff rather than an XLEN-wide result","related_sources":["asl/tile/model/execution/elementwise.asl"]}
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
            TileDataType_U8,
            TileLayout_RowMajor,
            TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);

    ExecuteTileUnary(TileUnary_NEG, 1, 0);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0xff;
    return 0;
end;
