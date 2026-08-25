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

本单元定义编码选择器完成解析后使用的语义舍入模式命名空间，以及通用执行控制记录。

它将数学舍入模式与标量 `FRM`、固定转换覆盖项、束 `RMode` 和公共 API 选择器编码明确区分。

<!-- PTO-READER-BLOCK: arch-rounding-concepts-state role=concepts-state -->
## 概念与可见状态

- `NumericRoundingMode` 包含 `RNE`、`RTM`、`RTP`、`RTZ`、`RNA`、`RTO` 和 `RHB` 七种语义模式。
- `NumericExecutionControl` 将 `NumericRoundingMode` 与 `saturating` 布尔值组合为一条记录。
- `NumericApplicabilityRuleSet` 表示没有额外拒绝规则，或采用有界的 `A2A3MxRejection` 规则集。

<!-- PTO-READER-BLOCK: arch-rounding-rules-interactions role=rules-interactions -->
## 规则与交互

`DefaultNumericExecutionControl` 选择 `NumericRound_RNE`，并设置 `saturating = FALSE`。

每个编码选择器命名空间都必须显式解析为 `NumericRoundingMode`；枚举位置不是隐含的线编码。

适用性枚举只选择一组有界的排除规则。未被拒绝并不表示目标一定支持，也不选择数值结果语义。

<!-- PTO-READER-BLOCK: arch-rounding-boundaries role=boundaries -->
## 架构边界

这些类型不定义具体算术操作如何舍入某个值；精确结果算法仍由操作或配置归属单元定义。

`A2A3MxRejection` 是命名的面向目标规则集，不是可以在其归属范围之外套用的可移植 PTO 行为。

<!-- PTO-READER-BLOCK: arch-rounding-example-usage role=example-usage -->
## 非规范阅读示例

束 `RMode` 编码先由其归属单元解码，随后才会成为例如 `NumericRound_RTZ`；本页不把两者的数值编码直接等同。

需要架构默认值的调用方可以调用 `DefaultNumericExecutionControl`，无需在本地重复 `RNE` 和非饱和默认值。

<!-- PTO-READER-BLOCK: arch-rounding-related-owners role=related-owners-navigation -->
## 相关归属单元

- [数值分类](numeric-classification.md)
- [硬件数值配置](../features/mx-formats.md)
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

// Selects only a bounded set of accepted negative applicability rules. This
// is not a complete target-profile selector: absence of a rejection does not
// claim target support or select numeric result semantics.
type NumericApplicabilityRuleSet of enumeration {
    NumericApplicabilityRules_None,
    NumericApplicabilityRules_A2A3MxRejection
};
```
<!-- GENERATED-ASL-END: unit -->
