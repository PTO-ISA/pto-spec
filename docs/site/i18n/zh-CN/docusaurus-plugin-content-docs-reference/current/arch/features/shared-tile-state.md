<!-- GENERATED FROM: asl/arch/features/shared-tile-state.asl -->
# Shared Tile State

**Normative ASL source:** `asl/arch/features/shared-tile-state.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-FEATURES-SHARED-TILE-STATE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-shared-tile-state-purpose role=purpose-scope -->
## 用途与范围

`PTO-ARCH-FEATURES-SHARED-TILE-STATE` 是共享 Tile 状态概念的架构级标记。

<!-- PTO-READER-BLOCK: arch-shared-tile-state-concepts role=concepts-state -->
## 概念与状态

- 把本页作为概念索引使用。
- 沿下方生成 ASL 中列出的依赖项检查具体状态。
- 从该状态所有者继续前往操作所有者，以回答状态修改问题。

<!-- PTO-READER-BLOCK: arch-shared-tile-state-rules role=rules-interactions -->
## 如何沿所有权链阅读

先查看生成的单元元数据，再前往依赖项的当前 ASL，不要把本标记页面当作可执行定义。

<!-- PTO-READER-BLOCK: arch-shared-tile-state-boundaries role=boundaries -->
## 边界

不要从本标记推导分配、可见性、发布或配置档行为。请在相应的当前 ASL 所有者中定位这些问题。

<!-- PTO-READER-BLOCK: arch-shared-tile-state-example role=example-usage -->
## 非规范阅读示例

本示例块只用于帮助阅读：先应用上文规则，再到规范 ASL 所有者中确认结果。它不会增加任何架构契约。

<!-- PTO-READER-BLOCK: arch-shared-tile-state-related role=related-owners-navigation -->
## 相关所有者

- 打开生成单元元数据中列出的依赖项以查看具体状态。
- 继续前往当前所调查状态转换的操作所有者。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/features/shared-tile-state.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-FEATURES-SHARED-TILE-STATE","surface":"arch","classification":["features","shared-tile-state"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-SHARED-TILE-REGISTERS"]}
// This unit owns the named architecture concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
