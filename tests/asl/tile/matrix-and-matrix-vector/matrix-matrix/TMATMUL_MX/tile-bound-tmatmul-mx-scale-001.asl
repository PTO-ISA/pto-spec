// PTO-TEST: {"id":"PTO-AVS-TILE-TMATMUL-MX-SCALE-001","source":"asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX.asl","requirements":["PTO-INST-TILE-TMATMUL-MX","PTO-CUBE-MATRIX-SCALE-001"],"kind":"boundary","summary":"TMATMULMX scale operands are omitted or required independently from each matrix type.","pass_condition":"FP16 sides reject supplied scales while E4M3 sides require correctly shaped Local CUBE_M32 E8M0 scales.","related_sources":["asl/tile/model/legality/matrix-shape.asl"]}
func SelectTMATMULMX(data_type: bits(5))
begin
    InstallBundleOperationDescriptor(BundleOperationDescriptor {
        valid = TRUE,
        form_identity = Zeros{7},
        operation_class = BundleOperation_TileMatrix,
        selector_valid = TRUE,
        selector = Zeros{10} + 4,
        data_type_valid = TRUE,
        data_type = data_type,
        mode_valid = FALSE,
        mode = Zeros{2},
        branch_type_valid = FALSE,
        branch_type = Zeros{3}
    });
end;

func main() => integer
begin
    ResetProfileState();
    SelectTMATMULMX('00100');
    let fp_left_ready = ConfigureCubeTile(1, 128, 1, 2,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix);
    let fp_right_ready = ConfigureCubeTile(2, 128, 2, 2,
        TileDataType_FP16, TileLayout_CUBE_N8,
        TileLocation_Matrix);
    assert fp_left_ready && fp_right_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 1, 1, Zeros{PTO_XLEN});
    assert TileCubeDescriptorLegal(_Tiles[[1]]);
    assert TileCubeDescriptorLegal(_Tiles[[2]]);
    assert TileMatrixCubeInfosMatchDimensions(
        _Tiles[[1]], _Tiles[[2]], 1, 2, 2);
    assert TileMXMatrixOperandsLegal(1, 2);
    assert TileMatrixInfoOptionalScalesLegal(
        _Tiles[[1]], _Tiles[[0]], FALSE,
        _Tiles[[2]], _Tiles[[0]], FALSE);
    assert !TileMatrixInfoOptionalScalesLegal(
        _Tiles[[1]], _Tiles[[0]], TRUE,
        _Tiles[[2]], _Tiles[[0]], FALSE);

    ResetProfileState();
    SelectTMATMULMX('00111');
    let mx_left_ready = ConfigureCubeTile(1, 128, 1, 2,
        TileDataType_E4M3, TileLayout_CUBE_M16,
        TileLocation_Matrix);
    let mx_right_ready = ConfigureCubeTile(2, 128, 2, 2,
        TileDataType_E4M3, TileLayout_CUBE_N8,
        TileLocation_Matrix);
    assert mx_left_ready && mx_right_ready;
    let left_scale_ready = ConfigureCubeTileForMask(3, 128, 1, 1,
        TileDataType_E8M0, TileLayout_CUBE_M32,
        TileLocation_Matrix, '1000');
    let right_scale_ready = ConfigureCubeTileForMask(4, 128, 2, 1,
        TileDataType_E8M0, TileLayout_CUBE_M32,
        TileLocation_Matrix, '1000');
    assert left_scale_ready && right_scale_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 1, 1, Zeros{PTO_XLEN});
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(4, 1, 0, Zeros{PTO_XLEN});
    MarkTileValidRegionDefined(3);
    MarkTileValidRegionDefined(4);
    assert TileMatrixInfoOptionalScalesLegal(
        _Tiles[[1]], _Tiles[[3]], TRUE,
        _Tiles[[2]], _Tiles[[4]], TRUE);
    assert !TileMatrixInfoOptionalScalesLegal(
        _Tiles[[1]], _Tiles[[3]], FALSE,
        _Tiles[[2]], _Tiles[[4]], TRUE);
    return 0;
end;
