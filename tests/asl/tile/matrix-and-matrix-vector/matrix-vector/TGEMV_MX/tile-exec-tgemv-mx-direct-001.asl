// PTO-TEST: {"id":"PTO-AVS-TILE-TGEMV-MX-EXEC-001","source":"asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_MX.asl","requirements":["PTO-TGEMV-MX-CONTRACT-001","PTO-INST-TILE-TGEMV-MX"],"kind":"execution","summary":"TGEMV_MX executes its direct 1x1 CUBE semantic handler","pass_condition":"the legal FP16 operands commit the expected FP32 result","related_sources":["asl/tile/model/legality/matrix-shape.asl","asl/tile/model/execution/cube.asl"]}
func SelectTGEMV_MXFP16()
begin
    InstallBundleOperationDescriptor(BundleOperationDescriptor {
        valid = TRUE,
        form_identity = Zeros{7},
        operation_class = BundleOperation_TileMatrix,
        selector_valid = TRUE,
        selector = Zeros{10} + 20,
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
    SelectTGEMV_MXFP16();
    assert ConfigureCubeTile(1, 128, 1, 1, TileDataType_FP16,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    assert ConfigureCubeTile(2, 128, 1, 1, TileDataType_FP16,
        TileLayout_CUBE_N8, TileLocation_Matrix);
    assert ConfigureCubeTile(3, 128, 1, 1, TileDataType_FP32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);

    assert TileOperandsLegal_TGEMV_MX(3, 1, 0, 2, 0);
    TGEMV_MX(3, 1, 0, 2, 0);
    assert ReadTileElement(3, 0, 0) ==
        Zeros{PTO_XLEN} + 6;
    return 0;
end;
