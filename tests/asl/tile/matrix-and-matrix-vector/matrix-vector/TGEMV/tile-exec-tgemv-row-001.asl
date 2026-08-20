// PTO-TEST: {"id":"PTO-AVS-TILE-TGEMV-ROW-001","source":"asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV.asl","requirements":["PTO-INST-TILE-TGEMV"],"kind":"execution","summary":"TGEMV is the M-equals-one matrix multiplication specialization","pass_condition":"a 1xK left vector multiplied by a KxN right matrix produces one 1xN destination row","related_sources":["asl/tile/model/legality/matrix-shape.asl","asl/tile/model/execution/cube.asl"]}
func SelectTGEMVUnsignedInputType()
begin
    InstallBundleOperationDescriptor(BundleOperationDescriptor {
        valid = TRUE,
        form_identity = Zeros{7},
        operation_class = BundleOperation_TileMatrix,
        selector_valid = TRUE,
        selector = Zeros{10} + 16,
        data_type_valid = TRUE,
        data_type = '11010',
        mode_valid = FALSE,
        mode = Zeros{2},
        branch_type_valid = FALSE,
        branch_type = Zeros{3}
    });
end;

func main() => integer
begin
    ResetProfileState();
    SelectTGEMVUnsignedInputType();

    assert ConfigureCubeTile(1, 128, 1, 2, TileDataType_U16,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    assert ConfigureCubeTile(2, 128, 2, 2, TileDataType_U16,
        TileLayout_CUBE_N8, TileLocation_Matrix);
    assert ConfigureCubeTile(3, 128, 1, 2, TileDataType_U32,
        TileLayout_CUBE_M16, TileLocation_Matrix);

    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 3);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 7);
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN} + 11);
    WriteTileElement(2, 1, 1, Zeros{PTO_XLEN} + 13);

    assert TileOperandsLegal_TGEMV(3, 1, 2);
    TGEMV(3, 1, 2);
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 43;
    assert ReadTileElement(3, 0, 1) == Zeros{PTO_XLEN} + 53;
    return 0;
end;
