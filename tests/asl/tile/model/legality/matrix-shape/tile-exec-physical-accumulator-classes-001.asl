// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-TILE-TESTMATRIXPHYSICALACCUMULATORCLASSES-EXECUTION-001","source":"asl/tile/model/legality/matrix-shape.asl","requirements":[],"kind":"execution","summary":"Covers Matrix Physical Accumulator Classes.","pass_condition":"TestMatrixPhysicalAccumulatorClasses completes without assertion failure","related_sources":[]}
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
    let fp_left = ConfigureCubeTile(45, 256, 1, 1, TileDataType_E4M3,
        TileLayout_CUBE_M16);
    assert fp_left;
    let fp_right = ConfigureCubeTile(46, 256, 1, 1, TileDataType_E4M3,
        TileLayout_CUBE_N8);
    assert fp_right;
    let fp_acc = ConfigureCubeTile(47, 256, 1, 1, TileDataType_FP32,
        TileLayout_CUBE_M16);
    assert fp_acc;
    WriteTileElement(45, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(46, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(47, 0, 0, Zeros{PTO_XLEN} + 1);
    TMATMUL_BIAS(47, 45, 46, 47);
    assert ReadTileElement(47, 0, 0) == Zeros{PTO_XLEN} + 7;

    SelectTestCUBEDataType('10011');
    let s_left = ConfigureCubeTile(45, 256, 1, 1, TileDataType_S8,
        TileLayout_CUBE_M16);
    assert s_left;
    let s_right = ConfigureCubeTile(46, 256, 1, 1, TileDataType_S8,
        TileLayout_CUBE_N8);
    assert s_right;
    WriteTileElement(45, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(46, 0, 0, Zeros{PTO_XLEN} + 3);
    let s_acc = ConfigureCubeTile(47, 256, 1, 1, TileDataType_S32,
        TileLayout_CUBE_M16);
    assert s_acc;
    TMATMUL(47, 45, 46);
    assert _Tiles[[47]].data_type == TileDataType_S32;

    SelectTestCUBEDataType('11011');
    let u_left = ConfigureCubeTile(45, 256, 1, 1, TileDataType_U8,
        TileLayout_CUBE_M16);
    assert u_left;
    let u_right = ConfigureCubeTile(46, 256, 1, 1, TileDataType_U8,
        TileLayout_CUBE_N8);
    assert u_right;
    WriteTileElement(45, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(46, 0, 0, Zeros{PTO_XLEN} + 3);
    let u_acc = ConfigureCubeTile(47, 256, 1, 1, TileDataType_U32,
        TileLayout_CUBE_M16);
    assert u_acc;
    TMATMUL(47, 45, 46);
    assert _Tiles[[47]].data_type == TileDataType_U32;
end;
func main() => integer
begin
    ResetProfileState();
    TestMatrixPhysicalAccumulatorClasses();
    return 0;
end;
