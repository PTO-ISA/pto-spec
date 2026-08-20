// PTO-TEST: {"id":"PTO-AVS-TILE-TMATMUL-CUBE-STORAGE-003","source":"asl/tile/model/execution/cube.asl","requirements":["PTO-CUBE-LOCAL-MATRIX-001"],"kind":"execution","summary":"TMATMUL reads and writes logical coordinates through persistent CUBE storage mappings","pass_condition":"M16 A N8 B and M16 D produce the exact 2 by 2 product while preserving their non-row-major physical payload order","related_sources":["asl/tile/model/shape/cube-cell.asl","asl/tile/model/legality/matrix-cube-primary.asl"]}
func WriteCubeStorageValue(index: TileIndex,
                           row: integer {0..65535},
                           column: integer {0..65535},
                           value: integer)
begin
    let element = TileStorageIndex(_Tiles[[index]], row, column);
    _Tiles[[index]].payload[[element]] = Zeros{PTO_XLEN} + value;
end;

func main() => integer
begin
    ResetProfileState();
    InstallBundleOperationDescriptor(BundleOperationDescriptor {
        valid = TRUE,
        form_identity = Zeros{7},
        operation_class = BundleOperation_TileMatrix,
        selector_valid = TRUE,
        selector = Zeros{10},
        data_type_valid = TRUE,
        data_type = Zeros{5} + 4,
        mode_valid = FALSE,
        mode = Zeros{2},
        branch_type_valid = FALSE,
        branch_type = Zeros{3}
    });
    let a_ready = ConfigureCubeTile(1, 128, 2, 3,
        TileDataType_FP16, TileLayout_CUBE_M16, TileLocation_Matrix);
    let b_ready = ConfigureCubeTile(2, 128, 3, 2,
        TileDataType_FP16, TileLayout_CUBE_N8, TileLocation_Matrix);
    let d_ready = ConfigureCubeTile(3, 128, 2, 2,
        TileDataType_FP32, TileLayout_CUBE_M16, TileLocation_Matrix);
    assert a_ready && b_ready && d_ready;

    WriteCubeStorageValue(1, 0, 0, 1);
    WriteCubeStorageValue(1, 0, 1, 2);
    WriteCubeStorageValue(1, 0, 2, 3);
    WriteCubeStorageValue(1, 1, 0, 4);
    WriteCubeStorageValue(1, 1, 1, 5);
    WriteCubeStorageValue(1, 1, 2, 6);
    WriteCubeStorageValue(2, 0, 0, 1);
    WriteCubeStorageValue(2, 0, 1, 2);
    WriteCubeStorageValue(2, 1, 0, 3);
    WriteCubeStorageValue(2, 1, 1, 4);
    WriteCubeStorageValue(2, 2, 0, 5);
    WriteCubeStorageValue(2, 2, 1, 6);
    MarkTileValidRegionDefined(1);
    MarkTileValidRegionDefined(2);

    TMATMUL(3, 1, 2);

    assert _LastFault == Fault_None;
    let d = _Tiles[[3]];
    assert d.layout == TileLayout_CUBE_M16;
    assert d.location == TileLocation_Matrix;
    assert d.payload[[TileStorageIndex(d, 0, 0)]] ==
        Zeros{PTO_XLEN} + 22;
    assert d.payload[[TileStorageIndex(d, 0, 1)]] ==
        Zeros{PTO_XLEN} + 28;
    assert d.payload[[TileStorageIndex(d, 1, 0)]] ==
        Zeros{PTO_XLEN} + 49;
    assert d.payload[[TileStorageIndex(d, 1, 1)]] ==
        Zeros{PTO_XLEN} + 64;
    assert d.contents_defined && d.defined_valid_elements == 4;
    return 0;
end;
