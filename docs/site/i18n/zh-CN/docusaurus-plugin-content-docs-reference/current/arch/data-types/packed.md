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

`asl/arch/data-types/packed.asl` 不含可执行 ASL。第 1 行是 `PTO-UNIT` 记录，第 2 行说明本单元拥有该具名架构概念，而可执行状态由其依赖定义。声明的一个依赖是 `PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES`。

因此本页记录的是 packed 概念的身份及其所有权边界，而不是打包规则。packed 元素表现出的任何数值或访存行为都归属于赋予它的单元。

设计要点：本单元被保留为没有主体的具名所有权点，而不是成为打包的第二份定义。其可观察的后果是：这里无法创建或修改任何 packed 规则；新的通道顺序或载体宽度必须在依赖中、或在消费该类型的指令归属单元中作出，并会在那一页而不是本页可见。

<!-- PTO-READER-BLOCK: arch-packed-concepts-state role=concepts-state -->
## 概念与可见状态

- 本单元不声明任何类型、状态对象或辅助函数，因此它没有自己的状态可描述。
- 依赖为 5 个名字以 `X2` 结尾的 `TileDataType` 成员分配编号：`TileDataType_E2M1X2` 为编号 `11`，`TileDataType_E1M2X2` 为编号 `12`，`TileDataType_HiF4X2` 为编号 `14`，`TileDataType_S4X2` 为编号 `20`，`TileDataType_U4X2` 为编号 `28`。
- 这些编号位于依赖的 `TileDataTypeEncoding` 中，其类型是 `bits(5)`。编号 `22`、`23`、`29`、`30` 和 `31` 在那里是保留值，并在产生架构效果之前被拒绝。

设计要点：`X2` 是数据类型命名空间里的名字，而不是关于存储的陈述。依赖分配编号和名字，而一个载体包含多少通道、这些通道的次序、以及移动对内存的影响由其他归属单元陈述。需要这些事实的读者无法在本页获得它们，而这个缺口正是本单元的实际内容。

<!-- PTO-READER-BLOCK: arch-packed-rules-interactions role=rules-interactions -->
## 规则与交互

依赖把编号 `0` 分配给 `FP64`，并声明零绝不表示缺失、继承、`NONE` 或 `NULL`，因此没有任何 packed 成员有零编号的写法。

表示“没有数据类型”的哨兵是另一个 5 位常量，即编号 `31`；`TileDataTypeEncodingValid` 拒绝它，它也不是 `TileDataType` 成员。

packed 助记符仍然受其自身的解码、合法性和移动契约约束。本单元不为其中任何一个添加分支，也不定义状态转移。

设计要点：由于保留编号会被拒绝，而不是解码为默认值，上面 5 个编号是唯一能够命名 packed 类型的编码。因此增加第 6 种 packed 类型、或增加“未指定 packed”编码，都需要修改依赖，而无法通过留下一个未分配编号来实现。

<!-- PTO-READER-BLOCK: arch-packed-boundaries role=boundaries -->
## 架构边界

这里没有陈述任何通道顺序、载体宽度或内存移动，因为归属单元不包含任何可以固定它们的陈述。

第 2 行的注释就是本单元的全部内容，因此规则的缺失是所有权边界，而不是本页可以填补的未指定规则。

设计要点：读者若来到 packed 页面却找不到辅助函数，应把这一点当作导航结果，并继续阅读格式或指令归属单元。把该缺口读成可以自由选择实现定义的 packed 表示，会造出一条没有 ASL 归属的规则，而这正是具名概念单元所避免的。

<!-- PTO-READER-BLOCK: arch-packed-example-usage role=example-usage -->
## 非规范阅读示例

要阅读 `TileDataType_U4X2`，先从依赖取得它的身份：它是 27 个 `TileDataType` 成员之一，并被分配编号 `28`。

然后按消费该类型的指令了解其移动和通道行为，按格式归属单元了解其数值解释。本页只贡献一个事实：`U4X2` 是一个有分配编号的具名成员，而拥有该名字的单元不含可执行 ASL。

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
