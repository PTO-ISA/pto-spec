<!-- GENERATED FROM: asl/arch/data-types/packed.asl -->
# Packed

**Normative ASL source:** `asl/arch/data-types/packed.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-PACKED}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-packed-purpose-scope role=purpose-scope -->
## 目的与范围

本单元是打包数据类型的当前架构身份，并依赖 Tile 数据类型命名空间。

它提供稳定的归属点，使其他归属单元可以引用打包概念，而无需在说明文字中另立编码或执行契约。

<!-- PTO-READER-BLOCK: arch-packed-concepts-state role=concepts-state -->
## 概念与可见状态

- 除 `PTO-UNIT` 身份外，本单元不包含独立的 ASL 类型、状态或可执行辅助函数。
- 其依赖 `PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES` 拥有 `S4X2`、`U4X2`、`E2M1X2`、`E1M2X2` 和 `HiF4X2` 等已分配的打包 Tile 成员。
- 打包布局、通道解释、内存搬运和算术行为仍由定义相应机制的当前归属单元负责。

<!-- PTO-READER-BLOCK: arch-packed-rules-interactions role=rules-interactions -->
## 规则与交互

不能仅凭“打包”一词推断统一的通道顺序或载体宽度；必须查阅所选 `TileDataType` 及其格式或执行归属单元。

这一命名概念不创建架构状态，也不执行任何状态转换。

打包指令仍由自身的解码、合法性、搬运和结果契约约束。

<!-- PTO-READER-BLOCK: arch-packed-boundaries role=boundaries -->
## 架构边界

本页不能用说明文字补充缺失的打包语义，因为归属单元有意不定义这些规则；新增规则必须修改相应 ASL/NDF 归属单元。

历史 ADR 可以解释为何设置该归属点，但当前含义必须从可达的 ASL 归属单元读取。

<!-- PTO-READER-BLOCK: arch-packed-example-usage role=example-usage -->
## 非规范阅读示例

遇到 `TileDataType_U4X2` 时，应先由 Tile 数据类型归属单元确认其已分配身份，再到使用该类型的指令中查看通道和内存行为。

因此，这里没有辅助函数表示的是导航边界，并不允许随意选择实现定义的打包表示。

<!-- PTO-READER-BLOCK: arch-packed-related-owners role=related-owners-navigation -->
## 相关归属单元

- [Tile 数据类型](tile-data-types.md)
- [数值格式分派](numeric-formats.md)
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/packed.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-PACKED","surface":"arch","classification":["data-types","packed"],"depends_on":["PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES"]}
// This unit owns the named architecture concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
