// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-TILE-TESTMATRIXPHYSICALACCUMULATORCLASSES-EXECUTION-001","source":"asl/tile/model/legality/matrix-shape.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for TestMatrixPhysicalAccumulatorClasses","pass_condition":"TestMatrixPhysicalAccumulatorClasses completes without assertion failure","related_sources":[]}
func SelectTestCUBEDataType(data_type: bits(5))
begin
    InstallBundleOperationDescriptor(BundleOperationDescriptor {
        valid = TRUE,
        form_identity = Zeros{7},
        operation_class = BundleOperation_TileMatrix,
        selector_valid = TRUE,
        selector = Zeros{10},
        data_type_valid = TRUE,
        data_type = data_type,
        mode_valid = FALSE,
        mode = Zeros{2},
        branch_type_valid = FALSE,
        branch_type = Zeros{3}
    });
end;

func TestMatrixPhysicalAccumulatorClasses()
begin
    SelectTestCUBEDataType('00111');
    ConfigureTile(45, 256, 1, 1, 1, 1, TileDataType_E4M3,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(46, 256, 1, 1, 1, 1, TileDataType_E4M3,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(47, 256, 1, 1, 1, 1, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(45, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(46, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(47, 0, 0, Zeros{PTO_XLEN} + 1);
    TMATMUL_BIAS(47, 45, 46, 47);
    assert ReadTileElement(47, 0, 0) == Zeros{PTO_XLEN} + 7;

    SelectTestCUBEDataType('10011');
    ConfigureTile(45, 256, 1, 1, 1, 1, TileDataType_S8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(46, 256, 1, 1, 1, 1, TileDataType_S8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(45, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(46, 0, 0, Zeros{PTO_XLEN} + 3);
    ConfigureTile(47, 256, 1, 1, 1, 1, TileDataType_S64,
        TileLayout_RowMajor, TileLocation_Any);
    TMATMUL(47, 45, 46);
    assert _Tiles[[47]].data_type == TileDataType_S64;

    SelectTestCUBEDataType('11011');
    ConfigureTile(45, 256, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(46, 256, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(45, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(46, 0, 0, Zeros{PTO_XLEN} + 3);
    ConfigureTile(47, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    TMATMUL(47, 45, 46);
    assert _Tiles[[47]].data_type == TileDataType_U64;
end;
func main() => integer
begin
    ResetProfileState();
    TestMatrixPhysicalAccumulatorClasses();
    return 0;
end;
