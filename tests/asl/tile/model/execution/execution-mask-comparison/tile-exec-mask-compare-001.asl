// PTO-TEST: {"id":"PTO-AVS-TILE-EXECUTION-MASK-COMPARE-001","source":"asl/tile/model/execution/execution-mask-comparison.asl","requirements":["PTO-REQ-TEPL-PREDICATE-CARRIER-001"],"kind":"execution","summary":"Predicated CUBE comparison skips inactive source lanes and applies predicate MERGE or ZERO","pass_condition":"active comparisons produce canonical predicate cells and status, inactive undefined sources are not read, PredicateCell MERGE preserves the prior coordinate, ZERO clears it, and GPR valid bits follow the same rule","related_sources":["asl/tile/model/execution/predicate-carriers.asl","asl/tile/model/legality/predicate-carriers.asl"]}
func main() => integer
begin
    ResetProfileState();
    let left_ready = ConfigureCubeTile(
        0, 256, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let right_ready = ConfigureCubeTile(
        1, 256, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let destination_ready = ConfigurePredicateCell(
        2, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let base_ready = ConfigurePredicateCell(
        3, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert left_ready && right_ready && destination_ready && base_ready;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 1);

    var exec_mask = Zeros{PTO_XLEN};
    exec_mask[0] = '1';
    CaptureBundleExecutionMaskGPR(
        exec_mask, Zeros{PTO_XLEN}, 1,
        TileLayout_CUBE_M16, 1, 2);
    _BundleExecutionMask.merge_base = 3;
    _BundleExecutionMask.merge_base_valid = TRUE;
    assert TileOperandsLegal_ExecuteTileCompareAs(
        2, 0, 1, TileComparison_EQ, TileDataType_U32);
    ExecuteTileCompareCellAs(
        2, 0, 1, TileComparison_EQ, TileDataType_U32);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN} + 1;

    _BundleExecutionMask.zero_inactive = TRUE;
    _BundleExecutionMask.merge_base_valid = FALSE;
    ExecuteTileCompareCellAs(
        2, 0, 1, TileComparison_EQ, TileDataType_U32);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN};

    var result_word = Zeros{PTO_XLEN};
    result_word[0] = '1';
    var old_word = Zeros{PTO_XLEN};
    old_word[16] = '1';
    _BundleExecutionMask.zero_inactive = FALSE;
    let merged_word = TileExecutionMaskPredicateGPRResult(
        result_word, old_word, TileDataType_U32,
        TileLayout_CUBE_M16, 1, 2, FALSE);
    assert merged_word[0] == '1' && merged_word[16] == '1';
    _BundleExecutionMask.zero_inactive = TRUE;
    let zero_word = TileExecutionMaskPredicateGPRResult(
        result_word, old_word, TileDataType_U32,
        TileLayout_CUBE_M16, 1, 2, TRUE);
    assert zero_word[0] == '1' && zero_word[16] == '0';
    return 0;
end;
