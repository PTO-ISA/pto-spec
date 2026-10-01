<!-- GENERATED FROM: asl/arch/data-types/numeric-classification.asl -->
# Numeric Classification

**Normative ASL source:** `asl/arch/data-types/numeric-classification.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-NUMERIC-CLASSIFICATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-numeric-classification-purpose-scope role=purpose-scope -->
## 目的与范围

本单元定义每个 Tile 数值格式共享的值类别词汇和数值策略记录。

它是类型与辅助函数单元，因此描述的是值是什么以及策略如何选择，而不是任何操作计算什么。

<!-- PTO-READER-BLOCK: arch-numeric-classification-concepts-state role=concepts-state -->
## 概念与可见状态

`NumericValueClass` 包含 `NumericValue_InvalidEncoding`、带符号零、次正规数、正规数、无穷大类别，以及 `NumericValue_QuietNaN` 和 `NumericValue_SignalingNaN`。

次正规数规则对输入和结果分别定义：`NumericInputSubnormalRule` 取 `NumericInputSubnormal_NotApplicable` 或 `NumericInputSubnormal_Preserve`，`NumericResultSubnormalRule` 取 `NumericResultSubnormal_NotApplicable` 或 `NumericResultSubnormal_GradualUnderflow`。

`TileNumericSelection` 记录是否采用操作默认值、所选 `NumericRoundingMode` 以及该操作是否饱和。

<!-- PTO-READER-BLOCK: arch-numeric-classification-rules-interactions role=rules-interactions -->
## 规则与交互

设计要点：输入与结果保留各自的次正规数规则，因为保留次正规数操作数与产生渐进下溢结果是两种不同行为，单个开关无法表达只做其中之一的配置。

`NumericValueClassIsNaN`、`NumericValueClassIsInfinity`、`NumericValueClassIsZero` 和 `NumericValueClassIsSubnormal` 各自只检查自己命名的类别对，并返回布尔值。

`NumericTininessDetectionRule` 区分 `NumericTininessDetection_NotApplicable` 与 `NumericTininessDetection_AfterRounding`；整数分类器 `ClassifySignedInteger` 和 `ClassifyUnsignedInteger` 由硬件数值配置单元拥有，而不在本单元中。

<!-- PTO-READER-BLOCK: arch-numeric-classification-boundaries role=boundaries -->
## 架构边界

分类是格式属性：它报告原始载体落入哪个类别，本身不选择异常标志、舍入模式、饱和决定或结果值。

`NumericValue_InvalidEncoding` 是独立类别，因此被格式拒绝的载体与表示 NaN 的载体可以区分。

本单元没有格式描述符，也没有分解函数，因此上面的值类别声明和四个布尔类别判断函数就是完整定义。

<!-- PTO-READER-BLOCK: arch-numeric-classification-example-usage role=example-usage -->
## 非规范阅读示例

本例说明当前的 ASL 归属单元，不替代规范操作。

设计要点：把无效编码与各值类别分开，是因为拒绝发生在任何数值解释之前，因此调用方可以区分畸变载体与形式良好的非有限值。

输入与结果次正规数枚举描述的是命名硬件数值配置，所有者中的注释也说明它们不是一般 `pto-v0` 算术行为。

值类别不能证明某项操作支持相应数据类型，因为支持范围仍由当前操作及配置所有者定义。

<!-- PTO-READER-BLOCK: arch-numeric-classification-related-owners role=related-owners-navigation -->
## 相关归属单元

- [数值格式分派](numeric-formats.md)把 Tile 数据类型分派到它的描述符和有限值分解。

- [舍入类型](rounding.md)定义选择记录中所命名的舍入模式。

- [硬件数值配置](../features/mx-formats.md)把这些规则应用到已声明类型。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/numeric-classification.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-NUMERIC-CLASSIFICATION","surface":"arch","classification":["data-types","numeric-classification"],"depends_on":["PTO-ARCH-DATA-TYPES-ROUNDING"]}
type NumericValueClass of enumeration {
    NumericValue_InvalidEncoding,
    NumericValue_PositiveZero,
    NumericValue_NegativeZero,
    NumericValue_PositiveSubnormal,
    NumericValue_NegativeSubnormal,
    NumericValue_PositiveNormal,
    NumericValue_NegativeNormal,
    NumericValue_PositiveInfinity,
    NumericValue_NegativeInfinity,
    NumericValue_QuietNaN,
    NumericValue_SignalingNaN
};

// Input and result subnormal rules are intentionally separate. They describe
// the named hardware numeric profile and are not pto-v0 arithmetic behavior.
type NumericInputSubnormalRule of enumeration {
    NumericInputSubnormal_NotApplicable,
    NumericInputSubnormal_Preserve
};

type NumericResultSubnormalRule of enumeration {
    NumericResultSubnormal_NotApplicable,
    NumericResultSubnormal_GradualUnderflow
};

type NumericTininessDetectionRule of enumeration {
    NumericTininessDetection_NotApplicable,
    NumericTininessDetection_AfterRounding
};

type TileNumericSelection of record {
    use_operation_default: boolean,
    rounding_mode: NumericRoundingMode,
    saturating: boolean
};

// PTO-REQ-RESET-001, PTO-REQ-HARDWARE-NUMERIC-001:
// bit-exact value classification for every TileDataType.

pure func NumericValueClassIsNaN(value_class: NumericValueClass) => boolean
begin
    return value_class == NumericValue_QuietNaN ||
           value_class == NumericValue_SignalingNaN;
end;

pure func NumericValueClassIsInfinity(value_class: NumericValueClass) => boolean
begin
    return value_class == NumericValue_PositiveInfinity ||
           value_class == NumericValue_NegativeInfinity;
end;

pure func NumericValueClassIsZero(value_class: NumericValueClass) => boolean
begin
    return value_class == NumericValue_PositiveZero ||
           value_class == NumericValue_NegativeZero;
end;

pure func NumericValueClassIsSubnormal(value_class: NumericValueClass) => boolean
begin
    return value_class == NumericValue_PositiveSubnormal ||
           value_class == NumericValue_NegativeSubnormal;
end;
```
<!-- GENERATED-ASL-END: unit -->
