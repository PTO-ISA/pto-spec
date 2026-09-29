<!-- GENERATED FROM: asl/tile/model/shape/cube-cell.asl -->
# CUBE Cell

**Normative ASL source:** `asl/tile/model/shape/cube-cell.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-SHAPE-CUBE-CELL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-shape-cube-cell-purpose role=purpose-scope -->
## Purpose and scope

This unit defines the storage geometry of the three Local CUBE layouts: `CUBE_M16`, `CUBE_M32`, and `CUBE_N8`. CUBE layouts are the layouts used by the CUBE matrix operations. Their storage is a sequence of CELLs, where one CELL is exactly 128 bytes (`PTO_TILE_CELL_BYTES`).

It owns the accepted requirement `PTO-CUBE-CELL-STATE-001` and the scale-grid requirement `PTO-CUBE-MATRIX-SCALE-CELL-001`. It computes CELL shape, storage rows and columns, repeat counts, byte counts, descriptor legality, and the payload index of each element.

<!-- PTO-READER-BLOCK: tile-model-shape-cube-cell-concepts role=concepts-state -->
## Concepts and visible state

The CELL shape depends on the layout and the element width:

| Layout | 32-bit | 16-bit | 8-bit | 4-bit | 64-bit |
| --- | --- | --- | --- | --- | --- |
| `CUBE_M16` | 16 x 2 | 16 x 4 | 16 x 8 | 16 x 16 | illegal |
| `CUBE_M32` | 32 x 1 | 32 x 2 | 32 x 4 | 32 x 8 | illegal |
| `CUBE_N8` | 4 x 8 | 8 x 8 | 16 x 8 | 32 x 8 | 2 x 8, U64 only |

Each entry is CELL rows by CELL columns. Every entry holds 128 bytes.

A CUBE `TileInfo` records four derived values: `cube_k_repeat`, `cube_n_repeat`, `cube_cell_count`, and `cube_storage_bytes`. The model checks them against the physical shape before indexing.

<!-- PTO-READER-BLOCK: tile-model-shape-cube-cell-rules role=rules-interactions -->
## Rules and interactions

Storage rows and columns round the valid region up to whole CELLs:

- `CUBE_M16` and `CUBE_M32` always have exactly 16 or 32 physical rows; the valid rows must not exceed that.
- `CUBE_N8` rounds valid rows up to a multiple of the CELL rows.
- All layouts round valid columns up to a multiple of the CELL columns.

The repeat counts follow from the physical shape. For M16 and M32, the K repeat is columns divided by CELL columns and the N repeat is 1. For N8, the K repeat is rows divided by CELL rows and the N repeat is columns divided by 8. The CELL count is K repeat times N repeat, and the storage is 128 bytes per CELL.

`TileCubeDescriptorShapeAndPhysicalLegal` also requires a legal capacity, a positive valid region inside the physical shape, and storage no larger than capacity.

Design point: storage is always a whole number of 128-byte CELLs. `PTO-CUBE-CELL-STATE-001` requires storage to be derived independently of valid M, N, and K, and requires unsupported types or insufficient capacity to be rejected before effects. `ConfigureCubeTileForMaskWithPhysical` returns FALSE before writing any state when this check fails.

Design point: M16 and M32 hold one physical M block. Their descriptors may carry a physical column envelope wider than the valid region, but N8 keeps the valid-derived geometry, as the source comment states.

Design point: 64-bit types are excluded except `CUBE_N8` with U64, which uses K2 x N8 CELLs. `PTO-CUBE-CELL-STATE-001` names this as the sole b64 exception.

<!-- PTO-READER-BLOCK: tile-model-shape-cube-cell-boundaries role=boundaries -->
## Architectural boundaries

Inside a CELL, `TileCubeCellElementIndex` orders N8 elements with K fastest and M16 or M32 elements with the column direction fastest. `CUBE_M16` with a 4-bit type additionally swaps inner columns 4 to 7 with 8 to 11.

`TileCubePayloadIndex` orders CELLs with K repeat fastest for N8, and by column CELL for M16 and M32.

`PTO-CUBE-MATRIX-SCALE-CELL-001` states that the generic grid must not expand primary A, C, or D legality beyond M16 and M32. Operand role rules belong to the matrix legality owners.

<!-- PTO-READER-BLOCK: tile-model-shape-cube-cell-example role=example-usage -->
## Non-normative reading example

A `CUBE_N8` FP16 Tile has valid K = 20 rows and valid N = 12 columns. The CELL is 8 x 8.

- Storage rows round 20 up to 24, and storage columns round 12 up to 16.
- K repeat is 24 / 8 = 3 and N repeat is 16 / 8 = 2, so there are 6 CELLs and 768 bytes.

Element row 10, column 9 lies in CELL K index 1 and CELL N index 1, so its CELL index is 1 x 3 + 1 = 4. Its inner position is row 2, column 1, which maps to 1 x 8 + 2 = 10. The payload index is 4 x 64 + 10 = 266.

A `CUBE_M16` FP16 Tile with a valid region of 10 by 6 has 16 rows and 8 columns, a K repeat of 2, and 256 bytes.

<!-- PTO-READER-BLOCK: tile-model-shape-cube-cell-related role=related-owners-navigation -->
## Related owners

- [Allocation](../state/allocation.md) records the CUBE geometry through `ConfigureCubeTileForMaskWithPhysical`.
- [Valid region](valid-region.md) owns the non-CUBE shape checks.
- [Descriptor shape legality](../legality/descriptor-shape.md) rechecks stored CUBE geometry.
- [Element definedness](../definedness/elements.md) routes CUBE indexing through `TileCubePayloadIndex`.
- [CUBE destination](../../../block/model/dispatch/cube-destination.md) allocates CUBE destinations for matrix operations.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/shape/cube-cell.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-SHAPE-CUBE-CELL","surface":"tile","classification":["model","shape","cube-cell"],"depends_on":["PTO-TILE-MODEL-SHAPE-VALID-REGION"]}
// NDF-BEGIN: PTO-CUBE-CELL-STATE-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Local CUBE layouts MUST use assigned 128-byte width-parametric CELL mappings,
// derive storage independently of valid M/N/K, and reject unsupported types or
// insufficient capacity before effects; M16/M32 contain one physical M block.
// CUBE_N8/U64 is the sole b64 exception and uses K2 x N8 CELL geometry.
// NDF-END: PTO-CUBE-CELL-STATE-001

// NDF-BEGIN: PTO-CUBE-MATRIX-SCALE-CELL-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// column/K repeat fast and one 32-row physical block; partial groups are tail.
// This generic grid MUST NOT expand primary A/C/D legality beyond M16/M32.
// NDF-END: PTO-CUBE-MATRIX-SCALE-CELL-001
pure func TileLayoutIsCube(layout: TileLayout) => boolean
begin
    return layout == TileLayout_CUBE_M16 ||
           layout == TileLayout_CUBE_M32 ||
           layout == TileLayout_CUBE_N8;
end;

pure func TileCubeDataTypeSupported(data_type: TileDataType) => boolean
begin
    let element_bits = TileElementBits(data_type);
    return element_bits != 64;
end;

pure func TileCubeLayoutDataTypeSupported(layout: TileLayout, data_type: TileDataType) => boolean
begin
    return TileCubeDataTypeSupported(data_type) || (layout == TileLayout_CUBE_N8 && data_type == TileDataType_U64);
end;

pure func TileCubeCellRows(layout: TileLayout,
                           data_type: TileDataType)
    => integer {0,2,4,8,16,32}
begin
    if !TileLayoutIsCube(layout) ||
       !TileCubeLayoutDataTypeSupported(layout, data_type) then
        return 0;
    end;
    if layout == TileLayout_CUBE_M16 then return 16;
    elsif layout == TileLayout_CUBE_M32 then return 32;
    end;
    case TileElementBits(data_type) of
        when 64 => return 2;
        when 32 => return 4;
        when 16 => return 8;
        when 8 => return 16;
        when 4 => return 32;
        otherwise => return 0;
    end;
end;

pure func TileCubeCellColumns(layout: TileLayout,
                              data_type: TileDataType)
    => integer {0,1,2,4,8,16}
begin
    if !TileLayoutIsCube(layout) ||
       !TileCubeLayoutDataTypeSupported(layout, data_type) then
        return 0;
    end;
    if layout == TileLayout_CUBE_N8 then return 8; end;
    case TileElementBits(data_type) of
        when 32 =>
            return if layout == TileLayout_CUBE_M16 then 2 else 1;
        when 16 =>
            return if layout == TileLayout_CUBE_M16 then 4 else 2;
        when 8 =>
            return if layout == TileLayout_CUBE_M16 then 8 else 4;
        when 4 =>
            return if layout == TileLayout_CUBE_M16 then 16 else 8;
        otherwise => return 0;
    end;
end;

pure func TileCubeAlignedExtent(value: integer {0..65535},
                                quantum: integer {1..65535})
    => integer {0..65535}
begin
    if value == 0 then return 0; end;
    let groups: integer = ((value - 1) DIVRM quantum) + 1;
    let aligned: integer = groups * quantum;
    if aligned > 65535 then return 0; end;
    return aligned as integer {1..65535};
end;

pure func TileCubeStorageRows(layout: TileLayout,
                              valid_rows: integer {0..65535},
                              data_type: TileDataType)
    => integer {0..65535}
begin
    let cell_rows = TileCubeCellRows(layout, data_type);
    if cell_rows == 0 || valid_rows == 0 then return 0; end;
    if layout == TileLayout_CUBE_N8 then
        return TileCubeAlignedExtent(valid_rows,
            cell_rows as integer {1..65535});
    end;
    if valid_rows > cell_rows then return 0; end;
    return cell_rows as integer {1..65535};
end;

pure func TileCubeStorageColumns(layout: TileLayout,
                                 valid_columns: integer {0..65535},
                                 data_type: TileDataType)
    => integer {0..65535}
begin
    let cell_columns = TileCubeCellColumns(layout, data_type);
    if cell_columns == 0 || valid_columns == 0 then return 0; end;
    return TileCubeAlignedExtent(valid_columns,
        cell_columns as integer {1..65535});
end;

pure func TileCubeKRepeat(layout: TileLayout,
                          valid_rows: integer {0..65535},
                          valid_columns: integer {0..65535},
                          data_type: TileDataType)
    => integer {0..65535}
begin
    return TileCubeKRepeatForColumns(layout, valid_rows,
        TileCubeStorageColumns(layout, valid_columns, data_type), data_type);
end;

pure func TileCubeKRepeatForColumns(layout: TileLayout,
                                    valid_rows: integer {0..65535},
                                    columns: integer {0..65535},
                                    data_type: TileDataType)
    => integer {0..65535}
begin
    let cell_rows = TileCubeCellRows(layout, data_type);
    let cell_columns = TileCubeCellColumns(layout, data_type);
    if cell_rows == 0 || columns == 0 then return 0; end;
    if cell_columns == 0 then return 0; end;
    if layout == TileLayout_CUBE_N8 then
        let storage_rows = TileCubeStorageRows(layout, valid_rows, data_type);
        if storage_rows == 0 then return 0; end;
        let row_divisor = cell_rows as integer {1..32};
        return (storage_rows DIVRM row_divisor) as integer {1..65535};
    end;
    let column_divisor = cell_columns as integer {1..16};
    if columns MOD column_divisor != 0 then return 0; end;
    return (columns DIVRM column_divisor) as integer {1..65535};
end;

pure func TileCubeNRepeat(layout: TileLayout,
                          valid_rows: integer {0..65535},
                          valid_columns: integer {0..65535},
                          data_type: TileDataType)
    => integer {0..8192}
begin
    return TileCubeNRepeatForColumns(layout, valid_rows,
        TileCubeStorageColumns(layout, valid_columns, data_type), data_type);
end;

pure func TileCubeNRepeatForColumns(layout: TileLayout,
                                    valid_rows: integer {0..65535},
                                    columns: integer {0..65535},
                                    data_type: TileDataType)
    => integer {0..8192}
begin
    if !TileLayoutIsCube(layout) ||
       !TileCubeLayoutDataTypeSupported(layout, data_type) || columns == 0 then
        return 0;
    end;
    if layout == TileLayout_CUBE_M32 then
        let storage_rows = TileCubeStorageRows(
            layout, valid_rows, data_type);
        if storage_rows == 0 then return 0; end;
        return 1;
    end;
    if layout != TileLayout_CUBE_N8 then return 1; end;
    if columns MOD 8 != 0 then return 0; end;
    return (columns DIVRM 8) as integer {1..8192};
end;

pure func TileCubeCellCount(layout: TileLayout,
                            valid_rows: integer {0..65535},
                            valid_columns: integer {0..65535},
                            data_type: TileDataType)
    => integer {0..16384}
begin
    return TileCubeCellCountForColumns(layout, valid_rows,
        TileCubeStorageColumns(layout, valid_columns, data_type), data_type);
end;

pure func TileCubeCellCountForColumns(layout: TileLayout,
                                      valid_rows: integer {0..65535},
                                      columns: integer {0..65535},
                                      data_type: TileDataType)
    => integer {0..16384}
begin
    let k_repeat = TileCubeKRepeatForColumns(
        layout, valid_rows, columns, data_type);
    let n_repeat = TileCubeNRepeatForColumns(
        layout, valid_rows, columns, data_type);
    if k_repeat == 0 || n_repeat == 0 then return 0; end;
    let cells: integer = k_repeat * n_repeat;
    if cells > 16384 then return 0; end;
    return cells as integer {1..16384};
end;

readonly func TileCubeStorageElementsForColumns(
    layout: TileLayout,
    valid_rows: integer {0..65535},
    columns: integer {0..65535},
    data_type: TileDataType) => integer {0..32768}
begin
    let cells = TileCubeCellCountForColumns(
        layout, valid_rows, columns, data_type);
    let cell_rows = TileCubeCellRows(layout, data_type);
    let cell_columns = TileCubeCellColumns(layout, data_type);
    if cells == 0 || cell_rows == 0 || cell_columns == 0 then return 0; end;
    let elements: integer = cells * cell_rows * cell_columns;
    if elements > PTO_MODEL_TILE_ELEMENTS then return 0; end;
    return elements as integer {1..32768};
end;

pure func TileCubeRequiredBytes(layout: TileLayout,
                                valid_rows: integer {0..65535},
                                valid_columns: integer {0..65535},
                                data_type: TileDataType)
    => integer {0..262144}
begin
    return TileCubeRequiredBytesForColumns(layout, valid_rows,
        TileCubeStorageColumns(layout, valid_columns, data_type), data_type);
end;

pure func TileCubeRequiredBytesForColumns(
    layout: TileLayout,
    valid_rows: integer {0..65535},
    columns: integer {0..65535},
    data_type: TileDataType) => integer {0..262144}
begin
    let cells = TileCubeCellCountForColumns(
        layout, valid_rows, columns, data_type);
    if cells == 0 then return 0; end;
    let required: integer = cells * PTO_TILE_CELL_BYTES;
    if required > 262144 then return 0; end;
    return required as integer {128..262144};
end;

// The helpers above describe the minimum physical envelope implied by a
// valid rectangle. M16/M32 descriptors additionally carry an independent
// physical envelope; N8 deliberately retains the valid-derived geometry.
pure func TileCubePhysicalKRepeat(
    layout: TileLayout,
    physical_rows: integer {0..65535},
    physical_columns: integer {0..65535},
    data_type: TileDataType) => integer {0..65535}
begin
    let cell_rows = TileCubeCellRows(layout, data_type);
    let cell_columns = TileCubeCellColumns(layout, data_type);
    if cell_rows == 0 || cell_columns == 0 ||
       physical_rows == 0 || physical_columns == 0 then
        return 0;
    end;
    if layout == TileLayout_CUBE_N8 then
        return (physical_rows DIVRM (cell_rows as integer {2,4,8,16,32}))
            as integer {1..65535};
    end;
    return (physical_columns DIVRM (cell_columns as integer {1,2,4,8,16}))
        as integer {1..65535};
end;

pure func TileCubePhysicalNRepeat(
    layout: TileLayout,
    physical_rows: integer {0..65535},
    physical_columns: integer {0..65535},
    data_type: TileDataType) => integer {0..8192}
begin
    let cell_rows = TileCubeCellRows(layout, data_type);
    let cell_columns = TileCubeCellColumns(layout, data_type);
    if cell_rows == 0 || cell_columns == 0 ||
       physical_rows == 0 || physical_columns == 0 then
        return 0;
    end;
    if layout == TileLayout_CUBE_M16 || layout == TileLayout_CUBE_M32 then
        return 1;
    end;
    return (physical_columns DIVRM 8) as integer {1..8192};
end;

pure func TileCubePhysicalCellCount(
    layout: TileLayout,
    physical_rows: integer {0..65535},
    physical_columns: integer {0..65535},
    data_type: TileDataType) => integer {0..16384}
begin
    let k_repeat = TileCubePhysicalKRepeat(
        layout, physical_rows, physical_columns, data_type);
    let n_repeat = TileCubePhysicalNRepeat(
        layout, physical_rows, physical_columns, data_type);
    if k_repeat == 0 || n_repeat == 0 then return 0; end;
    let cells: integer = k_repeat * n_repeat;
    if cells > 16384 then return 0; end;
    return cells as integer {1..16384};
end;

pure func TileCubePhysicalRequiredBytes(
    layout: TileLayout,
    physical_rows: integer {0..65535},
    physical_columns: integer {0..65535},
    data_type: TileDataType) => integer {0..262144}
begin
    let cells = TileCubePhysicalCellCount(
        layout, physical_rows, physical_columns, data_type);
    if cells == 0 then return 0; end;
    let required: integer = cells * PTO_TILE_CELL_BYTES;
    if required > 262144 then return 0; end;
    return required as integer {128..262144};
end;

readonly func TileCubePhysicalStorageElements(
    layout: TileLayout,
    physical_rows: integer {0..65535},
    physical_columns: integer {0..65535},
    data_type: TileDataType) => integer {0..32768}
begin
    let cells = TileCubePhysicalCellCount(
        layout, physical_rows, physical_columns, data_type);
    let cell_rows = TileCubeCellRows(layout, data_type);
    let cell_columns = TileCubeCellColumns(layout, data_type);
    if cells == 0 || cell_rows == 0 || cell_columns == 0 then return 0; end;
    let elements: integer = cells * cell_rows * cell_columns;
    if elements > PTO_MODEL_TILE_ELEMENTS then return 0; end;
    return elements as integer {1..32768};
end;

readonly func TileCubeDescriptorShapeAndPhysicalLegal(
    capacity_bytes: integer {0..262144},
    physical_rows: integer {0..65535},
    physical_columns: integer {0..65535},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    data_type: TileDataType,
    layout: TileLayout) => boolean
begin
    if !TileLayoutIsCube(layout) ||
       !TileCubeLayoutDataTypeSupported(layout, data_type) ||
       !TileCapacityIsLegal(capacity_bytes) ||
       physical_rows == 0 || physical_columns == 0 ||
       valid_rows == 0 || valid_columns == 0 ||
       valid_rows > physical_rows || valid_columns > physical_columns then
        return FALSE;
    end;
    let cell_columns = TileCubeCellColumns(layout, data_type);
    if layout == TileLayout_CUBE_M16 then
        if physical_rows != 16 ||
           physical_columns MOD (cell_columns as integer {1,2,4,8,16}) != 0 then
            return FALSE;
        end;
    elsif layout == TileLayout_CUBE_M32 then
        if physical_rows != 32 ||
           physical_columns MOD (cell_columns as integer {1,2,4,8,16}) != 0 then
            return FALSE;
        end;
    else
        if physical_rows != TileCubeStorageRows(layout, valid_rows, data_type) ||
           physical_columns != TileCubeStorageColumns(
               layout, valid_columns, data_type) then
            return FALSE;
        end;
    end;
    let cells = TileCubePhysicalCellCount(
        layout, physical_rows, physical_columns, data_type);
    let elements = TileCubePhysicalStorageElements(
        layout, physical_rows, physical_columns, data_type);
    let required_bytes = TileCubePhysicalRequiredBytes(
        layout, physical_rows, physical_columns, data_type);
    return cell_columns != 0 && cells != 0 && elements != 0 &&
           required_bytes != 0 && required_bytes <= capacity_bytes;
end;

readonly func TileCubeDescriptorShapeLegal(
    capacity_bytes: integer {0..262144},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    data_type: TileDataType,
    layout: TileLayout) => boolean
begin
    let storage_rows = TileCubeStorageRows(layout, valid_rows, data_type);
    let storage_columns = TileCubeStorageColumns(
        layout, valid_columns, data_type);
    return storage_rows != 0 && storage_columns != 0 &&
           TileCubeDescriptorShapeAndPhysicalLegal(
               capacity_bytes, storage_rows, storage_columns,
               valid_rows, valid_columns, data_type, layout);
end;

readonly func TileCubeDescriptorShapeLegalWithColumns(
    capacity_bytes: integer {0..262144},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    columns: integer {0..65535},
    data_type: TileDataType,
    layout: TileLayout) => boolean
begin
    let storage_rows = TileCubeStorageRows(layout, valid_rows, data_type);
    return storage_rows != 0 &&
           TileCubeDescriptorShapeAndPhysicalLegal(capacity_bytes,
               storage_rows, columns, valid_rows, valid_columns,
               data_type, layout);
end;

readonly func TileCubeGeometryLegalWithColumns(
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    columns: integer {0..65535},
    data_type: TileDataType,
    layout: TileLayout) => boolean
begin
    if !TileLayoutIsCube(layout) ||
       !TileCubeLayoutDataTypeSupported(layout, data_type) ||
       valid_rows == 0 ||
       valid_columns == 0 || columns == 0 || columns < valid_columns then
        return FALSE;
    end;
    let cell_columns = TileCubeCellColumns(layout, data_type);
    if cell_columns == 0 then return FALSE; end;
    let column_quantum = cell_columns as integer {1..65535};
    if columns MOD column_quantum != 0 then return FALSE; end;
    let storage_rows = TileCubeStorageRows(layout, valid_rows, data_type);
    let storage_columns = columns;
    let storage_elements = TileCubeStorageElementsForColumns(
        layout, valid_rows, columns, data_type);
    return storage_rows != 0 && storage_columns != 0 &&
           storage_elements != 0 && valid_rows <= storage_rows;
end;

pure func TileCubeCellElementIndex(
    layout: TileLayout,
    data_type: TileDataType,
    inner_row: integer {0..31},
    inner_column: integer {0..31})
    => integer {0..255}
begin
    let cell_rows = TileCubeCellRows(layout, data_type);
    let cell_columns = TileCubeCellColumns(layout, data_type);
    assert cell_rows != 0 && cell_columns != 0;
    assert inner_row < cell_rows && inner_column < cell_columns;
    if layout == TileLayout_CUBE_N8 then
        return (inner_column * cell_rows + inner_row)
            as integer {0..255};
    end;
    var mapped_column = inner_column;
    if layout == TileLayout_CUBE_M16 &&
       TileElementBits(data_type) == 4 then
        if inner_column < 4 then mapped_column = inner_column;
        elsif inner_column < 8 then
            mapped_column = (inner_column + 4) as integer {0..31};
        elsif inner_column < 12 then
            mapped_column = (inner_column - 4) as integer {0..31};
        else mapped_column = inner_column;
        end;
    end;
    return (inner_row * cell_columns + mapped_column)
        as integer {0..255};
end;

readonly func TileCubePayloadIndex(
    tile: TileInfo,
    row: integer {0..65535},
    column: integer {0..65535})
    => ModelTileElementIndex
begin
    assert TileLayoutIsCube(tile.layout);
    assert row < tile.rows && column < tile.columns;
    let cell_rows = TileCubeCellRows(tile.layout, tile.data_type);
    let cell_columns = TileCubeCellColumns(tile.layout, tile.data_type);
    let k_repeat = TileCubePhysicalKRepeat(tile.layout, tile.rows,
        tile.columns, tile.data_type);
    assert cell_rows != 0 && cell_columns != 0 && k_repeat != 0;
    let row_divisor = cell_rows as integer {1..32};
    let column_divisor = cell_columns as integer {1..16};
    var cell_index: integer = 0;
    var inner_row: integer = 0;
    var inner_column: integer = 0;
    if tile.layout == TileLayout_CUBE_N8 then
        let cell_k = (row DIVRM row_divisor) as integer {0..16383};
        let cell_n = (column DIVRM column_divisor) as integer {0..8191};
        cell_index = cell_n * k_repeat + cell_k;
        inner_row = row MOD row_divisor;
        inner_column = column MOD column_divisor;
    elsif tile.layout == TileLayout_CUBE_M32 then
        let cell_column = (column DIVRM column_divisor)
            as integer {0..65535};
        cell_index = cell_column;
        inner_row = row MOD row_divisor;
        inner_column = column MOD column_divisor;
    else
        cell_index = column DIVRM column_divisor;
        inner_row = row;
        inner_column = column MOD column_divisor;
    end;
    let cell_elements: integer = cell_rows * cell_columns;
    let local = TileCubeCellElementIndex(tile.layout, tile.data_type,
        inner_row as integer {0..31}, inner_column as integer {0..31});
    let index: integer = cell_index * cell_elements + local;
    assert index < PTO_MODEL_TILE_ELEMENTS;
    return index as ModelTileElementIndex;
end;
```
<!-- GENERATED-ASL-END: unit -->
