// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-CELL-WIDTH-001","source":"asl/tile/model/shape/cube-cell.asl","requirements":["PTO-CUBE-CELL-STATE-001"],"kind":"boundary","summary":"CUBE CELL geometry is exactly 128 bytes for each assigned width and layout","pass_condition":"M16 M32 and N8 return the assigned b32 b16 b8 and b4 dimensions while HiF4X2 and b64 reject","related_sources":["asl/arch/data-types/tile-data-types.asl"]}
func main() => integer
begin
    assert TileCubeCellRows(TileLayout_CUBE_N8, TileDataType_FP32) == 4;
    assert TileCubeCellRows(TileLayout_CUBE_N8, TileDataType_FP16) == 8;
    assert TileCubeCellRows(TileLayout_CUBE_N8, TileDataType_E4M3) == 16;
    assert TileCubeCellRows(TileLayout_CUBE_N8, TileDataType_E2M1X2) == 32;
    assert TileCubeCellColumns(TileLayout_CUBE_N8, TileDataType_FP32) == 8;
    assert TileCubeCellColumns(TileLayout_CUBE_N8, TileDataType_FP16) == 8;
    assert TileCubeCellColumns(TileLayout_CUBE_N8, TileDataType_E4M3) == 8;
    assert TileCubeCellColumns(TileLayout_CUBE_N8, TileDataType_E2M1X2) == 8;

    assert TileCubeCellRows(TileLayout_CUBE_M32, TileDataType_FP32) == 32;
    assert TileCubeCellRows(TileLayout_CUBE_M32, TileDataType_FP16) == 32;
    assert TileCubeCellRows(TileLayout_CUBE_M32, TileDataType_E4M3) == 32;
    assert TileCubeCellRows(TileLayout_CUBE_M32, TileDataType_E2M1X2) == 32;
    assert TileCubeCellColumns(TileLayout_CUBE_M32, TileDataType_FP32) == 1;
    assert TileCubeCellColumns(TileLayout_CUBE_M32, TileDataType_FP16) == 2;
    assert TileCubeCellColumns(TileLayout_CUBE_M32, TileDataType_E4M3) == 4;
    assert TileCubeCellColumns(TileLayout_CUBE_M32, TileDataType_E2M1X2) == 8;

    assert TileCubeCellRows(TileLayout_CUBE_M16, TileDataType_FP32) == 16;
    assert TileCubeCellRows(TileLayout_CUBE_M16, TileDataType_FP16) == 16;
    assert TileCubeCellRows(TileLayout_CUBE_M16, TileDataType_E4M3) == 16;
    assert TileCubeCellRows(TileLayout_CUBE_M16, TileDataType_E2M1X2) == 16;
    assert TileCubeCellColumns(TileLayout_CUBE_M16, TileDataType_FP32) == 2;
    assert TileCubeCellColumns(TileLayout_CUBE_M16, TileDataType_FP16) == 4;
    assert TileCubeCellColumns(TileLayout_CUBE_M16, TileDataType_E4M3) == 8;
    assert TileCubeCellColumns(TileLayout_CUBE_M16, TileDataType_E2M1X2) == 16;

    assert 4 * 8 * TileElementBits(TileDataType_FP32) == 1024;
    assert 8 * 8 * TileElementBits(TileDataType_FP16) == 1024;
    assert 16 * 8 * TileElementBits(TileDataType_E4M3) == 1024;
    assert 32 * 8 * TileElementBits(TileDataType_E2M1X2) == 1024;
    assert TileCubeDataTypeSupported(TileDataType_U4X2);
    assert !TileCubeDataTypeSupported(TileDataType_HiF4X2);
    assert !TileCubeDataTypeSupported(TileDataType_FP64);
    assert !TileCubeDataTypeSupported(TileDataType_S64);
    assert !TileCubeDataTypeSupported(TileDataType_U64);
    return 0;
end;
