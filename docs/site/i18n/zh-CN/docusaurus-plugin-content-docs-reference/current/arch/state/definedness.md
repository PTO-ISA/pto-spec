<!-- GENERATED FROM: asl/arch/state/definedness.asl -->
# Definedness

**Normative ASL source:** `asl/arch/state/definedness.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-DEFINEDNESS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-definedness-purpose-scope role=purpose-scope -->
## 用途与范围

本单元为架构已定义性提供稳定的状态所有者标识，并提供通往 Tile 描述符依赖项的路径；可执行状态由该依赖项提供。

<!-- PTO-READER-BLOCK: arch-definedness-concepts-state role=concepts-state -->
## 概念所有权

该所有者没有在本地声明已定义性字段、枚举或状态转换。其源文件明确表示可执行状态由依赖项定义。

<!-- PTO-READER-BLOCK: arch-definedness-rules-interactions role=rules-interactions -->
## 依赖关系

`PTO-ARCH-STATE-DEFINEDNESS` 依赖 `PTO-ARCH-STATE-TILE-DESCRIPTOR`。因此，任何具体的已定义性规则都必须从可达的当前 ASL 所有者中读取，不能根据本页标题推断。

<!-- PTO-READER-BLOCK: arch-definedness-boundaries role=boundaries -->
## 架构边界

本页不定义值何时变为已定义、未定义、已初始化、无效或触发故障，也不会引入隐式有效位。

<!-- PTO-READER-BLOCK: arch-definedness-example-usage role=example-usage -->
## 非规范阅读示例

如果审阅要确认某个 Tile 字段在一次转换之前是否可读，只能把本页用作概念索引。最终应在包含实际规则的 Tile 描述符或状态转换所有者处解决问题。

<!-- PTO-READER-BLOCK: arch-definedness-related-owners role=related-owners-navigation -->
## 相关所有者

- [Tile 描述符](tile-descriptor.md)是直接依赖项。
- [Shared Tile 状态](../features/shared-tile-state.md)可通过 Tile 描述符依赖项到达。
- [架构概览](../overview/architecture.md)解释架构状态的单一所有者规则。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/definedness.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-STATE-DEFINEDNESS","surface":"arch","classification":["state","definedness"],"depends_on":["PTO-ARCH-STATE-TILE-DESCRIPTOR"]}
// This unit owns the named architecture concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
