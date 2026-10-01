<!-- GENERATED FROM: asl/block/model/dispatch/expansion-schema.asl -->
# Expansion Schema

**Normative ASL source:** `asl/block/model/dispatch/expansion-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-EXPANSION-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-expansion-schema-purpose role=purpose-scope -->
## 用途与范围

本单元是十六种行扩展和列扩展的封闭指令束 schema。扩展从广播 Tile 中为每行（行形式）或每列（列形式）取一个值，并把它广播到整个矩形。封闭 schema 是该操作族的指令束可以携带的绑定、维度、类型和布局的完整清单。

它定义了以下分类器和一个合法性谓词：

- `TileOperationUsesClosedRowExpansionSchema` 选择 `TROWEXPAND` 以及七个 `TROWEXPAND*` 形式（ADD、SUB、MUL、DIV、MAX、MIN、EXPDIF）。
- `TileOperationUsesClosedColumnExpansionSchema` 选择对应的八个 `TCOLEXPAND` 形式。
- `TileExpansionOperationIsCopy` 选择两个纯复制形式 `TROWEXPAND` 和 `TCOLEXPAND`，它们没有全形状源。
- `TileExpansionOperationIsExponentialDifference` 选择两个 EXPDIF 形式。
- `SelectedBundleClosedExpansionSchemaLegal` 检查完整的指令束。

<!-- PTO-READER-BLOCK: block-model-dispatch-expansion-schema-concepts role=concepts-state -->
## 概念与可见状态

本单元只读取状态，自身不引发故障。

- `_BundleDimensions` 给出 `LB0`（有效列数）、`LB1`（有效行数）和 `LB2`（物理列数）。
- `_BundleTileBindings` 提供全形状源（操作绑定的 `source0`）、广播源和目标。
- `_BundleExecutionMask` 表明是否有生效的 ExecutionMask，以及其载体是 GPR 还是谓词 Tile。
- `_BundleScalarBindings` 的索引 0 必须恰好在掩码载体为 GPR 时存在。
- `_Tiles` 提供两个源的描述符和元素值。

对于复制形式，广播 Tile 是 `source0`；其他形式中它是操作绑定的 `source1`。

<!-- PTO-READER-BLOCK: block-model-dispatch-expansion-schema-rules role=rules-interactions -->
## 规则与交互

绑定流取决于操作和掩码载体：

| 情形 | 绑定数 | 形状 |
| --- | --- | --- |
| 无掩码或 GPR 掩码 | 1 | 复制：`source0` 和目标，无 `source1`；其他：`source0`、`source1`、目标、`last` |
| 谓词 Tile 掩码，复制 | 1 | `source0`、作为 `source1` 的掩码、目标；掩码序号 1 |
| 谓词 Tile 掩码，其他形式 | 2 | 绑定 0：两个源、无目标、不带 `last`；绑定 1：作为 `source0` 的掩码、目标、`last`；掩码序号 2 |

在所有情形中，目标都不能已由指令束分配，其大小码必须合法，不存在 Shared 绑定，三个维度都在 1 到 65535 之间。GPR 掩码还必须通过 `BundleExecutionMaskGPRBindingSchemaLegal`。

类型和布局规则如下：

- 数据类型属于向量算术集合。EXPDIF 形式改为从 `SelectedBundleExponentialDifferenceTypes` 取得源类型和目标类型，该函数必须报告合法的类型对。
- 布局为 `RowMajor`、`CUBE_M16` 或 `CUBE_M32`。广播 Tile 以及非复制形式的全形状源都使用同一布局。
- 行广播的 `valid_rows` 等于 `LB1`，且至少有一个有效列。列广播的 `valid_columns` 等于 `LB0`，且至少有一个有效行。
- 对于非复制形式，全形状源必须与 `LB0`、`LB1` 和 `LB2` 匹配，在其活跃坐标上已定义，并在这些坐标上持有源操作类型的有效编码。
- 对于整数类型的 `TROWEXPANDDIV` 和 `TCOLEXPANDDIV`，为源坐标读取的每个广播值都必须已定义且非零；在 ExecutionMask 下只计入活跃坐标。

设计要点：复制形式在关闭编码校验的情况下检查广播元素，只要求宽度兼容的载体。其他形式会用广播值进行计算，因此按源操作类型校验每个被消费的广播编码。

设计要点：整数零除数检查是 schema 的一部分。它在目标解析之前运行，因此零除数会引发 `Fault_TileLegality`，且不会留下新分配的 Tile。

<!-- PTO-READER-BLOCK: block-model-dispatch-expansion-schema-boundaries role=boundaries -->
## 架构边界

本单元不计算扩展，也不分配目标。目标形状由[目标操作](destination-operation.md)决定：所有形式都从 `LB0` 和 `LB1` 取得目标有效列数和有效行数，EXPDIF 形式还从 EXPDIF 类型对取得目标类型。CUBE 布局下的广播槽选择以及逐坐标的已定义性检查由 Tile 归约与扩展合法性负责。

<!-- PTO-READER-BLOCK: block-model-dispatch-expansion-schema-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

考虑 `TROWEXPANDADD <Row=8, Col=64, FP32>, T#1, T#2, ->T<2KB>`。`T#1` 是全形状源，有 8 个有效行以及 64 个有效列和物理列。`T#2` 是行广播源，有 8 个有效行。在 `RowMajor` 中，第 r 行的广播值是第 r 行的第 0 列。一个 `B.IOT` 携带两个源、目标和 `last`。

当两个 Tile 都是具有上述形状的已定义 `RowMajor` `FP32` Tile 时，schema 检查通过。2KB 的目标容纳 8 x 64 = 512 个 `FP32` 元素。如果 `T#2` 只有 7 个有效行，广播形状检查会失败，指令束会引发 `Fault_TileLegality`。

<!-- PTO-READER-BLOCK: block-model-dispatch-expansion-schema-related role=related-owners-navigation -->
## 相关所有者

- [Tile 执行分派](tile-execution.md)在目标解析之前把此谓词与其他封闭 schema 一起求值。
- [EXPDIF schema](expdif-schema.md)选择 EXPDIF 的源类型和目标类型。
- [标量 schema](scalar-schema.md)定义 GPR ExecutionMask 绑定检查。
- [归约与扩展合法性](../../../tile/model/legality/reduction-and-expansion.md)负责广播和源的合法性。
- [TROWEXPANDADD](../../../tile/reduce-and-expand/row-expansion/TROWEXPANDADD.md) 是使用此 schema 的一个指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/expansion-schema.asl -->
```asl
// PTO-UNIT: {"classification":["model","dispatch","expansion-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-EXPDIF-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA","PTO-TILE-MODEL-LEGALITY-REDUCTION-AND-EXPANSION"],"id":"PTO-BLOCK-MODEL-DISPATCH-EXPANSION-SCHEMA","surface":"block"}

pure func TileOperationUsesClosedRowExpansionSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TROWEXPAND ||
           decoded == TileOperation_TROWEXPANDADD ||
           decoded == TileOperation_TROWEXPANDSUB ||
           decoded == TileOperation_TROWEXPANDMUL ||
           decoded == TileOperation_TROWEXPANDDIV ||
           decoded == TileOperation_TROWEXPANDMAX ||
           decoded == TileOperation_TROWEXPANDMIN ||
           decoded == TileOperation_TROWEXPANDEXPDIF;
end;

pure func TileOperationUsesClosedColumnExpansionSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TCOLEXPAND ||
           decoded == TileOperation_TCOLEXPANDADD ||
           decoded == TileOperation_TCOLEXPANDSUB ||
           decoded == TileOperation_TCOLEXPANDMUL ||
           decoded == TileOperation_TCOLEXPANDDIV ||
           decoded == TileOperation_TCOLEXPANDMAX ||
           decoded == TileOperation_TCOLEXPANDMIN ||
           decoded == TileOperation_TCOLEXPANDEXPDIF;
end;

pure func TileOperationUsesClosedExpansionSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationUsesClosedRowExpansionSchema(operation) ||
           TileOperationUsesClosedColumnExpansionSchema(operation);
end;

pure func TileExpansionOperationIsCopy(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TROWEXPAND ||
           decoded == TileOperation_TCOLEXPAND;
end;

pure func TileExpansionOperationIsExponentialDifference(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TROWEXPANDEXPDIF ||
           decoded == TileOperation_TCOLEXPANDEXPDIF;
end;

readonly func SelectedBundleExpansionBroadcastShapeMatches(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1},
    broadcast: TileIndex) => boolean
begin
    let valid_columns = UInt(_BundleDimensions[[0]]);
    let valid_rows = UInt(_BundleDimensions[[1]]);
    if TileOperationUsesClosedRowExpansionSchema(operation) then
        return _Tiles[[broadcast]].valid_rows == valid_rows &&
               _Tiles[[broadcast]].valid_columns >= 1;
    end;
    return _Tiles[[broadcast]].valid_rows >= 1 &&
           _Tiles[[broadcast]].valid_columns == valid_columns;
end;

readonly func SelectedBundleClosedExpansionSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedExpansionSchema(operation) then
        return TRUE;
    end;
    let execution_mask_gpr = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_GPR;
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    let copy = TileExpansionOperationIsCopy(operation);
    let split_final_binding = execution_mask_tile && !copy;
    if BundleTileBindingCount() != (if split_final_binding then 2 else 1) ||
       BundleSharedBindingCount() != 0 ||
       (_BundleScalarBindings[[0]].valid != execution_mask_gpr) ||
       (execution_mask_gpr &&
        !BundleExecutionMaskGPRBindingSchemaLegal(operation)) ||
       !SelectedBundleComparisonDimensionsLegal() then
        return FALSE;
    end;

    let binding = _BundleTileBindings[[0]];
    let final_binding = if split_final_binding then
        _BundleTileBindings[[1]] else binding;
    if BundleTileBindingCount() != (if split_final_binding then 2 else 1) ||
       !final_binding.destination_valid ||
       final_binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(
           if split_final_binding then 1 else 0) ||
       !binding.source0_valid ||
       (if copy then
            binding.source1_valid != execution_mask_tile
        else if split_final_binding then
            !binding.source1_valid || binding.destination_valid || binding.last ||
            final_binding.source0_valid != execution_mask_tile ||
            final_binding.source1_valid || !final_binding.last
        else
            !binding.source1_valid || !binding.last) ||
       (execution_mask_tile &&
        _BundleExecutionMask.predicate_source_ordinal !=
            (if copy then 1 else 2)) then
        return FALSE;
    end;

    let operation_sources = if split_final_binding then
        binding else final_binding;
    let broadcast = if copy then
        binding.source0 else operation_sources.source1;
    let axis = if TileOperationUsesClosedRowExpansionSchema(operation) then
        TileAxis_Row else TileAxis_Column;
    var data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode()
            as TileDataTypeEncoding);
    let expdif = TileExpansionOperationIsExponentialDifference(operation);
    var source_data_type = data_type;
    if expdif then
        let (types_legal, selected_source_type, selected_destination_type) =
            SelectedBundleExponentialDifferenceTypes();
        if !types_legal then
            return FALSE;
        end;
        source_data_type = selected_source_type;
        data_type = selected_destination_type;
    end;
    if (!expdif && !TileVecArithmeticDataTypeSupported(data_type)) ||
       !TileReductionAndExpansionLayoutSupported(
           CurrentBundleTileLayout()) ||
       _Tiles[[broadcast]].layout != CurrentBundleTileLayout() ||
       !(if copy then
             TileExpansionBroadcastElementsLegalAs(
                 broadcast, axis, source_data_type, FALSE) &&
             TileCarrierWidthCompatible(
                 _Tiles[[broadcast]].data_type, source_data_type)
         else TileExpansionBroadcastLegalAs(
             broadcast, axis, source_data_type)) ||
       !SelectedBundleExpansionBroadcastShapeMatches(
           operation, broadcast) then
        return FALSE;
    end;

    if copy then
        return TRUE;
    end;
    return _Tiles[[operation_sources.source0]].layout == CurrentBundleTileLayout() &&
           TileReductionAndExpansionSourceLegalAs(
               operation_sources.source0, source_data_type) &&
           SelectedBundleComparisonShapeMatches(operation_sources.source0) &&
           ((TileOperationOfIndex(operation) != TileOperation_TROWEXPANDDIV &&
             TileOperationOfIndex(operation) != TileOperation_TCOLEXPANDDIV) ||
            !TileDataTypeIsInteger(data_type) ||
            TileExpansionBroadcastNonzero(
                axis,
                operation_sources.source0,
                operation_sources.source1,
                source_data_type));
end;
```
<!-- GENERATED-ASL-END: unit -->
