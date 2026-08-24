// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-CELL-CAPACITY-005","source":"asl/tile/model/shape/cube-cell.asl","requirements":["PTO-CUBE-CELL-STATE-001","PTO-CUBE-MATRIX-SCALE-001"],"kind":"fault","summary":"CUBE CELL descriptor legality rejects unsupported dimensions types and capacity before effects","pass_condition":"Exact capacity and HiF4X2 pass while one-byte-short, zero-dimension, primary-M row overflow, and b64 tuples reject","related_sources":["asl/tile/model/state/descriptors.asl"]}
func main() => integer
begin
    ResetProfileState();
    assert TileCubeDescriptorShapeLegal(768, 13, 19,
        TileDataType_FP16, TileLayout_CUBE_N8);
    assert !TileCubeDescriptorShapeLegal(767, 13, 19,
        TileDataType_FP16, TileLayout_CUBE_N8);
    assert !TileCubeDescriptorShapeLegal(128, 0, 8,
        TileDataType_FP16, TileLayout_CUBE_N8);
    assert !TileCubeDescriptorShapeLegal(128, 8, 0,
        TileDataType_FP16, TileLayout_CUBE_N8);
    assert !TileCubeDescriptorShapeLegal(128, 17, 1,
        TileDataType_FP32, TileLayout_CUBE_M16);
    assert !TileCubeDescriptorShapeLegal(128, 33, 1,
        TileDataType_FP32, TileLayout_CUBE_M32);
    assert TileCubeDescriptorShapeLegal(128, 16, 16,
        TileDataType_HiF4X2, TileLayout_CUBE_M16);
    assert !TileCubeDescriptorShapeLegal(128, 16, 1,
        TileDataType_FP64, TileLayout_CUBE_M16);
    return 0;
end;
