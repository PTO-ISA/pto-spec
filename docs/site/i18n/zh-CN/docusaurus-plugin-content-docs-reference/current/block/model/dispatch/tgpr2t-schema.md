<!-- GENERATED FROM: asl/block/model/dispatch/tgpr2t-schema.asl -->
# Tgpr2t Schema

**Normative ASL source:** `asl/block/model/dispatch/tgpr2t-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TGPR2T-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tgpr2t-schema-purpose role=purpose-scope -->
## 用途与范围

本单元定义 `TGPR2T` 的封闭指令束 schema。`TGPR2T` 读取四个通用寄存器（GPR），把它们的位写入一个小型 U8 CUBE Tile。`SelectedBundleClosedTGPR2TSchemaLegal` 对其他任何操作都返回真；对 `TGPR2T`，只有完整指令束符合该 schema 时才返回真。

Tile 执行所有者通过 `SelectedBundleClosedSchemasLegal` 调用它。在那里结果为假会在目标分配或该操作读取任何寄存器之前引发 `Fault_TileLegality`。

<!-- PTO-READER-BLOCK: block-model-dispatch-tgpr2t-schema-concepts role=concepts-state -->
## 概念与可见状态

NDF 条款 `PTO-BLOCK-MODEL-DISPATCH-TGPR2T-SCHEMA-001` 固定了操作数载体：

- 两个标量绑定（`B.IOR` 记录）提供四个 GPR 选择子。第一个提供三个源，第二个提供一个，即“3+1”拆分。两者都不能指定目标寄存器。
- 一个 Tile 绑定（`B.IOT`）指定目标并结束绑定列表。
- 形状由 `B.DIM` 给出：维度 1 是有效行数，维度 0 是有效列数。维度 2 必须保持其默认值 1。

该 schema 读取绑定、三个维度、执行掩码、描述符数据类型以及 `B.DATR` 的舍入与填充字段。它不写入任何状态。

<!-- PTO-READER-BLOCK: block-model-dispatch-tgpr2t-schema-rules role=rules-interactions -->
## 规则与交互

只有以下条件全部成立时 schema 才通过：

- 恰好一个 Tile 绑定，没有 Shared 绑定，且维度 2 等于 1。
- 行数与列数为 32 与 4，或 16 与 8。
- 该绑定指定一个指令束尚未分配的目标，尺寸码合法，并标记为最后。
- 只有当执行掩码是谓词 Tile 时才出现 `source0`，此时该掩码是源序号 0。`source1` 永不出现。
- 描述符数据类型为 `U8`。
- `BundleOperationGPRBindingValuesLegal` 接受这些标量绑定。
- `TileTGPR2TRModeLegal` 接受舍入字段：位 2 必须为 0。对于该操作，低两位选择字节偏移，而不是舍入模式。
- `TileTGPR2TPadLegal` 接受填充值：零或最大值。`B.DATR` 缺省时填充为零。

设计要点：NDF 条款 `PTO-BLOCK-MODEL-DISPATCH-TGPR2T-SCHEMA-001` 把 32 乘 4 与 `CUBE_M32` 配对，把 16 乘 8 与 `CUBE_M16` 配对。本 schema 只接受这两种形状，因此其他形状都在分配之前被拒绝；形状与布局的配对稍后由处理器的操作数检查 `TileOperandsLegal_TGPR2T` 检查。

设计要点：NDF 条款 `PTO-BLOCK-MODEL-DISPATCH-TGPR2T-BOUNDARY-001` 规定结果是普通的数值 U8 CUBE Tile，既不是 PredicateCell，也不是 `TSEL` 或 `TSELS` 的隐式掩码。因此数据类型固定为 `U8`，并且整 Tile 检查属于本 schema，在处理器运行和结果发布之前完成。

命令流在命令到达时更早受到检查。在 `TGPR2T` 指令束的第一个 `B.IOR` 之后，除非此前已出现零参与，下一条命令必须是第二个 `B.IOR` 或零参与的 `B.IOT`，否则引发 `Fault_BundleControl`。在两条记录都到齐之前出现非零参与的 `B.IOT` 也会引发 `Fault_BundleControl`。

<!-- PTO-READER-BLOCK: block-model-dispatch-tgpr2t-schema-boundaries role=boundaries -->
## 架构边界

本单元返回布尔值，自身不引发故障。命令时的流规则与放置规则属于标量 schema 和命令所有者。四个选择子到操作数的映射属于 Tile 指令操作数所有者。把 GPR 值按位打包进 Tile 属于 Tile 谓词载体执行所有者。

<!-- PTO-READER-BLOCK: block-model-dispatch-tgpr2t-schema-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

某指令束选择数据类型为 `U8` 的 `TGPR2T`。它把维度 0 设为 4，维度 1 设为 32，维度 2 保持为 1。第一个 `B.IOR` 指定 GPR 5、6、7，第二个指定 GPR 8，两者的目标均为 0。一个 `B.IOT` 指定目标并标记为最后。没有 `B.DATR` 时，填充为零，舍入字段为 `000`。该 schema 通过。如果在 32 行时维度 0 为 8，schema 会失败。

<!-- PTO-READER-BLOCK: block-model-dispatch-tgpr2t-schema-related role=related-owners-navigation -->
## 相关所有者

- [Scalar schema](scalar-schema.md) 强制两条记录的 `B.IOR` 流。
- [Tile instruction operands](tile-instruction-operands.md) 把四个选择子映射为操作数。
- [Tile execution](tile-execution.md) 调用该 schema。
- [TGPR2T](../../../tile/layout-and-rearrangement/layout/TGPR2T.md) 是指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tgpr2t-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TGPR2T-SCHEMA","surface":"block","classification":["model","dispatch","tgpr2t-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA","PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS"]}
// NDF-BEGIN: PTO-BLOCK-MODEL-DISPATCH-TGPR2T-SCHEMA-001
// ndf: kind=contract level=L1 layer=block status=accepted
// TGPR2T MUST consume exactly two contiguous source-only B.IOR records (3+1),
// one terminating destination B.IOT, and one exact shape pair: LB1/LB0 is
// 32/4 for CUBE_M32 or 16/8 for CUBE_M16. LB2 MUST have its default value one.
// Wrong-split, surplus, or destination-bearing forms reject before allocation,
// source reads, or publication.
// NDF-END: PTO-BLOCK-MODEL-DISPATCH-TGPR2T-SCHEMA-001

readonly func SelectedBundleClosedTGPR2TSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if TileOperationOfIndex(operation) != TileOperation_TGPR2T then
        return TRUE;
    end;
    if BundleTileBindingCount() != 1 ||
       BundleSharedBindingCount() != 0 ||
       UInt(_BundleDimensions[[2]]) != 1 then
        return FALSE;
    end;
    let binding = _BundleTileBindings[[0]];
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    let rows = UInt(_BundleDimensions[[1]]);
    let columns = UInt(_BundleDimensions[[0]]);
    let shape_legal = (rows == 32 && columns == 4) ||
        (rows == 16 && columns == 8);
    return shape_legal && binding.destination_valid &&
           !binding.destination_allocated_by_bundle &&
           BundleTileDestinationSizeLegal(0) &&
           (binding.source0_valid == execution_mask_tile) &&
           !binding.source1_valid &&
           (!execution_mask_tile ||
            _BundleExecutionMask.predicate_source_ordinal == 0) &&
           binding.last &&
           TileDataTypeFromEncoding(
               CurrentBundleTileOperationDataTypeCode()
                   as TileDataTypeEncoding) == TileDataType_U8 &&
           BundleOperationGPRBindingValuesLegal(operation) &&
           TileTGPR2TRModeLegal(_BundleDataAttributes.rounding_mode) &&
           TileTGPR2TPadLegal();
end;
```
<!-- GENERATED-ASL-END: unit -->
