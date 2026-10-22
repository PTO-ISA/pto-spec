// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-GMOV-HELPERS","surface":"block","classification":["model","dispatch","tlsu-gmov-helpers"],"depends_on":["PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-LEGALITY-MATRIX-INFO-DESCRIPTOR","PTO-TILE-MODEL-STATE-TYPES"]}
readonly func BundleGMOVPESourceTileReady(tile: TileInfo) => boolean
begin
    if TileLayoutIsCube(tile.layout) then
        return TileCubeDescriptorLegal(tile) && tile.contents_defined;
    end;
    return TileInfoDescriptorLegal(tile);
end;

readonly func BundleGMOVDestinationValueMatches(
    destination: TileInfo, source: TileInfo) => boolean
begin
    return destination.allocated &&
           destination.storage_kind == TileStorage_Numeric &&
           TileCubeDescriptorLegal(destination) &&
           TileElementwiseLayoutSupported(destination.layout) &&
           TileCarrierOrPackedBaselineDataTypeSupported(source.data_type) &&
           destination.rows == source.rows &&
           destination.columns == source.columns &&
           destination.valid_rows == source.valid_rows &&
           destination.valid_columns == source.valid_columns &&
           destination.data_type == source.data_type &&
           destination.layout == source.layout;
end;

readonly func BundleGMOVSourceDescriptorsMatch(left: TileInfo,
                                                right: TileInfo) => boolean
begin
    return left.capacity_bytes == right.capacity_bytes &&
           left.rows == right.rows && left.columns == right.columns &&
           left.valid_rows == right.valid_rows &&
           left.valid_columns == right.valid_columns &&
           left.data_type == right.data_type &&
           left.layout == right.layout &&
           left.storage_kind == right.storage_kind &&
           left.cube_k_repeat == right.cube_k_repeat &&
           left.cube_n_repeat == right.cube_n_repeat &&
           left.cube_cell_count == right.cube_cell_count &&
           left.cube_storage_bytes == right.cube_storage_bytes;
end;
