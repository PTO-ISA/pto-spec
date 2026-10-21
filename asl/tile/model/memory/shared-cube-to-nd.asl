// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-SHARED-CUBE-TO-ND","surface":"tile","classification":["model","memory","shared-cube-to-nd"],"depends_on":["PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","PTO-TILE-MODEL-DEFINEDNESS-PACKED-BOUNDARY","PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE","PTO-TILE-MODEL-SHAPE-CUBE-CELL","PTO-TILE-MODEL-SHAPE-CUBE-DOUBLE-CELL","PTO-TILE-MODEL-SHAPE-ROWS-COLUMNS"]}
// Convert a complete Local CUBE writer fragment into the ND payload geometry
// used by Shared B.ASSEMBLE.  The caller performs faulting schema checks first.
func SharedTileFromLocalCubeToND(source: TileIndex,
    writer_capacity_bytes: integer {128,256,512,1024,2048,4096,8192,
                                    16384,32768,65536,131072,262144})
    => TileInfo
begin
    let source_tile = _Tiles[[source]];
    assert source_tile.contents_defined && TileCubeDescriptorLegal(source_tile);
    assert source_tile.capacity_bytes == writer_capacity_bytes;
    assert source_tile.layout == TileLayout_CUBE_M16 ||
           source_tile.layout == TileLayout_CUBE_M32;
    assert source_tile.columns == TileCubePhysicalColumnsFromCapacity(
        writer_capacity_bytes, source_tile.layout, source_tile.data_type);
    assert source_tile.rows == DerivedTileRows(writer_capacity_bytes,
        source_tile.columns, source_tile.data_type);
    var result = source_tile;
    result.layout = TileLayout_RowMajor;
    result.capacity_bytes = writer_capacity_bytes;
    result.rows = DerivedTileRows(writer_capacity_bytes, result.columns,
        result.data_type);
    result.cube_k_repeat = 0;
    result.cube_n_repeat = 0;
    result.cube_cell_count = 0;
    result.cube_storage_bytes = 0;
    result.contents_defined = FALSE;
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    result.defined_valid_elements = 0;
    result.packed_defined_elements = ZeroPackedTileDefinedElements();
    var zero_payload: TilePayload;
    for index = 0 to PTO_MODEL_TILE_ELEMENTS - 1 looplimit 524288 do
        zero_payload[[index as ModelTileElementIndex]] = Zeros{PTO_XLEN};
    end;
    result.payload = zero_payload;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let source_element = TileLogicalLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let destination_element = TileLogicalLinearIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            assert TileLogicalElementDefined(source_tile, source_element);
            result = TileInfoWithLogicalElement(result, destination_element,
                TileReadLogicalElement(source_tile, source_element));
        end;
    end;
    result.defined_valid_elements =
        (source_tile.valid_rows * source_tile.valid_columns)
            as integer {0..524288};
    result.contents_defined = TRUE;
    return result;
end;
