<!-- GENERATED FROM: asl/tile/model/shape/rows-columns.asl -->
# Rows Columns

**Normative ASL source:** `asl/tile/model/shape/rows-columns.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-SHAPE-ROWS-COLUMNS}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/shape/rows-columns.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-SHAPE-ROWS-COLUMNS","surface":"tile","classification":["model","shape","rows-columns"],"depends_on":["PTO-TILE-MODEL-STATE-DESCRIPTORS"]}
// Architectural Tile dimensions use exact powers of two. This bounded form
// covers every 16-bit dimension value without relying on implementation
// integer bitwise operators.
pure func IsNonzeroPowerOfTwo(value: integer {0..65535}) => boolean
begin
    if value == 0 then return FALSE; end;
    var candidate: integer = 1;
    for exponent = 0 to 15 do
        if value == candidate then return TRUE; end;
        candidate = candidate * 2;
    end;
    return FALSE;
end;

// TSize is a per-PE byte capacity. Physical rows are descriptor state derived
// exactly from that capacity, the physical column count, and the element type.
// Zero means that no legal 16-bit row count exists for the supplied shape.
pure func DerivedTileRows(capacity_bytes: integer {0..262144},
                          columns: integer {0..65535},
                          data_type: TileDataType) => integer {0..65535}
begin
    if capacity_bytes == 0 || !IsNonzeroPowerOfTwo(columns) then
        return 0;
    end;
    let capacity_bits: integer = capacity_bytes * 8;
    let row_bits: integer = columns * TileElementBits(data_type);
    if row_bits == 0 || capacity_bits MOD row_bits != 0 then return 0; end;
    let rows: integer = capacity_bits DIVRM row_bits;
    if rows == 0 || rows > 65535 then return 0; end;
    return rows as integer {0..65535};
end;

pure func TileShapeMatchesCapacity(capacity_bytes: integer {0..262144},
                                   rows: integer {0..65535},
                                   columns: integer {0..65535},
                                   data_type: TileDataType) => boolean
begin
    let derived_rows = DerivedTileRows(capacity_bytes, columns, data_type);
    return derived_rows != 0 && rows == derived_rows;
end;

// CUBE storage is CELL based rather than dense power-of-two row based.  The
// helpers below are the single source for dtype-specific CELL dimensions and
// the persistent geometry retained in a Local Tile descriptor.
pure func TileLayoutIsCube(layout: TileLayout) => boolean
begin
    return layout == TileLayout_CUBE_M32 ||
           layout == TileLayout_CUBE_M16 ||
           layout == TileLayout_CUBE_N8;
end;

pure func TileCubeMPerCell(layout: TileLayout) => integer {0..32}
begin
    if layout == TileLayout_CUBE_M32 then return 32; end;
    if layout == TileLayout_CUBE_M16 then return 16; end;
    return 0;
end;

pure func TileCubeKPerCell(layout: TileLayout,
                           data_type: TileDataType) => integer {0..32}
begin
    let element_bits = TileElementBits(data_type);
    if element_bits == 64 then return 0; end;
    if layout == TileLayout_CUBE_N8 then
        return (128 DIVRM element_bits) as integer {1..32};
    end;
    if layout == TileLayout_CUBE_M32 then
        return (32 DIVRM element_bits) as integer {1..8};
    end;
    if layout == TileLayout_CUBE_M16 then
        return (64 DIVRM element_bits) as integer {2..16};
    end;
    return 0;
end;

pure func TileCubeNPerCell(layout: TileLayout) => integer {0..8}
begin
    if layout == TileLayout_CUBE_N8 then return 8; end;
    if layout == TileLayout_CUBE_M32 || layout == TileLayout_CUBE_M16 then
        return 1;
    end;
    return 0;
end;

pure func TileCubeRoleLegal(layout: TileLayout,
                            role: TileCubeOperandRole) => boolean
begin
    if layout == TileLayout_CUBE_N8 then
        return role == TileCubeOperand_B;
    end;
    if layout == TileLayout_CUBE_M32 || layout == TileLayout_CUBE_M16 then
        return role == TileCubeOperand_A ||
               role == TileCubeOperand_C ||
               role == TileCubeOperand_D;
    end;
    return FALSE;
end;

pure func TileCubeCeilDiv(value: integer {0..65535},
                          divisor: integer {1..65535}) => integer {0..65535}
begin
    if value == 0 then return 0; end;
    return (((value + divisor) - 1) DIVRM divisor)
        as integer {1..65535};
end;

pure func TileCubeStorageRows(layout: TileLayout,
                              role: TileCubeOperandRole,
                              valid_rows: integer {0..65535},
                              data_type: TileDataType) => integer {0..65535}
begin
    if !TileCubeRoleLegal(layout, role) then return 0; end;
    if role == TileCubeOperand_B then
        let k_per_cell = TileCubeKPerCell(layout, data_type);
        if k_per_cell == 0 then return 0; end;
        return (TileCubeCeilDiv(valid_rows,
            k_per_cell as integer {1..65535}) * k_per_cell)
            as integer {0..65535};
    end;
    return TileCubeMPerCell(layout) as integer {0..65535};
end;

pure func TileCubeStorageColumns(layout: TileLayout,
                                 role: TileCubeOperandRole,
                                 valid_columns: integer {0..65535},
                                 data_type: TileDataType) => integer {0..65535}
begin
    if !TileCubeRoleLegal(layout, role) then return 0; end;
    let width = TileCubeKPerCell(layout, data_type);
    if width == 0 then return 0; end;
    if role == TileCubeOperand_B then
        return (TileCubeCeilDiv(valid_columns, 8) * 8)
            as integer {0..65535};
    end;
    return (TileCubeCeilDiv(valid_columns,
        width as integer {1..65535}) * width)
        as integer {0..65535};
end;

pure func TileCubeKRepeat(layout: TileLayout, role: TileCubeOperandRole,
                          valid_rows: integer {0..65535},
                          valid_columns: integer {0..65535},
                          data_type: TileDataType) => integer {0..65535}
begin
    if !TileCubeRoleLegal(layout, role) then return 0; end;
    if role == TileCubeOperand_C || role == TileCubeOperand_D then
        return 1;
    end;
    if role == TileCubeOperand_B then
        let width = TileCubeKPerCell(layout, data_type);
        if width == 0 then return 0; end;
        return TileCubeCeilDiv(valid_rows,
            width as integer {1..65535});
    end;
    if role == TileCubeOperand_A then
        let width = TileCubeKPerCell(layout, data_type);
        if width == 0 then return 0; end;
        return TileCubeCeilDiv(valid_columns,
            width as integer {1..65535});
    end;
    return 0;
end;

pure func TileCubeNRepeat(layout: TileLayout, role: TileCubeOperandRole,
                          valid_columns: integer {0..65535},
                          data_type: TileDataType)
                          => integer {0..65535}
begin
    if !TileCubeRoleLegal(layout, role) then return 0; end;
    if role == TileCubeOperand_A then return 1; end;
    if role == TileCubeOperand_B then
        return TileCubeCeilDiv(valid_columns, 8);
    end;
    if role == TileCubeOperand_C || role == TileCubeOperand_D then
        return TileCubeCeilDiv(valid_columns,
            TileCubeKPerCell(layout, data_type) as integer {1..65535});
    end;
    return 0;
end;

pure func TileCubeCellCount(layout: TileLayout, role: TileCubeOperandRole,
                            valid_rows: integer {0..65535},
                            valid_columns: integer {0..65535},
                            data_type: TileDataType) => integer {0..65535}
begin
    let k_repeat = TileCubeKRepeat(layout, role, valid_rows, valid_columns,
        data_type);
    let n_repeat = TileCubeNRepeat(layout, role, valid_columns, data_type);
    if k_repeat == 0 || n_repeat == 0 then return 0; end;
    let cells: integer = k_repeat * n_repeat;
    if cells > 65535 then return 65535; end;
    return cells as integer {1..65535};
end;

pure func TileCubeRequiredBytes(layout: TileLayout,
                                role: TileCubeOperandRole,
                                valid_rows: integer {0..65535},
                                valid_columns: integer {0..65535},
                                data_type: TileDataType) => integer {0..262144}
begin
    let bytes: integer =
        TileCubeCellCount(layout, role, valid_rows, valid_columns, data_type) *
        PTO_TILE_CELL_BYTES;
    if bytes > 262144 then return 262144; end;
    return bytes as integer {0..262144};
end;

readonly func TileCubeDescriptorShapeLegal(
    capacity_bytes: integer {0..262144}, valid_rows: integer {0..65535},
    valid_columns: integer {0..65535}, data_type: TileDataType,
    layout: TileLayout, role: TileCubeOperandRole) => boolean
begin
    if !TileLayoutIsCube(layout) || !TileCubeRoleLegal(layout, role) ||
       !TileCapacityIsLegal(capacity_bytes) || valid_rows == 0 ||
       valid_columns == 0 then return FALSE; end;
    let k_per_cell = TileCubeKPerCell(layout, data_type);
    let storage_rows = TileCubeStorageRows(layout, role, valid_rows,
        data_type);
    let storage_columns = TileCubeStorageColumns(layout, role,
        valid_columns, data_type);
    let required_bytes = TileCubeRequiredBytes(layout, role, valid_rows,
        valid_columns, data_type);
    return k_per_cell != 0 && storage_rows != 0 && storage_columns != 0 &&
           valid_rows <= storage_rows && valid_columns <= storage_columns &&
           required_bytes <= capacity_bytes &&
           storage_rows * storage_columns <= PTO_MODEL_TILE_ELEMENTS;
end;

pure func TileCubeCellElementIndex(layout: TileLayout,
                                   data_type: TileDataType,
                                   local_row: integer {0..65535},
                                   local_column: integer {0..65535})
                                   => integer {0..65535}
begin
    let width = TileCubeKPerCell(layout, data_type);
    if layout == TileLayout_CUBE_N8 then
        // K is the fast direction inside a B CELL; N is the slow direction.
        return (local_column * width + local_row) as integer {0..65535};
    end;
    if layout == TileLayout_CUBE_M16 &&
       TileElementBits(data_type) == 4 then
        // For each fixed M row, b4 M16 stores x0..x3, x8..x11,
        // x4..x7, x12..x15 across the two 32-bit words.
        let interleaved = if local_column < 4 then local_column
            else if local_column < 8 then local_column + 4
            else if local_column < 12 then local_column - 4
            else local_column;
        return (local_row * width + interleaved) as integer {0..65535};
    end;
    // M is the slow direction and X/N/K is the fast direction.
    return (local_row * width + local_column) as integer {0..65535};
end;

readonly func TileCubePayloadIndex(layout: TileLayout,
                               data_type: TileDataType,
                               role: TileCubeOperandRole,
                               k_repeat: integer {0..65535},
                               row: integer {0..65535},
                               column: integer {0..65535})
                               => ModelTileElementIndex
begin
    let k_width = TileCubeKPerCell(layout, data_type);
    let n_width = TileCubeNPerCell(layout);
    let m_height = TileCubeMPerCell(layout);
    assert k_width != 0;
    if role == TileCubeOperand_B then
        let cell_k: integer =
            row DIVRM (k_width as integer {1..65535});
        let cell_n: integer =
            column DIVRM (n_width as integer {1..65535});
        let local_k: integer =
            row MOD (k_width as integer {1..65535});
        let local_n: integer =
            column MOD (n_width as integer {1..65535});
        let cell_index: integer = cell_n * k_repeat + cell_k;
        let cell_offset: integer = cell_index * (k_width * n_width);
        let local_offset: integer = TileCubeCellElementIndex(layout, data_type,
            local_k as integer {0..65535}, local_n as integer {0..65535});
        assert cell_offset + local_offset < PTO_MODEL_TILE_ELEMENTS;
        return (cell_offset + local_offset) as ModelTileElementIndex;
    end;

    let cell_width: integer = k_width;
    let cell_index: integer =
        column DIVRM (cell_width as integer {1..65535});
    let local_column: integer =
        column MOD (cell_width as integer {1..65535});
    let local_offset: integer = TileCubeCellElementIndex(layout, data_type,
        row, local_column as integer {0..65535});
    // A/C/D M layouts repeat only in K (A) or N (C/D); both have one
    // CELL-height in M and the same X-fast intra-CELL mapping.
    let cell_offset: integer = cell_index * (m_height * cell_width);
    assert cell_offset + local_offset < PTO_MODEL_TILE_ELEMENTS;
    return (cell_offset + local_offset) as ModelTileElementIndex;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
