// PTO-TEST: {"id":"PTO-AVS-TILE-EXECUTION-MASK-CELL-BASIS-001","source":"asl/tile/model/execution/predicate-carriers.asl","requirements":["PTO-REQ-TEPL-PREDICATE-CARRIER-001"],"kind":"execution","summary":"Generic ExecutionMask PredicateCell matching ignores producer basis type","pass_condition":"a canonical PredicateCell with matching CUBE layout and valid logical coordinates is a legal ExecutionMask even when its producer basis and physical geometry differ from the numeric consumer","related_sources":["asl/tile/model/legality/predicate-carriers.asl","asl/tile/model/state/types.asl"]}
func main() => integer
begin
    ResetProfileState();
    let mask_ready = ConfigurePredicateCell(
        8, 128, 1, 2, TileDataType_S16, TileLayout_CUBE_M16);
    let consumer_ready = ConfigureCubeTile(
        9, 256, 1, 2, TileDataType_FP32, TileLayout_CUBE_M16);
    assert mask_ready && consumer_ready;
    WriteTileElement(8, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(8, 0, 1, Zeros{PTO_XLEN});
    _Tiles[[8]].contents_defined = TRUE;

    assert TilePredicateCellValuesLegal(8);
    assert !TilePredicateCellShapeMatchesNumericAs(
        8, 9, TileDataType_FP32);
    assert TileExecutionMaskPredicateCellShapeLegal(
        8, TileLayout_CUBE_M16, 1, 2);
    assert !TileExecutionMaskPredicateCellShapeLegal(
        8, TileLayout_CUBE_M32, 1, 2);
    return 0;
end;
