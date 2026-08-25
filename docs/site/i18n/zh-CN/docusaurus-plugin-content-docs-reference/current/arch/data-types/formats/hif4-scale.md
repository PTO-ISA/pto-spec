<!-- GENERATED FROM: asl/arch/data-types/formats/hif4-scale.asl -->
# Hif4 Scale

**Normative ASL source:** `asl/arch/data-types/formats/hif4-scale.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-FORMAT-HIF4-SCALE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-hif4-scale-purpose role=purpose-scope -->
## 用途与范围

HiF4 Matrix 缩放值采用一个 `32` 位原始字，与 `64` 个逻辑 HiF4 lane 配合使用。本页说明 E6M2 基础字段如何与两级指数选择位组合；确切行为仍由 `PTO-CUBE-HIF4-SCALE-001` 及其 ASL 函数定义。

<!-- PTO-READER-BLOCK: arch-hif4-scale-concepts role=concepts-state -->
## 缩放字布局

`7:0` 位保存一个 E6M2 基础缩放值，`15:8` 位保存 8 个 E1_8 指数位，`31:16` 位保存 16 个 E1_16 指数位。

对于 `0..63` 范围内的 lane 索引 `q`，`HiF4ScaleExponentIncrement` 选择第 `8 + (q DIVRM 8)` 位和第 `16 + (q DIVRM 4)` 位，再把两位相加，得到 `0` 到 `2` 的增量。

<!-- PTO-READER-BLOCK: arch-hif4-scale-rules role=rules-interactions -->
## 基础值与 lane 缩放

E6M2 编码 `0x00` 到 `0xfe` 是偏置为 `48`、具有 2 个尾数位的正有限值。`0xff` 是合法的静默 NaN 缩放值。

基础值有限时，`HiF4ScaleFiniteValue` 把 `HiF4E6M2FiniteValue` 与 `FP19PowerOfTwo(increment)` 相乘，其中 `increment` 由 `HiF4ScaleExponentIncrement` 返回。该函数要求基础字段分类为 `NumericValue_PositiveNormal`。

<!-- PTO-READER-BLOCK: arch-hif4-scale-boundaries role=boundaries -->
## 边界

`0x00` 表示 `2^-48`；`0xfe` 表示 `1.5 * 2^15`；`0xff` 是静默 NaN 编码，因此 `HiF4E6M2FiniteValue` 不接受它。

每个 E1_8 位由连续 8 个逻辑 lane 共享，每个 E1_16 位由连续 4 个 lane 共享。对给定 `q` 起作用的是选中的这一对，而不是字中的其他指数位。

<!-- PTO-READER-BLOCK: arch-hif4-scale-example role=example-usage -->
## 非规范阅读示例

下面只演示索引方式，不增加缩放规则。

当基础值为 `0x00`、E1_8 的第 `8` 位和 E1_16 的第 `16` 位均置 1 时，lane `q = 0` 得到增量 `2` 和缩放值 `2^-46`；在 AVS 夹具中，lane `q = 8` 选择另外的指数位，因此增量为 `0`。

<!-- PTO-READER-BLOCK: arch-hif4-scale-related role=related-owners-navigation -->
## 相关所有者

- [FP19](../fp19.md)提供 `FP19PowerOfTwo`。
- [HiF4X2](hif4x2.md)定义打包的 HiF4 逻辑 lane 数值格式。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/formats/hif4-scale.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-FORMAT-HIF4-SCALE","surface":"arch","classification":["data-types","formats","hif4-scale"],"depends_on":["PTO-ARCH-DATA-TYPES-FP19"]}

// NDF-BEGIN: PTO-CUBE-HIF4-SCALE-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// A HiF4 Matrix scale MUST be one raw U32 word containing E6M2 in bits 7:0,
// eight E1_8 exponents in bits 15:8, and sixteen E1_16 exponents in bits
// 31:16. E6M2 values 00..FE MUST be finite with bias 48 and two fraction
// bits; FF MUST be a legal quiet NaN scale. One word scales 64 logical HiF4
// lanes through the selected E1_8 plus E1_16 exponent bits.
// NDF-END: PTO-CUBE-HIF4-SCALE-001

pure func HiF4E6M2ValueClass(value: bits(8)) => NumericValueClass
begin
    if value == Ones{8} then return NumericValue_QuietNaN; end;
    return NumericValue_PositiveNormal;
end;

pure func HiF4E6M2FiniteValue(value: bits(8)) => real
begin
    assert value != Ones{8};
    let exponent = (UInt(value[7:2]) - 48) as integer {-48..15};
    let mantissa_quarters = 4 + UInt(value[1:0]);
    return (Real(mantissa_quarters) / 4.0) * FP19PowerOfTwo(exponent);
end;

pure func HiF4ScaleExponentIncrement(
    scale_word: bits(32), q: integer {0..63}) => integer {0..2}
begin
    let e1_8_index = 8 + (q DIVRM 8);
    let e1_16_index = 16 + (q DIVRM 4);
    return UInt(scale_word[e1_8_index]) +
           UInt(scale_word[e1_16_index]);
end;

pure func HiF4ScaleFiniteValue(
    scale_word: bits(32), q: integer {0..63}) => real
begin
    assert HiF4E6M2ValueClass(scale_word[7:0]) ==
        NumericValue_PositiveNormal;
    return HiF4E6M2FiniteValue(scale_word[7:0]) *
        FP19PowerOfTwo(HiF4ScaleExponentIncrement(scale_word, q));
end;
```
<!-- GENERATED-ASL-END: unit -->
