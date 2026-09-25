// PTO-TEST: {"id":"PTO-AVS-TILE-TEXPDIF-TRANSACTION-SPECIAL-001","source":"asl/tile/elementwise-tile-tile/transcendental/TEXPDIF.asl","requirements":["PTO-INST-TILE-TEXPDIF","PTO-TEXPDIF-CONTRACT-001"],"kind":"execution","summary":"TEXPDIF snapshots an aliased source and accumulates status across elements","pass_condition":"FP32 aliased source0 yields read-old/write-new results for finite, infinite, zero, and overflow-producing elements; status equals the OR of each typed SUB-plus-EXP result","related_sources":["asl/tile/model/execution/expdif.asl","asl/tile/model/execution/elementwise.asl","asl/arch/state/numeric-status.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 16, 2, 1, 2,
        TileDataType_FP32, TileLayout_RowMajor);
    ConfigureTile(2, 128, 16, 2, 1, 2,
        TileDataType_FP32, TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x7f7fffff);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x3f000000);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0xff7fffff);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN});
    let (expected0, flags0) = TileExpdifValueWithTypesAndFlags(
        TileDataType_FP32, TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7f7fffff,
        Zeros{PTO_XLEN} + 0xff7fffff);
    let (expected1, flags1) = TileExpdifValueWithTypesAndFlags(
        TileDataType_FP32, TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x3f000000, Zeros{PTO_XLEN});
    assert TileOperandsLegal_ExecuteTileExpdif(1, 1, 2);
    ExecuteTileExpdif(1, 1, 2);
    assert ReadTileElement(1, 0, 0) == expected0;
    assert ReadTileElement(1, 0, 1) == expected1;
    assert NumericStatusFlags() == (flags0 OR flags1);

    let (positive_infinity, -) = TileExpdifValueWithTypesAndFlags(
        TileDataType_FP32, TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7f800000, Zeros{PTO_XLEN});
    let (negative_infinity_difference, -) =
        TileExpdifValueWithTypesAndFlags(
            TileDataType_FP32, TileDataType_FP32,
            Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x7f800000);
    let (negative_infinity_source_result, -) =
        TileExpdifValueWithTypesAndFlags(
            TileDataType_FP32, TileDataType_FP32,
            Zeros{PTO_XLEN} + 0xff800000, Zeros{PTO_XLEN});
    let (positive_zero_result, -) = TileExpdifValueWithTypesAndFlags(
        TileDataType_FP32, TileDataType_FP32,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN});
    let (negative_zero_result, -) = TileExpdifValueWithTypesAndFlags(
        TileDataType_FP32, TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x80000000, Zeros{PTO_XLEN});
    let (nan_result, -) = TileExpdifValueWithTypesAndFlags(
        TileDataType_FP32, TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7fc00000, Zeros{PTO_XLEN});
    assert positive_infinity[31:0] == Zeros{32} + 0x7f800000;
    assert negative_infinity_difference[31:0] == Zeros{32};
    assert negative_infinity_source_result[31:0] == Zeros{32};
    assert positive_zero_result[31:0] == Zeros{32} + 0x3f800000;
    assert negative_zero_result[31:0] == Zeros{32} + 0x3f800000;
    assert nan_result[30:23] == Ones{8};
    assert nan_result[22:0] != Zeros{23};
    return 0;
end;
