// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-TILE-TESTTILEMATMUL-EXECUTION-001","source":"asl/tile/model/execution/cube.asl","requirements":[],"kind":"execution","summary":"Covers Tile Matmul.","pass_condition":"TestTileMatmul completes without assertion failure","related_sources":[]}
func ConfigureTwoByTwo(index: TileIndex, data_type: TileDataType)
begin
    ConfigureTile(index, 256, 2, 2, 2, 2, data_type,
        TileLayout_RowMajor, TileLocation_Any);
end;

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

func TestTileMatmul()
begin
    SelectTestCUBEDataType('11010');
    ConfigureTwoByTwo(5, TileDataType_U16);
    ConfigureTwoByTwo(6, TileDataType_U16);
    ConfigureTwoByTwo(7, TileDataType_U32);
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(5, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(5, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(5, 1, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(6, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(6, 0, 1, Zeros{PTO_XLEN} + 6);
    WriteTileElement(6, 1, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(6, 1, 1, Zeros{PTO_XLEN} + 8);
    WriteTileElement(7, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(7, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(7, 1, 0, Zeros{PTO_XLEN});
    WriteTileElement(7, 1, 1, Zeros{PTO_XLEN});

    TMATMUL(7, 5, 6);
    assert ReadTileElement(7, 0, 0) == Zeros{PTO_XLEN} + 19;
    assert ReadTileElement(7, 0, 1) == Zeros{PTO_XLEN} + 22;
    assert ReadTileElement(7, 1, 0) == Zeros{PTO_XLEN} + 43;
    assert ReadTileElement(7, 1, 1) == Zeros{PTO_XLEN} + 50;

    ConfigureTile(26, 256, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(26, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(26, 0, 1, Zeros{PTO_XLEN} + 2);
    TMATMUL_BIAS(7, 5, 6, 26);
    assert ReadTileElement(7, 0, 0) == Zeros{PTO_XLEN} + 20;
    assert ReadTileElement(7, 1, 1) == Zeros{PTO_XLEN} + 52;
    TMATMUL_ACC(7, 7, 5, 6);
    assert ReadTileElement(7, 0, 0) == Zeros{PTO_XLEN} + 39;

    // Matrix M, N, and K are logical dimensions and must each be a nonzero
    // power of two even when the enclosing physical descriptors are legal.
    var non_power_m = _Tiles[[5]];
    non_power_m.valid_rows = 3;
    assert !TileMatrixInfoShapeLegal(non_power_m, _Tiles[[6]]);
    var zero_m = _Tiles[[5]];
    zero_m.valid_rows = 0;
    assert !TileMatrixInfoShapeLegal(zero_m, _Tiles[[6]]);

    var non_power_k_left = _Tiles[[5]];
    non_power_k_left.rows = 8;
    non_power_k_left.columns = 4;
    non_power_k_left.valid_columns = 3;
    var non_power_k_right = _Tiles[[6]];
    non_power_k_right.valid_rows = 3;
    assert !TileMatrixInfoShapeLegal(non_power_k_left, non_power_k_right);

    var non_power_n = _Tiles[[6]];
    non_power_n.rows = 8;
    non_power_n.columns = 4;
    non_power_n.valid_columns = 3;
    assert !TileMatrixInfoShapeLegal(_Tiles[[5]], non_power_n);

    ConfigureTile(27, 256, 2, 1, 2, 1, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(29, 256, 1, 2, 1, 2, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(28, 256, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(27, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(27, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(29, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(29, 0, 1, Zeros{PTO_XLEN} + 2);
    TGEMV(28, 29, 27);
    assert ReadTileElement(28, 0, 0) == Zeros{PTO_XLEN} + 8;

end;
func main() => integer
begin
    ResetProfileState();
    TestTileMatmul();
    return 0;
end;
