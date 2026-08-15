// PTO-TEST: {"id":"PTO-AVS-TILE-TMATMUL-MX-SCALE-001","source":"asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX.asl","requirements":["PTO-INST-TILE-TMATMUL-MX"],"kind":"boundary","summary":"TMATMULMX scale operands are omitted or required independently from each matrix type","pass_condition":"FP16 sides reject supplied scales while E4M3 sides require correctly shaped E8M0 scales","related_sources":["asl/tile/model/legality/matrix-shape.asl"]}
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
    ConfigureTile(1, 128, 8, 8, 1, 2, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(2, 128, 8, 8, 2, 2, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Matrix);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 1, 1, Zeros{PTO_XLEN});
    assert TileInfoDescriptorLegal(_Tiles[[1]]);
    assert TileInfoDescriptorLegal(_Tiles[[2]]);
    assert TileMatrixInfoShapeLegal(_Tiles[[1]], _Tiles[[2]]);
    assert TileMXMatrixOperandsLegal(1, 2);
    assert TileMatrixInfoOptionalScalesLegal(
        _Tiles[[1]], _Tiles[[0]], FALSE,
        _Tiles[[2]], _Tiles[[0]], FALSE);
    assert !TileMatrixInfoOptionalScalesLegal(
        _Tiles[[1]], _Tiles[[0]], TRUE,
        _Tiles[[2]], _Tiles[[0]], FALSE);

    ResetProfileState();
    SelectTMATMULMX('00111');
    ConfigureTile(1, 128, 16, 8, 1, 2, TileDataType_E4M3,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(2, 128, 16, 8, 2, 2, TileDataType_E4M3,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(3, 128, 16, 8, 1, 1, TileDataType_E8M0,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(4, 128, 16, 8, 1, 2, TileDataType_E8M0,
        TileLayout_RowMajor, TileLocation_Matrix);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 1, 1, Zeros{PTO_XLEN});
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN});
    assert TileMatrixInfoOptionalScalesLegal(
        _Tiles[[1]], _Tiles[[3]], TRUE,
        _Tiles[[2]], _Tiles[[4]], TRUE);
    assert !TileMatrixInfoOptionalScalesLegal(
        _Tiles[[1]], _Tiles[[3]], FALSE,
        _Tiles[[2]], _Tiles[[4]], TRUE);
    return 0;
end;
