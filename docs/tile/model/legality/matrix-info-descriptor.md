<!-- GENERATED FROM: asl/tile/model/legality/matrix-info-descriptor.asl -->
# Matrix Info Descriptor

**Normative ASL source:** `asl/tile/model/legality/matrix-info-descriptor.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-MATRIX-INFO-DESCRIPTOR}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-matrix-info-descriptor-purpose role=purpose-scope -->
## Purpose and scope

This unit defines two descriptor checks for matrix (CUBE matmul) operands that are passed as `TileInfo` values rather than as Local Tile register indices.

- `TileInfoDescriptorLegal` checks that a non-CUBE `TileInfo` value is a well-formed, defined, generically indexable Tile.
- `TileMatrixMixedInfosMatchDimensions` checks the mixed operand pair: a CUBE-layout left operand and a non-CUBE right operand, against the matmul dimensions M, N, and K.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-info-descriptor-concepts role=concepts-state -->
## Concepts and visible state

A `TileInfo` value is the full descriptor and payload record of one Tile. Matrix legality sometimes works on a value that is not stored in `_Tiles`, for example the right operand that `MaterializeBundleSharedMatrixPrimary` builds from a Shared Tile. That value has layout RowMajor and exists only for the duration of the check and computation.

Design point: `TileDescriptorLegal` takes a register index and reads `_Tiles`, so it cannot check a materialized value. `TileInfoDescriptorLegal` repeats the same kind of checks directly on the value.

In a matmul, the left operand is M x K and the right operand is K x N. The dimensions are compared with each operand's valid region.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-info-descriptor-rules role=rules-interactions -->
## Rules and interactions

`TileInfoDescriptorLegal` requires all of the following:

- `allocated` and `contents_defined` are TRUE.
- The capacity passes `TileCapacityIsLegal`, and `TileShapeMatchesCapacity` holds.
- The valid region fits inside the physical shape.
- `rows` x `columns` does not exceed `TileLogicalElementCapacity`.
- `TileGenericIndexingPermitted` holds, which rules out CUBE layouts.

Design point: unlike `TileDescriptorLegal`, this check also requires `contents_defined`, so a caller gets the definedness test without a separate `TileSourceContentsDefined` call. It has no predicate-storage branch: it does not test `storage_kind` and always applies the numeric `TileShapeMatchesCapacity` rule.

`TileMatrixMixedInfosMatchDimensions` returns FALSE if M, N, or K is 0. Otherwise it requires:

- The left operand passes `TileCubeDescriptorLegal` and is defined.
- The right operand passes `TileInfoDescriptorLegal`.
- The left valid region is M by K and the right valid region is K by N.

In the bundle path these predicates are not the preflight gate: `ExecuteBundleTMATMULOperation` evaluates `TileMatrixMixedInfosMatchDimensions` inside an `assert` after it allocates D, so the earlier Shared schema and Local source checks must already have rejected any bundle that would fail it.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-info-descriptor-boundaries role=boundaries -->
## Architectural boundaries

`TileInfoDescriptorLegal` is used, for example, by the matrix shape checks for non-CUBE operand pairs and scale Tiles. `TileMatrixInfoAccumulatorSchemaLegal` in the matrix operand checks also calls it, but that predicate has no caller in the current ASL.

`TileMatrixMixedInfosMatchDimensions` is used by `TileMatrixInfoOptionalScalesLegal` in the matrix shape unit, and by CUBE TMATMUL dispatch when the number of Shared operands equals the right-operand group count, which means only the right side comes from Shared storage.

Neither predicate compares data types with the operation types or checks the matmul function; the ordinary type list belongs to the matrix shape unit and the MX type list to the matrix functions unit.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-info-descriptor-example role=example-usage -->
## Non-normative reading example

Consider a matmul with M = 16, K = 32, N = 64, where the left operand is a Local CUBE_M16 Tile and the right operand is materialized from a Shared Tile.

- The left CUBE Tile must pass `TileCubeDescriptorLegal`, be defined, and have valid region 16 by 32.
- The right value is RowMajor with valid region 32 by 64. It must be allocated, defined, and fit its capacity.

If K were 0, the check would return FALSE before any descriptor is examined.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-info-descriptor-related role=related-owners-navigation -->
## Related owners

- [Matrix shape](matrix-shape.md) combines the primary, mixed, and scale shape checks.
- [Matrix CUBE primary](matrix-cube-primary.md) owns the all-CUBE operand pair check.
- [Descriptor shape](descriptor-shape.md) owns `TileCubeDescriptorLegal`.
- [Shared CUBE matrix](../../../block/model/dispatch/shared-cube-matrix.md) materializes Shared operands.
- [CUBE TMATMUL dispatch](../../../block/model/dispatch/cube-tmatmul.md) selects the operand pairing.
<!-- SUPPLEMENTARY-END -->

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
