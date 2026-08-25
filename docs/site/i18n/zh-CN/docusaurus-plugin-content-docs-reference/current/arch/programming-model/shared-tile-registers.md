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

本单元是 Shared Tile 寄存器的具名编程模型所有者，使 Shared Tile 概念拥有稳定的架构标识和导航目标。

<!-- PTO-READER-BLOCK: arch-shared-tile-registers-concepts-state role=concepts-state -->
## 概念所有权

该所有者自身不包含可执行状态声明或访问辅助函数。其源文件明确把可执行状态交给依赖项定义。

<!-- PTO-READER-BLOCK: arch-shared-tile-registers-rules-interactions role=rules-interactions -->
## 依赖关系

`PTO-ARCH-PROGRAMMING-MODEL-SHARED-TILE-REGISTERS` 依赖 `PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS`。需要了解可执行行为时，应阅读该依赖项及其可达的状态所有者。

<!-- PTO-READER-BLOCK: arch-shared-tile-registers-boundaries role=boundaries -->
## 架构边界

本页不定义 Shared Tile 状态的分配、生存期、容量、别名或指令效果。这些规则必须来自具备所有权的可达 ASL，而不是本解释页面。

<!-- PTO-READER-BLOCK: arch-shared-tile-registers-example-usage role=example-usage -->
## 非规范阅读示例

当问题询问 Shared Tile 寄存器如何变化时，用本页识别具名概念，再沿依赖链接继续查找，直到到达拥有相关状态转换的 ASL 单元。

<!-- PTO-READER-BLOCK: arch-shared-tile-registers-related-owners role=related-owners-navigation -->
## 相关所有者

- [Tile 寄存器](tile-registers.md)是直接依赖项。
- [Shared Tile 状态](../features/shared-tile-state.md)是相关的下游状态所有者，并不是本单元声明的依赖项。
- [架构概览](../overview/architecture.md)把 Shared Tile 状态列入架构状态闭包。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/programming-model/shared-tile-registers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROGRAMMING-MODEL-SHARED-TILE-REGISTERS","surface":"arch","classification":["programming-model","shared-tile-registers"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS"]}
// This unit owns the named architecture concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
