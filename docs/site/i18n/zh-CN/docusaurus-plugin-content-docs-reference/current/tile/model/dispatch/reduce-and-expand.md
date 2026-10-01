<!-- GENERATED FROM: asl/tile/model/dispatch/reduce-and-expand.asl -->
# Reduce And Expand

**Normative ASL source:** `asl/tile/model/dispatch/reduce-and-expand.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-DISPATCH-REDUCE-AND-EXPAND}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-dispatch-reduce-and-expand-purpose role=purpose-scope -->
## 用途与范围

本单元为归约与扩展类别的 Tile 操作命名。它不包含可执行 ASL。其内容是 `PTO-UNIT` 元数据行（其 `depends_on` 列表指名指令单元和 Tile 模型单元）以及一行注释。操作本身由各自的指令单元定义。

该类别中的每个操作要么把 Tile 的每一行或每一列归约为一个值，要么把按行或按列的值扩展到整个 Tile。

<!-- PTO-READER-BLOCK: tile-model-dispatch-reduce-and-expand-concepts role=concepts-state -->
## 概念与可见状态

本单元不声明状态。Tile 操作目录把 28 个操作放入该类别。下表按语义处理程序对它们分组，语义处理程序是生成的分派程序调用的 ASL 函数。

| 操作 | 语义处理程序 |
| --- | --- |
| `TROWSUM`、`TROWMAX`、`TROWMIN`、`TROWPROD`、`TROWARGMAX`、`TROWARGMIN` | `ExecuteTileReduction` |
| `TCOLSUM`、`TCOLMAX`、`TCOLMIN`、`TCOLPROD`、`TCOLARGMAX`、`TCOLARGMIN` | `ExecuteTileReduction` |
| `TROWEXPAND`、`TROWEXPANDADD`、`TROWEXPANDSUB`、`TROWEXPANDMUL`、`TROWEXPANDDIV`、`TROWEXPANDMAX`、`TROWEXPANDMIN`、`TROWEXPANDEXPDIF` | `ExecuteTileExpand` |
| `TCOLEXPAND`、`TCOLEXPANDADD`、`TCOLEXPANDSUB`、`TCOLEXPANDMUL`、`TCOLEXPANDDIV`、`TCOLEXPANDMAX`、`TCOLEXPANDMIN`、`TCOLEXPANDEXPDIF` | `ExecuteTileExpand` |

全部 28 个操作都使用 mode 为 2 的 TEPL 族和 SFU 引擎。按行形式使用 function 0 到 13（代码 `0x040` 到 `0x04D`）。每个按列形式使用其按行形式的 function 加 16，因此按列代码从 `0x050` 到 `0x05D`。代码 `0x04E`、`0x04F`、`0x05E` 和 `0x05F` 是保留的。

<!-- PTO-READER-BLOCK: tile-model-dispatch-reduce-and-expand-rules role=rules-interactions -->
## 规则与交互

分派不查看类别。Tile 执行用 `DecodeTileOperation(family, code)` 解码指令束描述符，其中族为 TEPL、TLSU 或 CUBE，代码为 12 位。没有目录行的代码返回 `PTO_TILE_OPERATION_COUNT`。`BundleOperationDescriptorLegal` 在 `BSTART` 解码时进行该检查，因此该 `BSTART` 以 `Fault_IllegalInstruction` 故障，指令束永远不会被安装；Tile 执行会重复该解码，若以这样的代码到达，也会引发同样的故障。

设计要点：类别是一种所有权与导航分组，而不是解码输入。把一个操作移到另一个类别，不会改变选择它的代码，也不会改变运行它的处理程序。

设计要点：该类别的两个处理程序的生产者效果类别都是 `RollbackSafe`。因此该类别的任何操作都可以作为 `B.ASSEMBLE` 代次的写者，因为失败的尝试可以被撤销。

<!-- PTO-READER-BLOCK: tile-model-dispatch-reduce-and-expand-boundaries role=boundaries -->
## 架构边界

本单元不解码、不检查合法性，也不执行任何内容。操作数 schema、合法性处理程序和执行属于各指令单元以及以下模型单元：

- [归约](../execution/reduction.md)
- [扩展](../execution/expansion.md)
- [矩阵形状合法性](../legality/matrix-shape.md)

本单元的 `depends_on` 列表指名了目录放入该类别的全部 28 个指令单元。

<!-- PTO-READER-BLOCK: tile-model-dispatch-reduce-and-expand-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

`TROWMAX` 的 function 为 1，因此其代码为 2 x 32 + 1 = 65，即 `0x041`。`TCOLMAX` 的 function 为 1 + 16 = 17，因此其代码为 2 x 32 + 17 = 81，即 `0x051`。两者都解码到 `ExecuteTileReduction`。选择轴的是目录参数，而不是类别：分派程序为 `TROWMAX` 传入 `TileAxis_Row`，为 `TCOLMAX` 传入 `TileAxis_Column`。

<!-- PTO-READER-BLOCK: tile-model-dispatch-reduce-and-expand-related role=related-owners-navigation -->
## 相关所有者

- [顶层分派](top-level.md)列出全部七个类别以及目录外壳。
- [Tile 执行](../../../block/model/dispatch/tile-execution.md)解码操作并运行其处理程序。
- [可移植载体](../../../block/model/operands/portable-carriers.md)拥有生产者效果类别。
- [TROWSUM](../../reduce-and-expand/row-reduction/TROWSUM.md) 是该类别的一个指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/dispatch/reduce-and-expand.asl -->
```asl
// PTO-UNIT: {"classification":["model","dispatch","reduce-and-expand"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE","PTO-TILE-MODEL-EXECUTION-REDUCTION","PTO-TILE-MODEL-EXECUTION-EXPANSION","PTO-TILE-TCOLARGMAX","PTO-TILE-TCOLARGMIN","PTO-TILE-TCOLEXPAND","PTO-TILE-TCOLEXPANDADD","PTO-TILE-TCOLEXPANDDIV","PTO-TILE-TCOLEXPANDEXPDIF","PTO-TILE-TCOLEXPANDMAX","PTO-TILE-TCOLEXPANDMIN","PTO-TILE-TCOLEXPANDMUL","PTO-TILE-TCOLEXPANDSUB","PTO-TILE-TCOLMAX","PTO-TILE-TCOLMIN","PTO-TILE-TCOLPROD","PTO-TILE-TCOLSUM","PTO-TILE-TROWARGMAX","PTO-TILE-TROWARGMIN","PTO-TILE-TROWEXPAND","PTO-TILE-TROWEXPANDADD","PTO-TILE-TROWEXPANDDIV","PTO-TILE-TROWEXPANDEXPDIF","PTO-TILE-TROWEXPANDMAX","PTO-TILE-TROWEXPANDMIN","PTO-TILE-TROWEXPANDMUL","PTO-TILE-TROWEXPANDSUB","PTO-TILE-TROWMAX","PTO-TILE-TROWMIN","PTO-TILE-TROWPROD","PTO-TILE-TROWSUM"],"id":"PTO-TILE-MODEL-DISPATCH-REDUCE-AND-EXPAND","surface":"tile"}
// Dispatch ownership for the reduce-and-expand PTO Tile instruction class.
```
<!-- GENERATED-ASL-END: unit -->
