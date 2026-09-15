// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-PHYSICAL-FAULTS-002","source":"asl/tile/model/shape/cube-cell.asl","requirements":["PTO-CUBE-CELL-STATE-001"],"kind":"fault","summary":"CUBE physical geometry rejects uncovered, misaligned, metadata-inconsistent, and under-capacity descriptors","pass_condition":"M16/M32 reject uncovered valid extents, explicit M16 wrong-row and M32 wrong-column geometry, other physical alignment violations, insufficient capacity, and each inconsistent k-repeat, n-repeat, CELL-count, or storage-byte field","related_sources":["asl/tile/model/legality/descriptor-shape.asl","asl/tile/model/state/allocation.asl"]}
func main() => integer
begin
    ResetProfileState();
    assert TileCubeDescriptorShapeAndPhysicalLegal(1024, 16, 32,
        1, 16, TileDataType_FP16, TileLayout_CUBE_M16);
    assert !TileCubeDescriptorShapeAndPhysicalLegal(1024, 16, 32,
        17, 16, TileDataType_FP16, TileLayout_CUBE_M16);
    assert !TileCubeDescriptorShapeAndPhysicalLegal(1024, 32, 32,
        1, 16, TileDataType_FP16, TileLayout_CUBE_M16);
    assert !TileCubeDescriptorShapeAndPhysicalLegal(1024, 16, 30,
        1, 16, TileDataType_FP16, TileLayout_CUBE_M16);
    assert !TileCubeDescriptorShapeAndPhysicalLegal(1024, 31, 16,
        1, 16, TileDataType_FP16, TileLayout_CUBE_M32);
    assert !TileCubeDescriptorShapeAndPhysicalLegal(1024, 32, 31,
        1, 16, TileDataType_FP16, TileLayout_CUBE_M32);
    assert !TileCubeDescriptorShapeAndPhysicalLegal(512, 16, 32,
        1, 16, TileDataType_FP16, TileLayout_CUBE_M16);

    let configured = ConfigureCubeTileForMaskWithPhysical(0, 1024, 16, 32,
        1, 16, TileDataType_FP16, TileLayout_CUBE_M16, '0001');
    assert configured;
    var tile = _Tiles[[0]];
    var bad_k_repeat = tile;
    bad_k_repeat.cube_k_repeat = 7;
    assert !TileCubeDescriptorLegal(bad_k_repeat);
    var bad_n_repeat = tile;
    bad_n_repeat.cube_n_repeat = 2;
    assert !TileCubeDescriptorLegal(bad_n_repeat);
    var bad_cell_count = tile;
    bad_cell_count.cube_cell_count = 7;
    assert !TileCubeDescriptorLegal(bad_cell_count);
    var bad_storage_bytes = tile;
    bad_storage_bytes.cube_storage_bytes = 896;
    assert !TileCubeDescriptorLegal(bad_storage_bytes);
    return 0;
end;
