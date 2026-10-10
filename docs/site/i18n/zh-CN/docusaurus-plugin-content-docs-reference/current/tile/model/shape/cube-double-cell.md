<!-- GENERATED FROM: asl/tile/model/shape/cube-double-cell.asl -->
# CUBE Double Cell

**Normative ASL source:** `asl/tile/model/shape/cube-double-cell.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-SHAPE-CUBE-DOUBLE-CELL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-shape-cube-double-cell-purpose role=purpose-scope -->
## 目的与范围

本单元定义 Local `CUBE_M32` Tile 在元素类型为 `FP64`、`S64` 或 `U64` 时使用的 double-CELL 表示。它保留 32 个逻辑行以及每个逻辑元素一个 64 位 `Word`，同时为每个逻辑列计入两个有序的 128 字节 CELL。

<!-- PTO-READER-BLOCK: tile-model-shape-cube-double-cell-concepts role=concepts-state -->
## 概念与可见状态

对于逻辑列 `c`，物理 CELL `2*c` 保存第 0 至 31 行的低 32 位 word，CELL `2*c+1` 保存相同行的高 32 位 word。在任一 CELL 内，word 索引就是逻辑行。因此一个逻辑列占用 256 字节。

Tile payload 仍按逻辑元素组织：`TileCubeM32B64PayloadIndex(row, column)` 以 `column * 32 + row` 选择一个 64 位元素。成对 CELL 描述物理存储、传输、subview 与 generation 范围；它们不会把一个架构元素拆成两个 payload 元素。

<!-- PTO-READER-BLOCK: tile-model-shape-cube-double-cell-rules role=rules-interactions -->
## 规则与交互

`TileCubeLayoutDataTypeSupported` 只允许 `CUBE_M32` 搭配 `FP64`、`S64` 或 `U64` 的 64 位元素，同时保留独立的 `CUBE_N8/U64` 例外。所有 64 位类型在 `CUBE_M16` 中仍非法。

`TileCubePhysicalCellsPerLogicalGroup` 对 M32 64 位形式返回二，其他形式返回一。因此物理偏移与数量必须从完整 pair 开始并在完整 pair 结束。辅助函数把完整物理 CELL 数换回逻辑列组，并把行列映射到低平面或高平面的字节偏移。

raw 辅助函数提取或替换 64 位值的一个 32 位半部。它们支持按 word 的 pack、unpack、shuffle、transport 与 mask 路径，同时保持普通操作对完整 64 位逻辑元素使用一个掩码位的规则。

<!-- PTO-READER-BLOCK: tile-model-shape-cube-double-cell-boundaries role=boundaries -->
## 架构边界

本单元只定义几何与 raw 半 word 访问。操作种类合法性仍决定 `FP64`、`S64`、`U64` 或 raw b64 载体是否适用。Matrix/MX 类型集、固定宽度原子操作、窄转换 tuple 与 `TGPR2T` 保持各自排除规则。

Subview、generation、transport 与 publication 边界不得只暴露 pair 中的一个 CELL。既有 raw pack/unpack 逐 word 掩码例外可以分别控制低、高 raw word；其他 ExecutionMask 使用者对完整 64 位逻辑元素使用一个活动位。

<!-- PTO-READER-BLOCK: tile-model-shape-cube-double-cell-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL owner，不替代规范规则。

具有两个逻辑列的 `CUBE_M32 U64` Tile 包含四个物理 CELL，需要 512 字节。CELL 0 和 1 是列 0 的低、高平面；CELL 2 和 3 是列 1 的两个平面。第 7 行第 1 列是一个逻辑 64 位 payload 值，其低半部位于 CELL 2 word 7，高半部位于 CELL 3 word 7。

<!-- PTO-READER-BLOCK: tile-model-shape-cube-double-cell-related role=related-owners-navigation -->
## 相关 owner

- [CUBE CELL 几何](cube-cell.md)根据 pairing factor 推导描述符数量与容量。
- [数据类型与布局合法性](../legality/dtype-layout.md)定义操作适用性。
- [Subview 描述符](../../../block/model/operands/subview-descriptor.md)要求完整 pair 范围。
- [Local CUBE generation](../../../block/model/operands/local-generation-cube.md)完成成对 writer extent 的最终化。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/shape/cube-double-cell.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-SHAPE-CUBE-DOUBLE-CELL","surface":"tile","classification":["model","shape","cube-double-cell"],"depends_on":["PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES","PTO-ARCH-FEATURES-TILE-ALLOCATION"]}
// NDF-BEGIN: PTO-CUBE-M32-B64-DOUBLE-CELL-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Local CUBE_M32 FP64, S64, and U64 storage MUST retain 32 logical rows and
// one Word payload per logical element while charging two ordered 128-byte
// CELLs per logical column. CELL 2*c carries low words and CELL 2*c+1 carries
// high words, with word index equal to row. Views and publications MUST begin
// and end on complete pairs; M16 b64 remains illegal and N8/U64 is unchanged.
// NDF-END: PTO-CUBE-M32-B64-DOUBLE-CELL-001

pure func TileLayoutIsCube(layout: TileLayout) => boolean
begin
    return layout == TileLayout_CUBE_M16 ||
           layout == TileLayout_CUBE_M32 ||
           layout == TileLayout_CUBE_N8;
end;

pure func TileCubeM32B64DataType(data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP64 ||
           data_type == TileDataType_S64 ||
           data_type == TileDataType_U64;
end;

pure func TileCubeDataTypeSupported(data_type: TileDataType) => boolean
begin
    return TileElementBits(data_type) != 64 ||
           TileCubeM32B64DataType(data_type);
end;

pure func TileCubeLayoutDataTypeSupported(
    layout: TileLayout, data_type: TileDataType) => boolean
begin
    if TileElementBits(data_type) != 64 then
        return TileCubeDataTypeSupported(data_type);
    end;
    return (layout == TileLayout_CUBE_M32 &&
            TileCubeM32B64DataType(data_type)) ||
           (layout == TileLayout_CUBE_N8 &&
            data_type == TileDataType_U64);
end;

pure func TileCubePhysicalCellsPerLogicalGroup(
    layout: TileLayout, data_type: TileDataType) => integer {1..2}
begin
    if layout == TileLayout_CUBE_M32 &&
       TileCubeM32B64DataType(data_type) then return 2; end;
    return 1;
end;

pure func TileCubePhysicalCellRangeComplete(
    layout: TileLayout, data_type: TileDataType,
    offset_cells: integer, cell_count: integer) => boolean
begin
    let factor = TileCubePhysicalCellsPerLogicalGroup(layout, data_type);
    return offset_cells >= 0 && cell_count > 0 &&
           offset_cells MOD factor == 0 && cell_count MOD factor == 0;
end;

pure func TileCubeLogicalGroupsForPhysicalCells(
    layout: TileLayout, data_type: TileDataType,
    cell_count: integer) => integer
begin
    let factor = TileCubePhysicalCellsPerLogicalGroup(layout, data_type);
    assert cell_count >= 0 && cell_count MOD factor == 0;
    return cell_count DIVRM factor;
end;

pure func TileCubeM32B64PlaneCellIndex(
    column: integer {0..1023}, high_plane: boolean) => integer {0..2047}
begin
    return (column * 2 + (if high_plane then 1 else 0))
        as integer {0..2047};
end;

pure func TileCubeM32DoubleCellIndex(
    column: integer {0..8191}, high_plane: boolean) => integer {0..16383}
begin
    return (column * 2 + (if high_plane then 1 else 0))
        as integer {0..16383};
end;

pure func TileCubeM32B64PlaneWordIndex(
    row: integer {0..31}) => integer {0..31}
begin
    return row;
end;

pure func TileCubeM32DoubleCellWord(
    row: integer {0..31}) => integer {0..31}
begin
    return row;
end;

pure func TileCubeM32DoubleCellLogical(
    cell: integer {0..16383}, word: integer {0..31})
    => (integer {0..8191}, integer {0..31}, boolean)
begin
    return ((cell DIVRM 2) as integer {0..8191}, word, cell MOD 2 == 1);
end;

pure func TileCubeM32B64PlaneByteOffset(
    row: integer {0..31}, column: integer {0..1023},
    high_plane: boolean) => integer {0..262143}
begin
    return (TileCubeM32B64PlaneCellIndex(column, high_plane) *
            PTO_TILE_CELL_BYTES + TileCubeM32B64PlaneWordIndex(row) * 4)
        as integer {0..262143};
end;

pure func TileCubeM32B64RawPlaneWord(
    value: Word, high_plane: boolean) => bits(32)
begin
    return if high_plane then value[63:32] else value[31:0];
end;

pure func TileCubeM32B64WithRawPlaneWord(
    value: Word, raw: bits(32), high_plane: boolean) => Word
begin
    var result = value;
    if high_plane then result[63:32] = raw;
    else result[31:0] = raw;
    end;
    return result;
end;

pure func TileCubeM32B64PayloadIndex(
    row: integer {0..31}, column: integer {0..1023})
    => integer {0..32767}
begin
    return (column * 32 + row) as integer {0..32767};
end;
```
<!-- GENERATED-ASL-END: unit -->
