<!-- GENERATED FROM: asl/arch/state/tile-descriptor.asl -->
# Tile Descriptor

**Normative ASL source:** `asl/arch/state/tile-descriptor.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-TILE-DESCRIPTOR}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-tile-descriptor-purpose-scope role=purpose-scope -->
## 用途与范围

本单元是 Tile 描述符状态概念的稳定架构所有者，并把读者引向定义可执行状态的 Shared Tile 状态依赖项。

<!-- PTO-READER-BLOCK: arch-tile-descriptor-concepts-state role=concepts-state -->
## 概念所有权

源文件没有在本地声明描述符记录、字段或状态转换，而是明确把可执行状态交给依赖项定义。

<!-- PTO-READER-BLOCK: arch-tile-descriptor-rules-interactions role=rules-interactions -->
## 依赖关系

`PTO-ARCH-STATE-TILE-DESCRIPTOR` 依赖 `PTO-ARCH-FEATURES-SHARED-TILE-STATE`。描述符行为必须从该可达 ASL 图以及执行状态转换的指令所有者中取得。

<!-- PTO-READER-BLOCK: arch-tile-descriptor-boundaries role=boundaries -->
## 架构边界

本页不虚构描述符布局、有效性、容量、所有权、生存期或故障规则。只有名称的所有者不能成为这些属性的第二份语义定义。

<!-- PTO-READER-BLOCK: arch-tile-descriptor-example-usage role=example-usage -->
## 非规范阅读示例

面对描述符字段问题时，先用本页识别架构概念，再检查 Shared Tile 状态所有者以及读取或写入该字段的确切操作。

<!-- PTO-READER-BLOCK: arch-tile-descriptor-related-owners role=related-owners-navigation -->
## 相关所有者

- [Shared Tile 状态](../features/shared-tile-state.md)是直接依赖项。
- [已定义性](definedness.md)依赖这个概念所有者。
- [Tile 寄存器](../programming-model/tile-registers.md)提供 Tile 寄存器的编程模型入口。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/tile-descriptor.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-STATE-TILE-DESCRIPTOR","surface":"arch","classification":["state","tile-descriptor"],"depends_on":["PTO-ARCH-FEATURES-SHARED-TILE-STATE"]}
// This unit owns the named architecture concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
