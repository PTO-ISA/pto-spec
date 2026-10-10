// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-M32-B64-GEOMETRY-002","source":"asl/tile/model/shape/cube-cell.asl","requirements":["PTO-CUBE-CELL-STATE-001","PTO-CUBE-M32-B64-DOUBLE-CELL-001"],"kind":"boundary","summary":"M32 b64 keeps one logical Word per element across partial rows and the maximum bounded physical column extent.","pass_condition":"A 3x2 valid U64 Tile uses four CELLs and 64 payload slots, payload indices remain column-major by 32 rows, 1024 columns exactly fill model bounds, 1025 columns reject, and lower-width M32 mapping remains unchanged.","related_sources":["asl/tile/model/shape/cube-double-cell.asl","asl/tile/model/state/allocation.asl"]}
func main() => integer
begin
    ResetProfileState();
    let configured = ConfigureCubeTile(
        0, 512, 3, 2, TileDataType_U64, TileLayout_CUBE_M32);
    assert configured;
    assert _Tiles[[0]].rows == 32 && _Tiles[[0]].columns == 2;
    assert _Tiles[[0]].valid_rows == 3 && _Tiles[[0]].valid_columns == 2;
    assert _Tiles[[0]].cube_cell_count == 4;
    assert _Tiles[[0]].cube_storage_bytes == 512;
    assert TileCubePhysicalStorageElements(
        TileLayout_CUBE_M32, 32, 2, TileDataType_U64) == 64;
    assert TileCubePayloadIndex(_Tiles[[0]], 0, 0) == 0;
    assert TileCubePayloadIndex(_Tiles[[0]], 31, 0) == 31;
    assert TileCubePayloadIndex(_Tiles[[0]], 0, 1) == 32;

    assert TileCubeDescriptorShapeAndPhysicalLegal(
        65536, 32, 256, 1, 1,
        TileDataType_U64, TileLayout_CUBE_M32);
    assert !TileCubeDescriptorShapeAndPhysicalLegal(
        65536, 32, 257, 1, 1,
        TileDataType_U64, TileLayout_CUBE_M32);
    assert TileCapacityIsLegal(65536);
    assert !TileCapacityIsLegal(262144);
    assert TileCubePhysicalCellCount(
        TileLayout_CUBE_M32, 32, 1024, TileDataType_U64) == 2048;
    assert TileCubePhysicalRequiredBytes(
        TileLayout_CUBE_M32, 32, 1024, TileDataType_U64) == 262144;
    assert TileCubePhysicalStorageElements(
        TileLayout_CUBE_M32, 32, 1024, TileDataType_U64) == 32768;
    assert TileCubePhysicalStorageElements(
        TileLayout_CUBE_M32, 32, 1025, TileDataType_U64) == 0;
    assert !TileCubeDescriptorShapeAndPhysicalLegal(
        262144, 32, 1025, 1, 1,
        TileDataType_U64, TileLayout_CUBE_M32);

    var lower = _Tiles[[1]];
    lower.layout = TileLayout_CUBE_M32;
    lower.data_type = TileDataType_U32;
    lower.rows = 32;
    lower.columns = 2;
    assert TileCubePhysicalCellCount(
        lower.layout, lower.rows, lower.columns, lower.data_type) == 2;
    assert TileCubePayloadIndex(lower, 0, 0) == 0;
    assert TileCubePayloadIndex(lower, 31, 0) == 31;
    assert TileCubePayloadIndex(lower, 0, 1) == 32;
    return 0;
end;
