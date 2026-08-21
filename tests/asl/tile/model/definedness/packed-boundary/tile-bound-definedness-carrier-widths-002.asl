// PTO-TEST: {"id":"PTO-AVS-TILE-CARRIER-WIDTHS-002","source":"asl/tile/model/definedness/packed-boundary.asl","requirements":["PTO-INST-BLOCK-B-IOS"],"kind":"boundary","summary":"The bounded Word-carrier model represents every legal element width at the maximum Shared capacity.","pass_condition":"U4, S8, S16, S32, and S64 descriptors address, define, write, and read their final logical element through carrier 32767 without narrowing capacity.","related_sources":["asl/tile/model/state/descriptors.asl","asl/tile/model/state/types.asl","asl/tile/model/definedness/elements.asl"]}
readonly func CarrierBoundaryTile(columns: integer {1..16},
                                  data_type: TileDataType) => TileInfo
begin
    var tile = _Tiles[[0]];
    tile.allocated = TRUE;
    tile.storage_kind = TileStorage_Numeric;
    tile.contents_defined = FALSE;
    tile.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    tile.defined_valid_elements = 0;
    tile.packed_defined_elements = ZeroPackedTileDefinedElements();
    tile.capacity_bytes = 262144;
    tile.rows = DerivedTileRows(262144, columns, data_type);
    tile.columns = columns;
    tile.valid_rows = tile.rows;
    tile.valid_columns = columns;
    tile.data_type = data_type;
    tile.layout = TileLayout_RowMajor;
    tile.location = TileLocation_Any;
    tile.cube_k_repeat = 0;
    tile.cube_n_repeat = 0;
    tile.cube_cell_count = 0;
    tile.cube_storage_bytes = 0;
    return tile;
end;

func CheckCarrierBoundary(columns: integer {1..16},
                          data_type: TileDataType,
                          expected_capacity: integer {1..524288},
                          expected_last: integer {0..524287},
                          value: Word)
begin
    let initial = CarrierBoundaryTile(columns, data_type);
    assert TileLogicalElementCapacity(262144, data_type) == expected_capacity;
    assert initial.rows * initial.columns == expected_capacity;
    let last = TilePackedLinearIndex(initial,
        (initial.rows - 1) as integer {0..65535},
        (initial.columns - 1) as integer {0..65535});
    assert last == expected_last;
    let updated = TileInfoWithLogicalElement(initial, last, value);
    assert TileLogicalElementDefined(updated, last);
    assert TileReadLogicalElement(updated, last) ==
        TileRawElementValue(value, data_type);
end;

func main() => integer
begin
    ResetProfileState();
    assert PTO_MODEL_TILE_ELEMENTS == 32768;
    CheckCarrierBoundary(16, TileDataType_U4X2, 524288, 524287,
        Zeros{PTO_XLEN} + 0xf);
    CheckCarrierBoundary(8, TileDataType_S8, 262144, 262143,
        Zeros{PTO_XLEN} + 0xa5);
    CheckCarrierBoundary(4, TileDataType_S16, 131072, 131071,
        Zeros{PTO_XLEN} + 0xa55a);
    CheckCarrierBoundary(2, TileDataType_S32, 65536, 65535,
        Zeros{PTO_XLEN} + 0xa55aa55a);
    CheckCarrierBoundary(1, TileDataType_S64, 32768, 32767,
        Zeros{PTO_XLEN} + 0xa55aa55aa55aa55a);
    return 0;
end;
