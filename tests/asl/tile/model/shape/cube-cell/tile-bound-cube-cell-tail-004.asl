// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-CELL-TAIL-004","source":"asl/tile/model/shape/cube-cell.asl","requirements":["PTO-CUBE-CELL-STATE-001"],"kind":"boundary","summary":"CUBE valid dimensions may be non-powers-of-two and derive aligned storage tails","pass_condition":"N8 and M layouts round physical storage while retaining valid dimensions 3 5 13 and 19","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    assert TileCubeStorageRows(TileLayout_CUBE_N8, 13,
        TileDataType_FP16) == 16;
    assert TileCubeStorageColumns(TileLayout_CUBE_N8, 19,
        TileDataType_FP16) == 24;
    assert TileCubeStorageRows(TileLayout_CUBE_M16, 3,
        TileDataType_FP32) == 16;
    assert TileCubeStorageColumns(TileLayout_CUBE_M16, 5,
        TileDataType_FP32) == 6;
    assert TileCubeStorageRows(TileLayout_CUBE_M32, 13,
        TileDataType_FP16) == 32;
    assert TileCubeStorageColumns(TileLayout_CUBE_M32, 19,
        TileDataType_FP16) == 20;
    assert TileCubeDescriptorShapeLegal(768, 13, 19,
        TileDataType_FP16, TileLayout_CUBE_N8);
    assert TileCubeDescriptorShapeLegal(384, 3, 5,
        TileDataType_FP32, TileLayout_CUBE_M16);
    return 0;
end;
