// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-EXACT-CAPACITY-001","source":"asl/tile/model/shape/cube-cell.asl","requirements":["PTO-CUBE-CELL-STATE-001"],"kind":"boundary","summary":"Local M16/M32 geometry derives its complete physical envelope from allocation capacity and actual backing width.","pass_condition":"Exact M16/M32 capacity accepts valid-region padding, rejects independent allocation slack, and implicit physical columns cover the complete capacity for U8, packed-four-bit, and M32 b64 storage while M16 b64 remains illegal.","related_sources":["asl/tile/model/state/allocation.asl","asl/tile/model/legality/descriptor-shape.asl","asl/tile/model/definedness/elements.asl"]}
func main() => integer
begin
    ResetProfileState();

    assert TileCubeDescriptorShapeAndPhysicalLegal(
        512, 32, 16, 32, 12,
        TileDataType_U8, TileLayout_CUBE_M32);
    assert !TileCubeDescriptorShapeAndPhysicalLegal(
        512, 32, 12, 32, 12,
        TileDataType_U8, TileLayout_CUBE_M32);
    assert !TileCubeDescriptorShapeAndPhysicalLegal(
        8192, 32, 128, 32, 128,
        TileDataType_U8, TileLayout_CUBE_M32);

    let full_capacity = ConfigureCubeTile(
        0, 8192, 32, 1, TileDataType_U8, TileLayout_CUBE_M32);
    assert full_capacity;
    assert _Tiles[[0]].rows == 32 && _Tiles[[0]].columns == 256 &&
           _Tiles[[0]].valid_rows == 32 && _Tiles[[0]].valid_columns == 1 &&
           _Tiles[[0]].capacity_bytes == 8192 &&
           _Tiles[[0]].cube_storage_bytes == 8192;

    let m16 = ConfigureCubeTile(
        1, 512, 12, 27, TileDataType_U8, TileLayout_CUBE_M16);
    assert m16;
    assert _Tiles[[1]].rows == 16 && _Tiles[[1]].columns == 32 &&
           _Tiles[[1]].valid_rows == 12 && _Tiles[[1]].valid_columns == 27 &&
           _Tiles[[1]].cube_storage_bytes == 512;

    let packed = ConfigureCubeTile(
        2, 512, 12, 27, TileDataType_E2M1X2, TileLayout_CUBE_M16);
    assert packed;
    assert _Tiles[[2]].rows == 16 && _Tiles[[2]].columns == 64 &&
           _Tiles[[2]].valid_columns == 27 &&
           _Tiles[[2]].cube_storage_bytes == 512;

    let m32_b64 = ConfigureCubeTile(
        3, 512, 32, 1, TileDataType_U64, TileLayout_CUBE_M32);
    assert m32_b64;
    assert _Tiles[[3]].rows == 32 && _Tiles[[3]].columns == 2 &&
           _Tiles[[3]].cube_cell_count == 4 &&
           _Tiles[[3]].cube_storage_bytes == 512;

    assert !TileCubeDescriptorShapeLegal(
        512, 16, 1, TileDataType_FP64, TileLayout_CUBE_M16);
    return 0;
end;
