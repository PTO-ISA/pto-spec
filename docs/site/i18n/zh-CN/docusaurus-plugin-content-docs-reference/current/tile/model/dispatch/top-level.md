<!-- GENERATED FROM: asl/tile/model/dispatch/top-level.asl -->
# Top Level

**Normative ASL source:** `asl/tile/model/dispatch/top-level.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-DISPATCH-TOP-LEVEL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-dispatch-top-level-purpose role=purpose-scope -->
## 用途与范围

本单元是 Tile 分派类别的根。它不包含可执行 ASL。其内容是 `PTO-UNIT` 元数据行和一条注释：块分派程序恰好选择一个绑定到目录的 Tile 操作类别。

该元数据承担两项工作。其 `depends_on` 列表指名七个类别单元。其 `catalog_projection` 对象提供生成的 Tile 操作目录的外壳：即不属于单个操作记录的字段。

<!-- PTO-READER-BLOCK: tile-model-dispatch-top-level-concepts role=concepts-state -->
## 概念与可见状态

本单元不声明状态。七个类别为：

| 类别 | 族 | 操作数 |
| --- | --- | --- |
| 逐元素 tile-tile | TEPL mode 0 | 26 |
| tile-标量与立即数 | TEPL mode 1 | 15 |
| 归约与扩展 | TEPL mode 2 | 28 |
| 不规则与复杂 | TEPL mode 3 | 4 |
| 布局与重排 | TEPL mode 3 和 TLSU | 6 |
| 内存与数据移动 | TLSU | 27 |
| 矩阵与矩阵-向量 | CUBE | 12 |

共 118 个操作，即目录的 `operation_count`。

`catalog_projection` 外壳保存：

- `reserved`：TEPL selector 范围、TLSU function 28 到 31，以及没有命名操作的 CUBE function；
- `rejected_review_only_codes`：八个 TEPL 代码，`0x060`、`0x062`、`0x063`、`0x068` 以及 `0x06A` 到 `0x06D`；
- `deleted_names`：33 个以前的助记符，例如 `TSORT`、`TMRGSORT`、`TCONCAT` 和 `TFILLPAD`；
- `rejected_names`：`TEXRACT`、`TFILL/TEXPANDS`、`TPOW` 和 `TPOWS`。

<!-- PTO-READER-BLOCK: tile-model-dispatch-top-level-rules role=rules-interactions -->
## 规则与交互

目录投影器把这个外壳复制到 `spec/catalog/tile-operations.json` 中，并用各指令单元填充 `operations` 列表。`DecodeTileOperation` 由操作列表生成。不在列表中的代码（包括每个保留代码和仅审阅代码）得到 `PTO_TILE_OPERATION_COUNT`。`BundleOperationDescriptorLegal` 在 `BSTART` 解码时进行该检查，因此该 `BSTART` 在指令束被安装之前以 `Fault_IllegalInstruction` 故障；Tile 执行会重复同样的解码。

设计要点：保留代码和被拒绝代码被明确列出，而不是作为空隙留下。解码器生成器为每个列出的代码生成一项检查，确认它不解码到任何操作，因此之后在保留代码上添加的操作会与生成的检查冲突。

设计要点：被删除的名称被记录下来，而不是被遗忘。ADR-TILE-0013 退役了 `TSORT`、`TMRGSORT` 以及其他六个操作，并规定它们以前的编码以 `Fault_IllegalInstruction` 拒绝，且没有兼容别名。把这些名称保留在外壳中，标明它们是有意从目录中缺席的。

<!-- PTO-READER-BLOCK: tile-model-dispatch-top-level-boundaries role=boundaries -->
## 架构边界

本单元不是块分派程序。命令解码和指令束执行属于块模型分派单元。它也不在运行时选择类别：解码键是族和 12 位代码，类别是每个操作上的目录标签。

`BSTART.TIMG2COL` 使用外壳保留的 TLSU function 28。它不是目录中的操作。Tile 执行识别其确切的命令形式并跳过通用解码。

<!-- PTO-READER-BLOCK: tile-model-dispatch-top-level-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

代码为 `0x06C` 的 TEPL 指令束位于被拒绝的仅审阅列表中，而 `TSORT` 位于 `deleted_names` 中。`DecodeTileOperation` 找不到该代码的行，因此该 `BSTART` 在 `BundleOperationDescriptorLegal` 中以 `Fault_IllegalInstruction` 故障，发生在指令束被安装之前。代码为 `0x06F` 的 TEPL 指令束找到 `TGATHER` 行，它属于不规则与复杂类别。

<!-- PTO-READER-BLOCK: tile-model-dispatch-top-level-related role=related-owners-navigation -->
## 相关所有者

- [逐元素 tile-tile](elementwise-tile-tile.md)、[tile-标量与立即数](tile-scalar-and-immediate.md)、[归约与扩展](reduce-and-expand.md)和[不规则与复杂](irregular-and-complex.md)是仅使用 TEPL 的类别。
- [布局与重排](layout-and-rearrangement.md)、[内存与数据移动](memory-and-data-movement.md)和[矩阵与矩阵-向量](matrix-and-matrix-vector.md)是其余类别。
- [Tile 执行](../../../block/model/dispatch/tile-execution.md)解码并运行所选操作。
- [块顶层分派](../../../block/model/dispatch/top-level.md)是命令级分派程序。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/dispatch/top-level.asl -->
```asl
// PTO-UNIT: {"catalog_projection":{"catalog":"tile-operations","deleted_names":["ACCCVT","TADDC","TADDSC","TALLOC","TAXPY","TCONCAT","TDEINTERLEAVE","TDEQUANT","TFILLPAD","TFMOD","TFMODS","TFREE","TEXTRACT","TGATHERB","THISTOGRAM","TINSERT","TINTERLEAVE","TLRELU","TPARTADD","TPARTARGMAX","TPARTARGMIN","TPARTMAX","TPARTMIN","TPARTMUL","TPOP","TPRELU","TPUSH","TQUANT","TRESHAPE","TSORT","TSORT32","TTRANS","TMRGSORT"],"isa":"PTO Instruction Set Architecture","rejected_names":["TEXRACT","TFILL/TEXPANDS","TPOW","TPOWS"],"rejected_review_only_codes":{"CUBE":[],"TEPL":["0x060","0x062","0x063","0x068","0x06A","0x06B","0x06C","0x06D"],"TLSU":[]},"reserved":{"cube_functions_without_named_alias":[3,7,8,[9,15],19,[23,31]],"tepl_selector_ranges":[["0x005","0x005"],["0x00E","0x00E"],["0x018","0x019"],["0x01E","0x01F"],["0x025","0x025"],["0x02F","0x039"],["0x03C","0x03F"],["0x04E","0x04F"],["0x05E","0x05F"],["0x061","0x061"],["0x065","0x065"],["0x069","0x069"],["0x06E","0x06E"],["0x071","0x074"],["0x079","0x07D"],["0x07F","0x07F"]],"tlsu_functions":[[28,31]]},"schema_version":3},"classification":["model","dispatch","top-level"],"depends_on":["PTO-TILE-MODEL-DISPATCH-ELEMENTWISE-TILE-TILE","PTO-TILE-MODEL-DISPATCH-TILE-SCALAR-AND-IMMEDIATE","PTO-TILE-MODEL-DISPATCH-REDUCE-AND-EXPAND","PTO-TILE-MODEL-DISPATCH-MEMORY-AND-DATA-MOVEMENT","PTO-TILE-MODEL-DISPATCH-MATRIX-AND-MATRIX-VECTOR","PTO-TILE-MODEL-DISPATCH-LAYOUT-AND-REARRANGEMENT","PTO-TILE-MODEL-DISPATCH-IRREGULAR-AND-COMPLEX"],"id":"PTO-TILE-MODEL-DISPATCH-TOP-LEVEL","surface":"tile"}
// The block dispatcher selects exactly one catalog-bound tile operation class.
```
<!-- GENERATED-ASL-END: unit -->
