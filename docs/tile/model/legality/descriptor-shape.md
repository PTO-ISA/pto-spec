<!-- GENERATED FROM: asl/tile/model/legality/descriptor-shape.asl -->
# Descriptor Shape

**Normative ASL source:** `asl/tile/model/legality/descriptor-shape.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-descriptor-shape-purpose role=purpose-scope -->
## Purpose and scope

This unit defines the basic descriptor checks that most Tile legality predicates build on. A descriptor is the `TileInfo` record of a Local Tile register: capacity, shape, valid region, data type, layout, and storage kind.

- `TileDescriptorConfigured` checks that the descriptor is internally consistent.
- `TileDescriptorLegal` adds that generic element indexing is permitted.
- `TileCubeDescriptorLegal` is the separate check for CUBE layouts.
- `TileSourceContentsDefined` adds that the payload is defined.

The unit carries requirement `PTO-REQ-TILE-LEGALITY-001`: decoded Tile operands are rejected before effects.

<!-- PTO-READER-BLOCK: tile-model-legality-descriptor-shape-concepts role=concepts-state -->
## Concepts and visible state

The four predicates read `_Tiles` and, through `TileCapacityIsLegal`, the configured Tile capacity limit; none of them writes state or raises a fault.

The valid region is the `valid_rows` by `valid_columns` rectangle that operations compute on. It lies inside the physical `rows` by `columns` shape.

Generic indexing means addressing an element by row and column through `TileLinearIndex`. `TileGenericIndexingPermitted` allows it for RowMajor and ColumnMajor, and for the fractal layouts when `rows` is a multiple of 16 and `columns` is a multiple of the fractal inner width. It rejects CUBE layouts and `TileLayout_ImplementationDefined`.

<!-- PTO-READER-BLOCK: tile-model-legality-descriptor-shape-rules role=rules-interactions -->
## Rules and interactions

`TileDescriptorConfigured` requires all of the following:

- The register is allocated and its capacity passes `TileCapacityIsLegal`.
- For a predicate Tile, `rows` and `columns` are positive and `PredicateTileStorageBytes` fits in the capacity.
- For any other Tile, `TileShapeMatchesCapacity` holds for its capacity, shape, and data type.
- The valid region fits inside the physical shape.
- `rows` x `columns` does not exceed `TileLogicalElementCapacity`.

`TileDescriptorLegal` accepts a configured predicate Tile directly. For other storage kinds it also requires `TileGenericIndexingPermitted`.

Design point: a CUBE Tile never satisfies `TileDescriptorLegal`, because generic indexing rejects CUBE layouts. CUBE Tiles use `TileCubeDescriptorLegal` instead. That predicate requires a numeric allocated Tile, calls `TileCubeDescriptorShapeAndPhysicalLegal`, and compares the stored `cube_k_repeat`, `cube_n_repeat`, `cube_cell_count`, and `cube_storage_bytes` with the values recomputed from layout, shape, and data type. Because the recorded geometry must equal the recomputed geometry, a CUBE descriptor whose repeat or cell fields are inconsistent with its shape is rejected.

`TileSourceContentsDefined` is `TileDescriptorLegal` plus `contents_defined`. It is the usual gate for a source Tile.

Design point: legality predicates built on these checks run before an operation reads source snapshots or writes destination payload. Some run in the bundle closed schemas before the destination is allocated; the generated legality handlers run after allocation, and a failure rolls that allocation back. A Tile that was released, never allocated, or allocated but not yet written fails here, so the operation never reads stale or undefined source data.

<!-- PTO-READER-BLOCK: tile-model-legality-descriptor-shape-boundaries role=boundaries -->
## Architectural boundaries

These predicates are called widely. For example, the legality units for reductions, indexed rearrangement, memory, ExecutionMask sources, and allocation capacity use them, and bundle dispatch uses `TileDescriptorConfigured` in `ResolveBundleEffectiveDataType` for the `TMOV` path.

`TileSourceContentsDefined` checks the whole-Tile flag only. Per-element definedness for masked operations is checked elsewhere, for example by `TileElementwiseSourceContentsDefined`.

These predicates do not check free capacity in a PE pool. Capacity admission belongs to the Local capacity unit.

<!-- PTO-READER-BLOCK: tile-model-legality-descriptor-shape-example role=example-usage -->
## Non-normative reading example

Take an allocated FP32 RowMajor Tile with capacity 4096 bytes, 64 rows, 16 columns, and valid region 50 by 10.

- 4096 is a legal capacity when the configured Tile capacity limit is at least 4096, and 4096 x 8 / (16 x 32) = 64 derived rows, so the shape matches.
- 64 x 16 = 1024 elements, equal to `TileLogicalElementCapacity`, which is 32768 bits / 32 = 1024.
- RowMajor permits generic indexing, so `TileDescriptorLegal` is TRUE.

If the Tile has not yet been written, `contents_defined` is FALSE and `TileSourceContentsDefined` is FALSE.

<!-- PTO-READER-BLOCK: tile-model-legality-descriptor-shape-related role=related-owners-navigation -->
## Related owners

- [Tile model types](../state/types.md) defines `TileInfo`.
- [Tile allocation](../state/allocation.md) writes the descriptors checked here.
- [Rows and columns](../shape/rows-columns.md) owns `TileShapeMatchesCapacity`.
- [CUBE cell geometry](../shape/cube-cell.md) owns the CUBE shape and physical checks.
- [Element definedness](../definedness/elements.md) owns `TileGenericIndexingPermitted`.
<!-- SUPPLEMENTARY-END -->

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
       !TileCubeDescriptorShapeAndPhysicalLegal(tile.capacity_bytes,
           tile.rows, tile.columns, tile.valid_rows, tile.valid_columns,
           tile.data_type, tile.layout) then
        return FALSE;
    end;
    return tile.cube_k_repeat == TileCubePhysicalKRepeat(tile.layout,
               tile.rows, tile.columns, tile.data_type) &&
           tile.cube_n_repeat == TileCubePhysicalNRepeat(
               tile.layout, tile.rows, tile.columns, tile.data_type) &&
           tile.cube_cell_count == TileCubePhysicalCellCount(tile.layout,
               tile.rows, tile.columns, tile.data_type) &&
           tile.cube_storage_bytes == TileCubePhysicalRequiredBytes(tile.layout,
               tile.rows, tile.columns, tile.data_type) &&
           tile.cube_storage_bytes <= tile.capacity_bytes;
end;

readonly func TileSourceContentsDefined(index: TileIndex) => boolean
begin
    return TileDescriptorLegal(index) && _Tiles[[index]].contents_defined;
end;
```
<!-- GENERATED-ASL-END: unit -->
