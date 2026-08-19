// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-E8M0-FINITE-002","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001"],"kind":"execution","summary":"TCVT converts positive finite BF16 values into E8M0 power-of-two exponents.","pass_condition":"Exact powers map without status and an inexact 1.5 input rounds to exponent one with NX before atomic destination publication.","related_sources":["asl/tile/model/numeric/formats.asl","asl/arch/data-types/formats/e8m0.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 256, 16, 8, 1, 4, TileDataType_BF16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 16, 8, 1, 4, TileDataType_E8M0,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x3f80);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0x4000);
    WriteTileElement(0, 0, 2, Zeros{PTO_XLEN} + 0x3f00);
    WriteTileElement(0, 0, 3, Zeros{PTO_XLEN} + 0x3fc0);
    let control = DefaultNumericExecutionControl();
    assert TileOperandsLegal_TCVT(1, 0, control);

    TCVT(1, 0, control);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 127;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 128;
    assert ReadTileElement(1, 0, 2) == Zeros{PTO_XLEN} + 126;
    assert ReadTileElement(1, 0, 3) == Zeros{PTO_XLEN} + 128;
    assert NumericStatusFlags() == Zeros{5} + 0x10;
    assert ReadTileElement(0, 0, 3) == Zeros{PTO_XLEN} + 0x3fc0;
    return 0;
end;
