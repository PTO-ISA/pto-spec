<!-- GENERATED FROM: asl/arch/data-types/formats/rcpe6m2.asl -->
# Rcpe6m2

**Normative ASL source:** `asl/arch/data-types/formats/rcpe6m2.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-FORMAT-RCPE6M2}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-format-rcpe6m2-purpose role=purpose-scope -->
## 用途与范围

RCPE6M2 是一种仅作源使用的派生 PTO 数值类型，通过精确倒数重新解释 E6M2 原始编码空间。本页帮助读者把共享载体、倒数值规则和值分类联系起来；ASL 所有者仍是确切定义。

<!-- PTO-READER-BLOCK: arch-format-rcpe6m2-concepts role=concepts-state -->
## 载体与字段

描述符使用 `8` 位载体、`8` 位逻辑 lane，并且每个载体包含 `1` 个 lane。它保留 E6M2 的六位指数、两位尾数、偏置 `48` 和无符号字段布局，因此两种类型解释相同的原始编码。

描述符不包含零、带符号零、次正规数、无穷大或信号 NaN 编码，编码 `0xff` 仍是静默 NaN 编码。

<!-- PTO-READER-BLOCK: arch-format-rcpe6m2-rules role=rules-interactions -->
## 倒数值与分类

对于编码 `0x00` 至 `0xfe`，`RCPE6M2FiniteValue` 返回相同原始编码对应 `E6M2FiniteValue` 的精确数学倒数。每个此类编码都归类为正正规数，而 `0xff` 归类为静默 NaN。

一般倒数的精确值是有理数，不是普通有限值分解使用的整数有效数二进制形式。因此 `RCPE6M2FiniteDecomposition` 报告分解不可用，参考转换直接使用精确倒数值。

<!-- PTO-READER-BLOCK: arch-format-rcpe6m2-boundaries role=boundaries -->
## 边界与转换边界

`0xff` 既是唯一的静默 NaN 编码，也是所有者返回的规范 NaN。其余所有原始编码都是有限倒数输入。

TCVT 使用 RCPE6M2 时只执行一次最终目标舍入，不会先物化一个经过舍入的中间浮点值。

<!-- PTO-READER-BLOCK: arch-format-rcpe6m2-example role=example-usage -->
## 非规范阅读示例

下面的示例只演示如何阅读所有者函数，不增加转换规则。

例如，E6M2 编码 `0x00` 表示 `2^-48`，所以 RCPE6M2 编码 `0x00` 表示其精确倒数 `2^48`；原始编码不变，只有数值解释不同。

<!-- PTO-READER-BLOCK: arch-format-rcpe6m2-related role=related-owners-navigation -->
## 相关所有者

- [E6M2](./e6m2.md)定义 RCPE6M2 所表示倒数的原始编码值。
- [数值格式描述符](../format-descriptor.md)定义公共元数据记录。
- [数值格式](../numeric-formats.md)把 Tile 数据类型分派到各格式自己的辅助函数。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/formats/rcpe6m2.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-FORMAT-RCPE6M2","surface":"arch","classification":["data-types","formats","rcpe6m2"],"depends_on":["PTO-ARCH-DATA-TYPES-FORMAT-E6M2"]}
// NDF-BEGIN: PTO-NUMERIC-RCPE6M2-FORMAT-001
// ndf: kind=executable level=L3 layer=architecture status=accepted
// RCPE6M2 uses the E6M2 raw eight-bit code space as a source-only derived
// numeric type. Code FF is quiet NaN; every finite code denotes the exact
// mathematical reciprocal of the corresponding E6M2 value. TCVT performs
// one final destination rounding and never materializes an intermediate
// rounded floating value.
// NDF-END: PTO-NUMERIC-RCPE6M2-FORMAT-001
// DOC-BEGIN: operation
// PTO-REQ-HARDWARE-NUMERIC-001: exact reciprocal interpretation of E6M2.

pure func RCPE6M2NumericFormatDescriptor() => NumericFormatDescriptor
begin
    return NumericFormatDescriptor {
        available = TRUE, kind = NumericFormatKind_FixedBinary,
        carrier_bits = 8, lane_bits = 8, lanes_per_carrier = 1,
        sign_bits = 0, sign_bit = 0,
        exponent_bits_min = 6, exponent_bits_max = 6,
        fraction_bits_min = 2, fraction_bits_max = 2,
        exponent_bias_available = TRUE, exponent_bias = 48,
        required_low_zero_bits = 0, required_high_zero_bits = 0,
        has_zero = FALSE, has_signed_zero = FALSE, has_subnormal = FALSE,
        has_infinity = FALSE, has_quiet_nan = TRUE,
        has_signaling_nan = FALSE
    };
end;

pure func RCPE6M2FiniteValue(value: bits(8)) => real
begin
    assert value != Ones{8};
    return 1.0 / E6M2FiniteValue(value);
end;

pure func RCPE6M2FiniteDecomposition(value: bits(8))
    => (boolean, boolean, Word, integer {-1074..1023})
begin
    // A reciprocal of a general E6M2 significand is an exact rational rather
    // than an integer-significand binary value. Reference conversion consumes
    // RCPE6M2FiniteValue directly, so the ordinary binary decomposition is
    // intentionally unavailable for this derived source type.
    return (FALSE, FALSE, Zeros{PTO_XLEN}, 0);
end;

pure func ClassifyRCPE6M2(value: bits(8)) => NumericValueClass
begin
    if value == Ones{8} then return NumericValue_QuietNaN; end;
    return NumericValue_PositiveNormal;
end;

pure func RCPE6M2CanonicalNaN() => Word
begin
    return Zeros{PTO_XLEN} + 0xff;
end;
// DOC-END: operation
```
<!-- GENERATED-ASL-END: unit -->
