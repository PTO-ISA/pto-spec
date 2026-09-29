<!-- GENERATED FROM: asl/tile/model/ordering/sorting.asl -->
# Sorting

**Normative ASL source:** `asl/tile/model/ordering/sorting.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-ORDERING-SORTING}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-ordering-sorting-purpose role=purpose-scope -->
## 用途与范围

本单元为浮点 Tile 值定义一个排序关系，以及建立在其上的若干谓词。该关系说明在已排序序列中，左值何时可以保持在右值之前。

在当前 ASL 中，没有其他单元调用这些辅助函数。`TSORT` 和 `TMRGSORT` 操作已由 ADR-TILE-0013 退役，它们的名称现在出现在 Tile 目录的 `deleted_names` 列表中。请把本页视为这些辅助函数的定义，而不是一条现行指令的定义。

<!-- PTO-READER-BLOCK: tile-model-ordering-sorting-concepts role=concepts-state -->
## 概念与可见状态

本单元不声明状态。它定义六个辅助函数：

- `TileSortDataTypeSupported` 只对 FP32 和 FP16 为 TRUE。
- 当值的数值类别为 `NumericValue_SignalingNaN` 时，`TileSortValueIsSignalingNaN` 为 TRUE。
- `TileSortLeftBefore(left, right, descending, data_type)` 是排序关系。
- `TileSortSourceValuesLegal` 要求源 Tile 已定义且其所有编码有效。
- `TileSortSourceHasSignalingNaN` 在有效区域中扫描 signaling NaN。
- `TileSortSequenceOrdered` 检查 Tile 的第 0 行是否有序。

<!-- PTO-READER-BLOCK: tile-model-ordering-sorting-rules role=rules-interactions -->
## 规则与交互

`TileSortLeftBefore` 按以下顺序判断：

1. 如果 `left` 是 NaN，只有当 `right` 也是 NaN 时结果才为 TRUE。
2. 如果只有 `right` 是 NaN，结果为 TRUE。
3. 如果两个值都是零，或者两个字完全相同，结果为 TRUE。
4. 否则两个值都通过 `TileFloatingOrderKey` 映射，并作为无符号整数比较：升序用 `<`，降序用 `>`。

`TileFloatingOrderKey` 把负值的所有位取反，并为非负值设置符号位。于是键的无符号顺序遵循非 NaN 值的数值顺序（包括无穷大），并把 `-0` 排在 `+0` 之下紧邻的位置；第 3 条规则在比较键之前就处理了两个零的情况。

设计要点：在两个方向上，NaN 都排在每个数之后。降序标志只改变第 4 步，因此 NaN 的位置不会翻转。ASL 注释说明两个 NaN 保持其输入顺序。

设计要点：相等的值和带符号的零返回 TRUE。比较相等的一对永远不会被报告为乱序，因此 `-0` 和 `+0` 可以以任一顺序出现。

第 1 步和第 2 步使用 `NumericValueClassIsNaN`，它对 quiet NaN 和 signaling NaN 都为 TRUE。ASL 中的注释提到的是 quiet NaN；`TileSortSourceHasSignalingNaN` 是查找 signaling NaN 的独立辅助函数。

<!-- PTO-READER-BLOCK: tile-model-ordering-sorting-boundaries role=boundaries -->
## 架构边界

当有效列数至多为 1 时，`TileSortSequenceOrdered` 返回 TRUE。否则它检查第 0 行的每对相邻元素，不查看其他行。这些辅助函数不做分配、不写任何 Tile，也不引发故障。

本单元不定义排序指令、其操作数、其稳定性或其索引输出。这些属于已退役的 `TSORT` 所有者。

<!-- PTO-READER-BLOCK: tile-model-ordering-sorting-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 FP32 第 0 行为 `-2.0`、`-0.0`、`+0.0`、`3.0`、`NaN`。在升序下，每对相邻元素都满足该关系：`-2.0` 按键排在 `-0.0` 之前，两个零按第 3 条规则，`+0.0` 按键排在 `3.0` 之前，`3.0` 按第 2 条规则排在 `NaN` 之前。`TileSortSequenceOrdered` 返回 TRUE。设置 `descending` 后，同一行在第一对就失败，因为 `-2.0` 的键小于 `-0.0` 的键。

<!-- PTO-READER-BLOCK: tile-model-ordering-sorting-related role=related-owners-navigation -->
## 相关所有者

- [比较](../execution/comparison.md)拥有 `TileFloatingOrderKey`。
- [数值格式](../numeric/formats.md)拥有数值类别划分。
- [顶层分派](../dispatch/top-level.md)把 `TSORT` 和 `TMRGSORT` 记录为已删除名称。
- [元素已定义性](../definedness/elements.md)拥有源编码检查。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/ordering/sorting.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-ORDERING-SORTING","surface":"tile","classification":["model","ordering","sorting"],"depends_on":["PTO-TILE-MODEL-EXECUTION-COMPARISON"]}

pure func TileSortDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP32 ||
           data_type == TileDataType_FP16;
end;

pure func TileSortValueIsSignalingNaN(
    data_type: TileDataType,
    value: Word) => boolean
begin
    return TileNumericValueClass(data_type, value) ==
        NumericValue_SignalingNaN;
end;

pure func TileSortLeftBefore(
    left: Word,
    right: Word,
    descending: boolean,
    data_type: TileDataType) => boolean
begin
    let left_class = TileNumericValueClass(data_type, left);
    let right_class = TileNumericValueClass(data_type, right);
    let left_nan = NumericValueClassIsNaN(left_class);
    let right_nan = NumericValueClassIsNaN(right_class);

    // Every numeric value precedes every quiet NaN in both directions.
    // Two NaNs retain their incoming order.
    if left_nan then
        return right_nan;
    elsif right_nan then
        return TRUE;
    end;

    let both_zero =
        NumericValueClassIsZero(left_class) &&
        NumericValueClassIsZero(right_class);
    if both_zero || left == right then
        return TRUE;
    end;

    let left_key = TileFloatingOrderKey(data_type, left);
    let right_key = TileFloatingOrderKey(data_type, right);
    if descending then
        return UInt(left_key) > UInt(right_key);
    end;
    return UInt(left_key) < UInt(right_key);
end;

readonly func TileSortSourceValuesLegal(
    source: TileIndex) => boolean
begin
    return TileSourceContentsDefined(source) &&
           TileSourceEncodingsValid(source);
end;

readonly func TileSortSourceHasSignalingNaN(
    source: TileIndex) => boolean
begin
    let source_tile = _Tiles[[source]];
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(
                source_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            if TileSortValueIsSignalingNaN(
                   source_tile.data_type,
                   TileReadLogicalElement(source_tile, element)) then
                return TRUE;
            end;
        end;
    end;
    return FALSE;
end;

readonly func TileSortSequenceOrdered(
    source: TileIndex,
    descending: boolean) => boolean
begin
    let source_tile = _Tiles[[source]];
    if source_tile.valid_columns <= 1 then
        return TRUE;
    end;

    for column = 0 to source_tile.valid_columns - 2 looplimit 65536 do
        let left_element = TileLogicalLinearIndex(
            source_tile,
            0,
            column as integer {0..65535});
        let right_element = TileLogicalLinearIndex(
            source_tile,
            0,
            (column + 1) as integer {0..65535});
        if !TileSortLeftBefore(
               TileReadLogicalElement(source_tile, left_element),
               TileReadLogicalElement(source_tile, right_element),
               descending,
               source_tile.data_type) then
            return FALSE;
        end;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
