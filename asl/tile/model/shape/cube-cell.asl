// PTO-UNIT: {"id":"PTO-TILE-MODEL-SHAPE-CUBE-CELL","surface":"tile","classification":["model","shape","cube-cell"],"depends_on":["PTO-TILE-MODEL-SHAPE-VALID-REGION"]}
// NDF-BEGIN: PTO-CUBE-CELL-STATE-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Local CUBE layouts MUST use the assigned 128-byte width-parametric CELL
// mappings, derive storage independently of valid M/N/K, and reject unsupported
// types or insufficient per-PE capacity before effects.
// NDF-END: PTO-CUBE-CELL-STATE-001

pure func TileLayoutIsCube(layout: TileLayout) => boolean
begin
    return layout == TileLayout_CUBE_M16 ||
           layout == TileLayout_CUBE_M32 ||
           layout == TileLayout_CUBE_N8;
end;

pure func TileCubeDataTypeSupported(data_type: TileDataType) => boolean
begin
    let element_bits = TileElementBits(data_type);
    return data_type != TileDataType_HiF4X2 && element_bits != 64;
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
    let cell_rows = TileCubeCellRows(layout, data_type);
    let cell_columns = TileCubeCellColumns(layout, data_type);
    if cell_rows == 0 || cell_columns == 0 then return 0; end;
    if layout == TileLayout_CUBE_N8 then
        let storage_rows = TileCubeStorageRows(layout, valid_rows, data_type);
        if storage_rows == 0 then return 0; end;
        let row_divisor = cell_rows as integer {1..32};
        return (storage_rows DIVRM row_divisor) as integer {1..65535};
    end;
    let storage_columns = TileCubeStorageColumns(
        layout, valid_columns, data_type);
    if storage_columns == 0 then return 0; end;
    let column_divisor = cell_columns as integer {1..16};
    return (storage_columns DIVRM column_divisor) as integer {1..65535};
end;

pure func TileCubeNRepeat(layout: TileLayout,
                          valid_columns: integer {0..65535},
                          data_type: TileDataType)
    => integer {0..8192}
begin
    if !TileLayoutIsCube(layout) ||
       !TileCubeDataTypeSupported(data_type) || valid_columns == 0 then
        return 0;
    end;
    if layout != TileLayout_CUBE_N8 then return 1; end;
    let storage_columns = TileCubeStorageColumns(
        layout, valid_columns, data_type);
    if storage_columns == 0 then return 0; end;
    return (storage_columns DIVRM 8) as integer {1..8192};
end;

pure func TileCubeCellCount(layout: TileLayout,
                            valid_rows: integer {0..65535},
                            valid_columns: integer {0..65535},
                            data_type: TileDataType)
    => integer {0..16384}
begin
    let k_repeat = TileCubeKRepeat(
        layout, valid_rows, valid_columns, data_type);
    let n_repeat = TileCubeNRepeat(layout, valid_columns, data_type);
    if k_repeat == 0 || n_repeat == 0 then return 0; end;
    let cells: integer = k_repeat * n_repeat;
    if cells > 16384 then return 0; end;
    return cells as integer {1..16384};
end;

readonly func TileCubeStorageElements(layout: TileLayout,
                                  valid_rows: integer {0..65535},
                                  valid_columns: integer {0..65535},
                                  data_type: TileDataType)
    => integer {0..16384}
begin
    let cells = TileCubeCellCount(
        layout, valid_rows, valid_columns, data_type);
    let cell_rows = TileCubeCellRows(layout, data_type);
    let cell_columns = TileCubeCellColumns(layout, data_type);
    if cells == 0 || cell_rows == 0 || cell_columns == 0 then return 0; end;
    let elements: integer = cells * cell_rows * cell_columns;
    if elements > PTO_MODEL_TILE_ELEMENTS then return 0; end;
    return elements as integer {1..16384};
end;

pure func TileCubeRequiredBytes(layout: TileLayout,
                                valid_rows: integer {0..65535},
                                valid_columns: integer {0..65535},
                                data_type: TileDataType)
    => integer {0..262144}
begin
    let cells = TileCubeCellCount(
        layout, valid_rows, valid_columns, data_type);
    if cells == 0 then return 0; end;
    let required: integer = cells * PTO_TILE_CELL_BYTES;
    if required > 262144 then return 0; end;
    return required as integer {128..262144};
end;

readonly func TileCubeDescriptorShapeLegal(
    capacity_bytes: integer {0..262144},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    data_type: TileDataType,
    layout: TileLayout) => boolean
begin
    if !TileLayoutIsCube(layout) ||
       !TileCubeDataTypeSupported(data_type) ||
       !TileCapacityIsLegal(capacity_bytes) ||
       valid_rows == 0 || valid_columns == 0 then
        return FALSE;
    end;
    let storage_rows = TileCubeStorageRows(layout, valid_rows, data_type);
    let storage_columns = TileCubeStorageColumns(
        layout, valid_columns, data_type);
    let storage_elements = TileCubeStorageElements(
        layout, valid_rows, valid_columns, data_type);
    let required_bytes = TileCubeRequiredBytes(
        layout, valid_rows, valid_columns, data_type);
    return storage_rows != 0 && storage_columns != 0 &&
           storage_elements != 0 && required_bytes != 0 &&
           valid_rows <= storage_rows &&
           valid_columns <= storage_columns &&
           required_bytes <= capacity_bytes;
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
    let k_repeat = TileCubeKRepeat(tile.layout, tile.valid_rows,
        tile.valid_columns, tile.data_type);
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
