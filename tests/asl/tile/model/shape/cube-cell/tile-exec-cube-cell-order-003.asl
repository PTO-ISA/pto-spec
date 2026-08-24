// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-CELL-ORDER-003","source":"asl/tile/model/shape/cube-cell.asl","requirements":["PTO-CUBE-CELL-STATE-001"],"kind":"execution","summary":"CUBE N8 multi-CELL storage uses K-fast and N-slow repeat order","pass_condition":"a 13 by 19 FP16 B shape has six CELLs and distinguishes n0k1 from n1k0 payload positions","related_sources":[]}
func main() => integer
begin
    var tile = _Tiles[[0]];
    tile.layout = TileLayout_CUBE_N8;
    tile.data_type = TileDataType_FP16;
    tile.valid_rows = 13;
    tile.valid_columns = 19;
    tile.rows = 16;
    tile.columns = 24;
    assert TileCubeKRepeat(tile.layout, tile.valid_rows,
        tile.valid_columns, tile.data_type) == 2;
    assert TileCubeNRepeat(tile.layout, tile.valid_rows,
        tile.valid_columns, tile.data_type) == 3;
    assert TileCubeCellCount(tile.layout, tile.valid_rows,
        tile.valid_columns, tile.data_type) == 6;
    assert TileCubePayloadIndex(tile, 0, 0) == 0;
    assert TileCubePayloadIndex(tile, 8, 0) == 64;
    assert TileCubePayloadIndex(tile, 0, 8) == 128;
    assert TileCubePayloadIndex(tile, 12, 18) == 340;
    return 0;
end;
