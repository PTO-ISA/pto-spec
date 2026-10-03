// PTO-TEST: {"id":"PTO-AVS-TILE-PREDICATE-CARRIERS-LOCAL64-001","source":"asl/tile/model/execution/predicate-carriers.asl","requirements":["PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-CUBE-M32-B64-DOUBLE-CELL-001"],"kind":"execution","summary":"M32 64-bit comparisons publish logical predicate bits through GPR and PredicateCell carriers.","pass_condition":"FP64 column one row 31 reaches GPR bit 63, signed-negative and unsigned-high comparisons use their selected 64-bit meanings, and FP64/S64/U64 PredicateCell basis descriptors remain legal only on M32.","related_sources":["asl/tile/model/legality/predicate-carriers.asl","asl/tile/model/execution/comparison.asl"]}
func main() => integer
begin
    ResetProfileState();
    let fp_left = ConfigureCubeTile(
        0, 512, 32, 2, TileDataType_FP64, TileLayout_CUBE_M32);
    let fp_right = ConfigureCubeTile(
        1, 512, 32, 2, TileDataType_FP64, TileLayout_CUBE_M32);
    assert fp_left && fp_right;
    WriteTileElement(0, 31, 1, Zeros{PTO_XLEN} + 0x3ff0000000000000);
    WriteTileElement(1, 31, 1, Zeros{PTO_XLEN} + 0x3ff0000000000000);
    MarkTileValidRegionDefined(0);
    MarkTileValidRegionDefined(1);
    let fp_mask = TileCompareCUBEToGPRAs(
        0, 1, TileComparison_EQ, FALSE, TileDataType_FP64);
    assert fp_mask[63] == '1';

    let signed_ready = ConfigureCubeTile(
        2, 256, 1, 1, TileDataType_S64, TileLayout_CUBE_M32);
    let unsigned_ready = ConfigureCubeTile(
        3, 256, 1, 1, TileDataType_U64, TileLayout_CUBE_M32);
    assert signed_ready && unsigned_ready;
    WriteTileElement(2, 0, 0, Ones{PTO_XLEN});
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 0x8000000000000000);
    let signed_mask = TileCompareCUBEScalarToGPRAs(
        2, Zeros{PTO_XLEN}, TileComparison_LT, FALSE, TileDataType_S64);
    let unsigned_mask = TileCompareCUBEScalarToGPRAs(
        3, Zeros{PTO_XLEN} + 1, TileComparison_GT, FALSE, TileDataType_U64);
    assert signed_mask[0] == '1' && unsigned_mask[0] == '1';

    let fp_predicate = ConfigurePredicateCell(
        4, 128, 32, 2, TileDataType_FP64, TileLayout_CUBE_M32);
    let signed_predicate = ConfigurePredicateCell(
        5, 128, 1, 1, TileDataType_S64, TileLayout_CUBE_M32);
    let unsigned_predicate = ConfigurePredicateCell(
        6, 128, 1, 1, TileDataType_U64, TileLayout_CUBE_M32);
    assert fp_predicate && signed_predicate && unsigned_predicate;
    assert TilePredicateCellDescriptorLegal(4);
    assert TilePredicateCellDescriptorLegal(5);
    assert TilePredicateCellDescriptorLegal(6);
    assert TileOperandsLegal_ExecuteTileCompareScalarAs(
        4, 0, Zeros{PTO_XLEN} + 0x3ff0000000000000,
        TileComparison_EQ, TileDataType_FP64);
    ExecuteTileCompareCellScalarAs(
        4, 0, Zeros{PTO_XLEN} + 0x3ff0000000000000,
        TileComparison_EQ, TileDataType_FP64);
    assert ReadTileElement(4, 31, 1) == Zeros{PTO_XLEN} + 1;
    assert TileOperandsLegal_ExecuteTileCompareScalarAs(
        5, 2, Zeros{PTO_XLEN}, TileComparison_LT, TileDataType_S64);
    ExecuteTileCompareCellScalarAs(
        5, 2, Zeros{PTO_XLEN}, TileComparison_LT, TileDataType_S64);
    assert ReadTileElement(5, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert TileOperandsLegal_ExecuteTileCompareScalarAs(
        6, 3, Zeros{PTO_XLEN} + 1,
        TileComparison_GT, TileDataType_U64);
    ExecuteTileCompareCellScalarAs(
        6, 3, Zeros{PTO_XLEN} + 1,
        TileComparison_GT, TileDataType_U64);
    assert ReadTileElement(6, 0, 0) == Zeros{PTO_XLEN} + 1;
    let m16_predicate = ConfigurePredicateCell(
        7, 128, 1, 1, TileDataType_U64, TileLayout_CUBE_M16);
    assert !m16_predicate;
    return 0;
end;
