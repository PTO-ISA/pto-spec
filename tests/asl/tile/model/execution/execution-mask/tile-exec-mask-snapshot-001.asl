// PTO-TEST: {"id":"PTO-AVS-TILE-EXECUTION-MASK-SNAPSHOT-001","source":"asl/tile/model/execution/execution-mask.asl","requirements":["PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001"],"kind":"execution","summary":"ExecutionMask carriers snapshot canonical coordinate activity","pass_condition":"GPR and PredicateCell carriers expose the same logical coordinate interface, PredInv reverses activity, and a PredicateCell source mutation after capture does not alter the bound mask","related_sources":["asl/tile/model/legality/predicate-carriers.asl","asl/block/model/state/types.asl"]}
func main() => integer
begin
    ResetProfileState();
    var gpr_mask = Zeros{PTO_XLEN};
    gpr_mask[1] = '1';
    CaptureBundleExecutionMaskGPR(
        gpr_mask, Zeros{PTO_XLEN}, 1,
        TileLayout_CUBE_M16, 16, 1);
    assert BundleExecutionMaskActiveAt(TileLayout_CUBE_M16, 1, 0);
    assert !BundleExecutionMaskActiveAt(TileLayout_CUBE_M16, 0, 0);
    _BundleExecutionMask.invert = TRUE;
    assert !BundleExecutionMaskActiveAt(TileLayout_CUBE_M16, 1, 0);
    assert BundleExecutionMaskActiveAt(TileLayout_CUBE_M16, 0, 0);

    ResetProfileState();
    let predicate_ready = ConfigurePredicateCell(
        8, 128, 1, 2, TileDataType_S16, TileLayout_CUBE_M16);
    assert predicate_ready;
    WriteTileElement(8, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(8, 0, 1, Zeros{PTO_XLEN});
    MarkTileValidRegionDefined(8);
    CaptureBundleExecutionMaskPredicateTile(
        8, TileLayout_CUBE_M16, 1, 2);
    assert BundleExecutionMaskActiveAt(TileLayout_CUBE_M16, 0, 0);
    assert !BundleExecutionMaskActiveAt(TileLayout_CUBE_M16, 0, 1);
    WriteTileElement(8, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(8, 0, 1, Zeros{PTO_XLEN} + 1);
    assert BundleExecutionMaskActiveAt(TileLayout_CUBE_M16, 0, 0);
    assert !BundleExecutionMaskActiveAt(TileLayout_CUBE_M16, 0, 1);
    return 0;
end;
