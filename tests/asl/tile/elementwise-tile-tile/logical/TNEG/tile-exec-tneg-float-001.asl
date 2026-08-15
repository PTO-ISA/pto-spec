// PTO-TEST: {"id":"PTO-AVS-TILE-TNEG-FLOAT-001","source":"asl/tile/elementwise-tile-tile/logical/TNEG.asl","requirements":["PTO-TNEG-CONTRACT-001"],"kind":"execution","summary":"TNEG toggles only the floating sign bit","pass_condition":"negative FP32 signaling NaN becomes the same positive signaling NaN payload without invalid status","related_sources":["asl/tile/model/execution/unary.asl","asl/scalar/model/fsu/profile.asl"]}
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

    ExecuteTileUnary(TileUnary_NEG, 1, 0);

    assert ReadTileElement(1, 0, 0) ==
        Zeros{PTO_XLEN} + 0x7f800001;
    assert ScalarFPFlags() == Zeros{5};
    return 0;
end;
