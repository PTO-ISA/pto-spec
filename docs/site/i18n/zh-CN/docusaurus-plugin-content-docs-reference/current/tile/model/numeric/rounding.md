<!-- GENERATED FROM: asl/tile/model/numeric/rounding.asl -->
# Rounding

**Normative ASL source:** `asl/tile/model/numeric/rounding.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-NUMERIC-ROUNDING}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-numeric-rounding-purpose role=purpose-scope -->
## 作用与范围

本单元不包含可执行 ASL。它唯一的内容是一条注释，说明 Tile 舍入选择由架构舍入模型与格式操作定义。它依赖 Tile formats 单元以及架构舍入单元 `PTO-ARCH-DATA-TYPES-ROUNDING`。

请把本页当作一张地图阅读：Tile 舍入模式从何而来，又在何处应用。

<!-- PTO-READER-BLOCK: tile-model-numeric-rounding-concepts role=concepts-state -->
## 概念与可见状态

`NumericRoundingMode` 命名七种模式：

| 模式 | 含义 |
| --- | --- |
| RNE | 就近，平局取偶 |
| RTM | 向负无穷 |
| RTP | 向正无穷 |
| RTZ | 向零 |
| RNA | 就近，平局远离零 |
| RTO | 向奇：不精确结果取最低位为奇数的相邻值 |
| RHB | 就近，平局取数值较大的候选 |

`NumericExecutionControl` 把一种模式与一个 `saturating` 标志配对。`DefaultNumericExecutionControl` 为 RNE 且不饱和。

<!-- PTO-READER-BLOCK: tile-model-numeric-rounding-rules role=rules-interactions -->
## 规则与交互

指令束的三位 `RMode` 字段由 `DecodeBundleRoundingSelection` 译码：`000` 请求操作默认值，`010` 为 RTZ，`011` 为 RTM，`100` 为 RTP，`101` 为 RNA，`110` 为 RTO，`111` 为 RHB。编码 `001` 显式选择 RNE。

默认值由操作的归属单元决定。对 `TCVT`，浮点到整数的默认值为 RTZ，其他情况为 RNE。

设计要点：模式名称是语义性的，每种编码选择器都显式映射到它们。其结果是：同一个 `NumericRoundingMode` 值无论来自指令束、标量控制寄存器还是固定转换，含义都相同，尽管编码各不相同。

设计要点：某些操作限制其接受的模式。涉及 E6M2 或 RCPE6M2 时，`HardwareTCVTRoundingModeSupported` 只允许 RNE 与 RNA；其他模式在目标分配之前被拒绝。

舍入本身发生在格式编码器内部，例如 `ReferenceMatrixFloatingEncoding`、`ReferencePacked4Encoding`、`ReferenceE6M2Encoding` 与 `ReferenceE8M0RoundExponent`。有些辅助函数忽略所请求的模式：浮点取模与有限值一元参考辅助函数总是以默认控制编码。

<!-- PTO-READER-BLOCK: tile-model-numeric-rounding-boundaries role=boundaries -->
## 架构边界

本单元不定义任何模式、编码或舍入算法。归属单元为：

- 架构 rounding 单元拥有模式枚举与控制记录。
- 标量 FSU arithmetic 单元拥有 `DecodeBundleRoundingSelection`。
- 每个操作拥有其默认模式与可接受模式。
- 每个格式编码器拥有值如何被舍入。

<!-- PTO-READER-BLOCK: tile-model-numeric-rounding-example role=example-usage -->
## 非规范阅读示例

按 `FloatingToInteger` 的方式，在各模式下把 2.5 舍入为整数：

- RNE 得 2，RNA 得 3，RHB 得 3。
- RTZ 得 2，RTM 得 2，RTP 得 3。
- RTO 得 3，因为 2 是偶数且结果不精确。

对负 2.5，RNE 得 -2，RNA 得 -3，RHB 得 -2，RTO 得 -3。

`RMode=000` 的 FP32 到 S32 `TCVT` 使用操作默认值 RTZ，因此 2.7 变为 2。

<!-- PTO-READER-BLOCK: tile-model-numeric-rounding-related role=related-owners-navigation -->
## 相关归属

- [Rounding](../../../arch/data-types/rounding.md) 拥有模式枚举与控制记录。
- [Scalar FSU arithmetic](../../../scalar/model/fsu/arithmetic.md) 拥有选择器译码与 `FloatingToInteger`。
- [Formats](formats.md) 与 [E8M0 conversion](e8m0-conversion.md) 展示 TCVT 在何处应用模式。
- [Exceptions](exceptions.md) 是标志方面的配套指针。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/numeric/rounding.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-NUMERIC-ROUNDING","surface":"tile","classification":["model","numeric","rounding"],"depends_on":["PTO-TILE-MODEL-NUMERIC-FORMATS","PTO-ARCH-DATA-TYPES-ROUNDING"]}
// Tile rounding selection is defined by the architecture rounding model and format operations.
```
<!-- GENERATED-ASL-END: unit -->
