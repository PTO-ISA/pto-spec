<!-- GENERATED FROM: asl/tile/model/shape/cube-cell.asl -->
# CUBE Cell

**Normative ASL source:** `asl/tile/model/shape/cube-cell.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-SHAPE-CUBE-CELL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-shape-cube-cell-purpose role=purpose-scope -->
## 用途与范围

本单元定义三种 Local CUBE 布局的存储几何：`CUBE_M16`、`CUBE_M32` 和 `CUBE_N8`。CUBE 布局是 CUBE 矩阵操作所使用的布局。它们的存储是一串 CELL，其中一个 CELL 恰好为 128 字节（`PTO_TILE_CELL_BYTES`）。

它拥有已接受的需求 `PTO-CUBE-CELL-STATE-001` 和缩放网格需求 `PTO-CUBE-MATRIX-SCALE-CELL-001`。它计算 CELL 形状、存储行数与列数、重复次数、字节数、描述符合法性以及每个元素的载荷索引。

<!-- PTO-READER-BLOCK: tile-model-shape-cube-cell-concepts role=concepts-state -->
## 概念与可见状态

CELL 形状取决于布局和元素宽度：

| 布局 | 32 位 | 16 位 | 8 位 | 4 位 | 64 位 |
| --- | --- | --- | --- | --- | --- |
| `CUBE_M16` | 16 x 2 | 16 x 4 | 16 x 8 | 16 x 16 | 非法 |
| `CUBE_M32` | 32 x 1 | 32 x 2 | 32 x 4 | 32 x 8 | 逻辑 32 x 1，每列两个 CELL |
| `CUBE_N8` | 4 x 8 | 8 x 8 | 16 x 8 | 32 x 8 | 2 x 8，仅限 U64 |

每一项为 CELL 行数乘 CELL 列数。每一项都容纳 128 字节。

CUBE `TileInfo` 记录四个派生值：`cube_k_repeat`、`cube_n_repeat`、`cube_cell_count` 和 `cube_storage_bytes`。模型在索引之前把它们与物理形状进行核对。

<!-- PTO-READER-BLOCK: tile-model-shape-cube-cell-rules role=rules-interactions -->
## 规则与交互

存储行数与列数把有效区域向上取整到整数个 CELL：

- `CUBE_M16` 和 `CUBE_M32` 总是恰好有 16 或 32 个物理行；有效行数不得超过该值。
- `CUBE_N8` 把有效行数向上取整到 CELL 行数的倍数。
- 所有布局都把有效列数向上取整到 CELL 列数的倍数。

重复次数由物理形状得出。对 M16 和 M32，K 重复次数为列数除以 CELL 列数，N 重复次数为 1。对 N8，K 重复次数为行数除以 CELL 行数，N 重复次数为列数除以 8。物理 CELL 数为 K 重复乘 N 重复；M32 `FP64`、`S64`、`U64` 再乘二。每个 CELL 仍为 128 字节。

`TileCubeDescriptorShapeAndPhysicalLegal` 还要求容量合法、有效区域为正且位于物理形状之内，并且存储不大于容量。

设计要点：存储总是整数个 128 字节 CELL。`PTO-CUBE-CELL-STATE-001` 要求存储的推导独立于有效的 M、N 和 K，并要求在产生效果之前拒绝不受支持的类型或不足的容量。当该检查失败时，`ConfigureCubeTileForMaskWithPhysical` 在写入任何状态之前返回 FALSE。

设计要点：M16 和 M32 容纳一个物理 M 块。如源注释所述，它们的描述符可以携带比有效区域更宽的物理列包络，但 N8 保持由有效区域派生的几何。

设计要点：`CUBE_M32` 通过 double-CELL owner 接受 `FP64`、`S64` 与 `U64`：每个逻辑列使用完整低/高 CELL pair，占 256 字节。`CUBE_M16` 的 64 位元素仍非法。既有 `CUBE_N8/U64` K2 x N8 例外保持不变。

<!-- PTO-READER-BLOCK: tile-model-shape-cube-cell-boundaries role=boundaries -->
## 架构边界

在一个 CELL 内部，`TileCubeCellElementIndex` 对 N8 元素以 K 方向最快变化排序，对 M16 或 M32 元素以列方向最快变化排序。使用 4 位类型的 `CUBE_M16` 还会把内部第 4 到 7 列与第 8 到 11 列互换。

`TileCubePayloadIndex` 对 N8 以 K 重复最快变化的顺序排列 CELL，对 M16 和 M32 按列方向 CELL 排列。

`PTO-CUBE-MATRIX-SCALE-CELL-001` 规定通用网格不得把主 A、C 或 D 的合法性扩展到 M16 和 M32 之外。操作数角色规则属于矩阵合法性所有者。

<!-- PTO-READER-BLOCK: tile-model-shape-cube-cell-example role=example-usage -->
## 非规范阅读示例

一个 `CUBE_N8` FP16 Tile 的有效 K = 20 行，有效 N = 12 列。CELL 为 8 x 8。

- 存储行数把 20 向上取整为 24，存储列数把 12 向上取整为 16。
- K 重复次数为 24 / 8 = 3，N 重复次数为 16 / 8 = 2，因此共有 6 个 CELL、768 字节。

第 10 行第 9 列的元素位于 CELL K 索引 1 和 CELL N 索引 1，因此其 CELL 索引为 1 x 3 + 1 = 4。其内部位置为第 2 行第 1 列，映射为 1 x 8 + 2 = 10。载荷索引为 4 x 64 + 10 = 266。

一个有效区域为 10 乘 6 的 `CUBE_M16` FP16 Tile 有 16 行和 8 列，K 重复次数为 2，共 256 字节。

<!-- PTO-READER-BLOCK: tile-model-shape-cube-cell-related role=related-owners-navigation -->
## 相关所有者

- [分配](../state/allocation.md)通过 `ConfigureCubeTileForMaskWithPhysical` 记录 CUBE 几何。
- [有效区域](valid-region.md)拥有非 CUBE 形状检查。
- [描述符形状合法性](../legality/descriptor-shape.md)重新检查已存储的 CUBE 几何。
- [元素已定义性](../definedness/elements.md)通过 `TileCubePayloadIndex` 路由 CUBE 索引。
- [Double-CELL 几何](cube-double-cell.md)负责 M32 64 位 pairing 与 raw plane 辅助函数。
- [CUBE 目标](../../../block/model/dispatch/cube-destination.md)为矩阵操作分配 CUBE 目标。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/shape/cube-cell.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-SHAPE-CUBE-CELL","surface":"tile","classification":["model","shape","cube-cell"],"depends_on":["PTO-TILE-MODEL-SHAPE-CUBE-DOUBLE-CELL","PTO-TILE-MODEL-SHAPE-VALID-REGION"]}
// NDF-BEGIN: PTO-CUBE-CELL-STATE-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Local CUBE layouts MUST use assigned 128-byte width-parametric CELL mappings,
// derive storage independently of valid M/N/K, and reject unsupported types or
// insufficient capacity before effects; M16/M32 contain one physical M block.
// CUBE_N8/U64 retains its K2 x N8 exception; M32 b64 delegates physical
// pairing to PTO-CUBE-M32-B64-DOUBLE-CELL-001.
// NDF-END: PTO-CUBE-CELL-STATE-001

// NDF-BEGIN: PTO-CUBE-MATRIX-SCALE-CELL-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// column/K repeat fast and one 32-row physical block; partial groups are tail.
// This generic grid MUST NOT expand primary A/C/D legality beyond M16/M32.
// NDF-END: PTO-CUBE-MATRIX-SCALE-CELL-001

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
        when 64 => return 1;
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
    let cells: integer = k_repeat * n_repeat *
        TileCubePhysicalCellsPerLogicalGroup(layout, data_type);
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
    let groups = TileCubeLogicalGroupsForPhysicalCells(
        layout, data_type, cells);
    let elements: integer = groups * cell_rows * cell_columns;
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
    let cells: integer = k_repeat * n_repeat *
        TileCubePhysicalCellsPerLogicalGroup(layout, data_type);
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
    let groups = TileCubeLogicalGroupsForPhysicalCells(
        layout, data_type, cells);
    let elements: integer = groups * cell_rows * cell_columns;
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
    if tile.layout == TileLayout_CUBE_M32 &&
       TileCubeM32B64DataType(tile.data_type) then
        assert row < 32 && column < 1024;
        return TileCubeM32B64PayloadIndex(
            row as integer {0..31}, column as integer {0..1023})
            as ModelTileElementIndex;
    end;
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
