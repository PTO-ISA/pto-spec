// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-TILE-TESTMATRIXNUMERICCONTRACTLEGALITY-BOUNDARY-001","source":"asl/tile/model/legality/matrix-shape.asl","requirements":[],"kind":"boundary","summary":"Covers Matrix Numeric Contract Legality.","pass_condition":"TestMatrixNumericContractLegality completes without assertion failure","related_sources":[]}
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

func TestMatrixNumericContractLegality()
begin
    SelectTestCUBEDataType('00111');
    SetBundleDataAttributeState(Zeros{5} + 8, Zeros{5}, Zeros{2},
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    let left_ready = ConfigureCubeTile(40, 512, 1, 32,
        TileDataType_E4M3, TileLayout_CUBE_M16, TileLocation_Matrix);
    let right_ready = ConfigureCubeTile(41, 512, 32, 1,
        TileDataType_E5M2, TileLayout_CUBE_N8, TileLocation_Matrix);
    ConfigureTile(42, 256, 1, 1, 1, 1, TileDataType_E8M0,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(43, 256, 1, 1, 1, 1, TileDataType_E8M0,
        TileLayout_RowMajor, TileLocation_Any);
    let destination_ready = ConfigureCubeTile(44, 512, 1, 1,
        TileDataType_FP32, TileLayout_CUBE_M16, TileLocation_Matrix);
    let accumulated_ready = ConfigureCubeTile(45, 512, 1, 1,
        TileDataType_FP32, TileLayout_CUBE_M16, TileLocation_Matrix);
    assert left_ready && right_ready && destination_ready && accumulated_ready;
    for inner = 0 to 31 do
        WriteTileElement(40, 0, inner as integer {0..65535},
            Zeros{PTO_XLEN} + 1);
        WriteTileElement(41, inner as integer {0..65535}, 0,
            Zeros{PTO_XLEN} + 1);
    end;
    WriteTileElement(42, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(43, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(44, 0, 0, Zeros{PTO_XLEN} + 2);

    assert TileOperandsLegal_TMATMUL_MX(44, 40, 42, 41, 43);
    TMATMUL_MX(44, 40, 42, 41, 43);
    assert ReadTileElement(44, 0, 0) == Zeros{PTO_XLEN} + 32;
    TMATMUL_MX_ACC(45, 44, 40, 42, 41, 43);
    assert ReadTileElement(45, 0, 0) == Zeros{PTO_XLEN} + 64;

    ConfigureTile(42, 256, 1, 1, 1, 1, TileDataType_E8M0,
        TileLayout_RowMajor, TileLocation_Any);
    assert !TileOperandsLegal_TMATMUL_MX(44, 40, 42, 41, 43);
    ConfigureTile(42, 256, 1, 2, 1, 2, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    assert !TileOperandsLegal_TMATMUL_MX(44, 40, 42, 41, 43);
    SelectTestCUBEDataType('00100');
    assert !TileOperandsLegal_TMATMUL_MX(44, 40, 42, 41, 43);
end;
func main() => integer
begin
    ResetProfileState();
    TestMatrixNumericContractLegality();
    return 0;
end;
