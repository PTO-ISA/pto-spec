// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-TILE-TESTTILEMATMUL-EXECUTION-001","source":"asl/tile/model/execution/cube.asl","requirements":[],"kind":"execution","summary":"Covers Tile Matmul.","pass_condition":"TestTileMatmul completes without assertion failure","related_sources":[]}
func ConfigureTwoByTwoLeft(index: TileIndex, data_type: TileDataType)
begin
    assert ConfigureCubeTile(index, 128, 2, 2, data_type,
        TileLayout_CUBE_M16, TileLocation_Matrix);
end;

func ConfigureTwoByTwoRight(index: TileIndex, data_type: TileDataType)
begin
    assert ConfigureCubeTile(index, 128, 2, 2, data_type,
        TileLayout_CUBE_N8, TileLocation_Matrix);
end;

func ConfigureTwoByTwoDestination(index: TileIndex, data_type: TileDataType)
begin
    assert ConfigureCubeTile(index, 128, 2, 2, data_type,
        TileLayout_CUBE_M16, TileLocation_Matrix);
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
    ConfigureTwoByTwoLeft(5, TileDataType_U16);
    ConfigureTwoByTwoRight(6, TileDataType_U16);
    ConfigureTwoByTwoDestination(7, TileDataType_U32);
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

    // Local CUBE Matrix logical dimensions may be arbitrary positive values.
    assert ConfigureCubeTile(30, 128, 3, 3, TileDataType_U16,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    assert ConfigureCubeTile(31, 128, 3, 3, TileDataType_U16,
        TileLayout_CUBE_N8, TileLocation_Matrix);
    assert TileMatrixInfoShapeLegal(_Tiles[[30]], _Tiles[[31]]);
    var zero_m = _Tiles[[5]];
    zero_m.valid_rows = 0;
    assert !TileMatrixInfoShapeLegal(zero_m, _Tiles[[6]]);

    assert ConfigureCubeTile(27, 128, 2, 1, TileDataType_U16,
        TileLayout_CUBE_N8, TileLocation_Matrix);
    assert ConfigureCubeTile(29, 128, 1, 2, TileDataType_U16,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    assert ConfigureCubeTile(28, 128, 1, 1, TileDataType_U32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
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
