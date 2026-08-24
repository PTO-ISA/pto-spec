<!-- GENERATED FROM: asl/tile/model/legality/descriptor-shape.asl -->
# Descriptor Shape

**Normative ASL source:** `asl/tile/model/legality/descriptor-shape.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/descriptor-shape.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE","surface":"tile","classification":["model","legality","descriptor-shape"],"depends_on":["PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS"]}
// PTO-REQ-TILE-LEGALITY-001: decoded tile operands are rejected before effects.

readonly func TileDescriptorConfigured(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    return tile.allocated &&
           TileCapacityIsLegal(tile.capacity_bytes) &&
           (if tile.storage_kind == TileStorage_Predicate then
                tile.rows > 0 && tile.columns > 0 &&
                PredicateTileStorageBytes(tile.rows, tile.columns) <=
                    tile.capacity_bytes
            else
                TileShapeMatchesCapacity(tile.capacity_bytes, tile.rows,
                    tile.columns, tile.data_type)) &&
           tile.valid_rows <= tile.rows &&
           tile.valid_columns <= tile.columns &&
           tile.rows * tile.columns <=
               TileLogicalElementCapacity(tile.capacity_bytes,
                                           tile.data_type);
end;

readonly func TileDescriptorLegal(index: TileIndex) => boolean
begin
    return TileDescriptorConfigured(index) &&
           (_Tiles[[index]].storage_kind == TileStorage_Predicate ||
            TileGenericIndexingPermitted(_Tiles[[index]]));
end;

readonly func TileCubeDescriptorLegal(tile: TileInfo) => boolean
begin
    if !tile.allocated || tile.storage_kind != TileStorage_Numeric ||
       tile.location != TileLocation_Matrix ||
       !TileCubeDescriptorShapeLegal(tile.capacity_bytes,
           tile.valid_rows, tile.valid_columns,
           tile.data_type, tile.layout) then
        return FALSE;
    end;
    return tile.rows == TileCubeStorageRows(
               tile.layout, tile.valid_rows, tile.data_type) &&
           tile.columns == TileCubeStorageColumns(
               tile.layout, tile.valid_columns, tile.data_type) &&
           tile.cube_k_repeat == TileCubeKRepeat(tile.layout,
               tile.valid_rows, tile.valid_columns, tile.data_type) &&
           tile.cube_n_repeat == TileCubeNRepeat(
               tile.layout, tile.valid_rows, tile.valid_columns,
               tile.data_type) &&
           tile.cube_cell_count == TileCubeCellCount(tile.layout,
               tile.valid_rows, tile.valid_columns, tile.data_type) &&
           tile.cube_storage_bytes == TileCubeRequiredBytes(tile.layout,
               tile.valid_rows, tile.valid_columns, tile.data_type) &&
           tile.cube_storage_bytes <= tile.capacity_bytes;
end;

readonly func TileSourceContentsDefined(index: TileIndex) => boolean
begin
    return TileDescriptorLegal(index) && _Tiles[[index]].contents_defined;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
