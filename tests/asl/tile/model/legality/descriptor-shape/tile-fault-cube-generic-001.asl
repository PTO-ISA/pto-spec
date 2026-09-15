// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-GENERIC-001","source":"asl/tile/model/legality/descriptor-shape.asl","requirements":["PTO-CUBE-CELL-STATE-001"],"kind":"fault","summary":"CUBE descriptors retain physical geometry independently from valid geometry","pass_condition":"an M16 FP16 descriptor with physical slack passes CUBE legality, preserves physical metadata, and remains unavailable to generic indexing","related_sources":["asl/tile/model/shape/cube-cell.asl","asl/tile/model/definedness/elements.asl"]}
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
    return 0;
end;
