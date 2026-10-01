<!-- GENERATED FROM: asl/block/model/dispatch/binary-operation-classification.asl -->
# Binary Operation Classification

**Normative ASL source:** `asl/block/model/dispatch/binary-operation-classification.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-BINARY-OP-CLASSIFICATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-binary-operation-classification-purpose role=purpose-scope -->
## 用途与范围

本单元为指令束分派回答一个问题：一个已解码的 Tile 操作是否使用封闭二元 schema？在本模型中，schema 是一个操作所接受的指令束命令与操作数绑定的精确集合。封闭 schema 列出每一种合法形态，因此列表之外的任何绑定都会被拒绝。

本单元只包含一个 pure 谓词 `TileOperationUsesClosedBinarySchema`。它接收一个已解码的操作索引，并且恰好对八个操作返回 true：`TADD`、`TSUB`、`TMUL`、`TDIV`、`TREM`、`TMAX`、`TMIN` 和 `TEXPDIF`。

<!-- PTO-READER-BLOCK: block-model-dispatch-binary-operation-classification-concepts role=concepts-state -->
## 概念与可见状态

该谓词用 `TileOperationOfIndex` 转换索引，并将结果与这八个操作名比较。它被声明为 `pure`，因此不读取也不写入任何架构状态。

这八个操作都读取两个 Local 源 Tile，并写入一个 Local 目标 Tile。该分类归并的正是这种共同的操作数形态。算术数据类型、布局和元素结果由其他所有者负责。

<!-- PTO-READER-BLOCK: block-model-dispatch-binary-operation-classification-rules role=rules-interactions -->
## 规则与交互

在分派模型中，该谓词有两个调用者。

- Tile schema 单元中的 `SelectedBundleClosedBinarySchemaLegal` 在谓词为 false 时立即返回 true。谓词为 true 时，该调用者要求一个带两个源和一个目标的终止 `B.IOT` 绑定（当谓词 Tile 执行掩码生效时为两个绑定），不允许 Shared 绑定，并要求维度位于 1..65535。对 `TEXPDIF` 以外的七个操作，它还要求操作类型满足 `TileVecArithmeticDataTypeSupported`，并要求逐元素布局。
- `ResolveBundleTileDestinationsForOperation` 将它与其他封闭 schema 谓词一起用于选择目标解析方式。对 `TEXPDIF` 以外的七个操作（`TEXPDIF` 有自己更早的分支），目标形状随后来自 `LB0`、`LB1` 和 `LB2`，而不走通用路径。

两个调用者都在 Tile 执行所有者中、任何源快照或载荷写入之前运行。Tile 操作数数量错误的指令束会先被 `BundleOperationBindingsComplete` 以 `Fault_BundleControl` 拒绝；随后封闭二元 schema 检查在目标解析之前运行，而目标解析正是分配目标的步骤，因此属于此类但不满足该 schema 的操作会在分配任何目标之前引发 `Fault_TileLegality`。

设计要点：`TEXPDIF` 属于此类，尽管它是在 `SFU` 引擎上的超越运算，并有自己的类型规则。该分类描述的是操作数结构，而不是算术。`TEXPDIF` 接收两个源和一个目标，因此共享绑定检查；schema 检查随后再加上它自己的规则：`LB0` 必须出现，用 `SelectedBundleExponentialDifferenceTypes` 检查源类型和目标类型，并用 `TileElementwiseLayoutSupported` 与 `TileExpdifSourcesLegal` 检查布局和源。

<!-- PTO-READER-BLOCK: block-model-dispatch-binary-operation-classification-boundaries role=boundaries -->
## 架构边界

本单元不检查类型、布局、维度或绑定，也不引发故障。它只做分类。

`TROWEXPANDEXPDIF` 这类行、列扩展形式不属于此类，它们使用扩展 schema。`TADDS` 这类 Tile-标量形式同样不在此类中，它们使用 Tile-标量 schema。

<!-- PTO-READER-BLOCK: block-model-dispatch-binary-operation-classification-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

考虑下面的 Tile 宏。

```text
TADD <Row=8, Col=64, FP32>, T#1, T#2, ->T<2KB>
```

分派将该操作解码为 `TADD`，谓词返回 true。随后 Tile schema 检查要求一个标记为 last 的 `B.IOT` 绑定，其中左源为 `T#1`、右源为 `T#2`，并带一个目标。`LB0` 提供 `ValidCol=64`。目标按该显式形状解析。相比之下，`TABS` 指令束在此得到 false，改由一元 schema 检查。

<!-- PTO-READER-BLOCK: block-model-dispatch-binary-operation-classification-related role=related-owners-navigation -->
## 相关所有者

- [Tile schema](tile-schema.md) 拥有 `SelectedBundleClosedBinarySchemaLegal`，即此类的绑定检查。
- [目标操作](destination-operation.md) 按操作类别路由目标解析。
- [指数差 schema](expdif-schema.md) 解析 `TEXPDIF` 的源类型和目标类型。
- [TADD](../../../tile/elementwise-tile-tile/arithmetic/TADD.md) 是一个代表性成员指令。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/binary-operation-classification.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-BINARY-OP-CLASSIFICATION","surface":"block","classification":["model","dispatch","binary-operation-classification"],"depends_on":[]}
pure func TileOperationUsesClosedBinarySchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TADD ||
           decoded == TileOperation_TSUB ||
           decoded == TileOperation_TMUL ||
           decoded == TileOperation_TDIV ||
           decoded == TileOperation_TREM ||
           decoded == TileOperation_TMAX ||
           decoded == TileOperation_TMIN ||
           decoded == TileOperation_TEXPDIF;
end;
```
<!-- GENERATED-ASL-END: unit -->
