// PTO-TEST: {"id":"PTO-AVS-TILE-TMATMUL-EXEC-001","source":"asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL.asl","requirements":["PTO-TMATMUL-CONTRACT-001","PTO-INST-TILE-TMATMUL"],"kind":"execution","summary":"TMATMUL executes its direct 1x1 CUBE semantic handler","pass_condition":"the legal FP16 operands commit the expected FP32 result","related_sources":["asl/tile/model/legality/matrix-shape.asl","asl/tile/model/execution/cube.asl"]}
func SelectTMATMULFP16()
begin
    InstallBundleOperationDescriptor(BundleOperationDescriptor {
        valid = TRUE,
        form_identity = Zeros{7},
        operation_class = BundleOperation_TileMatrix,
        selector_valid = TRUE,
        selector = Zeros{10} + 0,
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
    SelectTMATMULFP16();
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

    assert TileOperandsLegal_TMATMUL(3, 1, 2);
    TMATMUL(3, 1, 2);
    assert ReadTileElement(3, 0, 0) ==
        Zeros{PTO_XLEN} + 0x40c00000;
    return 0;
end;
