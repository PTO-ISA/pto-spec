<!-- GENERATED FROM: asl/tile/model/dispatch/irregular-and-complex.asl -->
# Irregular And Complex

**Normative ASL source:** `asl/tile/model/dispatch/irregular-and-complex.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-DISPATCH-IRREGULAR-AND-COMPLEX}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-dispatch-irregular-and-complex-purpose role=purpose-scope -->
## 用途与范围

本单元为不规则与复杂类别的 Tile 操作命名。它不包含可执行 ASL。其内容是 `PTO-UNIT` 元数据行（其 `depends_on` 列表指名指令单元和 Tile 模型单元）以及一行注释。操作本身由各自的指令单元定义。

该类别包含向新 Tile 写入整数序列或三角矩阵的生成类操作，以及 Tile 之间的带索引 gather 和 scatter。

<!-- PTO-READER-BLOCK: tile-model-dispatch-irregular-and-complex-concepts role=concepts-state -->
## 概念与可见状态

本单元不声明状态。Tile 操作目录把 4 个操作放入该类别。下表按语义处理程序对它们分组，语义处理程序是生成的分派程序调用的 ASL 函数。

| 操作 | 语义处理程序 |
| --- | --- |
| `TCI` | `TCI` |
| `TTRI` | `TTRI` |
| `TGATHER` | `TGATHER` |
| `TSCATTER` | `TSCATTER` |

全部四个操作都使用 mode 为 3 的 TEPL 族和 SFU 引擎：`TCI` `0x066`、`TTRI` `0x067`、`TGATHER` `0x06F` 和 `TSCATTER` `0x070`。它们之间的代码 `0x068` 以及 `0x06A` 到 `0x06D` 是被拒绝的仅审阅代码，`0x069` 和 `0x06E` 是保留的。

<!-- PTO-READER-BLOCK: tile-model-dispatch-irregular-and-complex-rules role=rules-interactions -->
## 规则与交互

分派不查看类别。Tile 执行用 `DecodeTileOperation(family, code)` 解码指令束描述符，其中族为 TEPL、TLSU 或 CUBE，代码为 12 位。没有目录行的代码返回 `PTO_TILE_OPERATION_COUNT`。`BundleOperationDescriptorLegal` 在 `BSTART` 解码时进行该检查，因此该 `BSTART` 以 `Fault_IllegalInstruction` 故障，指令束永远不会被安装；Tile 执行会重复该解码，若以这样的代码到达，也会引发同样的故障。

设计要点：类别是一种所有权与导航分组，而不是解码输入。把一个操作移到另一个类别，不会改变选择它的代码，也不会改变运行它的处理程序。

设计要点：`TCI`、`TTRI` 和 `TGATHER` 是 `RollbackSafe`，但 `TSCATTER` 是 `NonRollbackAuxiliary`。因此带 `B.ASSEMBLE` 修饰符的 `TSCATTER` 指令束会在任何效果之前以 `Fault_TileLegality` 故障。

<!-- PTO-READER-BLOCK: tile-model-dispatch-irregular-and-complex-boundaries role=boundaries -->
## 架构边界

本单元不解码、不检查合法性，也不执行任何内容。操作数 schema、合法性处理程序和执行属于各指令单元以及以下模型单元：

- [生成](../execution/generation.md)
- [重排](../execution/rearrangement.md)
- [带索引重排](../execution/indexed-rearrangement.md)
- [数值格式](../numeric/formats.md)
- [矩阵形状合法性](../legality/matrix-shape.md)

本单元的 `depends_on` 列表指名了目录放入该类别的全部四个指令单元。当指令束布局为 `CUBE_M16` 或 `CUBE_M32` 时，Tile 执行通过专用的 `TCICube` 路径运行 `TCI`，而不是通用处理程序。

<!-- PTO-READER-BLOCK: tile-model-dispatch-irregular-and-complex-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

`TSCATTER` 的 mode 为 3，function 为 16，因此其 selector 为 3 x 32 + 16 = 112，即 `0x070`。代码为 `0x06C` 的 TEPL 指令束找不到目录行，会以 `Fault_IllegalInstruction` 故障。

<!-- PTO-READER-BLOCK: tile-model-dispatch-irregular-and-complex-related role=related-owners-navigation -->
## 相关所有者

- [顶层分派](top-level.md)列出全部七个类别以及目录外壳。
- [Tile 执行](../../../block/model/dispatch/tile-execution.md)解码操作并运行其处理程序。
- [可移植载体](../../../block/model/operands/portable-carriers.md)拥有生产者效果类别。
- [TCI](../../irregular-and-complex/initialization/TCI.md) 是该类别的一个指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/dispatch/irregular-and-complex.asl -->
```asl
// PTO-UNIT: {"classification":["model","dispatch","irregular-and-complex"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE","PTO-TILE-MODEL-EXECUTION-GENERATION","PTO-TILE-MODEL-NUMERIC-FORMATS","PTO-TILE-MODEL-EXECUTION-REARRANGEMENT","PTO-TILE-MODEL-EXECUTION-INDEXED-REARRANGEMENT","PTO-TILE-TCI","PTO-TILE-TGATHER","PTO-TILE-TSCATTER","PTO-TILE-TTRI"],"id":"PTO-TILE-MODEL-DISPATCH-IRREGULAR-AND-COMPLEX","surface":"tile"}
// Dispatch ownership for the irregular-and-complex PTO Tile instruction class.
```
<!-- GENERATED-ASL-END: unit -->
