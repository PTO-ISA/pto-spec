<!-- GENERATED FROM: asl/tile/model/dispatch/elementwise-tile-tile.asl -->
# Elementwise Tile Tile

**Normative ASL source:** `asl/tile/model/dispatch/elementwise-tile-tile.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-DISPATCH-ELEMENTWISE-TILE-TILE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-dispatch-elementwise-tile-tile-purpose role=purpose-scope -->
## 用途与范围

本单元为逐元素 tile-tile类别的 Tile 操作命名。它不包含可执行 ASL。其内容是 `PTO-UNIT` 元数据行（其 `depends_on` 列表指名指令单元和 Tile 模型单元）以及一行注释。操作本身由各自的指令单元定义。

该类别中的每个操作都按位置逐元素地组合或变换 Tile 元素。其数据源是 Tile，但 `TSEL` 可以从 GPR 取掩码，`TCMP` 可以把结果写入 GPR。

<!-- PTO-READER-BLOCK: tile-model-dispatch-elementwise-tile-tile-concepts role=concepts-state -->
## 概念与可见状态

本单元不声明状态。Tile 操作目录把 26 个操作放入该类别。下表按语义处理程序对它们分组，语义处理程序是生成的分派程序调用的 ASL 函数。

| 操作 | 语义处理程序 |
| --- | --- |
| `TADD`、`TSUB`、`TMUL`、`TDIV`、`TREM`、`TAND`、`TOR`、`TXOR`、`TSHL`、`TSHR`、`TMAX`、`TMIN` | `ExecuteTileBinary` |
| `TCMP` | `ExecuteTileCompare` |
| `TABS`、`TNOT`、`TNEG`、`TEXP`、`TLOG`、`TRECIP`、`TSQRT`、`TRSQRT`、`TRELU` | `ExecuteTileUnary` |
| `TSEL` | `ExecuteTileSelect` |
| `TCVT`、`TFMA` | `TCVT`、`TFMA` |
| `TEXPDIF` | `ExecuteTileExpdif` |

全部 26 个操作都使用 mode 为 0 的 TEPL 族。selector 为 `mode * 32 + function`，因此代码从 `0x000`（`TADD`）到 `0x01D`（`TEXPDIF`）。代码 `0x005`、`0x00E`、`0x018`、`0x019`、`0x01E` 和 `0x01F` 是保留的。目录把 SFU 引擎分配给 `TDIV`、`TREM`、`TEXP`、`TLOG`、`TRECIP`、`TSQRT`、`TRSQRT` 和 `TEXPDIF`，其余使用 VEC 引擎。

<!-- PTO-READER-BLOCK: tile-model-dispatch-elementwise-tile-tile-rules role=rules-interactions -->
## 规则与交互

分派不查看类别。Tile 执行用 `DecodeTileOperation(family, code)` 解码指令束描述符，其中族为 TEPL、TLSU 或 CUBE，代码为 12 位。没有目录行的代码返回 `PTO_TILE_OPERATION_COUNT`。`BundleOperationDescriptorLegal` 在 `BSTART` 解码时进行该检查，因此该 `BSTART` 以 `Fault_IllegalInstruction` 故障，指令束永远不会被安装；Tile 执行会重复该解码，若以这样的代码到达，也会引发同样的故障。

设计要点：类别是一种所有权与导航分组，而不是解码输入。把一个操作移到另一个类别，不会改变选择它的代码，也不会改变运行它的处理程序。

设计要点：在可移植载体单元中，该类别的每个处理程序的生产者效果类别都是 `RollbackSafe`。因此该类别的任何操作都可以作为 `B.ASSEMBLE` 代次的写者，因为失败的尝试可以被撤销。

<!-- PTO-READER-BLOCK: tile-model-dispatch-elementwise-tile-tile-boundaries role=boundaries -->
## 架构边界

本单元不解码、不检查合法性，也不执行任何内容。操作数 schema、合法性处理程序和执行属于各指令单元以及以下模型单元：

- [逐元素执行](../execution/elementwise.md)
- [比较](../execution/comparison.md)
- [EXPDIF 执行](../execution/expdif.md)
- [EXPDIF 操作数合法性](../legality/expdif-operands.md)
- [矩阵形状合法性](../legality/matrix-shape.md)
- [数值格式](../numeric/formats.md)

本单元的 `depends_on` 列表指名了目录放入该类别的全部 26 个指令单元。

<!-- PTO-READER-BLOCK: tile-model-dispatch-elementwise-tile-tile-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

`TMAX` 的 mode 为 0，function 为 11，因此其 selector 为 0 x 32 + 11 = 11，即 `0x00B`。代码为 `0x00B` 的 TEPL 指令束解码为 `TMAX` 并运行 `ExecuteTileBinary`。代码为 `0x00E` 的 TEPL 指令束没有目录行，因此在读取任何操作数之前以 `Fault_IllegalInstruction` 故障。

<!-- PTO-READER-BLOCK: tile-model-dispatch-elementwise-tile-tile-related role=related-owners-navigation -->
## 相关所有者

- [顶层分派](top-level.md)列出全部七个类别以及目录外壳。
- [Tile 执行](../../../block/model/dispatch/tile-execution.md)解码操作并运行其处理程序。
- [可移植载体](../../../block/model/operands/portable-carriers.md)拥有生产者效果类别。
- [TADD](../../elementwise-tile-tile/arithmetic/TADD.md) 是该类别的一个指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/dispatch/elementwise-tile-tile.asl -->
```asl
// PTO-UNIT: {"classification":["model","dispatch","elementwise-tile-tile"],"depends_on":["PTO-TILE-MODEL-EXECUTION-COMPARISON","PTO-TILE-MODEL-EXECUTION-ELEMENTWISE","PTO-TILE-MODEL-EXECUTION-EXPDIF","PTO-TILE-MODEL-LEGALITY-EXPDIF-OPERANDS","PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE","PTO-TILE-MODEL-NUMERIC-FORMATS","PTO-TILE-TABS","PTO-TILE-TADD","PTO-TILE-TAND","PTO-TILE-TCMP","PTO-TILE-TCVT","PTO-TILE-TDIV","PTO-TILE-TEXP","PTO-TILE-TEXPDIF","PTO-TILE-TFMA","PTO-TILE-TLOG","PTO-TILE-TMAX","PTO-TILE-TMIN","PTO-TILE-TMUL","PTO-TILE-TNEG","PTO-TILE-TNOT","PTO-TILE-TOR","PTO-TILE-TRECIP","PTO-TILE-TRELU","PTO-TILE-TREM","PTO-TILE-TRSQRT","PTO-TILE-TSEL","PTO-TILE-TSHL","PTO-TILE-TSHR","PTO-TILE-TSQRT","PTO-TILE-TSUB","PTO-TILE-TXOR"],"id":"PTO-TILE-MODEL-DISPATCH-ELEMENTWISE-TILE-TILE","surface":"tile"}
// Dispatch ownership for the elementwise-tile-tile PTO Tile instruction class.
```
<!-- GENERATED-ASL-END: unit -->
