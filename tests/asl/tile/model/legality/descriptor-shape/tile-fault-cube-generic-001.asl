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
        64, 32, 1, 16, TileDataType_FP16, TileLayout_CUBE_M32,
        '0001');
    assert m32_configured;
    let m32_tile = _Tiles[[1]];
    assert TileCubeDescriptorLegal(m32_tile);
    assert m32_tile.rows == 64 && m32_tile.columns == 32;
    assert m32_tile.valid_rows == 1 && m32_tile.valid_columns == 16;
    assert m32_tile.cube_k_repeat == 16 && m32_tile.cube_n_repeat == 2;
    assert m32_tile.cube_cell_count == 32 &&
           m32_tile.cube_storage_bytes == 4096;
    return 0;
end;
