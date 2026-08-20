// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-RECONFIGURE-002","source":"asl/tile/model/state/allocation.asl","requirements":["PTO-CUBE-CELL-STATE-001"],"kind":"fault","summary":"Rejected CUBE reconfiguration preserves the complete existing Tile and capacity accounting","pass_condition":"an undersized N8 replacement returns false without changing descriptor payload definedness mask or capacity","related_sources":["asl/tile/model/shape/cube-cell.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 16, 8, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Vector);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x5a);
    let before = _Tiles[[0]];
    let before_mask = _TileAllocationMasks[[0]];
    let before_capacity = TileCapacityInUse();
    assert !ConfigureCubeTile(0, 128, 13, 19, TileDataType_FP16,
        TileLayout_CUBE_N8, TileLocation_Matrix);
    let after = _Tiles[[0]];
    assert after.allocated == before.allocated;
    assert after.storage_kind == before.storage_kind;
    assert after.contents_defined == before.contents_defined;
    assert after.defined_elements == before.defined_elements;
    assert after.defined_valid_elements == before.defined_valid_elements;
    assert after.capacity_bytes == before.capacity_bytes;
    assert after.rows == before.rows;
    assert after.columns == before.columns;
    assert after.valid_rows == before.valid_rows;
    assert after.valid_columns == before.valid_columns;
    assert after.data_type == before.data_type;
    assert after.layout == before.layout;
    assert after.location == before.location;
    assert after.payload == before.payload;
    assert after.cube_k_repeat == before.cube_k_repeat;
    assert after.cube_n_repeat == before.cube_n_repeat;
    assert after.cube_cell_count == before.cube_cell_count;
    assert after.cube_storage_bytes == before.cube_storage_bytes;
    assert _TileAllocationMasks[[0]] == before_mask;
    assert TileCapacityInUse() == before_capacity;
    return 0;
end;
