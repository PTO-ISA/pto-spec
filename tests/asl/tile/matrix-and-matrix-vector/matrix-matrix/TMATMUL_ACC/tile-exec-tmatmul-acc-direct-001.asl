// PTO-TEST: {"id":"PTO-AVS-TILE-TMATMUL-ACC-EXEC-001","source":"asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_ACC.asl","requirements":["PTO-TMATMUL-ACC-CONTRACT-001","PTO-INST-TILE-TMATMUL-ACC"],"kind":"execution","summary":"TMATMUL_ACC executes its direct 1x1 CUBE semantic handler","pass_condition":"the legal FP16 operands commit the expected FP32 result","related_sources":["asl/tile/model/legality/matrix-shape.asl","asl/tile/model/execution/cube.asl"]}
func SelectTMATMUL_ACCFP16()
begin
    InstallBundleOperationDescriptor(BundleOperationDescriptor {
        valid = TRUE,
        form_identity = Zeros{7},
        operation_class = BundleOperation_TileMatrix,
        selector_valid = TRUE,
        selector = Zeros{10} + 2,
        data_type_valid = TRUE,
        data_type = '00100',
        mode_valid = FALSE,
        mode = Zeros{2},
        branch_type_valid = FALSE,
        branch_type = Zeros{3}
    });
end;

func main() => integer
begin
    ResetProfileState();
    SelectTMATMUL_ACCFP16();
    let cube_configuration_1 = ConfigureCubeTile(1, 128, 1, 1, TileDataType_FP16,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    assert cube_configuration_1;
    let cube_configuration_2 = ConfigureCubeTile(2, 128, 1, 1, TileDataType_FP16,
        TileLayout_CUBE_N8, TileLocation_Matrix);
    assert cube_configuration_2;
    let cube_configuration_3 = ConfigureCubeTile(3, 128, 1, 1, TileDataType_FP32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    assert cube_configuration_3;
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 5);
    let cube_configuration_4 = ConfigureCubeTile(4, 128, 1, 1, TileDataType_FP32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    assert cube_configuration_4;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);

    assert TileOperandsLegal_TMATMUL_ACC(4, 3, 1, 2);
    TMATMUL_ACC(4, 3, 1, 2);
    assert ReadTileElement(4, 0, 0) ==
        Zeros{PTO_XLEN} + 11;
    return 0;
end;
