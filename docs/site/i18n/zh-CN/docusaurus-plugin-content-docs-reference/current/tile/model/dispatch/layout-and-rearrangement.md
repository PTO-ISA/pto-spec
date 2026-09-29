<!-- GENERATED FROM: asl/tile/model/dispatch/layout-and-rearrangement.asl -->
# Layout And Rearrangement

**Normative ASL source:** `asl/tile/model/dispatch/layout-and-rearrangement.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-DISPATCH-LAYOUT-AND-REARRANGEMENT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-dispatch-layout-and-rearrangement-purpose role=purpose-scope -->
## 用途与范围

本单元为布局与重排类别的 Tile 操作命名。它不包含可执行 ASL。其内容是 `PTO-UNIT` 元数据行（其 `depends_on` 列表指名指令单元和 Tile 模型单元）以及一行注释。操作本身由各自的指令单元定义。

该类别中的每个操作都在不做数值计算的情况下移动或重排 Tile 元素，或者从标量寄存器构建 Tile。

<!-- PTO-READER-BLOCK: tile-model-dispatch-layout-and-rearrangement-concepts role=concepts-state -->
## 概念与可见状态

本单元不声明状态。Tile 操作目录把 6 个操作放入该类别。下表按语义处理程序对它们分组，语义处理程序是生成的分派程序调用的 ASL 函数。

| 操作 | 语义处理程序 |
| --- | --- |
| `TMOV` | `TMOV` |
| `TPERMUTE`、`TSHUF` | `TPERMUTE`、`TSHUF` |
| `TPACK`、`TUNPACK` | `TPACK`、`TUNPACK` |
| `TGPR2T` | `TGPR2T` |

该类别跨越两个族。`TMOV` 是 TLSU function 2，有自己的 `BSTART.TMOV` 形式并使用 TLSU 引擎。其他五个使用 mode 为 3 的 TEPL 族和 SFU 引擎：`TPERMUTE` `0x075`、`TSHUF` `0x076`、`TPACK` `0x077`、`TUNPACK` `0x078` 和 `TGPR2T` `0x07E`。mode 3 与不规则与复杂类别共用。

<!-- PTO-READER-BLOCK: tile-model-dispatch-layout-and-rearrangement-rules role=rules-interactions -->
## 规则与交互

分派不查看类别。Tile 执行用 `DecodeTileOperation(family, code)` 解码指令束描述符，其中族为 TEPL、TLSU 或 CUBE，代码为 12 位。没有目录行的代码返回 `PTO_TILE_OPERATION_COUNT`。`BundleOperationDescriptorLegal` 在 `BSTART` 解码时进行该检查，因此该 `BSTART` 以 `Fault_IllegalInstruction` 故障，指令束永远不会被安装；Tile 执行会重复该解码，若以这样的代码到达，也会引发同样的故障。

设计要点：类别是一种所有权与导航分组，而不是解码输入。把一个操作移到另一个类别，不会改变选择它的代码，也不会改变运行它的处理程序。

设计要点：该类别的每个处理程序的生产者效果类别都是 `RollbackSafe`。因此该类别的任何操作都可以作为 `B.ASSEMBLE` 代次的写者，因为失败的尝试可以被撤销。

<!-- PTO-READER-BLOCK: tile-model-dispatch-layout-and-rearrangement-boundaries role=boundaries -->
## 架构边界

本单元不解码、不检查合法性，也不执行任何内容。操作数 schema、合法性处理程序和执行属于各指令单元以及以下模型单元：

- [重排](../execution/rearrangement.md)
- [生成](../execution/generation.md)
- [矩阵形状合法性](../legality/matrix-shape.md)

本单元的 `depends_on` 列表指名 `TMOV`、`TPERMUTE`、`TSHUF`、`TPACK` 和 `TUNPACK`。它没有列出 `TGPR2T`，尽管目录把 `TGPR2T` 放入该类别。

<!-- PTO-READER-BLOCK: tile-model-dispatch-layout-and-rearrangement-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

`TPACK` 的 mode 为 3，function 为 23，因此其 selector 为 3 x 32 + 23 = 119，即 `0x077`。`TMOV` 根本不在 TEPL 中：代码为 2 的 TLSU 指令束解码为 `TMOV`。同样的代码 2 在 TEPL 族中会解码为 `TMUL`，因为族是解码键的一部分。

<!-- PTO-READER-BLOCK: tile-model-dispatch-layout-and-rearrangement-related role=related-owners-navigation -->
## 相关所有者

- [顶层分派](top-level.md)列出全部七个类别以及目录外壳。
- [Tile 执行](../../../block/model/dispatch/tile-execution.md)解码操作并运行其处理程序。
- [可移植载体](../../../block/model/operands/portable-carriers.md)拥有生产者效果类别。
- [TMOV](../../layout-and-rearrangement/layout/TMOV.md) 是该类别的一个指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/dispatch/layout-and-rearrangement.asl -->
```asl
// PTO-UNIT: {"classification":["model","dispatch","layout-and-rearrangement"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE","PTO-TILE-MODEL-EXECUTION-GENERATION","PTO-TILE-MODEL-EXECUTION-REARRANGEMENT","PTO-TILE-TMOV","PTO-TILE-TPERMUTE","PTO-TILE-TSHUF","PTO-TILE-TPACK","PTO-TILE-TUNPACK"],"id":"PTO-TILE-MODEL-DISPATCH-LAYOUT-AND-REARRANGEMENT","surface":"tile"}
// Dispatch ownership for the layout-and-rearrangement PTO Tile instruction class.
```
<!-- GENERATED-ASL-END: unit -->
