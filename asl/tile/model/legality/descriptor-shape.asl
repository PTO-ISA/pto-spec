// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE","surface":"tile","classification":["model","legality","descriptor-shape"],"depends_on":["PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS"]}
// PTO-REQ-TILE-LEGALITY-001: decoded tile operands are rejected before effects.

readonly func TileDescriptorConfigured(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    if TileLayoutIsCube(tile.layout) then
        return tile.allocated &&
               TileCubeDescriptorShapeLegal(tile.capacity_bytes,
                   tile.valid_rows, tile.valid_columns, tile.data_type,
                   tile.layout) &&
               tile.rows == tile.storage_rows &&
               tile.columns == tile.storage_columns &&
               tile.storage_bytes == TileCubeRequiredBytes(tile.layout,
                   tile.valid_rows, tile.valid_columns,
                   tile.data_type) &&
               tile.cube_k_repeat == TileCubeKRepeat(tile.layout,
                   tile.valid_rows, tile.valid_columns,
                   tile.data_type) &&
               tile.cube_n_repeat == TileCubeNRepeat(tile.layout,
                   tile.valid_columns, tile.data_type) &&
               tile.cube_cell_count == TileCubeCellCount(tile.layout,
                   tile.valid_rows, tile.valid_columns,
                   tile.data_type) &&
               tile.storage_bytes <= tile.capacity_bytes;
    end;
    return tile.allocated &&
           TileCapacityIsLegal(tile.capacity_bytes) &&
           TileShapeMatchesCapacity(tile.capacity_bytes, tile.rows,
               tile.columns, tile.data_type) &&
           tile.valid_rows <= tile.rows &&
           tile.valid_columns <= tile.columns &&
           tile.rows * tile.columns <= PTO_MODEL_TILE_ELEMENTS;
end;

readonly func TileDescriptorLegal(index: TileIndex) => boolean
begin
    // Generic VEC/SFU/rearrangement consumers remain ordinary-layout only in
    // Stage A.  Matrix/TLSU owners may opt into CUBE descriptors explicitly
    // when their later stages define those bindings.
    return TileDescriptorConfigured(index) &&
           !TileLayoutIsCube(_Tiles[[index]].layout) &&
           TileGenericIndexingPermitted(_Tiles[[index]]);
end;

// TLSU is the first consumer that may carry a persistent CUBE descriptor.
// Other generic tile engines continue to use TileDescriptorLegal and remain
// ordinary-layout only until a later stage defines their bindings.
readonly func TileMemoryDescriptorLegal(index: TileIndex) => boolean
begin
    return TileDescriptorConfigured(index) &&
           (TileLayoutIsCube(_Tiles[[index]].layout) ||
            TileGenericIndexingPermitted(_Tiles[[index]]));
end;

readonly func TileSourceContentsDefined(index: TileIndex) => boolean
begin
    return TileDescriptorLegal(index) && _Tiles[[index]].contents_defined;
end;

readonly func TileMemorySourceContentsDefined(index: TileIndex) => boolean
begin
    return TileMemoryDescriptorLegal(index) &&
           _Tiles[[index]].contents_defined;
end;
