// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-PACKED-PAIRING-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001"],"kind":"execution","summary":"Packed TCVT logical pairs stay column-adjacent and reset at each row across RowMajor and CUBE layouts","pass_condition":"distinct logical columns occupy low/high X2 lanes without crossing a row boundary, and CUBE_M16/M32 map the same logical column pairs through their payload indexes","related_sources":["asl/tile/model/definedness/packed-boundary.asl","asl/tile/model/shape/cube-cell.asl"]}
func PairingTile() => TileInfo
begin
    var tile = _Tiles[[0]];
    tile.allocated = TRUE;
    tile.storage_kind = TileStorage_Numeric;
    tile.contents_defined = FALSE;
    tile.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    tile.defined_valid_elements = 0;
    tile.packed_defined_elements = ZeroPackedTileDefinedElements();
    tile.capacity_bytes = 128;
    tile.rows = 2;
    tile.columns = 5;
    tile.valid_rows = 2;
    tile.valid_columns = 5;
    tile.data_type = TileDataType_E2M1X2;
    tile.layout = TileLayout_RowMajor;
    tile.cube_k_repeat = 0;
    tile.cube_n_repeat = 0;
    tile.cube_cell_count = 0;
    tile.cube_storage_bytes = 0;
    return tile;
end;

func main() => integer
begin
    ResetProfileState();
    let tile = PairingTile();
    let row0_col4 = TilePackedLinearIndex(tile, 0, 4);
    let row1_col0 = TilePackedLinearIndex(tile, 1, 0);
    assert TilePackedLinearIndex(tile, 0, 0) == 0;
    assert TilePackedLinearIndex(tile, 0, 1) == 1;
    assert TilePackedLinearIndex(tile, 0, 2) == 2;
    assert TilePackedLinearIndex(tile, 0, 3) == 3;
    assert row0_col4 == 4;
    assert row1_col0 == 6;
    assert row0_col4 MOD 2 == 0;
    assert row1_col0 MOD 2 == 0;
    assert row0_col4 + 1 != row1_col0;

    var packed = TileInfoWithLogicalElement(tile,
        TilePackedLinearIndex(tile, 0, 0), Zeros{PTO_XLEN} + 1);
    packed = TileInfoWithLogicalElement(packed,
        TilePackedLinearIndex(tile, 0, 1), Zeros{PTO_XLEN} + 2);
    packed = TileInfoWithLogicalElement(packed,
        TilePackedLinearIndex(tile, 0, 2), Zeros{PTO_XLEN} + 3);
    packed = TileInfoWithLogicalElement(packed,
        TilePackedLinearIndex(tile, 0, 3), Zeros{PTO_XLEN} + 4);
    packed = TileInfoWithLogicalElement(packed, row0_col4,
        Zeros{PTO_XLEN} + 5);
    packed = TileInfoWithLogicalElement(packed, row1_col0,
        Zeros{PTO_XLEN} + 6);
    assert packed.payload[[0]] == Zeros{PTO_XLEN} + 0x654321;
    assert TileReadLogicalElement(packed,
        TilePackedLinearIndex(packed, 0, 1)) ==
        Zeros{PTO_XLEN} + 2;
    assert TileReadLogicalElement(packed, row1_col0) ==
        Zeros{PTO_XLEN} + 6;

    var cube_m16 = tile;
    cube_m16.layout = TileLayout_CUBE_M16;
    cube_m16.rows = 16;
    cube_m16.columns = 16;
    cube_m16.valid_rows = 1;
    cube_m16.valid_columns = 5;
    assert TileCubePayloadIndex(cube_m16, 0, 0) == 0;
    assert TileCubePayloadIndex(cube_m16, 0, 1) == 1;
    assert TileCubePayloadIndex(cube_m16, 0, 2) == 2;
    assert TileCubePayloadIndex(cube_m16, 0, 3) == 3;
    assert TileCubePayloadIndex(cube_m16, 0, 4) == 8;
    assert TileCubePayloadIndex(cube_m16, 0, 5) == 9;

    var cube_m32 = tile;
    cube_m32.layout = TileLayout_CUBE_M32;
    cube_m32.rows = 32;
    cube_m32.columns = 8;
    cube_m32.valid_rows = 1;
    cube_m32.valid_columns = 5;
    assert TileCubePayloadIndex(cube_m32, 0, 0) == 0;
    assert TileCubePayloadIndex(cube_m32, 0, 1) == 1;
    assert TileCubePayloadIndex(cube_m32, 0, 2) == 2;
    assert TileCubePayloadIndex(cube_m32, 0, 3) == 3;
    assert TileCubePayloadIndex(cube_m32, 0, 4) == 4;
    assert TileCubePayloadIndex(cube_m32, 0, 5) == 5;
    return 0;
end;
