// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-TILE-TESTTILEHANDLERCLOSURE-BOUNDARY-001","source":"asl/tile/model/dispatch/top-level.asl","requirements":[],"kind":"boundary","summary":"Covers Tile Handler Closure.","pass_condition":"TestTileHandlerClosure completes without assertion failure","related_sources":[]}
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
    ConfigurePredicateTile(53, 256, 16, 2, 2, 2);
    ExecuteTileCompare(53, 51, 52, TileComparison_LT);
    assert ReadTilePredicateBit(53, 0, 0);
    assert !ReadTilePredicateBit(53, 0, 1);
    ExecuteTileCompareScalar(53, 51, Zeros{PTO_XLEN} + 3,
        TileComparison_GE);
    assert !ReadTilePredicateBit(53, 0, 0);
    assert ReadTilePredicateBit(53, 0, 1);
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
    TINSERT(55, 55, 56, 1, 0);
    assert ReadTileElement(55, 1, 0) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(55, 1, 1) == Zeros{PTO_XLEN} + 8;

    ConfigureTile(56, 256, 1, 2, 1, 2, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(57, 256, 1, 2, 1, 2, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(61, 256, 4, 2, 4, 2, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(56, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(56, 0, 1, Zeros{PTO_XLEN} + 8);
    WriteTileElement(57, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(57, 0, 1, Zeros{PTO_XLEN} + 3);
    TSCATTER(61, 56, 57);
    assert ReadTileElement(61, 1, 0) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(61, 3, 1) == Zeros{PTO_XLEN} + 8;

    ConfigureTile(56, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(56, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(56, 0, 1, Zeros{PTO_XLEN} + 8);
    TCONCAT(59, 56, 58);
    assert ReadTileElement(59, 0, 0) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(59, 0, 3) == Zeros{PTO_XLEN} + 8;
    TMOV(62, 55);
    assert ReadTileElement(62, 1, 1) == Zeros{PTO_XLEN} + 8;

    // This closure test owns its matrix fixture. It must not inherit tiles
    // configured by TestTileMatmul when executed as an independent shard.
    ConfigureTile(5, 256, 2, 2, 2, 2, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(6, 256, 2, 2, 2, 2, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(7, 256, 2, 2, 2, 2, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(27, 256, 2, 1, 2, 1, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(28, 256, 1, 1, 1, 1, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(29, 256, 1, 2, 1, 2, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 0x3c00);
    WriteTileElement(5, 0, 1, Zeros{PTO_XLEN} + 0x4000);
    WriteTileElement(5, 1, 0, Zeros{PTO_XLEN} + 0x4200);
    WriteTileElement(5, 1, 1, Zeros{PTO_XLEN} + 0x4400);
    WriteTileElement(6, 0, 0, Zeros{PTO_XLEN} + 0x4500);
    WriteTileElement(6, 0, 1, Zeros{PTO_XLEN} + 0x4600);
    WriteTileElement(6, 1, 0, Zeros{PTO_XLEN} + 0x4700);
    WriteTileElement(6, 1, 1, Zeros{PTO_XLEN} + 0x4800);
    WriteTileElement(27, 0, 0, Zeros{PTO_XLEN} + 0x4000);
    WriteTileElement(27, 1, 0, Zeros{PTO_XLEN} + 0x4200);
    WriteTileElement(29, 0, 0, Zeros{PTO_XLEN} + 0x3c00);
    WriteTileElement(29, 0, 1, Zeros{PTO_XLEN} + 0x4000);

    ConfigureTile(61, 256, 1, 1, 1, 1, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(61, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
    SelectTestCUBEDataType('00100');
    TMATMUL_MX(7, 5, 0, 6, 0);
    assert ReadTileElement(7, 0, 0) == Zeros{PTO_XLEN} + 0x41980000;
    TGEMV_BIAS(28, 29, 27, 61);
    assert ReadTileElement(28, 0, 0) == Zeros{PTO_XLEN} + 0x41100000;
    TGEMV_ACC(28, 28, 29, 27);
    assert ReadTileElement(28, 0, 0) == Zeros{PTO_XLEN} + 0x41880000;
    TGEMV_MX(28, 29, 0, 27, 0);
    assert ReadTileElement(28, 0, 0) == Zeros{PTO_XLEN} + 0x41000000;
end;
func main() => integer
begin
    ResetProfileState();
    TestTileHandlerClosure();
    return 0;
end;
