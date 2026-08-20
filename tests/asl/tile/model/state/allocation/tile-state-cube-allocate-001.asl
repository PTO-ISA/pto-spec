// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-ALLOCATE-001","source":"asl/tile/model/state/allocation.asl","requirements":["PTO-CUBE-CELL-STATE-001"],"kind":"state-transition","summary":"CUBE allocation publishes persistent aligned descriptor geometry without defining payload","pass_condition":"a 13 by 19 FP16 N8 Tile records 16 by 24 storage six CELLs and zero defined valid elements","related_sources":["asl/tile/model/shape/cube-cell.asl","asl/tile/model/state/types.asl"]}
func main() => integer
begin
    ResetProfileState();
    assert ConfigureCubeTile(0, 768, 13, 19, TileDataType_FP16,
        TileLayout_CUBE_N8, TileLocation_Matrix);
    let tile = _Tiles[[0]];
    assert tile.allocated;
    assert tile.storage_kind == TileStorage_Numeric;
    assert tile.capacity_bytes == 768;
    assert tile.rows == 16;
    assert tile.columns == 24;
    assert tile.valid_rows == 13;
    assert tile.valid_columns == 19;
    assert tile.data_type == TileDataType_FP16;
    assert tile.layout == TileLayout_CUBE_N8;
    assert tile.location == TileLocation_Matrix;
    assert tile.cube_k_repeat == 2;
    assert tile.cube_n_repeat == 3;
    assert tile.cube_cell_count == 6;
    assert tile.cube_storage_bytes == 768;
    assert tile.defined_elements == Zeros{PTO_MODEL_TILE_ELEMENTS};
    assert tile.defined_valid_elements == 0;
    assert !tile.contents_defined;
    assert _TileAllocationMasks[[0]] == '0001';
    assert TileCapacityInUse() == 768;
    return 0;
end;
