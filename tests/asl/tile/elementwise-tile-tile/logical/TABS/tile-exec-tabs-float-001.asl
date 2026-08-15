// PTO-TEST: {"id":"PTO-AVS-TILE-TABS-FLOAT-001","source":"asl/tile/elementwise-tile-tile/logical/TABS.asl","requirements":["PTO-TABS-CONTRACT-001"],"kind":"execution","summary":"TABS clears only the floating sign bit","pass_condition":"negative FP32 signaling NaN becomes the same positive signaling NaN payload without invalid status","related_sources":["asl/tile/model/execution/unary.asl","asl/scalar/model/fsu/profile.asl"]}
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
            TileDataType_FP32,
            TileLayout_RowMajor,
            TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xff800001);

    ExecuteTileUnary(TileUnary_ABS, 1, 0);

    assert ReadTileElement(1, 0, 0) ==
        Zeros{PTO_XLEN} + 0x7f800001;
    assert ScalarFPFlags() == Zeros{5};
    return 0;
end;
