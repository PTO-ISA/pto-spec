// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-TILE-TESTTILESELECTORCLOSUREEXTENSIONS-BOUNDARY-001","source":"asl/tile/model/dispatch/top-level.asl","requirements":[],"kind":"boundary","summary":"Covers Tile Selector Closure Extensions.","pass_condition":"TestTileSelectorClosureExtensions completes without assertion failure","related_sources":[]}
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

func TestTileSelectorClosureExtensions()
begin
    ConfigureTwoByTwo(0);
    ConfigureTwoByTwo(1);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} - 3);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} - 5);
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN} + 6);

    ConfigureTile(55, 256, 1, 4, 1, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(56, 256, 1, 4, 1, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigurePredicateTile(57, 128, 1, 4, 1, 3);
    ExecuteTileFillScalar(55, Zeros{PTO_XLEN} + 0xaa);
    WriteTileElement(56, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(56, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(56, 0, 2, Zeros{PTO_XLEN} + 2);
    WriteTilePredicateBit(57, 0, 0, TRUE);
    WriteTilePredicateBit(57, 0, 1, FALSE);
    WriteTilePredicateBit(57, 0, 2, TRUE);
    Store(Zeros{PTO_XLEN} + 1536, 8, Zeros{PTO_XLEN} + 11);
    Store(Zeros{PTO_XLEN} + 1544, 8, Zeros{PTO_XLEN} + 22);
    Store(Zeros{PTO_XLEN} + 1552, 8, Zeros{PTO_XLEN} + 33);
    MGATHER_MASK(55, Zeros{PTO_XLEN} + 1536,
        Zeros{PTO_XLEN} + 3, 56, 57, TilePad_Zero);
    assert ReadTileElement(55, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(55, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(55, 0, 2) == Zeros{PTO_XLEN} + 33;

    // MSCATTER_MASK uses the same logical linear element indices.
    Store(Zeros{PTO_XLEN} + 2048, 8, Zeros{PTO_XLEN});
    Store(Zeros{PTO_XLEN} + 2056, 8, Zeros{PTO_XLEN});
    Store(Zeros{PTO_XLEN} + 2064, 8, Zeros{PTO_XLEN});
    MSCATTER_MASK(Zeros{PTO_XLEN} + 2048,
        Zeros{PTO_XLEN} + 3, 55, 56, 57);
    let masked_scatter_first = LoadUnsigned(Zeros{PTO_XLEN} + 2048, 8);
    let masked_scatter_middle = LoadUnsigned(Zeros{PTO_XLEN} + 2056, 8);
    let masked_scatter_last = LoadUnsigned(Zeros{PTO_XLEN} + 2064, 8);
    assert masked_scatter_first == Zeros{PTO_XLEN} + 11;
    assert masked_scatter_middle == Zeros{PTO_XLEN};
    assert masked_scatter_last == Zeros{PTO_XLEN} + 33;

    ConfigureTile(58, 256, 1, 4, 1, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(59, 256, 1, 4, 1, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(58, 0, 0, Zeros{PTO_XLEN} + 11);
    WriteTileElement(58, 0, 1, Zeros{PTO_XLEN} + 99);
    WriteTileElement(58, 0, 2, Zeros{PTO_XLEN} + 33);
    WriteTileElement(59, 0, 0, Zeros{PTO_XLEN} + 111);
    WriteTileElement(59, 0, 1, Zeros{PTO_XLEN} + 222);
    WriteTileElement(59, 0, 2, Zeros{PTO_XLEN} + 333);
    // MGATHER_CAS indices are signed or unsigned logical element indices.
    WriteTileElement(56, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(56, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(56, 0, 2, Zeros{PTO_XLEN} + 2);
    MGATHER_CAS(55, Zeros{PTO_XLEN} + 1536,
        Zeros{PTO_XLEN} + 3, 56, 58, 59);
    assert ReadTileElement(55, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(55, 0, 1) == Zeros{PTO_XLEN} + 22;
    assert ReadTileElement(55, 0, 2) == Zeros{PTO_XLEN} + 33;
    let cas_first = LoadUnsigned(Zeros{PTO_XLEN} + 1536, 8);
    let cas_middle = LoadUnsigned(Zeros{PTO_XLEN} + 1544, 8);
    let cas_last = LoadUnsigned(Zeros{PTO_XLEN} + 1552, 8);
    assert cas_first == Zeros{PTO_XLEN} + 111;
    assert cas_middle == Zeros{PTO_XLEN} + 22;
    assert cas_last == Zeros{PTO_XLEN} + 333;

    ConfigureTile(2, 256, 2, 2, 2, 2, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(3, 256, 2, 2, 2, 2, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTwoByTwo(4);
    ConfigureTile(5, 256, 2, 1, 2, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(6, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(7, 256, 1, 2, 1, 2, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Matrix);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(2, 1, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 6);
    WriteTileElement(3, 1, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(3, 1, 1, Zeros{PTO_XLEN} + 8);
    ExecuteTileFillScalar(5, Zeros{PTO_XLEN} + 1);
    ExecuteTileFillScalar(6, Zeros{PTO_XLEN} + 1);
    ExecuteTileFillScalar(7, Zeros{PTO_XLEN} + 2);
    SelectTestCUBEDataType('00001');
    ConfigureTile(10, 256, 2, 2, 2, 2, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    TMATMUL_MX_BIAS(10, 2, 5, 3, 6, 7);
    assert ReadTileElement(10, 0, 0) == Zeros{PTO_XLEN} + 21;
    TMATMUL_MX_ACC(10, 10, 2, 5, 3, 6);
    assert ReadTileElement(10, 0, 0) == Zeros{PTO_XLEN} + 40;

    ConfigureTile(12, 128, 1, 1, 1, 1, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(13, 128, 1, 1, 1, 1, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(14, 128, 1, 1, 1, 1, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(15, 128, 1, 1, 1, 1, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Matrix);
    WriteTileElement(12, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(13, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(14, 0, 0, Zeros{PTO_XLEN} + 5);
    TGEMV_MX_BIAS(15, 12, 0, 13, 0, 14);
    assert ReadTileElement(15, 0, 0) == Zeros{PTO_XLEN} + 11;
    TGEMV_MX_ACC(15, 15, 12, 0, 13, 0);
    assert ReadTileElement(15, 0, 0) == Zeros{PTO_XLEN} + 17;
end;
func main() => integer
begin
    ResetProfileState();
    TestTileSelectorClosureExtensions();
    return 0;
end;
