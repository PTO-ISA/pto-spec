<!-- GENERATED FROM: asl/block/model/dispatch/generation-schema.asl -->
# Generation Schema

**Normative ASL source:** `asl/block/model/dispatch/generation-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-GENERATION-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-generation-schema-purpose role=purpose-scope -->
## 用途与范围

本单元是两种生成操作 `TCI` 和 `TTRI` 的封闭指令束 schema。生成操作只根据标量参数写出新 Tile：`TCI` 写出索引序列，`TTRI` 写出由 1 和 0 组成的三角图样。两者都不读取数值源 Tile。

它定义了三个函数：

- `TileOperationUsesClosedGenerationSchema` 选择 `TCI` 和 `TTRI`。
- `SelectedBundleGenerationDimensionsLegal` 针对所选操作检查 `B.DIM` 值。
- `SelectedBundleClosedGenerationSchemaLegal` 检查整个指令束。

<!-- PTO-READER-BLOCK: block-model-dispatch-generation-schema-concepts role=concepts-state -->
## 概念与可见状态

本单元只读取状态，自身不引发故障。

- `_BundleDimensions` 和 `_BundleDimensionPresent` 给出 `LB0`（有效列数）、`LB1`（有效行数）和 `LB2`（物理列数），以及每个维度是否被编码。未编码的维度保持清除指令束头状态时写入的值 1。
- `_BundleTileBindings` 的绑定 0 携带目标、其大小码、可选的掩码源以及 `last` 标志。
- `_BundleExecutionMask` 表明是否有生效的谓词 Tile ExecutionMask。
- 操作 `DataType` 和布局来自 `BSTART` 编码和 `B.DATR`。

<!-- PTO-READER-BLOCK: block-model-dispatch-generation-schema-rules role=rules-interactions -->
## 规则与交互

两种操作的指令束都必须恰好有一个 Local Tile 绑定，且没有 Shared 绑定。该绑定有一个尚未由指令束分配的目标、合法的大小码、没有 `source1`，并带有 `last` 标志。它恰好在谓词 Tile ExecutionMask 生效时携带 `source0`，此时掩码序号必须为 0。

设计要点：生成操作没有数据源，因此唯一可能的 Tile 输入就是掩码。所以该 schema 把掩码放在唯一绑定的 `source0` 中，而不要求第二个绑定。

`TCI` 接受 `S32`、`S16`、`U32` 和 `U16`，形状规则如下：

- `LB0` 必须被编码，且在 1 到 65535 之间。
- 在 `RowMajor` 中，省略 `LB2` 时 `Col` 等于有效列数。在 `CUBE_M16` 和 `CUBE_M32` 中，它选择按该类型的单元列数向上取整后的有效列数。
- `LB1` 和得到的 `Col` 必须在范围内，且 `Col` 至少等于有效列数。
- `RowMajor` 要求恰好 1 个有效行。
- `CUBE_M16` 最多允许 16 个有效行。两种 CUBE 布局都要求 `Col` 是单元列数的倍数，没有单元列数的类型会被拒绝。

`TTRI` 只在 `RowMajor` 中接受 `FP32`、`FP16`、`S32`、`S16`、`U32` 和 `U16`。`LB0` 必须在 1 到 65535 之间，`LB1` 在 1 到 65535 之间，`Col`（来自 `LB2`，省略时为有效列数）必须至少等于有效列数且不超过 65535。

设计要点：该 schema 返回假，而不是直接引发故障。本地 Tile 执行路径通过 `SelectedBundleClosedSchemasLegal` 求值它，失败时引发 `Fault_TileLegality`，之后才解析目标。因此被拒绝的生成指令束不会分配任何内容。

<!-- PTO-READER-BLOCK: block-model-dispatch-generation-schema-boundaries role=boundaries -->
## 架构边界

本单元不检查标量参数。`B.IOR` 字段布局由[标量 schema](scalar-schema.md)检查；对于 CUBE `TCI`，它还拒绝超出 -1、0 和 1 的 Step2D 行步长或列步长。生成的值和三角规则由 Tile 生成执行模型负责。

<!-- PTO-READER-BLOCK: block-model-dispatch-generation-schema-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

考虑 `RowMajor` 中的 `TCI <Row=1, Col=64, U32>, ->T<256B>`，Start 和 Direction 保持默认值。之所以写出 `Row`，是因为 TCI 从编码的 `ValidRow` 推导它。该指令束用 `LB0=64` 携带 `ValidCol`；`LB1` 和 `LB2` 要么省略，要么编码为 1 和 64，两种情况下 schema 都读到 1 个有效行，并得到 `Col` = 64。256B 的目标容纳 64 个 `U32` 元素。

如果 `B.DATR` 选择 `CUBE_M16`，类型为 `U16`，`LB0=3`、`LB1=2` 且省略 `LB2`，则单元列数为 4，因此 `Col` 为 3 向上取整到 4。显式的 `LB2=6` 会失败，因为 6 不是 4 的倍数。

<!-- PTO-READER-BLOCK: block-model-dispatch-generation-schema-related role=related-owners-navigation -->
## 相关所有者

- [Tile 执行分派](tile-execution.md)在目标解析之前把此谓词与其他封闭 schema 组合。
- [目标操作](destination-operation.md)根据指令束维度决定生成目标的形状。
- [Tile 生成执行](../../../tile/model/execution/generation.md)负责支持的类型集合和生成的值。
- [TCI](../../../tile/irregular-and-complex/initialization/TCI.md) 和 [TTRI](../../../tile/irregular-and-complex/initialization/TTRI.md) 是对应的指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/generation-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-GENERATION-SCHEMA","surface":"block","classification":["model","dispatch","generation-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA","PTO-TILE-MODEL-EXECUTION-GENERATION"]}
pure func TileOperationUsesClosedGenerationSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TCI ||
           decoded == TileOperation_TTRI;
end;

readonly func SelectedBundleGenerationDimensionsLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    if decoded == TileOperation_TCI then
        if !_BundleDimensionPresent[[0]] ||
           UInt(_BundleDimensions[[0]]) < 1 ||
           UInt(_BundleDimensions[[0]]) > 65535 then
            return FALSE;
        end;
        let data_type = TileDataTypeFromEncoding(
            CurrentBundleTileOperationDataTypeCode()
                as TileDataTypeEncoding);
        if !TileTCIDataTypeSupported(data_type) then return FALSE; end;
        let layout = CurrentBundleTileLayout();
        let valid_columns = UInt(_BundleDimensions[[0]])
            as integer {1..65535};
        let valid_rows = UInt(_BundleDimensions[[1]]);
        let columns = if _BundleDimensionPresent[[2]] then
            UInt(_BundleDimensions[[2]])
        else if layout == TileLayout_CUBE_M16 ||
              layout == TileLayout_CUBE_M32 then
            TileCubeAlignedExtent(valid_columns,
                TileCubeCellColumns(layout, data_type) as integer {1..65535})
        else
            valid_columns;
        if valid_rows < 1 || valid_rows > 65535 ||
           columns < valid_columns || columns > 65535 then
            return FALSE;
        end;
        if layout == TileLayout_CUBE_M16 then
            if valid_rows > 16 then return FALSE; end;
            let cell_columns = TileCubeCellColumns(layout, data_type);
            if cell_columns == 0 then return FALSE; end;
            return columns MOD (cell_columns as integer {1..65535}) == 0;
        elsif layout == TileLayout_CUBE_M32 then
            let cell_columns = TileCubeCellColumns(layout, data_type);
            if cell_columns == 0 then return FALSE; end;
            return columns MOD (cell_columns as integer {1..65535}) == 0;
        end;
        return layout == TileLayout_RowMajor && valid_rows == 1;
    end;
    if decoded != TileOperation_TTRI then
        return FALSE;
    end;
    let valid_columns = UInt(_BundleDimensions[[0]]);
    let columns = if _BundleDimensionPresent[[2]] then
        UInt(_BundleDimensions[[2]])
    else
        valid_columns;
    if valid_columns < 1 || valid_columns > 65535 ||
       columns < valid_columns || columns > 65535 then
        return FALSE;
    end;
    return UInt(_BundleDimensions[[1]]) >= 1 &&
           UInt(_BundleDimensions[[1]]) <= 65535;
end;

readonly func SelectedBundleClosedGenerationSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedGenerationSchema(operation) then
        return TRUE;
    end;
    if BundleTileBindingCount() != 1 ||
       BundleSharedBindingCount() != 0 then
        return FALSE;
    end;

    let binding = _BundleTileBindings[[0]];
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    if !binding.destination_valid ||
       binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(0) ||
       (binding.source0_valid != execution_mask_tile) ||
       binding.source1_valid ||
       (execution_mask_tile &&
        _BundleExecutionMask.predicate_source_ordinal != 0) ||
       !binding.last then
        return FALSE;
    end;
    if !SelectedBundleGenerationDimensionsLegal(operation) then
        return FALSE;
    end;

    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode()
            as TileDataTypeEncoding);
    let decoded = TileOperationOfIndex(operation);
    let data_type_legal = if decoded == TileOperation_TCI then
        TileTCIDataTypeSupported(data_type)
    else
        TileTTRIDataTypeSupported(data_type);
    let layout = CurrentBundleTileLayout();
    return data_type_legal &&
           (layout == TileLayout_RowMajor ||
            (decoded == TileOperation_TCI &&
             (layout == TileLayout_CUBE_M16 ||
              layout == TileLayout_CUBE_M32)));
end;
```
<!-- GENERATED-ASL-END: unit -->
