<!-- GENERATED FROM: asl/arch/programming-model/shared-tile-registers.asl -->
# Shared Tile Registers

**Normative ASL source:** `asl/arch/programming-model/shared-tile-registers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROGRAMMING-MODEL-SHARED-TILE-REGISTERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-shared-tile-registers-purpose-scope role=purpose-scope -->
## 用途与范围

Shared Tile 是一个 Core 的全部四个 PE 共同寻址的 Tile。Local Tile 被拆分为每 PE 分片；Shared Tile 则是一个覆盖整个 Core 的对象。本单元是 Shared Tile 寄存器的具名编程模型入口，并把读者引向定义它们的 ASL 所有者。

<!-- PTO-READER-BLOCK: arch-shared-tile-registers-concepts-state role=concepts-state -->
## 概念所有权

该所有者自身不包含可执行状态声明或访问辅助函数。其源文件明确把可执行状态交给依赖项定义。

它所命名的状态是 `PTO-STATE-TILE-SHARED`：`64` 个绝对的、Core 私有的寄存器 `S0` 到 `S63`。每条记录保存一个 Tile 描述符和载荷、一个分配掩码、一个已初始化掩码、一个整父级就绪标志和一个已发布标志。同一 Core 的全部四个 PE 寻址同一组 `64` 条记录。

<!-- PTO-READER-BLOCK: arch-shared-tile-registers-rules-interactions role=rules-interactions -->
## 依赖关系

`PTO-ARCH-PROGRAMMING-MODEL-SHARED-TILE-REGISTERS` 依赖 `PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS`。需要了解可执行行为时，应阅读该依赖项及其可达的状态所有者。

Shared Tile 由 `B.IOS` 绑定，而不是由 `B.IOT` 绑定。一个 `B.IOS` SizeCode 描述一项完整的、覆盖整个 Core 的 Shared 分配。

设计要点：Shared Tile 有自己的 `256 KiB` 池，与每个 PE 的 Local 池相互独立。因此 Shared 分配永远不会减少任何 PE 上的 Local 容量，Local 存储用满也不会阻止 Shared 分配。

<!-- PTO-READER-BLOCK: arch-shared-tile-registers-boundaries role=boundaries -->
## 架构边界

本页不定义 Shared Tile 状态的分配、生存期、容量、别名或指令效果。这些规则必须来自具备所有权的可达 ASL，而不是本解释页面。

设计要点：生产者覆盖、整父级就绪和发布是彼此独立的事实。Shared 源的消费者必须等待或空操作，直到父级既整父级就绪又已发布，因此一个 PE 上的消费者无法读取其他 PE 仍在写入的 Shared Tile。

<!-- PTO-READER-BLOCK: arch-shared-tile-registers-example-usage role=example-usage -->
## 非规范阅读示例

当问题询问 Shared Tile 寄存器如何变化时，用本页识别具名概念，再沿依赖链接继续查找，直到到达拥有相关状态转换的 ASL 单元。

例如，首次写入为 `S7` 记录分配掩码 `1100` 后，之后对 `S7` 的写入可以选择子集 `1000`。选择 `0011` 的写入包含记录掩码之外的 PE，不是对 `S7` 的兼容更新。

<!-- PTO-READER-BLOCK: arch-shared-tile-registers-related-owners role=related-owners-navigation -->
## 相关所有者

- [Tile 寄存器](tile-registers.md)是直接依赖项。
- [Shared Tile 状态](../features/shared-tile-state.md)是相关的下游状态所有者；它不是本单元声明的依赖项。
- [Shared Tile 寄存器模型](../../tile/model/state/shared-registers.md)拥有就绪、发布和掩码规则。
- [架构概览](../overview/architecture.md)在架构状态闭包中列出 Shared Tile 状态，并拥有 Shared 容量契约。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/programming-model/shared-tile-registers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROGRAMMING-MODEL-SHARED-TILE-REGISTERS","surface":"arch","classification":["programming-model","shared-tile-registers"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS"]}
// This unit owns the named architecture concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
