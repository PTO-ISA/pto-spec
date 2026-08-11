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
    if TileLayoutIsCube(tile.layout) then
        return tile.allocated &&
               TileCubeDescriptorShapeLegal(tile.capacity_bytes,
                   tile.valid_rows, tile.valid_columns, tile.data_type,
                   tile.layout, tile.cube_role) &&
               tile.rows == tile.storage_rows &&
               tile.columns == tile.storage_columns &&
               tile.storage_bytes == TileCubeRequiredBytes(tile.layout,
                   tile.cube_role, tile.valid_rows, tile.valid_columns,
                   tile.data_type) &&
               tile.cube_k_repeat == TileCubeKRepeat(tile.layout,
                   tile.cube_role, tile.valid_rows, tile.valid_columns,
                   tile.data_type) &&
               tile.cube_n_repeat == TileCubeNRepeat(tile.layout,
                   tile.cube_role, tile.valid_columns, tile.data_type) &&
               tile.cube_cell_count == TileCubeCellCount(tile.layout,
                   tile.cube_role, tile.valid_rows, tile.valid_columns,
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

readonly func TileSourceContentsDefined(index: TileIndex) => boolean
begin
    return TileDescriptorLegal(index) && _Tiles[[index]].contents_defined;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
