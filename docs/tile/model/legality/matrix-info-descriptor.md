<!-- GENERATED FROM: asl/tile/model/legality/matrix-info-descriptor.asl -->
# Matrix Info Descriptor

**Normative ASL source:** `asl/tile/model/legality/matrix-info-descriptor.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-MATRIX-INFO-DESCRIPTOR}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/matrix-info-descriptor.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-MATRIX-INFO-DESCRIPTOR","surface":"tile","classification":["model","legality","matrix-info-descriptor"],"depends_on":["PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE"]}

readonly func TileInfoDescriptorLegal(tile: TileInfo) => boolean
begin
    return tile.allocated && tile.contents_defined &&
           TileCapacityIsLegal(tile.capacity_bytes) &&
           TileShapeMatchesCapacity(tile.capacity_bytes, tile.rows,
               tile.columns, tile.data_type) &&
           tile.valid_rows <= tile.rows &&
           tile.valid_columns <= tile.columns &&
           tile.rows * tile.columns <=
               TileLogicalElementCapacity(tile.capacity_bytes,
                                          tile.data_type) &&
           TileGenericIndexingPermitted(tile);
end;

readonly func TileMatrixMixedInfosMatchDimensions(
    left: TileInfo, right: TileInfo,
    m: integer {0..65535}, n: integer {0..65535},
    k: integer {0..65535}) => boolean
begin
    if m == 0 || n == 0 || k == 0 then return FALSE; end;
    return TileCubeDescriptorLegal(left) && left.contents_defined &&
           TileInfoDescriptorLegal(right) &&
           left.valid_rows == m && left.valid_columns == k &&
           right.valid_rows == k && right.valid_columns == n;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
