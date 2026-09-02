// PTO-TEST: {"id":"PTO-AVS-TILE-TMATMUL-MX-UNSCALED-001","source":"asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX.asl","requirements":["PTO-TMATMUL-MX-CONTRACT-001"],"kind":"execution","summary":"TMATMUL_MX omits both scale operands for FP16 inputs","pass_condition":"an FP16 1x1 product accepts absent scale Tiles and commits the FP32 value six","related_sources":["asl/tile/model/legality/matrix-shape.asl","asl/tile/model/execution/cube.asl"]}
func SelectTMATMULMXFP16()
begin
    InstallBundleOperationDescriptor(BundleOperationDescriptor {
        valid = TRUE,
        form_identity = Zeros{7},
        operation_class = BundleOperation_TileMatrix,
        selector_valid = TRUE,
        selector = Zeros{10} + 4,
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
    SelectTMATMULMXFP16();
    let cube_configuration_1 = ConfigureCubeTile(1, 128, 1, 1, TileDataType_FP16,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    assert cube_configuration_1;
    let cube_configuration_2 = ConfigureCubeTile(2, 128, 1, 1, TileDataType_FP16,
        TileLayout_CUBE_N8, TileLocation_Matrix);
    assert cube_configuration_2;
    let cube_configuration_3 = ConfigureCubeTile(3, 128, 1, 1, TileDataType_FP32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    assert cube_configuration_3;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x4000);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x4200);

    assert TileOperandsLegal_TMATMUL_MX(3, 1, 0, 2, 0);
    TMATMUL_MX(3, 1, 0, 2, 0);
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 0x40c00000;
    return 0;
end;
