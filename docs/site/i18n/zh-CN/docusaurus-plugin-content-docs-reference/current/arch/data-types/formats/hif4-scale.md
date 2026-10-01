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

HiF4 Matrix 缩放是一个原始 `32` 位字，它为 `64` 个逻辑 HiF4 lane 提供基准缩放和逐 lane 指数增量；本单元拥有它的字段布局、索引选择和有限值规则。

契约 `PTO-CUBE-HIF4-SCALE-001` 固定该字的布局，本单元的 ASL 函数实现它。

设计要点：缩放字本身不是一种 Tile 数据类型，因此描述符函数没有它的条目；一个原始缩放字改而固定 `64` 个逻辑 HiF4 lane 共享的增量。

<!-- PTO-READER-BLOCK: arch-hif4-scale-concepts role=concepts-state -->
## 载体与字段

该字在 `7:0` 位保存一个 `E6M2` 基准值，在 `15:8` 位保存八个 E1_8 指数位，在 `31:16` 位保存十六个 E1_16 指数位。

对于 `0..63` 范围内的 lane 索引 `q`，`HiF4ScaleExponentIncrement` 读取 `8 + (q DIVRM 8)` 位和 `16 + (q DIVRM 4)` 位，然后返回二者之和，即 `0..2` 范围内的增量。

设计要点：每个 E1_8 位由八个连续 lane 共享，每个 E1_16 位由四个 lane 共享，因此该增量是粗粒度项与细粒度项之和，而不是逐 lane 字段。

<!-- PTO-READER-BLOCK: arch-hif4-scale-rules role=rules-interactions -->
## 分解与分类

`HiF4E6M2ValueClass` 转发到 `ClassifyE6M2`，`HiF4E6M2FiniteValue` 转发到 `E6M2FiniteValue`，因此两个函数都保持 `E6M2` 编码含义不变。

`HiF4ScaleFiniteValue` 断言基准字段分类为 `NumericValue_PositiveNormal`，然后把 `E6M2` 有限值乘以增量的 `FP19PowerOfTwo`。

`E6M2` 编码 `0x00` 到 `0xfe` 是偏置为 `48`、带两位尾数的有限正值，`0xff` 是合法的静默 NaN 缩放。

设计要点：本单元不返回可用性标志；`E6M2` 基准编码 `0xff` 由 `HiF4E6M2FiniteValue` 中的断言排除，因此非有限基准是已定义性失败，而不是调用方可以检测的值。

<!-- PTO-READER-BLOCK: arch-hif4-scale-boundaries role=boundaries -->
## 边界与确切编码

基准字段必须是正规格化数，因此 `E6M2` 字段为 `0xff` 的缩放字不能作为有限缩放求值；对某个 lane 索引只有被选中的那一对指数位起作用。

设计要点：`HiF4ScaleFiniteValue` 在乘法之前断言基准类别，因此 `E6M2` 字段不是正规格化数的缩放字会在断言处停止，而不会返回逐 lane 的缩放值。

设计要点：`E6M2` 基准字段没有零编码，因为 `E6M2` 描述符不声明零编码，分类也从不返回零类别。

按函数顺序阅读本页：字段位置取自 `PTO-CUBE-HIF4-SCALE-001` 契约，在需要基准值类别时调用 `HiF4E6M2ValueClass`，并且只对分类为 `NumericValue_PositiveNormal` 的基准编码调用 `HiF4ScaleFiniteValue`。

<!-- PTO-READER-BLOCK: arch-hif4-scale-example role=example-usage -->
## 非规范阅读示例

本例说明当前的 ASL 归属单元，不替代规范操作。

`0x00` 表示 `2^-48`，`0xfe` 表示 `1.5 * 2^15`；这是缩放字能承载的最小和最大有限基准值。

`HiF4E6M2ValueClass` 对 `0xff` 报告静默 NaN 类别，对其他每个基准编码报告正规格化数类别，因此 `HiF4E6M2FiniteValue` 对 `0xff` 触发断言。

<!-- PTO-READER-BLOCK: arch-hif4-scale-related role=related-owners-navigation -->
## 相关归属单元

- [数值格式描述符](../format-descriptor.md)定义公共元数据记录。

- [数值格式](../numeric-formats.md)把 Tile 数据类型分派到各格式自己的辅助函数。

- [HiF4X2](hif4x2.md)定义该缩放字相乘的打包逻辑 lane。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/formats/hif4-scale.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-FORMAT-HIF4-SCALE","surface":"arch","classification":["data-types","formats","hif4-scale"],"depends_on":["PTO-ARCH-DATA-TYPES-FP19","PTO-ARCH-DATA-TYPES-FORMAT-E6M2"]}

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
    return ClassifyE6M2(value);
end;

pure func HiF4E6M2FiniteValue(value: bits(8)) => real
begin
    return E6M2FiniteValue(value);
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
