<!-- GENERATED FROM: asl/tile/model/dispatch/matrix-and-matrix-vector.asl -->
# Matrix And Matrix Vector

**Normative ASL source:** `asl/tile/model/dispatch/matrix-and-matrix-vector.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-DISPATCH-MATRIX-AND-MATRIX-VECTOR}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-dispatch-matrix-and-matrix-vector-purpose role=purpose-scope -->
## 用途与范围

本单元为矩阵与矩阵-向量类别的 Tile 操作命名。它不包含可执行 ASL。其内容是 `PTO-UNIT` 元数据行（其 `depends_on` 列表指名指令单元和 Tile 模型单元）以及一行注释。操作本身由各自的指令单元定义。

该类别中的每个操作都在 CUBE 引擎上进行矩阵乘法或矩阵-向量乘法。

<!-- PTO-READER-BLOCK: tile-model-dispatch-matrix-and-matrix-vector-concepts role=concepts-state -->
## 概念与可见状态

本单元不声明状态。Tile 操作目录把 12 个操作放入该类别。下表按语义处理程序对它们分组，语义处理程序是生成的分派程序调用的 ASL 函数。

| 操作 | 语义处理程序 |
| --- | --- |
| `TMATMUL`、`TMATMUL_BIAS`、`TMATMUL_ACC` | 各自使用同名的一个处理程序 |
| `TMATMUL_MX`、`TMATMUL_MX_BIAS`、`TMATMUL_MX_ACC` | 各自使用同名的一个处理程序 |
| `TGEMV`、`TGEMV_BIAS`、`TGEMV_ACC` | 各自使用同名的一个处理程序 |
| `TGEMV_MX`、`TGEMV_MX_BIAS`、`TGEMV_MX_ACC` | 各自使用同名的一个处理程序 |

全部 12 个操作都使用 CUBE 族，12 位代码就是 function 编号。function 遵循规则的模式：`TMATMUL` 为 0，MX 形式加 4，`TGEMV` 形式加 16，`_BIAS` 加 1，`_ACC` 加 2。function 3、7、8、9 到 15、19 以及 23 到 31 是保留的。每个操作都有自己的 `BSTART` 命令形式。

<!-- PTO-READER-BLOCK: tile-model-dispatch-matrix-and-matrix-vector-rules role=rules-interactions -->
## 规则与交互

分派不查看类别。Tile 执行用 `DecodeTileOperation(family, code)` 解码指令束描述符，其中族为 TEPL、TLSU 或 CUBE，代码为 12 位。没有目录行的代码返回 `PTO_TILE_OPERATION_COUNT`。`BundleOperationDescriptorLegal` 在 `BSTART` 解码时进行该检查，因此该 `BSTART` 以 `Fault_IllegalInstruction` 故障，指令束永远不会被安装；Tile 执行会重复该解码，若以这样的代码到达，也会引发同样的故障。

设计要点：类别是一种所有权与导航分组，而不是解码输入。把一个操作移到另一个类别，不会改变选择它的代码，也不会改变运行它的处理程序。

设计要点：该类别的每个处理程序的生产者效果类别都是 `AtomicAuxiliary`。可移植载体契约规定这类效果与 `B.ASSEMBLE` 主体参与同一事务，因此这些操作可以作为代次写者。

<!-- PTO-READER-BLOCK: tile-model-dispatch-matrix-and-matrix-vector-boundaries role=boundaries -->
## 架构边界

本单元不解码、不检查合法性，也不执行任何内容。操作数 schema、合法性处理程序和执行属于各指令单元以及以下模型单元：

- [CUBE 执行](../execution/cube.md)
- [矩阵形状合法性](../legality/matrix-shape.md)

本单元的 `depends_on` 列表指名了目录放入该类别的全部 12 个指令单元。Tile 执行把 CUBE 矩阵指令束送到块分派单元中的 CUBE 矩阵路径，而不经过通用的第 2 阶段准备。

<!-- PTO-READER-BLOCK: tile-model-dispatch-matrix-and-matrix-vector-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

`TGEMV_MX_ACC` 是 `TGEMV` 形式（16），带 MX（4）和累加（2），因此其 function 为 16 + 4 + 2 = 22。代码为 22 的 CUBE 指令束解码为 `TGEMV_MX_ACC`。代码 19 会是 16 + 1 + 2（同时带偏置和累加），它没有目录行，也没有任何 `BSTART` 形式产生它；外壳把它列为保留，生成的解码器检查断言它解码为 `PTO_TILE_OPERATION_COUNT`。

<!-- PTO-READER-BLOCK: tile-model-dispatch-matrix-and-matrix-vector-related role=related-owners-navigation -->
## 相关所有者

- [顶层分派](top-level.md)列出全部七个类别以及目录外壳。
- [Tile 执行](../../../block/model/dispatch/tile-execution.md)解码操作并运行其处理程序。
- [可移植载体](../../../block/model/operands/portable-carriers.md)拥有生产者效果类别。
- [TMATMUL](../../matrix-and-matrix-vector/matrix-matrix/TMATMUL.md) 是该类别的一个指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/dispatch/matrix-and-matrix-vector.asl -->
```asl
// PTO-UNIT: {"classification":["model","dispatch","matrix-and-matrix-vector"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE","PTO-TILE-MODEL-EXECUTION-CUBE","PTO-TILE-TGEMV","PTO-TILE-TGEMV-ACC","PTO-TILE-TGEMV-BIAS","PTO-TILE-TGEMV-MX","PTO-TILE-TGEMV-MX-ACC","PTO-TILE-TGEMV-MX-BIAS","PTO-TILE-TMATMUL","PTO-TILE-TMATMUL-ACC","PTO-TILE-TMATMUL-BIAS","PTO-TILE-TMATMUL-MX","PTO-TILE-TMATMUL-MX-ACC","PTO-TILE-TMATMUL-MX-BIAS"],"id":"PTO-TILE-MODEL-DISPATCH-MATRIX-AND-MATRIX-VECTOR","surface":"tile"}
// Dispatch ownership for the matrix-and-matrix-vector PTO Tile instruction class.
```
<!-- GENERATED-ASL-END: unit -->
