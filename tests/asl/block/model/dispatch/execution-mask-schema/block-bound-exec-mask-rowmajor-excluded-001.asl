// PTO-TEST: {"id":"PTO-AVS-BLOCK-EXECUTION-MASK-ROWMAJOR-EXCLUDED-001","source":"asl/block/model/dispatch/execution-mask-schema.asl","requirements":["PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-TGATHER-CONTRACT-001","PTO-TSCATTER-CONTRACT-001","PTO-TTRI-CONTRACT-001"],"kind":"boundary","summary":"TGATHER and TSCATTER without baseline CUBE forms, plus RowMajor TTRI, reject ExecutionMask applicability","pass_condition":"the three RowMajor operations remain legal under their owning schemas, while GPR and PredicateCell ExecutionMask shape validation rejects the RowMajor coordinate domain","related_sources":["asl/tile/model/legality/indexed-rearrangement.asl","asl/tile/model/legality/operand-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        10, 512, 2, 1, 2, 1, TileDataType_U16, TileLayout_RowMajor);
    ConfigureTile(
        11, 512, 2, 1, 2, 1, TileDataType_U16, TileLayout_RowMajor);
    ConfigureTile(
        12, 512, 3, 1, 3, 1, TileDataType_U16, TileLayout_RowMajor);
    ConfigureTile(
        15, 512, 2, 1, 2, 1, TileDataType_U16, TileLayout_RowMajor);
    ConfigureTile(
        16, 512, 2, 1, 2, 1, TileDataType_U16, TileLayout_RowMajor);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 17);
    WriteTileElement(10, 1, 0, Zeros{PTO_XLEN} + 21);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(11, 1, 0, Zeros{PTO_XLEN});
    WriteTileElement(16, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(16, 1, 0, Zeros{PTO_XLEN});
    assert TileOperandsLegal_TGATHER(15, 10, 16);
    assert TileOperandsLegal_TSCATTER(12, 10, 11);

    ConfigureTile(
        13, 512, 2, 2, 2, 2, TileDataType_U32, TileLayout_RowMajor);
    assert TileOperandsLegal_TTRI(13, TRUE, 0);
    let predicate_ready = ConfigurePredicateCell(
        14, 256, 2, 1, TileDataType_U16, TileLayout_CUBE_M16);
    assert predicate_ready;
    WriteTileElement(14, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(14, 1, 0, Zeros{PTO_XLEN});
    MarkTileValidRegionDefined(14);
    assert !TileExecutionMaskPredicateCellShapeLegal(
        14, TileLayout_RowMajor, 2, 1);

    _BundleTileBindings[[0]].valid = TRUE;
    _BundleTileBindings[[0]].source0_valid = TRUE;
    _BundleTileBindings[[0]].source0 = 10;
    _BundleTileBindings[[0]].source1_valid = TRUE;
    _BundleTileBindings[[0]].source1 = 11;
    assert BundleExecutionMaskCoordinateLayout(70) == TileLayout_RowMajor;
    assert !BundleExecutionMaskGPRCarrierShapeLegal(70);
    assert BundleExecutionMaskCoordinateLayout(71) == TileLayout_RowMajor;
    assert !BundleExecutionMaskGPRCarrierShapeLegal(71);
    assert BundleExecutionMaskCoordinateLayout(69) == TileLayout_RowMajor;
    assert !BundleExecutionMaskGPRCarrierShapeLegal(69);
    return 0;
end;
