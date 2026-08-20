// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-PADDING-001","source":"asl/tile/model/definedness/elements.asl","requirements":["PTO-CUBE-CELL-STATE-001"],"kind":"state-transition","summary":"CUBE physical positions outside the valid region receive PadValue without becoming valid elements","pass_condition":"K-tail N-tail and final physical positions contain FP16 Max and are physically defined while valid elements remain undefined","related_sources":["asl/tile/model/shape/cube-cell.asl","asl/tile/model/state/allocation.asl"]}
func main() => integer
begin
    ResetProfileState();
    let configured = ConfigureCubeTile(0, 768, 13, 19,
        TileDataType_FP16, TileLayout_CUBE_N8, TileLocation_Matrix);
    assert configured;
    ApplyTilePadding(0, TilePad_Max);
    let tile = _Tiles[[0]];
    let valid_index = TileCubePayloadIndex(tile, 0, 0);
    let k_tail_index = TileCubePayloadIndex(tile, 13, 0);
    let n_tail_index = TileCubePayloadIndex(tile, 0, 19);
    let final_index = TileCubePayloadIndex(tile, 15, 23);
    let padding = TilePadValueForDataType(
        TilePad_Max, TileDataType_FP16);
    assert tile.defined_elements[valid_index] == '0';
    assert tile.payload[[k_tail_index]] == padding;
    assert tile.payload[[n_tail_index]] == padding;
    assert tile.payload[[final_index]] == padding;
    assert tile.defined_elements[k_tail_index] == '1';
    assert tile.defined_elements[n_tail_index] == '1';
    assert tile.defined_elements[final_index] == '1';
    assert tile.defined_valid_elements == 0;
    assert !tile.contents_defined;
    return 0;
end;
