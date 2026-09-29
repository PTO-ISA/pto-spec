<!-- GENERATED FROM: asl/tile/model/dispatch/memory-and-data-movement.asl -->
# Memory And Data Movement

**Normative ASL source:** `asl/tile/model/dispatch/memory-and-data-movement.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-DISPATCH-MEMORY-AND-DATA-MOVEMENT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-dispatch-memory-and-data-movement-purpose role=purpose-scope -->
## 用途与范围

本单元为内存与数据移动类别的 Tile 操作命名。它不包含可执行 ASL。其内容是 `PTO-UNIT` 元数据行（其 `depends_on` 列表指名指令单元和 Tile 模型单元）以及一行注释。操作本身由各自的指令单元定义。

该类别中的每个操作都访问全局内存（GM），方式为加载、存储、预取或带索引及原子的访问；`GMOV` 例外，它在对等 PE 之间复制 Local 片段。

<!-- PTO-READER-BLOCK: tile-model-dispatch-memory-and-data-movement-concepts role=concepts-state -->
## 概念与可见状态

本单元不声明状态。Tile 操作目录把 27 个操作放入该类别。下表按语义处理程序对它们分组，语义处理程序是生成的分派程序调用的 ASL 函数。

| 操作 | 语义处理程序 |
| --- | --- |
| `TLOAD`、`TSTORE`、`TPREFETCH` | `TLOAD`、`TSTORE`、`TPREFETCH` |
| `MGATHER`、`MGATHER_MASK`、`MSCATTER`、`MSCATTER_MASK`、`GMOV` | 各自使用同名的一个处理程序 |
| `MGATHER_CAS` | `GM_ATOM_CAS` |
| `MGATHER_EXCH`、`MGATHER_MAX`、`MGATHER_MIN`、`MGATHER_ADD`、`MGATHER_INC`、`MGATHER_DEC`、`MGATHER_AND`、`MGATHER_OR`、`MGATHER_XOR` | `GM_ATOM_VALUE` |
| `MSCATTER_MAX`、`MSCATTER_MIN`、`MSCATTER_ADD`、`MSCATTER_INC`、`MSCATTER_DEC`、`MSCATTER_AND`、`MSCATTER_OR`、`MSCATTER_XOR` | `GM_RED_VALUE` |
| `MSCATTER_POPC` | `GM_RED_POPC` |

全部 27 个操作都使用 TLSU 族和 TLSU 引擎。对 TLSU，12 位代码就是 function 编号本身。function 为 0、1 以及 3 到 27；function 2 是属于布局类别的 `TMOV`，function 28 到 31 是保留的。每个操作都有自己的 `BSTART` 命令形式，例如 `BSTART.TLOAD` 或 `BSTART.MGATHER.ADD`。

<!-- PTO-READER-BLOCK: tile-model-dispatch-memory-and-data-movement-rules role=rules-interactions -->
## 规则与交互

分派不查看类别。Tile 执行用 `DecodeTileOperation(family, code)` 解码指令束描述符，其中族为 TEPL、TLSU 或 CUBE，代码为 12 位。没有目录行的代码返回 `PTO_TILE_OPERATION_COUNT`。`BundleOperationDescriptorLegal` 在 `BSTART` 解码时进行该检查，因此该 `BSTART` 以 `Fault_IllegalInstruction` 故障，指令束永远不会被安装；Tile 执行会重复该解码，若以这样的代码到达，也会引发同样的故障。

设计要点：类别是一种所有权与导航分组，而不是解码输入。把一个操作移到另一个类别，不会改变选择它的代码，也不会改变运行它的处理程序。

设计要点：该类别混合了多种生产者效果类别。`TLOAD`、`MGATHER`、`MGATHER_MASK` 和 `GMOV` 是 `RollbackSafe`。`TSTORE`、`TPREFETCH`、`MSCATTER`、`MSCATTER_MASK` 以及四个 GM 原子和归约处理程序是 `NonRollbackAuxiliary`。若指令束的 Local Tile 绑定带有 `B.ASSEMBLE` 修饰符且选择了后者之一，它会在 `BundleProducerEffectEligible` 中、任何主体或辅助效果之前以 `Fault_TileLegality` 故障。

<!-- PTO-READER-BLOCK: tile-model-dispatch-memory-and-data-movement-boundaries role=boundaries -->
## 架构边界

本单元不解码、不检查合法性，也不执行任何内容。操作数 schema、合法性处理程序和执行属于各指令单元以及以下模型单元：

- [内存重启](../memory/restart.md)
- [矩阵形状合法性](../legality/matrix-shape.md)

本单元的 `depends_on` 列表只指名 9 个指令单元：`GMOV`、`MGATHER`、`MGATHER_CAS`、`MGATHER_MASK`、`MSCATTER`、`MSCATTER_MASK`、`TLOAD`、`TPREFETCH` 和 `TSTORE`。目录同样放入该类别的 18 个原子和归约单元没有列出。`BSTART.TIMG2COL` 使用 TLSU function 28，但它不是目录中的操作；Tile 执行通过其确切的命令形式识别它，并跳过通用解码。

<!-- PTO-READER-BLOCK: tile-model-dispatch-memory-and-data-movement-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

`MGATHER_ADD` 的 TLSU function 为 12，因此其代码为 `0x00C`。它解码到带常量 `GMAtomic_ADD` 的 `GM_ATOM_VALUE`。如果同一个指令束还带有 `B.ASSEMBLE` 修饰符，效果条件检查会在任何 GM 访问之前以 `Fault_TileLegality` 拒绝它。

<!-- PTO-READER-BLOCK: tile-model-dispatch-memory-and-data-movement-related role=related-owners-navigation -->
## 相关所有者

- [顶层分派](top-level.md)列出全部七个类别以及目录外壳。
- [Tile 执行](../../../block/model/dispatch/tile-execution.md)解码操作并运行其处理程序。
- [可移植载体](../../../block/model/operands/portable-carriers.md)拥有生产者效果类别。
- [TLOAD](../../memory-and-data-movement/regular/TLOAD.md) 是该类别的一个指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/dispatch/memory-and-data-movement.asl -->
```asl
// PTO-UNIT: {"classification":["model","dispatch","memory-and-data-movement"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE","PTO-TILE-MODEL-MEMORY-RESTART","PTO-TILE-GMOV","PTO-TILE-MGATHER","PTO-TILE-MGATHER-CAS","PTO-TILE-MGATHER-MASK","PTO-TILE-MSCATTER","PTO-TILE-MSCATTER-MASK","PTO-TILE-TLOAD","PTO-TILE-TPREFETCH","PTO-TILE-TSTORE"],"id":"PTO-TILE-MODEL-DISPATCH-MEMORY-AND-DATA-MOVEMENT","surface":"tile"}
// Dispatch ownership for the memory-and-data-movement PTO Tile instruction class.
```
<!-- GENERATED-ASL-END: unit -->
