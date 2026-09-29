<!-- GENERATED FROM: asl/block/model/dispatch/reduction-schema.asl -->
# Reduction Schema

**Normative ASL source:** `asl/block/model/dispatch/reduction-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-REDUCTION-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-reduction-schema-purpose role=purpose-scope -->
## 用途与范围

本单元是十二种 Tile 归约的封闭指令束 schema。封闭 schema 是一张完整清单，列出某一操作族的指令束可以携带的操作数绑定、维度、类型和布局；清单之外的任何内容都会被拒绝。

它定义了三个分类器和一个合法性谓词：

- `TileOperationUsesClosedRowReductionSchema` 选择 `TROWSUM`、`TROWPROD`、`TROWMIN`、`TROWMAX`、`TROWARGMIN` 和 `TROWARGMAX`。
- `TileOperationUsesClosedColumnReductionSchema` 选择对应的六个 `TCOL*` 操作。
- `TileReductionOperationReturnsIndex` 选择四个 arg 形式，它们返回列或行索引而不是数值。
- `SelectedBundleClosedReductionSchemaLegal` 按归约 schema 检查完整的指令束。

<!-- PTO-READER-BLOCK: block-model-dispatch-reduction-schema-concepts role=concepts-state -->
## 概念与可见状态

本单元只读取状态。它不写入任何内容，自身也不引发故障。

- `_BundleTileBindings` 保存 `B.IOT` 绑定。该谓词读取绑定 0：其源、目标、目标大小码以及 `last` 标志。
- `_BundleDimensions` 保存 `LB0`（有效列数）、`LB1`（有效行数）和 `LB2`（物理列数）。
- `_BundleExecutionMask`、`_BundleScalarBindings` 和 Shared 绑定计数只用于确认它们不存在。
- 操作 `DataType` 通过 `CurrentBundleTileOperationDataTypeCode` 来自 `BSTART` 编码，布局来自 `CurrentBundleTileLayout`。
- `_Tiles` 提供源描述符及其元素值。

<!-- PTO-READER-BLOCK: block-model-dispatch-reduction-schema-rules role=rules-interactions -->
## 规则与交互

对于归约，只有以下条件全部成立时谓词才返回真：

- 没有生效的 ExecutionMask。
- 恰好有一个 Local Tile 绑定，没有 Shared 绑定，索引 0 处没有标量绑定。
- 三个维度都在 1 到 65535 之间。
- 绑定 0 有源 0、没有源 1，有一个尚未由指令束分配的目标，目标大小码合法，并带有 `last` 标志。
- 数据类型对 arg 形式属于 arg 归约集合（`S32`、`U32`、`FP32`、`S16`、`U16`、`FP16`、`BF16`、`S8`、`U8`），其他形式属于向量算术集合。
- 布局为 `RowMajor`、`CUBE_M16` 或 `CUBE_M32`，且源使用同一布局。
- 源通过 `TileReductionSourceLegalAs`：数值存储、宽度兼容的载体、不是 `RCPE6M2`，并且每个有效坐标都已定义且编码有效。
- 源的有效行数和有效列数非零，并分别等于 `LB1` 和 `LB0`，其物理列数等于 `LB2`（CUBE 布局下为由 `LB2` 推导出的 CUBE 存储列数）。

对于任何其他操作，该谓词返回真，因此可以与其他封闭 schema 谓词组合使用。

设计要点：归约会读取每个有效坐标，而 `TileReductionSourceLegalAs` 中的 ASL 注释说明归约不支持 ExecutionMask 校验状态。因此该 schema 直接拒绝任何 ExecutionMask，而不是只在部分元素上归约。

设计要点：此检查在分配任何目标之前运行。本地 Tile 执行路径通过 `SelectedBundleClosedSchemasLegal` 调用它，失败时引发 `Fault_TileLegality`，之后才调用 `ResolveBundleTileDestinationsForOperation`。因此被拒绝的归约指令束不会留下新分配的 Tile。

<!-- PTO-READER-BLOCK: block-model-dispatch-reduction-schema-boundaries role=boundaries -->
## 架构边界

本单元不计算归约，也不分配目标。归约的目标形状由[目标操作](destination-operation.md)决定：行归约得到源的有效行数和一列，列归约得到一行和源的有效列数，arg 形式得到 `U32` 目标。归约运算由 Tile 执行模型负责。

`PE_MASK` 未选择任何 PE 的指令束会在求值此谓词之前退出本地执行路径。

<!-- PTO-READER-BLOCK: block-model-dispatch-reduction-schema-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

考虑 `TROWSUM <Row=8, Col=64, FP32>, T#1, ->T<2KB>`。该指令束携带 `LB0=64`、`LB1=8` 和 `LB2=64`，以及一个 `B.IOT`，其源为 `T#1`、带一个新目标和 `last` 标志。如果 `T#1` 是已定义的 `RowMajor` `FP32` Tile，有 8 个有效行、64 个有效列和 64 个物理列，则 schema 检查通过。目标随后得到 8 个有效行和 1 个有效列。

如果同一指令束还携带一个所有选择子都为零的 `B.IOR`，或者 `T#1` 只有 7 个有效行，谓词将返回假，指令束会在任何目标存在之前引发 `Fault_TileLegality`。带有非零选择子的 `B.IOR` 会更早被完整性检查拒绝，并引发 `Fault_BundleControl`。

<!-- PTO-READER-BLOCK: block-model-dispatch-reduction-schema-related role=related-owners-navigation -->
## 相关所有者

- [Tile 执行分派](tile-execution.md)把此谓词与其他封闭 schema 组合，并把它排在目标解析之前。
- [比较 schema](comparison-schema.md)提供共享的维度和源形状检查。
- [目标操作](destination-operation.md)决定归约目标的形状。
- [归约与扩展合法性](../../../tile/model/legality/reduction-and-expansion.md)负责源合法性辅助函数。
- [TROWSUM](../../../tile/reduce-and-expand/row-reduction/TROWSUM.md) 是使用此 schema 的一个指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/reduction-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-REDUCTION-SCHEMA","surface":"block","classification":["model","dispatch","reduction-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA"]}

pure func TileOperationUsesClosedRowReductionSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TROWSUM ||
           decoded == TileOperation_TROWPROD ||
           decoded == TileOperation_TROWMIN ||
           decoded == TileOperation_TROWMAX ||
           decoded == TileOperation_TROWARGMIN ||
           decoded == TileOperation_TROWARGMAX;
end;

pure func TileOperationUsesClosedColumnReductionSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TCOLSUM ||
           decoded == TileOperation_TCOLPROD ||
           decoded == TileOperation_TCOLMIN ||
           decoded == TileOperation_TCOLMAX ||
           decoded == TileOperation_TCOLARGMIN ||
           decoded == TileOperation_TCOLARGMAX;
end;

pure func TileOperationUsesClosedReductionSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationUsesClosedRowReductionSchema(operation) ||
           TileOperationUsesClosedColumnReductionSchema(operation);
end;

pure func TileReductionOperationReturnsIndex(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TROWARGMIN ||
           decoded == TileOperation_TROWARGMAX ||
           decoded == TileOperation_TCOLARGMIN ||
           decoded == TileOperation_TCOLARGMAX;
end;

readonly func SelectedBundleClosedReductionSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedReductionSchema(operation) then
        return TRUE;
    end;
    if _BundleExecutionMask.valid then return FALSE; end;
    if BundleTileBindingCount() != 1 ||
       BundleSharedBindingCount() != 0 ||
       _BundleScalarBindings[[0]].valid ||
       !SelectedBundleComparisonDimensionsLegal() then
        return FALSE;
    end;

    let binding = _BundleTileBindings[[0]];
    if !binding.destination_valid ||
       binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(0) ||
       !binding.source0_valid ||
       binding.source1_valid ||
       !binding.last then
        return FALSE;
    end;

    let source = BundleTileSourceIndex(0, FALSE);
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode()
            as TileDataTypeEncoding);
    let source_tile = _Tiles[[source]];
    let source_type_legal = if TileReductionOperationReturnsIndex(operation) then
        TileArgReductionSourceDataTypeSupported(data_type)
    else
        TileVecArithmeticDataTypeSupported(data_type);
    return source_type_legal &&
           TileReductionAndExpansionLayoutSupported(
               CurrentBundleTileLayout()) &&
           source_tile.layout == CurrentBundleTileLayout() &&
           TileReductionSourceLegalAs(source, data_type) &&
           source_tile.valid_rows > 0 &&
           source_tile.valid_columns > 0 &&
           SelectedBundleComparisonShapeMatches(source);
end;
```
<!-- GENERATED-ASL-END: unit -->
