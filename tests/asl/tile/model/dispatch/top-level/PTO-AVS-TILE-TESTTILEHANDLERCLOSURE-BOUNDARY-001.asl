// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-TILE-TESTTILEHANDLERCLOSURE-BOUNDARY-001","source":"asl/tile/model/dispatch/top-level.asl","requirements":[],"kind":"boundary","summary":"migrated independent behavior point for TestTileHandlerClosure","pass_condition":"TestTileHandlerClosure completes without assertion failure","related_sources":[]}
func ConfigureTwoByTwo(index: TileIndex)
begin
    ConfigureTile(index, 256, 2, 2, 2, 2, TileDataType_U64,
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

func TestTileHandlerClosure()
begin
    ConfigureTwoByTwo(51);
    ConfigureTwoByTwo(52);
    ConfigureTwoByTwo(53);
    ConfigureTwoByTwo(54);
    WriteTileElement(51, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(51, 0, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(51, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(51, 1, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(52, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(52, 0, 1, Zeros{PTO_XLEN} + 3);
    WriteTileElement(52, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(52, 1, 1, Zeros{PTO_XLEN} + 4);

    ExecuteTileUnary(TileUnary_NEG, 53, 51);
    assert ReadTileElement(53, 0, 0) == Zeros{PTO_XLEN} - 1;
    ExecuteTileScalar(TileBinary_ADD, 53, 51, Zeros{PTO_XLEN} + 5);
    assert ReadTileElement(53, 0, 1) == Zeros{PTO_XLEN} + 9;
    ExecuteTileCompare(53, 51, 52, TileComparison_LT);
    assert ReadTileElement(53, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(53, 0, 1) == Zeros{PTO_XLEN};
    ExecuteTileCompareScalar(53, 51, Zeros{PTO_XLEN} + 3,
        TileComparison_GE);
    assert ReadTileElement(53, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(53, 0, 1) == Zeros{PTO_XLEN} + 1;
    ExecuteTileSelect(54, 53, 51, 52);
    assert ReadTileElement(54, 0, 0) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(54, 0, 1) == Zeros{PTO_XLEN} + 4;
    ExecuteTileSelectScalar(54, 53, 51, Zeros{PTO_XLEN} + 9);
    assert ReadTileElement(54, 0, 0) == Zeros{PTO_XLEN} + 9;
    assert ReadTileElement(54, 0, 1) == Zeros{PTO_XLEN} + 4;

    ConfigureTwoByTwo(55);
    ConfigureTile(56, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(57, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(58, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(59, 256, 1, 4, 1, 4, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(60, 256, 1, 4, 1, 4, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(61, 256, 1, 4, 1, 4, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTwoByTwo(62);
    ExecuteTileFillScalar(55, Zeros{PTO_XLEN});
    ExecuteTileFillScalar(61, Zeros{PTO_XLEN});
    WriteTileElement(56, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(56, 0, 1, Zeros{PTO_XLEN} + 8);
    WriteTileElement(58, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(58, 0, 1, Zeros{PTO_XLEN} + 8);
    TINSERT(55, 56, 1, 0);
    assert ReadTileElement(55, 1, 0) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(55, 1, 1) == Zeros{PTO_XLEN} + 8;

    WriteTileElement(57, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(57, 0, 1, Zeros{PTO_XLEN} + 24);
    WriteTileElement(57, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(57, 0, 1, Zeros{PTO_XLEN} + 3);
    TSCATTER(61, 56, 57);
    assert ReadTileElement(61, 0, 1) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(61, 0, 3) == Zeros{PTO_XLEN} + 8;

    TCONCAT(59, 56, 58, TileAxis_Column);
    assert ReadTileElement(59, 0, 0) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(59, 0, 3) == Zeros{PTO_XLEN} + 8;
    TMOV(62, 55);
    assert ReadTileElement(62, 1, 1) == Zeros{PTO_XLEN} + 8;

    // This closure test owns its matrix fixture. It must not inherit tiles
    // configured by TestTileMatmul when executed as an independent shard.
    ConfigureTwoByTwo(5);
    ConfigureTwoByTwo(6);
    ConfigureTwoByTwo(7);
    ConfigureTile(27, 256, 2, 1, 2, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(28, 256, 2, 1, 2, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(5, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(5, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(5, 1, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(6, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(6, 0, 1, Zeros{PTO_XLEN} + 6);
    WriteTileElement(6, 1, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(6, 1, 1, Zeros{PTO_XLEN} + 8);
    WriteTileElement(27, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(27, 1, 0, Zeros{PTO_XLEN} + 3);

    ConfigureTile(61, 256, 2, 1, 2, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(62, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(63, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(61, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(61, 1, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(62, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(62, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(63, 0, 0, Zeros{PTO_XLEN} + 1);
    SelectTestCUBEDataType('11000');
    TMATMUL_MX(7, 5, 61, 6, 62);
    assert ReadTileElement(7, 0, 0) == Zeros{PTO_XLEN} + 19;
    TGEMV_BIAS(28, 5, 27, 61);
    assert ReadTileElement(28, 0, 0) == Zeros{PTO_XLEN} + 9;
    assert ReadTileElement(28, 1, 0) == Zeros{PTO_XLEN} + 19;
    TGEMV_ACC(28, 28, 5, 27);
    assert ReadTileElement(28, 0, 0) == Zeros{PTO_XLEN} + 17;
    assert ReadTileElement(28, 1, 0) == Zeros{PTO_XLEN} + 37;
    TGEMV_MX(28, 5, 61, 27, 63);
    assert ReadTileElement(28, 0, 0) == Zeros{PTO_XLEN} + 8;
    assert ReadTileElement(28, 1, 0) == Zeros{PTO_XLEN} + 18;
end;
func main() => integer
begin
    ResetProfileState();
    TestTileHandlerClosure();
    return 0;
end;
