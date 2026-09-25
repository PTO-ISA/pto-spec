// PTO-TEST: {"id":"PTO-AVS-TILE-TEXPDIF-SOURCE1-ALIAS-001","source":"asl/tile/elementwise-tile-tile/transcendental/TEXPDIF.asl","requirements":["PTO-INST-TILE-TEXPDIF","PTO-TEXPDIF-CONTRACT-001"],"kind":"execution","summary":"TEXPDIF destination aliasing source1 reads its old complete payload before publication","pass_condition":"Two result elements use the old source1 values, preserve the other source, and publish the combined numeric status","related_sources":["asl/tile/model/execution/expdif.asl","asl/tile/model/legality/expdif-operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 16, 2, 1, 2,
        TileDataType_FP32, TileLayout_RowMajor);
    ConfigureTile(2, 128, 16, 2, 1, 2,
        TileDataType_FP32, TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x40000000);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 0x40000000);
    let (expected0, flags0) = TileExpdifValueWithTypesAndFlags(
        TileDataType_FP32, TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x40000000,
        Zeros{PTO_XLEN} + 0x3f800000);
    let (expected1, flags1) = TileExpdifValueWithTypesAndFlags(
        TileDataType_FP32, TileDataType_FP32,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x40000000);
    assert TileOperandsLegal_ExecuteTileExpdif(2, 1, 2);
    ExecuteTileExpdif(2, 1, 2);
    assert ReadTileElement(2, 0, 0) == expected0;
    assert ReadTileElement(2, 0, 1) == expected1;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0x40000000;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN};
    assert NumericStatusFlags() == (flags0 OR flags1);
    return 0;
end;
