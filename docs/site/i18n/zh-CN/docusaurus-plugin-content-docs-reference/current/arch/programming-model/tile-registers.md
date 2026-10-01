<!-- GENERATED FROM: asl/arch/programming-model/tile-registers.asl -->
# Tile Registers

**Normative ASL source:** `asl/arch/programming-model/tile-registers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-tile-registers-purpose-scope role=purpose-scope -->
## 用途与范围

Tile 是保存在架构 Tile 存储中的二维元素块。Tile 操作把 Tile 作为源读取，并把新的 Tile 作为目标发布。本单元是 Local Tile 寄存器的具名编程模型入口，并把读者引向定义它们的 ASL 所有者。

本单元本身不声明存储，也不声明访问过程。其源文件表明可执行状态由其依赖项定义。

<!-- PTO-READER-BLOCK: arch-tile-registers-concepts-state role=concepts-state -->
## 概念所有权

共有 `64` 个 Local Tile 寄存器。每个寄存器保存一个 `TileInfo` 描述符，记录分配、形状、有效区域、数据类型、布局、容量、元素已定义性和载荷。每个寄存器还有一个四位分配掩码，记录哪些 PE 持有它的分片。

这些寄存器分成 T、U、M、N 四个 hand，每个 hand 有 `16` 个寄存器。程序按 hand 和新旧顺序命名 Local Tile，例如 `T#1` 表示最新的 T Tile，`T#2` 表示它之前的那个。

设计要点：目标只命名其 hand，而不命名寄存器编号。目标发布时成为其 hand 的 `#1`，较早的存活代次向 `#16` 移动。源代次保持存在，因此程序可以用新的相对名称继续读取较早的 Tile，例如 `T#2`。

<!-- PTO-READER-BLOCK: arch-tile-registers-rules-interactions role=rules-interactions -->
## 依赖关系

`PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS` 依赖 `PTO-ARCH-FEATURES-PREDICATION`。由依赖图而非补充说明决定哪个可达 ASL 所有者提供具体状态规则。

Local Tile 存储本身是 `PTO-STATE-TILE-LOCAL`，由 Tile local-register 模型拥有。它是封闭架构状态集合的一个成员。

设计要点：操作读取或发布的每个 Tile 都是带有显式描述符的具名 Local 或 Shared Tile 寄存器，`PTO-STATE-TILE-LOCAL` 与 `PTO-STATE-TILE-SHARED` 是封闭架构状态集合中的 Tile 寄存器成员。该集合之外的实现存储，例如 CUBE 内部累加器缓存，不得改变架构结果、故障或发布。

<!-- PTO-READER-BLOCK: arch-tile-registers-boundaries role=boundaries -->
## 架构边界

这个概念页面不指定 Tile 形状、数据、有效性、容量、谓词结果或指令效果。读者必须到相关功能、状态和指令所有者中查找这些契约。

容量按 PE 计算。一个 `B.IOT` 目标可以使用 `128 B` 到 `64 KiB`，计入每个被选中 PE 的 `256 KiB` Local 池，与 Shared 池相互独立。

<!-- PTO-READER-BLOCK: arch-tile-registers-example-usage role=example-usage -->
## 非规范阅读示例

对于 Tile 寄存器谓词问题，先从本页确认编程模型术语，再沿谓词依赖继续查找，最后用生成的 ASL 及其 AVS 引用检查实际所有者。

以命名为例，假设 `T#1` 命名 Tile A，`T#2` 命名 Tile B。宏 `TADD <Row=8, Col=64, FP32>, T#1, T#2, ->T<2KB>` 把和发布为新的 `T#1`。完成后，Tile A 仍然存活并被命名为 `T#2`，Tile B 被命名为 `T#3`。

<!-- PTO-READER-BLOCK: arch-tile-registers-related-owners role=related-owners-navigation -->
## 相关所有者

- [谓词](../features/predication.md)是直接依赖项。
- [Local Tile 寄存器](../../tile/model/state/local-registers.md)拥有 `PTO-STATE-TILE-LOCAL` 以及最新优先的 hand 规则。
- [Tile 分配](../features/tile-allocation.md)声明 Local 池和单对象容量限制。
- [Shared Tile 寄存器](shared-tile-registers.md)在本单元基础上建立其具名概念。
- [Core PE 拓扑](core-pe-topology.md)声明 Tile 与 Shared Tile 命名空间数量。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/programming-model/tile-registers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS","surface":"arch","classification":["programming-model","tile-registers"],"depends_on":["PTO-ARCH-FEATURES-PREDICATION"]}
// This unit owns the named architecture concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
