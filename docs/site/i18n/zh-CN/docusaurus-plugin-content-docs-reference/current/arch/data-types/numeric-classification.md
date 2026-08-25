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

本单元定义所有 Tile 数值格式共享的数值类别和数值策略记录。

统一的分类词汇使格式归属单元能够报告精确的比特模式类别，而不在此选择算术结果或目标实现。

<!-- PTO-READER-BLOCK: arch-numeric-classification-concepts-state role=concepts-state -->
## 概念与可见状态

- `NumericValueClass` 包含无效编码、带符号零、次正规数、正规数和无穷大，以及静默 NaN 与信号 NaN。
- 输入和结果采用相互独立的次正规数策略：`NumericInputSubnormalRule` 与 `NumericResultSubnormalRule` 不合并为一个开关。
- `TileNumericSelection` 记录是否采用操作默认值、所选 `NumericRoundingMode` 以及是否饱和。

<!-- PTO-READER-BLOCK: arch-numeric-classification-rules-interactions role=rules-interactions -->
## 规则与交互

`NumericValueClassIsNaN`、`NumericValueClassIsInfinity`、`NumericValueClassIsZero` 和 `NumericValueClassIsSubnormal` 只检查各自命名的类别对。

`NumericTininessDetectionRule` 区分不适用与舍入后检测。

分类只描述格式属性，本身不选择异常标志、舍入方式、饱和方式或操作结果。

<!-- PTO-READER-BLOCK: arch-numeric-classification-boundaries role=boundaries -->
## 架构边界

输入/结果次正规数枚举描述命名硬件数值配置，而不是一般 `pto-v0` 算术行为。

数值类别不能证明某项操作支持相应数据类型；支持范围仍由当前操作及配置归属单元定义。

<!-- PTO-READER-BLOCK: arch-numeric-classification-example-usage role=example-usage -->
## 非规范阅读示例

`NumericValue_NegativeZero` 会使 `NumericValueClassIsZero` 为真，但不会使 `NumericValueClassIsSubnormal` 为真。

调用方可以在普通比较前根据 NaN 类别分支，再回到自身配置归属单元取得精确结果。

<!-- PTO-READER-BLOCK: arch-numeric-classification-related-owners role=related-owners-navigation -->
## 相关归属单元

- [数值格式分派](numeric-formats.md)
- [舍入类型](rounding.md)
- [硬件数值配置](../features/mx-formats.md)
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

// PTO-REQ-PROFILE-001, PTO-REQ-HARDWARE-NUMERIC-001:
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
