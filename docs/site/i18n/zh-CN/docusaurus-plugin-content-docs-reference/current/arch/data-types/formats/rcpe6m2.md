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

`RCPE6M2` 是已分配的 PTO 数值类型，把 `E6M2` 编码空间重新解释为精确倒数；本单元拥有它的描述符、精确有限值、分解可用性、分类和规范 NaN。

它是仅作源类型使用的类型：原始八位编码不变，只有该编码的数值解释与 `E6M2` 不同。

<!-- PTO-READER-BLOCK: arch-format-rcpe6m2-concepts role=concepts-state -->
## 载体与字段

描述符使用 `8` 位载体、`8` 位逻辑 lane，并且每个载体包含 `1` 个 lane。

它保留 `E6M2` 的形状：`6` 个指数位位于 `7:2`，`2` 个尾数位位于 `1:0`，指数偏置为 `48`，没有符号位，并且 `required_low_zero_bits` 与 `required_high_zero_bits` 都是 `0`。

设计要点：描述符重复写出 `E6M2` 的字段宽度，而不是引用它们，因此读者从一条记录就能看出两种类型消费完全相同的原始编码。

<!-- PTO-READER-BLOCK: arch-format-rcpe6m2-rules role=rules-interactions -->
## 分解与分类

`RCPE6M2FiniteValue` 对不是 `0xff` 的编码返回 `1.0 / E6M2FiniteValue(value)`，而 `RCPE6M2FiniteDecomposition` 始终报告分解不可用。

`ClassifyRCPE6M2` 对 `0xff` 返回静默 NaN，对其他每个编码返回正规格化数类别，因此没有编码是零、次正规数、无穷大或信号 NaN。

分解对所有编码都不可用，包括有限编码，因为一般有效数的倒数是精确有理数，而不是整数有效数乘以 2 的幂的形式。

设计要点：分解不可用并不是针对特殊编码的说明；`RCPE6M2FiniteDecomposition` 对每个编码都返回 `FALSE`，包括有限编码，因此调用方改为从 `RCPE6M2FiniteValue` 取值。

<!-- PTO-READER-BLOCK: arch-format-rcpe6m2-boundaries role=boundaries -->
## 边界与确切编码

设计要点：报告不可用而不是把倒数舍入到最近的二进制值，可以把精确有理数留给消费它的转换使用，因此后续舍入只在目标格式发生一次。

`0x00` 表示最小 `E6M2` 值 `2^-48` 的精确倒数，即 `2^48`；`0xfe` 表示 `1.5 * 2^15` 的倒数。

设计要点：该格式根本不声明零编码，因此需要零的调用方必须通过转换得到，而不是通过本类型中的原始编码。

按函数顺序阅读本页：字段位置取自描述符，在需要值类别时调用 `ClassifyRCPE6M2`，并从 `RCPE6M2FiniteValue` 取值，因为本类型从不报告可用的分解。

<!-- PTO-READER-BLOCK: arch-format-rcpe6m2-example role=example-usage -->
## 非规范阅读示例

本例说明当前的 ASL 归属单元，不替代规范操作。

`0xff` 既是唯一的静默 NaN 编码，也是 `RCPE6M2CanonicalNaN` 返回的规范 NaN，并且 `RCPE6M2FiniteValue` 断言其参数不是 `0xff`。

参考转换直接消费精确倒数值而不是分解结果，因此调用方不得要求分解可用才使用本类型。

<!-- PTO-READER-BLOCK: arch-format-rcpe6m2-related role=related-owners-navigation -->
## 相关归属单元

- [数值格式描述符](../format-descriptor.md)定义公共元数据记录。

- [数值格式](../numeric-formats.md)把 Tile 数据类型分派到各格式自己的辅助函数。

- [E6M2](e6m2.md)定义本类型取倒数所依据的原始编码值。
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
