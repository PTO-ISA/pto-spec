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

本单元是 Tile 寄存器的具名编程模型所有者，并提供从编程模型术语进入可执行架构所有者的稳定路径。

<!-- PTO-READER-BLOCK: arch-tile-registers-concepts-state role=concepts-state -->
## 概念所有权

本单元不声明独立的 Tile 寄存器存储或访问过程。其源文件表明可执行状态由依赖项定义。

<!-- PTO-READER-BLOCK: arch-tile-registers-rules-interactions role=rules-interactions -->
## 依赖关系

`PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS` 依赖 `PTO-ARCH-FEATURES-PREDICATION`。由依赖图而非补充说明决定哪个可达 ASL 所有者提供具体状态规则。

<!-- PTO-READER-BLOCK: arch-tile-registers-boundaries role=boundaries -->
## 架构边界

这个概念页面不指定 Tile 形状、数据、有效性、容量、谓词结果或指令效果。读者必须到相关功能、状态和指令所有者中查找这些契约。

<!-- PTO-READER-BLOCK: arch-tile-registers-example-usage role=example-usage -->
## 非规范阅读示例

对于 Tile 寄存器谓词问题，先从本页确认编程模型术语，再沿谓词依赖继续查找，最后用生成的 ASL 及其 AVS 引用检查实际所有者。

<!-- PTO-READER-BLOCK: arch-tile-registers-related-owners role=related-owners-navigation -->
## 相关所有者

- [谓词](../features/predication.md)是直接依赖项。
- [Shared Tile 寄存器](shared-tile-registers.md)在本单元之上建立其具名概念。
- [Core PE 拓扑](core-pe-topology.md)声明 Tile 和 Shared Tile 命名空间数量。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/programming-model/tile-registers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS","surface":"arch","classification":["programming-model","tile-registers"],"depends_on":["PTO-ARCH-FEATURES-PREDICATION"]}
// This unit owns the named architecture concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
