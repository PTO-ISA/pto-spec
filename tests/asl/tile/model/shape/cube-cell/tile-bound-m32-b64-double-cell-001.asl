// PTO-TEST: {"id":"PTO-AVS-TILE-M32-B64-DOUBLE-CELL-001","source":"asl/tile/model/shape/cube-cell.asl","requirements":["PTO-CUBE-CELL-STATE-001","PTO-CUBE-M32-B64-DOUBLE-CELL-001"],"kind":"boundary","summary":"M32 b64 storage preserves 32 logical rows and charges two physical CELLs per column.","pass_condition":"FP64, S64 and U64 accept M32 with exact 256-byte per-column capacity while M16 b64 remains illegal.","related_sources":["asl/tile/model/shape/cube-double-cell.asl"]}
func main() => integer
begin
    ResetProfileState();
    assert TileCubeLayoutDataTypeSupported(TileLayout_CUBE_M32, TileDataType_U64);
    assert TileCubeLayoutDataTypeSupported(TileLayout_CUBE_M32, TileDataType_S64);
    assert TileCubeLayoutDataTypeSupported(TileLayout_CUBE_M32, TileDataType_FP64);
    assert !TileCubeLayoutDataTypeSupported(TileLayout_CUBE_M16, TileDataType_U64);
    assert TileCubeCellCount(TileLayout_CUBE_M32, 32, 1, TileDataType_U64) == 2;
    assert TileCubeRequiredBytes(TileLayout_CUBE_M32, 32, 1, TileDataType_U64) == 256;
    assert TileCubeStorageElementsForColumns(TileLayout_CUBE_M32, 32, 1, TileDataType_U64) == 32;
    assert !TileCubeDescriptorShapeLegal(128, 32, 1, TileDataType_U64, TileLayout_CUBE_M32);
    assert TileCubeDescriptorShapeLegal(256, 32, 1, TileDataType_FP64, TileLayout_CUBE_M32);
    assert TileCubeDescriptorShapeLegal(256, 32, 1, TileDataType_S64, TileLayout_CUBE_M32);
    assert TileCubeDescriptorShapeLegal(256, 32, 1, TileDataType_U64, TileLayout_CUBE_M32);
    return 0;
end;
