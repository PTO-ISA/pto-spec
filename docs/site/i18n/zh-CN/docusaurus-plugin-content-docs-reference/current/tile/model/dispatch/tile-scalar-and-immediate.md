<!-- GENERATED FROM: asl/tile/model/dispatch/tile-scalar-and-immediate.asl -->
# Tile Scalar And Immediate

**Normative ASL source:** `asl/tile/model/dispatch/tile-scalar-and-immediate.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-DISPATCH-TILE-SCALAR-AND-IMMEDIATE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-dispatch-tile-scalar-and-immediate-purpose role=purpose-scope -->
## 用途与范围

本单元为tile-标量与立即数类别的 Tile 操作命名。它不包含可执行 ASL。其内容是 `PTO-UNIT` 元数据行（其 `depends_on` 列表指名指令单元和 Tile 模型单元）以及一行注释。操作本身由各自的指令单元定义。

该类别中的每个操作都把一个 Tile 与一个标量值组合，或者用标量填充一个 Tile。

<!-- PTO-READER-BLOCK: tile-model-dispatch-tile-scalar-and-immediate-concepts role=concepts-state -->
## 概念与可见状态

本单元不声明状态。Tile 操作目录把 15 个操作放入该类别。下表按语义处理程序对它们分组，语义处理程序是生成的分派程序调用的 ASL 函数。

| 操作 | 语义处理程序 |
| --- | --- |
| `TADDS`、`TSUBS`、`TMULS`、`TDIVS`、`TREMS`、`TANDS`、`TORS`、`TXORS`、`TSHLS`、`TSHRS`、`TMAXS`、`TMINS` | `ExecuteTileScalar` |
| `TCMPS` | `ExecuteTileCompareScalar` |
| `TSELS` | `ExecuteTileSelectScalar` |
| `TEXPANDS` | `ExecuteTileFillScalar` |

全部 15 个操作都使用 mode 为 1 的 TEPL 族，因此代码从 `0x020`（`TADDS`）到 `0x03B`（`TEXPANDS`）。对 `TADDS` 到 `TCMPS` 以及 `TSELS`，function 编号等于 mode 0 中同名词干的 tile-tile 形式的 function。`TEXPANDS` 使用 function 27，它在 mode 0 中属于 `TCVT`，因此它没有 tile-tile 对应形式。目录把 SFU 引擎分配给 `TDIVS` 和 `TREMS`，其余使用 VEC 引擎。

<!-- PTO-READER-BLOCK: tile-model-dispatch-tile-scalar-and-immediate-rules role=rules-interactions -->
## 规则与交互

分派不查看类别。Tile 执行用 `DecodeTileOperation(family, code)` 解码指令束描述符，其中族为 TEPL、TLSU 或 CUBE，代码为 12 位。没有目录行的代码返回 `PTO_TILE_OPERATION_COUNT`。`BundleOperationDescriptorLegal` 在 `BSTART` 解码时进行该检查，因此该 `BSTART` 以 `Fault_IllegalInstruction` 故障，指令束永远不会被安装；Tile 执行会重复该解码，若以这样的代码到达，也会引发同样的故障。

设计要点：类别是一种所有权与导航分组，而不是解码输入。把一个操作移到另一个类别，不会改变选择它的代码，也不会改变运行它的处理程序。

设计要点：该类别的每个处理程序的生产者效果类别都是 `RollbackSafe`。因此该类别的任何操作都可以作为 `B.ASSEMBLE` 代次的写者，因为失败的尝试可以被撤销。

<!-- PTO-READER-BLOCK: tile-model-dispatch-tile-scalar-and-immediate-boundaries role=boundaries -->
## 架构边界

本单元不解码、不检查合法性，也不执行任何内容。操作数 schema、合法性处理程序和执行属于各指令单元以及以下模型单元：

- [逐元素执行](../execution/elementwise.md)
- [比较](../execution/comparison.md)
- [生成](../execution/generation.md)
- [矩阵形状合法性](../legality/matrix-shape.md)

本单元的 `depends_on` 列表指名了目录放入该类别的全部 15 个指令单元。

<!-- PTO-READER-BLOCK: tile-model-dispatch-tile-scalar-and-immediate-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

`TMULS` 的 mode 为 1，function 为 2，因此其 selector 为 1 x 32 + 2 = 34，即 `0x022`。其 tile-tile 对应形式 `TMUL` 在 mode 0 中具有相同的 function 2，selector 为 `0x002`。这两个代码只在 mode 位上不同，并解码到不同的处理程序：`ExecuteTileScalar` 和 `ExecuteTileBinary`。

<!-- PTO-READER-BLOCK: tile-model-dispatch-tile-scalar-and-immediate-related role=related-owners-navigation -->
## 相关所有者

- [顶层分派](top-level.md)列出全部七个类别以及目录外壳。
- [Tile 执行](../../../block/model/dispatch/tile-execution.md)解码操作并运行其处理程序。
- [可移植载体](../../../block/model/operands/portable-carriers.md)拥有生产者效果类别。
- [TADDS](../../tile-scalar-and-immediate/arithmetic/TADDS.md) 是该类别的一个指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/dispatch/tile-scalar-and-immediate.asl -->
```asl
// PTO-UNIT: {"classification":["model","dispatch","tile-scalar-and-immediate"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE","PTO-TILE-MODEL-EXECUTION-ELEMENTWISE","PTO-TILE-MODEL-EXECUTION-COMPARISON","PTO-TILE-MODEL-EXECUTION-GENERATION","PTO-TILE-TADDS","PTO-TILE-TANDS","PTO-TILE-TCMPS","PTO-TILE-TDIVS","PTO-TILE-TEXPANDS","PTO-TILE-TMAXS","PTO-TILE-TMINS","PTO-TILE-TMULS","PTO-TILE-TORS","PTO-TILE-TREMS","PTO-TILE-TSELS","PTO-TILE-TSHLS","PTO-TILE-TSHRS","PTO-TILE-TSUBS","PTO-TILE-TXORS"],"id":"PTO-TILE-MODEL-DISPATCH-TILE-SCALAR-AND-IMMEDIATE","surface":"tile"}
// Dispatch ownership for the tile-scalar-and-immediate PTO Tile instruction class.
```
<!-- GENERATED-ASL-END: unit -->
