// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-N8-REGRESSION-003","source":"asl/tile/model/shape/cube-cell.asl","requirements":["PTO-CUBE-CELL-STATE-001"],"kind":"boundary","summary":"CUBE_N8 retains its baseline valid-derived descriptor formulas","pass_condition":"N8 derives rows, columns, repeats, cell count, and storage bytes from valid geometry and rejects an insufficient capacity","related_sources":["asl/tile/model/state/allocation.asl","asl/tile/model/legality/descriptor-shape.asl"]}
func main() => integer
begin
    ResetProfileState();
    let configured = ConfigureCubeTile(0, 768, 13, 19,
        TileDataType_FP16, TileLayout_CUBE_N8);
    assert configured;
    assert _Tiles[[0]].rows == 16 && _Tiles[[0]].columns == 24;
    assert _Tiles[[0]].cube_k_repeat == 2 &&
           _Tiles[[0]].cube_n_repeat == 3 &&
           _Tiles[[0]].cube_cell_count == 6 &&
           _Tiles[[0]].cube_storage_bytes == 768;
    assert !TileCubeDescriptorShapeLegal(767, 13, 19,
        TileDataType_FP16, TileLayout_CUBE_N8);
    return 0;
end;
