// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-N8-U64-001","source":"asl/tile/model/shape/cube-cell.asl","requirements":["PTO-CUBE-CELL-STATE-001","PTO-CUBE-AUX-CELLREG-001","PTO-CUBE-M32-B64-DOUBLE-CELL-001"],"kind":"boundary","summary":"CUBE_N8 U64 retains its narrow exception alongside M32 double-CELL b64 storage","pass_condition":"U64 N8 geometry is legal with K_repeat one and aligned N-cell storage, M32 U64 uses two CELLs per logical column, and M16 U64 plus FP64/S64 N8 remain illegal","related_sources":["asl/tile/model/legality/descriptor-shape.asl","asl/tile/model/shape/cube-double-cell.asl"]}
func main() => integer
begin
    ResetProfileState();
    assert TileCubeLayoutDataTypeSupported(
        TileLayout_CUBE_N8, TileDataType_U64);
    assert TileCubeCellRows(
        TileLayout_CUBE_N8, TileDataType_U64) == 2;
    assert TileCubeCellColumns(
        TileLayout_CUBE_N8, TileDataType_U64) == 8;
    assert TileCubeStorageRows(
        TileLayout_CUBE_N8, 1, TileDataType_U64) == 2;
    assert TileCubeStorageColumns(
        TileLayout_CUBE_N8, 1, TileDataType_U64) == 8;
    assert TileCubeStorageColumns(
        TileLayout_CUBE_N8, 9, TileDataType_U64) == 16;
    assert TileCubeKRepeat(
        TileLayout_CUBE_N8, 1, 9, TileDataType_U64) == 1;
    assert TileCubeNRepeat(
        TileLayout_CUBE_N8, 1, 9, TileDataType_U64) == 2;
    assert TileCubeCellCount(
        TileLayout_CUBE_N8, 1, 9, TileDataType_U64) == 2;
    assert TileCubePhysicalRequiredBytes(
        TileLayout_CUBE_N8, 2, 8, TileDataType_U64) == 128;
    assert TileCubePhysicalRequiredBytes(
        TileLayout_CUBE_N8, 2, 16, TileDataType_U64) == 256;
    assert TileCubeDescriptorShapeLegal(
        128, 1, 1, TileDataType_U64, TileLayout_CUBE_N8);
    assert TileCubeDescriptorShapeLegal(
        256, 1, 9, TileDataType_U64, TileLayout_CUBE_N8);
    assert !TileCubeLayoutDataTypeSupported(
        TileLayout_CUBE_M16, TileDataType_U64);
    assert TileCubeLayoutDataTypeSupported(
        TileLayout_CUBE_M32, TileDataType_U64);
    assert TileCubeRequiredBytes(
        TileLayout_CUBE_M32, 32, 1, TileDataType_U64) == 256;
    assert !TileCubeLayoutDataTypeSupported(
        TileLayout_CUBE_N8, TileDataType_FP64);
    assert !TileCubeLayoutDataTypeSupported(
        TileLayout_CUBE_N8, TileDataType_S64);
    assert !TileCubeDescriptorShapeLegal(
        128, 1, 1, TileDataType_U64, TileLayout_CUBE_M16);
    return 0;
end;
