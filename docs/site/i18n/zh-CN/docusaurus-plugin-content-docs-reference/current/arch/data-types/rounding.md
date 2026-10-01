<!-- GENERATED FROM: asl/arch/data-types/rounding.asl -->
# Rounding

**Normative ASL source:** `asl/arch/data-types/rounding.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-ROUNDING}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-rounding-purpose-scope role=purpose-scope -->
## 目的与范围

`NumericRoundingMode` 是舍入模式的语义枚举，`NumericExecutionControl` 是把一个模式与 `saturating` 标志配成对的二元记录。同一文件还声明了有界的 `NumericApplicabilityRuleSet` 枚举。

本单元只拥有含义。它不读任何选择器域，也不对任何值舍入，因此使用方必须先把编码的选择器解析为 `NumericRoundingMode`，再把该记录交给操作。

设计要点：标量 `FRM`、定点转换覆盖、指令束 `RMode` 以及公共 API 控制，是同一小组含义的四种不同编码，而每种含义在本枚举中只出现一次。后果是枚举位置在任何地方都不是编码，而且同样的三位在两个命名空间里可以表示两个不同模式：`010` 在 `ResolveScalarFPActiveRoundingMode` 中为标量 `FRM` 选择 `NumericRound_RTP`，而 `010` 在 `DecodeBundleRoundingSelection` 中为指令束 `RMode` 选择 `NumericRound_RTZ`。

<!-- PTO-READER-BLOCK: arch-rounding-concepts-state role=concepts-state -->
## 概念与可见状态

- `NumericRoundingMode` 有 7 个成员：`NumericRound_RNE`、`NumericRound_RTM`、`NumericRound_RTP`、`NumericRound_RTZ`、`NumericRound_RNA`、`NumericRound_RTO` 和 `NumericRound_RHB`。
- `NumericExecutionControl` 恰有两个域，`rounding_mode: NumericRoundingMode` 与 `saturating: boolean`。
- `NumericApplicabilityRuleSet` 有两个成员，`NumericApplicabilityRules_None` 与 `NumericApplicabilityRules_MxRejection`。

设计要点：`DefaultNumericExecutionControl()` 把 `NumericRound_RNE` 与 `saturating = FALSE` 作为一个值返回，而不是两个独立默认值。需要架构默认值的使用方通过一次调用同时得到两个域，因此不会因为只选其中一个而把默认模式与不同的饱和设置配成对。

<!-- PTO-READER-BLOCK: arch-rounding-rules-interactions role=rules-interactions -->
## 规则与交互

架构默认值是 `NumericRound_RNE` 与 `saturating = FALSE`。`DefaultNumericExecutionControl` 是不带参数的 `pure func`，因此其结果不依赖任何寄存器，也不依赖任何编码域。

解析指令默认值是另一步，有自己的归属单元。`ResolveTileNumericExecutionControl` 复制操作数控制记录，并在指令要求操作默认值时把 `rounding_mode` 替换为 `NumericRound_RNE`；当操作是 `TileOperation_TCVT` 且源为浮点、目的不是浮点时，替换为 `NumericRound_RTZ`。该分支不改变 `saturating`。

设计要点：操作默认值由解析器应用，而不是通过改写 `DefaultNumericExecutionControl`。后果是两种情形保持可区分：显式控制保留调用方编码的模式，而被取默认值的控制只替换 `rounding_mode`，`saturating` 仍原样来自操作数控制。

<!-- PTO-READER-BLOCK: arch-rounding-boundaries role=boundaries -->
## 架构边界

本单元不定义算法。某个操作对哪个值舍入、舍入结果如何变成 `Word`，都属于操作与配置档的 ASL。

`NumericApplicabilityRuleSet` 只选择一组有界的、被接受的负面适用性规则。没有拒绝并不声称目标支持什么，也不选择结果语义。

设计要点：`NumericApplicabilityRules_MxRejection` 是一个具名规则集，而不是布尔的“已拒绝”标志。由于该枚举命名的是哪些负面规则处于活动状态，这个值在选定该规则集的归属单元之外没有意义，而是否拒绝某个具体操作数仍由该归属单元决定。

<!-- PTO-READER-BLOCK: arch-rounding-example-usage role=example-usage -->
## 非规范阅读示例

标量浮点操作从它所指名的编码域读取活动模式：`ScalarFPActiveRoundingMode` 把 `core_state[39:37]` 传给 `ResolveScalarFPActiveRoundingMode`，后者把 `001` 映射为 `NumericRound_RTM`、`010` 映射为 `NumericRound_RTP`、`011` 映射为 `NumericRound_RTZ`，其余任何值映射为 `NumericRound_RNE`。

定点转换不查询该域。`ScalarFPFixedConversionRoundingMode` 把 `ScalarOperation_FCVTA` 映射为 `NumericRound_RNA`、`ScalarOperation_FCVTM` 映射为 `NumericRound_RTM`、`ScalarOperation_FCVTN` 映射为 `NumericRound_RNE`、`ScalarOperation_FCVTP` 映射为 `NumericRound_RTP`、`ScalarOperation_FCVTZ` 映射为 `NumericRound_RTZ`。

指令束选择器通过两步到达同一类型：`DecodeBundleRoundingSelection` 把三位的 `RMode` 变成选择记录，其 `rounding_mode` 是 7 个成员之一；`ResolveTileNumericExecutionControl` 从操作数读取该选择，并产生本单元声明的 `NumericExecutionControl`。

<!-- PTO-READER-BLOCK: arch-rounding-related-owners role=related-owners-navigation -->
## 相关归属单元

- [数值分类](numeric-classification.md)
- [浮点](floating-point.md)
- [硬件数值配置档](../features/mx-formats.md)
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/rounding.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-ROUNDING","surface":"arch","classification":["data-types","rounding"],"depends_on":["PTO-ARCH-DATA-TYPES-FLOATING-POINT"]}
// Semantic rounding modes are independent of every encoded selector
// namespace. Scalar FRM, fixed conversion overrides, bundle RMode, and public
// API controls must resolve into this type explicitly.
type NumericRoundingMode of enumeration {
    NumericRound_RNE,
    NumericRound_RTM,
    NumericRound_RTP,
    NumericRound_RTZ,
    NumericRound_RNA,
    NumericRound_RTO,
    NumericRound_RHB
};

type NumericExecutionControl of record {
    rounding_mode: NumericRoundingMode,
    saturating: boolean
};

// Bit-exact value classes are format properties. They do not select an
// operation result, exception flag, target profile, or arithmetic algorithm.
pure func DefaultNumericExecutionControl() => NumericExecutionControl
begin
    return NumericExecutionControl {
        rounding_mode = NumericRound_RNE,
        saturating = FALSE
    };
end;

// Selects only a bounded set of accepted negative applicability rules.
// Absence of a rejection does not claim support or select numeric result
// semantics.
type NumericApplicabilityRuleSet of enumeration {
    NumericApplicabilityRules_None,
    NumericApplicabilityRules_MxRejection
};
```
<!-- GENERATED-ASL-END: unit -->
