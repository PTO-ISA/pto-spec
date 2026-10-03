<!-- GENERATED FROM: asl/tile/model/state/allocation.asl -->
# Allocation

**Normative ASL source:** `asl/tile/model/state/allocation.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-STATE-ALLOCATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-state-allocation-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the transitions that turn a Local Tile register into an allocated Tile and back. A Local Tile register is one of the 64 absolute entries of `_Tiles`, each described by a `TileInfo` record, with a four-bit allocation mask in `_TileAllocationMasks`.

It defines four allocation families and one release transition:

- `ConfigureTileForMask` for ordinary (non-CUBE) numeric Tiles; it stores the supplied layout without checking it.
- `ConfigurePredicateTileForMask` for bit-packed predicate Tiles.
- `ConfigureCubeTileForMaskWithPhysical` and its wrappers for CUBE layouts.
- `ConfigurePredicateCellForMask` for U8 CUBE predicate cells.
- `ReleaseTile`, which returns the register to the unallocated state.

The single-PE wrappers `ConfigureTile`, `ConfigurePredicateTile`, `ConfigureCubeTile`, and `ConfigurePredicateCell` pass mask `0001`; the first three also install the register as a relative-source fixture (`ConfigureCubeTile` only when allocation succeeds).

<!-- PTO-READER-BLOCK: tile-model-state-allocation-concepts role=concepts-state -->
## Concepts and visible state

Every allocation writes the complete descriptor part of `TileInfo`:

- `capacity_bytes` is the per-PE byte budget of the object.
- `rows` and `columns` are the physical shape; `valid_rows` and `valid_columns` bound the valid region inside it.
- `data_type` and `layout` select element width and element order.
- `storage_kind` is `TileStorage_Numeric`, `TileStorage_Predicate`, or `TileStorage_PredicateCell`.
- `predicate_basis_type` records the comparison type for predicate cells and otherwise equals `data_type`.
- `cube_k_repeat`, `cube_n_repeat`, `cube_cell_count`, and `cube_storage_bytes` are nonzero only for CUBE layouts.

The allocation mask names the PEs that own a copy of the object. PE0 is the high bit, so `1000` is PE0 alone and `0001` is PE3 alone.

Design point: allocation defines `TileInfo` but not the payload. Every allocation sets `contents_defined` to FALSE, clears `defined_elements`, and sets `defined_valid_elements` to 0. The numeric and predicate paths also clear `packed_defined_elements`; CUBE Tiles never use that packed bitmap. A producer must write the Tile before a generic payload read is legal, so a generic read cannot return a value left by an earlier allocation of the same register.

<!-- PTO-READER-BLOCK: tile-model-state-allocation-rules role=rules-interactions -->
## Rules and interactions

`ConfigureTileForMask` asserts, in this order: a legal capacity (`TileCapacityIsLegal`), a nonzero mask, positive `rows`, `valid_rows <= rows`, a legal descriptor shape at the derived row count, `valid_rows` within the configured row count, a legal physical shape at the configured row count, and room in every selected PE's Local pool (`LocalTileAllocationFitsExcept`). Only then does it write state.

The configured row count depends on the column count. For a power-of-two column count, the rows come from `DerivedTileRows`; for types other than E2M1X2 and E1M2X2 the Tile then exactly fills its capacity. For a column count that is not a power of two, with FP32, FP16, BF16, E2M1X2, or E1M2X2, the caller's `rows` is kept, and it only has to fit.

Predicate Tiles use `PredicateTileStorageBytes`, which is one bit per element rounded up to whole bytes. Their `data_type` is always U8 and their layout is always RowMajor.

CUBE allocation returns FALSE instead of asserting when the mask is zero, the geometry is illegal, or the pool is full. It records the cell geometry computed by the CUBE helpers.

Design point: every allocation and `ReleaseTile` call `InvalidateTileFeatureMapDescriptor`. The feature-map descriptor is invalidated on every allocation and release, even if the new shape is identical, so it must be configured again before use.

Design point: capacity is checked with `LocalTileAllocationFitsExcept`, which excludes the register being configured. Reconfiguring a register replaces its old contribution instead of adding to it.

<!-- PTO-READER-BLOCK: tile-model-state-allocation-boundaries role=boundaries -->
## Architectural boundaries

These helpers are not instructions. Bundle dispatch calls them, for example through `ConfigureBundleTileDestination` in destination-auxiliary, the predicate, CUBE, and TCVT destination resolvers, cell rearrangement, subview materialization, and the TIMG2COL and layout-conversion paths. Fault rollback and local-generation abort call `ReleaseTile` for destinations that the bundle allocated, and subview handling releases its temporary materializations.

`ReleaseTile` also calls `RemoveRelativeTileMapping`, so a released register can no longer be reached through a relative `#n` selector.

`PTO_MODEL_TILE_ELEMENTS` (32768 in this model) sizes the executable definedness bitmap and bounds predicate Tiles. It is a model bound, not a claim about every implementation.

<!-- PTO-READER-BLOCK: tile-model-state-allocation-example role=example-usage -->
## Non-normative reading example

Consider `ConfigureTile` on register 5 with capacity 4096 bytes, a `rows` argument of 64, 16 columns, valid region 50 by 10, FP32, RowMajor.

- The capacity is a multiple of 128 and no larger than 64 KiB, so it is legal.
- 16 is a power of two, so rows are derived: 4096 x 8 = 32768 bits divided by 16 x 32 = 512 bits per row gives 64 rows.
- Valid rows 50 and valid columns 10 fit inside 64 by 16.
- Mask `0001` charges 4096 bytes to PE3's Local pool.

After the call, `rows` is 64 and `contents_defined` is FALSE. Reading any element before a producer writes it violates the definedness precondition.

<!-- PTO-READER-BLOCK: tile-model-state-allocation-related role=related-owners-navigation -->
## Related owners

- [Tile model types](types.md) defines `TileInfo` and `TileStorageKind`.
- [Rows and columns](../shape/rows-columns.md) and [valid region](../shape/valid-region.md) own the shape checks used here.
- [CUBE cell geometry](../shape/cube-cell.md) owns the CUBE repeat, cell, and byte counts.
- [Local capacity](../capacity/local.md) owns the per-PE pool check.
- [Destination auxiliary](../../../block/model/dispatch/destination-auxiliary.md) shows how bundle dispatch reaches these transitions.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/state/allocation.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-STATE-ALLOCATION","surface":"tile","classification":["model","state","allocation"],"depends_on":["PTO-TILE-MODEL-SHAPE-VALID-REGION","PTO-TILE-MODEL-STATE-FEATURE-MAP-DESCRIPTORS"]}
func ConfigureTileForMask(index: TileIndex,
                   capacity_bytes: integer {0..262144},
                   rows: integer {0..65535}, columns: integer {0..65535},
                   valid_rows: integer {0..65535}, valid_columns: integer {0..65535},
                   data_type: TileDataType, layout: TileLayout,
                   allocation_mask: bits(4))
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    assert TileCapacityIsLegal(capacity_bytes);
    assert allocation_mask != Zeros{4};
    assert rows > 0;
    assert valid_rows <= rows;
    assert TileDescriptorShapeLegal(capacity_bytes, columns, valid_rows,
        valid_columns, data_type);
    let derived_rows = DerivedTileRows(capacity_bytes, columns, data_type);
    let configured_rows = if !IsNonzeroPowerOfTwo(columns) &&
        TileDataTypeAllowsOddPhysicalColumns(data_type) then rows
        else derived_rows;
    assert valid_rows <= configured_rows;
    assert TileDescriptorPhysicalShapeLegal(capacity_bytes, configured_rows, columns,
        valid_rows, valid_columns, data_type);
    assert LocalTileAllocationFitsExcept(
        index, allocation_mask, capacity_bytes);
    InvalidateTileFeatureMapDescriptor(index);
    _TileAllocationMasks[[index]] = allocation_mask;
    _Tiles[[index]].allocated = TRUE;
    _Tiles[[index]].storage_kind = TileStorage_Numeric;
    // Allocation defines TileInfo but not the payload. A producer must write
    // the tile before any generic payload read is legal.
    _Tiles[[index]].contents_defined = FALSE;
    _Tiles[[index]].defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    _Tiles[[index]].defined_valid_elements = 0;
    _Tiles[[index]].packed_defined_elements =
        zero_packed_tile_elements;
    _Tiles[[index]].capacity_bytes = capacity_bytes;
    _Tiles[[index]].rows = configured_rows;
    _Tiles[[index]].columns = columns;
    _Tiles[[index]].valid_rows = valid_rows;
    _Tiles[[index]].valid_columns = valid_columns;
    _Tiles[[index]].data_type = data_type;
    _Tiles[[index]].predicate_basis_type = data_type;
    _Tiles[[index]].layout = layout;
    _Tiles[[index]].cube_k_repeat = 0;
    _Tiles[[index]].cube_n_repeat = 0;
    _Tiles[[index]].cube_cell_count = 0;
    _Tiles[[index]].cube_storage_bytes = 0;
end;

pure func PredicateTileStorageBytes(
    rows: integer {0..65535},
    columns: integer {0..65535}) => integer
begin
    return ((rows * columns) + 7) DIVRM 8;
end;

func ConfigurePredicateTileForMask(
    index: TileIndex,
    capacity_bytes: integer {0..262144},
    rows: integer {0..65535},
    columns: integer {0..65535},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    allocation_mask: bits(4))
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    assert TileCapacityIsLegal(capacity_bytes);
    assert allocation_mask != Zeros{4};
    assert rows > 0 && columns > 0;
    assert valid_rows <= rows && valid_columns <= columns;
    assert rows * columns <= PTO_MODEL_TILE_ELEMENTS;
    assert PredicateTileStorageBytes(rows, columns) <= capacity_bytes;
    assert LocalTileAllocationFitsExcept(
        index, allocation_mask, capacity_bytes);
    InvalidateTileFeatureMapDescriptor(index);
    _TileAllocationMasks[[index]] = allocation_mask;
    _Tiles[[index]].allocated = TRUE;
    _Tiles[[index]].storage_kind = TileStorage_Predicate;
    _Tiles[[index]].contents_defined = FALSE;
    _Tiles[[index]].defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    _Tiles[[index]].defined_valid_elements = 0;
    _Tiles[[index]].packed_defined_elements =
        zero_packed_tile_elements;
    _Tiles[[index]].capacity_bytes = capacity_bytes;
    _Tiles[[index]].rows = rows;
    _Tiles[[index]].columns = columns;
    _Tiles[[index]].valid_rows = valid_rows;
    _Tiles[[index]].valid_columns = valid_columns;
    _Tiles[[index]].data_type = TileDataType_U8;
    _Tiles[[index]].predicate_basis_type = TileDataType_U8;
    _Tiles[[index]].layout = TileLayout_RowMajor;
    _Tiles[[index]].cube_k_repeat = 0;
    _Tiles[[index]].cube_n_repeat = 0;
    _Tiles[[index]].cube_cell_count = 0;
    _Tiles[[index]].cube_storage_bytes = 0;
end;

func ConfigurePredicateTile(
    index: TileIndex,
    capacity_bytes: integer {0..262144},
    rows: integer {0..65535},
    columns: integer {0..65535},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535})
begin
    ConfigurePredicateTileForMask(
        index,
        capacity_bytes,
        rows,
        columns,
        valid_rows,
        valid_columns,
        '0001');
    InstallRelativeTileFixture(index, index);
end;

func ConfigureTile(index: TileIndex, capacity_bytes: integer {0..262144},
                   rows: integer {0..65535}, columns: integer {0..65535},
                   valid_rows: integer {0..65535}, valid_columns: integer {0..65535},
                   data_type: TileDataType, layout: TileLayout)
begin
    // Direct one-level operations model the already-resolved current-PE
    // fragment and therefore charge one PE of capacity.
    ConfigureTileForMask(index, capacity_bytes, rows, columns,
        valid_rows, valid_columns, data_type, layout, '0001');
    InstallRelativeTileFixture(index, index);
end;

func ConfigureCubeTileForMaskWithPhysical(
    index: TileIndex,
    capacity_bytes: integer {0..262144},
    physical_rows: integer {0..65535},
    physical_columns: integer {0..65535},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    data_type: TileDataType,
    layout: TileLayout,
    allocation_mask: bits(4)) => boolean
begin
    if allocation_mask == Zeros{4} ||
       !TileCubeDescriptorShapeAndPhysicalLegal(capacity_bytes,
           physical_rows, physical_columns, valid_rows, valid_columns,
           data_type, layout) then
        return FALSE;
    end;
    if !LocalTileAllocationFitsExcept(
           index, allocation_mask, capacity_bytes) then
        return FALSE;
    end;
    let rows = physical_rows;
    let columns = physical_columns;
    let k_repeat = TileCubePhysicalKRepeat(
        layout, physical_rows, physical_columns, data_type);
    let n_repeat = TileCubePhysicalNRepeat(
        layout, physical_rows, physical_columns, data_type);
    let cell_count = TileCubePhysicalCellCount(
        layout, physical_rows, physical_columns, data_type);
    let storage_bytes = TileCubePhysicalRequiredBytes(
        layout, physical_rows, physical_columns, data_type);
    assert rows != 0 && columns != 0 && k_repeat != 0 &&
           n_repeat != 0 && cell_count != 0 && storage_bytes != 0;
    InvalidateTileFeatureMapDescriptor(index);
    _TileAllocationMasks[[index]] = allocation_mask;
    _Tiles[[index]].allocated = TRUE;
    _Tiles[[index]].storage_kind = TileStorage_Numeric;
    _Tiles[[index]].contents_defined = FALSE;
    _Tiles[[index]].defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    _Tiles[[index]].defined_valid_elements = 0;
    _Tiles[[index]].capacity_bytes = capacity_bytes;
    _Tiles[[index]].rows = rows;
    _Tiles[[index]].columns = columns;
    _Tiles[[index]].valid_rows = valid_rows;
    _Tiles[[index]].valid_columns = valid_columns;
    _Tiles[[index]].data_type = data_type;
    _Tiles[[index]].predicate_basis_type = data_type;
    _Tiles[[index]].layout = layout;
    _Tiles[[index]].cube_k_repeat = k_repeat;
    _Tiles[[index]].cube_n_repeat = n_repeat;
    _Tiles[[index]].cube_cell_count = cell_count;
    _Tiles[[index]].cube_storage_bytes = storage_bytes;
    return TRUE;
end;

func ConfigureCubeTileForMaskWithColumns(
    index: TileIndex,
    capacity_bytes: integer {0..262144},
    valid_rows: integer {0..65535},
    columns: integer {0..65535},
    valid_columns: integer {0..65535},
    data_type: TileDataType,
    layout: TileLayout,
    allocation_mask: bits(4)) => boolean
begin
    return ConfigureCubeTileForMaskWithPhysical(index, capacity_bytes,
        TileCubeStorageRows(layout, valid_rows, data_type), columns,
        valid_rows, valid_columns, data_type, layout, allocation_mask);
end;

func ConfigureCubeTileForMask(
    index: TileIndex,
    capacity_bytes: integer {0..262144},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    data_type: TileDataType,
    layout: TileLayout,
    allocation_mask: bits(4)) => boolean
begin
    return ConfigureCubeTileForMaskWithPhysical(index, capacity_bytes,
        TileCubeStorageRows(layout, valid_rows, data_type),
        TileCubeStorageColumns(layout, valid_columns, data_type), valid_rows,
        valid_columns, data_type, layout, allocation_mask);
end;

func ConfigureCubeTile(
    index: TileIndex,
    capacity_bytes: integer {0..262144},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    data_type: TileDataType,
    layout: TileLayout) => boolean
begin
    let configured = ConfigureCubeTileForMask(index, capacity_bytes, valid_rows,
        valid_columns, data_type, layout, '0001');
    if configured then InstallRelativeTileFixture(index, index); end;
    return configured;
end;

func ReleaseTile(index: TileIndex)
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    RemoveRelativeTileMapping(index);
    InvalidateTileFeatureMapDescriptor(index);
    _TileAllocationMasks[[index]] = Zeros{4};
    _Tiles[[index]].allocated = FALSE;
    _Tiles[[index]].storage_kind = TileStorage_Numeric;
    _Tiles[[index]].contents_defined = FALSE;
    _Tiles[[index]].defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    _Tiles[[index]].defined_valid_elements = 0;
    _Tiles[[index]].packed_defined_elements =
        zero_packed_tile_elements;
    _Tiles[[index]].capacity_bytes = 0;
    _Tiles[[index]].rows = 0;
    _Tiles[[index]].columns = 0;
    _Tiles[[index]].valid_rows = 0;
    _Tiles[[index]].valid_columns = 0;
    _Tiles[[index]].data_type = TileDataType_U8;
    _Tiles[[index]].predicate_basis_type = TileDataType_U8;
    _Tiles[[index]].layout = TileLayout_RowMajor;
    _Tiles[[index]].cube_k_repeat = 0;
    _Tiles[[index]].cube_n_repeat = 0;
    _Tiles[[index]].cube_cell_count = 0;
    _Tiles[[index]].cube_storage_bytes = 0;
end;

func ConfigurePredicateCellForMask(
    index: TileIndex, capacity_bytes: integer {0..262144},
    valid_rows: integer {0..65535}, valid_columns: integer {0..65535},
    basis_type: TileDataType, layout: TileLayout,
    allocation_mask: bits(4)) => boolean
begin
    if (layout != TileLayout_CUBE_M16 && layout != TileLayout_CUBE_M32) ||
       !TileCubePredicateDataTypeSupported(basis_type) ||
       !TileCubeLayoutDataTypeSupported(layout, basis_type) then
        return FALSE;
    end;
    if !ConfigureCubeTileForMask(
           index, capacity_bytes, valid_rows, valid_columns,
           TileDataType_U8, layout, allocation_mask) then
        return FALSE;
    end;
    _Tiles[[index]].storage_kind = TileStorage_PredicateCell;
    _Tiles[[index]].predicate_basis_type = basis_type;
    return TRUE;
end;

func ConfigurePredicateCell(
    index: TileIndex, capacity_bytes: integer {0..262144},
    valid_rows: integer {0..65535}, valid_columns: integer {0..65535},
    basis_type: TileDataType, layout: TileLayout) => boolean
begin
    return ConfigurePredicateCellForMask(
        index, capacity_bytes, valid_rows, valid_columns,
        basis_type, layout, '0001');
end;
```
<!-- GENERATED-ASL-END: unit -->
