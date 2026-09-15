// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-PHYSICAL-FAULTS-002","source":"asl/tile/model/shape/cube-cell.asl","requirements":["PTO-CUBE-CELL-STATE-001"],"kind":"fault","summary":"CUBE physical geometry rejects uncovered, misaligned, metadata-inconsistent, and under-capacity descriptors","pass_condition":"M16/M32 reject uncovered valid extents, physical alignment violations, insufficient capacity, and mutated physical CELL metadata","related_sources":["asl/tile/model/legality/descriptor-shape.asl","asl/tile/model/state/allocation.asl"]}
func main() => integer
begin
    ResetProfileState();
    assert TileCubeDescriptorShapeAndPhysicalLegal(1024, 16, 32,
        1, 16, TileDataType_FP16, TileLayout_CUBE_M16);
    assert !TileCubeDescriptorShapeAndPhysicalLegal(1024, 16, 32,
        17, 16, TileDataType_FP16, TileLayout_CUBE_M16);
    assert !TileCubeDescriptorShapeAndPhysicalLegal(1024, 16, 30,
        1, 16, TileDataType_FP16, TileLayout_CUBE_M16);
    assert !TileCubeDescriptorShapeAndPhysicalLegal(1024, 31, 16,
        1, 16, TileDataType_FP16, TileLayout_CUBE_M32);
    assert !TileCubeDescriptorShapeAndPhysicalLegal(512, 16, 32,
        1, 16, TileDataType_FP16, TileLayout_CUBE_M16);

    let configured = ConfigureCubeTileForMaskWithPhysical(0, 1024, 16, 32,
        1, 16, TileDataType_FP16, TileLayout_CUBE_M16, '0001');
    assert configured;
    var tile = _Tiles[[0]];
    tile.cube_cell_count = 7;
    assert !TileCubeDescriptorLegal(tile);
    return 0;
end;
