// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-SHARED-ND-TO-CUBE","surface":"tile","classification":["model","memory","shared-nd-to-cube"],"depends_on":["PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","PTO-TILE-MODEL-DEFINEDNESS-PACKED-BOUNDARY","PTO-TILE-MODEL-STATE-SHARED-REGISTERS","PTO-TILE-MODEL-STATE-TYPES"]}

type SharedNDToCubeFragment of record {
    valid: boolean,
    origin_row: integer {0..65535},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    physical_rows: integer {0..65535},
    physical_columns: integer {0..65535},
    capacity_bytes: integer {0..262144},
    data_type: TileDataType,
    layout: TileLayout
};

pure func EmptySharedNDToCubeFragment() => SharedNDToCubeFragment
begin
    return SharedNDToCubeFragment {
        valid = FALSE,
        origin_row = 0,
        valid_rows = 0,
        valid_columns = 0,
        physical_rows = 0,
        physical_columns = 0,
        capacity_bytes = 0,
        data_type = TileDataType_U8,
        layout = TileLayout_CUBE_M32
    };
end;

// Read only selected valid coordinates from a published Shared ND source.
// Destination padding is deterministic raw zero and remains undefined.
func TMOVSharedNDToCubeToValue(
    destination: TileInfo,
    shared_tile_id: SharedTileID,
    source_parent: TileInfo,
    fragment: SharedNDToCubeFragment) => TileInfo
begin
    assert fragment.valid && fragment.valid_rows > 0 &&
           fragment.valid_columns > 0 &&
           destination.layout == fragment.layout &&
           destination.data_type == fragment.data_type &&
           destination.capacity_bytes == fragment.capacity_bytes &&
           destination.rows == fragment.physical_rows &&
           destination.columns == fragment.physical_columns &&
           destination.valid_rows == fragment.valid_rows &&
           destination.valid_columns == fragment.valid_columns;
    var result = destination;
    for row = 0 to result.rows - 1 looplimit 65536 do
        for column = 0 to result.columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(result,
                row as integer {0..65535},
                column as integer {0..65535});
            result = TileInfoWithLogicalElementAndDefined(result, element,
                Zeros{PTO_XLEN}, FALSE);
        end;
    end;
    for row = 0 to fragment.valid_rows - 1 looplimit 65536 do
        for column = 0 to fragment.valid_columns - 1 looplimit 65536 do
            let source_element = TileLogicalLinearIndex(source_parent,
                (fragment.origin_row + row) as integer {0..65535},
                column as integer {0..65535});
            assert TileLogicalElementDefined(source_parent, source_element);
            let value = ReadSharedTileWord(shared_tile_id, source_element);
            let destination_element = TileLogicalLinearIndex(result,
                row as integer {0..65535},
                column as integer {0..65535});
            result = TileInfoWithLogicalElementAndDefined(result,
                destination_element, value, TRUE);
        end;
    end;
    result.defined_valid_elements =
        (fragment.valid_rows * fragment.valid_columns)
            as integer {0..524288};
    result.contents_defined = TRUE;
    return result;
end;
