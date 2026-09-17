// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-GENERIC-001","source":"asl/tile/model/legality/descriptor-shape.asl","requirements":["PTO-CUBE-CELL-STATE-001"],"kind":"fault","summary":"CUBE descriptors retain physical geometry independently from valid geometry","pass_condition":"M16 and M32 FP16 descriptors with physical slack pass CUBE legality and preserve exact physical metadata while remaining unavailable to generic indexing","related_sources":["asl/tile/model/shape/cube-cell.asl","asl/tile/model/definedness/elements.asl"]}
func main() => integer
begin
    ResetProfileState();
    let configured = ConfigureCubeTileForMaskWithPhysical(0, 1024, 16, 32,
        1, 16,
        TileDataType_FP16, TileLayout_CUBE_M16, '0001');
    assert configured;
    let tile = _Tiles[[0]];
    assert TileCubeDescriptorLegal(tile);
    assert tile.rows == 16 && tile.columns == 32;
    assert tile.valid_rows == 1 && tile.valid_columns == 16;
    assert tile.cube_k_repeat == 8 && tile.cube_n_repeat == 1;
    assert tile.cube_cell_count == 8 && tile.cube_storage_bytes == 1024;
    assert !TileGenericIndexingPermitted(tile);
    assert !TileDescriptorLegal(0);
    assert !TileSourceContentsDefined(0);

    let m32_configured = ConfigureCubeTileForMaskWithPhysical(1, 4096,
        32, 32, 1, 16, TileDataType_FP16, TileLayout_CUBE_M32,
        '0001');
    assert m32_configured;
    let m32_tile = _Tiles[[1]];
    assert TileCubeDescriptorLegal(m32_tile);
    assert m32_tile.rows == 32 && m32_tile.columns == 32;
    assert m32_tile.valid_rows == 1 && m32_tile.valid_columns == 16;
    assert m32_tile.cube_k_repeat == 16 && m32_tile.cube_n_repeat == 1;
    assert m32_tile.cube_cell_count == 16 &&
           m32_tile.cube_storage_bytes == 2048;
    assert TileCubeDescriptorShapeLegal(
        4096, 32, 31, TileDataType_FP16, TileLayout_CUBE_M32);
    let m32_slack_configured = ConfigureCubeTileForMaskWithPhysical(
        2, 4096, 32, 32, 31, 32,
        TileDataType_FP16, TileLayout_CUBE_M32, '0001');
    assert m32_slack_configured;
    assert _Tiles[[2]].valid_rows == 31 && _Tiles[[2]].rows == 32;
    let m32_rows64_valid32 = ConfigureCubeTileForMaskWithPhysical(
        3, 4096, 64, 32, 32, 32,
        TileDataType_FP16, TileLayout_CUBE_M32, '0001');
    assert !m32_rows64_valid32;
    let m32_rows64_valid64 = ConfigureCubeTileForMaskWithPhysical(
        3, 4096, 64, 32, 64, 32,
        TileDataType_FP16, TileLayout_CUBE_M32, '0001');
    assert !m32_rows64_valid64;
    assert !TileCubeDescriptorShapeAndPhysicalLegal(4096, 64, 32,
        1, 16, TileDataType_FP16, TileLayout_CUBE_M32);
    assert !TileCubeDescriptorShapeAndPhysicalLegal(4096, 32, 32,
        33, 16, TileDataType_FP16, TileLayout_CUBE_M32);
    return 0;
end;
