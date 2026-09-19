<!-- GENERATED FROM: asl/tile/model/shape/cube-cell.asl -->
# CUBE Cell

**Normative ASL source:** `asl/tile/model/shape/cube-cell.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-SHAPE-CUBE-CELL}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/shape/cube-cell.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-SHAPE-CUBE-CELL","surface":"tile","classification":["model","shape","cube-cell"],"depends_on":["PTO-TILE-MODEL-SHAPE-VALID-REGION"]}
// NDF-BEGIN: PTO-CUBE-CELL-STATE-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Local CUBE layouts MUST use the assigned 128-byte width-parametric CELL
// mappings, derive storage independently of valid M/N/K, and reject unsupported
// types or insufficient per-PE capacity before effects. Local M16 and M32
// descriptors each contain exactly one physical M block; valid rows are a
// nonzero tail within that block.
// NDF-END: PTO-CUBE-CELL-STATE-001

// NDF-BEGIN: PTO-CUBE-MATRIX-SCALE-CELL-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Matrix scale Tiles in CUBE_M32 MUST use a 128-byte CellReg grid with
// column/K repeat fast and exactly one 32-row physical block. Partial final
// group slots remain invalid storage tail. This generic grid MUST NOT expand
// primary A/C/D legality beyond one M16/M32 row block.
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

pure func TileCubeCellRows(layout: TileLayout,
                           data_type: TileDataType)
    => integer {0,4,8,16,32}
begin
    if !TileLayoutIsCube(layout) ||
       !TileCubeDataTypeSupported(data_type) then
        return 0;
    end;
    if layout == TileLayout_CUBE_M16 then return 16;
    elsif layout == TileLayout_CUBE_M32 then return 32;
    end;
    case TileElementBits(data_type) of
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
       !TileCubeDataTypeSupported(data_type) then
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
       !TileCubeDataTypeSupported(data_type) || columns == 0 then
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
        return (physical_rows DIVRM (cell_rows as integer {4,8,16,32}))
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
       !TileCubeDataTypeSupported(data_type) ||
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
       !TileCubeDataTypeSupported(data_type) ||
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
