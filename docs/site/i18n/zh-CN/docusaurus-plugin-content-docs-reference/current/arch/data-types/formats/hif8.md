<!-- GENERATED FROM: asl/arch/data-types/formats/hif8.asl -->
# Hif8

**Normative ASL source:** `asl/arch/data-types/formats/hif8.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-FORMAT-HIF8}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-hif8-purpose-scope role=purpose-scope -->
## 目的与范围

本单元精确定义 `HiF8` 的八位格式描述、动态点字段解码、有限值分解、数值分类和规范 NaN。

有了这一归属单元，使用者可以直接根据原始载体推理，而无需用宿主浮点类型替代架构规定的编码。

<!-- PTO-READER-BLOCK: arch-hif8-concepts-state role=concepts-state -->
## 概念与可见状态

- `HiF8NumericFormatDescriptor` 规定一个符号位、`0..4` 个可变指数位、`1..3` 个小数位和一个八位通道，并且不采用固定指数偏置。
- `HiF8DecodeDotField` 将载体中的点字段映射为 `HiF8DotField_Denormal` 或 `HiF8DotField_D0` 至 `HiF8DotField_D4`，同时返回当前采用的指数宽度和小数宽度。
- `HiF8FiniteDecomposition` 返回可用性、符号、整数有效数和二进制指数；`ClassifyHiF8` 返回相应的数值类别。

<!-- PTO-READER-BLOCK: arch-hif8-rules-interactions role=rules-interactions -->
## 规则与交互

原始载体 `0x80`、`0x6f` 和 `0xef` 都是非有限值：前者是静默 NaN，后两者分别是正无穷大和负无穷大。

全零载体表示正零。低七位处于 `1..7` 的载体归类为带符号次正规数，其余有限载体归类为带符号正规数。

`HiF8CanonicalNaN` 返回 `0x80`，与分类规则一致，不另设第二种 NaN 编码。

<!-- PTO-READER-BLOCK: arch-hif8-boundaries role=boundaries -->
## 架构边界

该描述符声明支持零、次正规数、无穷大和静默 NaN，但不支持带符号零或信号 NaN。

所有非有限载体的分解结果都标记为不可用；调用者必须先检查可用性，再使用返回的有效数和指数。

<!-- PTO-READER-BLOCK: arch-hif8-example-usage role=example-usage -->
## 非规范阅读示例

对于 `0x01`，解码器选择 `HiF8DotField_Denormal`。该值可用、为正且属于次正规数，其精确大小由返回的整数有效数和指数表示。

对于 `0x80`，分类结果为 `NumericValue_QuietNaN`，有限值分解则报告不可用。

这只是两个 API 的阅读示例，不构成新的算术规则。

<!-- PTO-READER-BLOCK: arch-hif8-related-owners role=related-owners-navigation -->
## 相关归属单元

- [数值格式分派](../numeric-formats.md)
- [数值分类](../numeric-classification.md)
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/formats/hif8.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-FORMAT-HIF8","surface":"arch","classification":["data-types","formats","hif8"],"depends_on":["PTO-ARCH-DATA-TYPES-FORMAT-DESCRIPTOR"]}
// DOC-BEGIN: operation
// PTO-REQ-HARDWARE-NUMERIC-001: exact HiF8 dynamic encoding.

pure func HiF8NumericFormatDescriptor() => NumericFormatDescriptor
begin
    return NumericFormatDescriptor {
        available = TRUE, kind = NumericFormatKind_HiF8,
        carrier_bits = 8, lane_bits = 8, lanes_per_carrier = 1,
        sign_bits = 1, sign_bit = 7,
        exponent_bits_min = 0, exponent_bits_max = 4,
        fraction_bits_min = 1, fraction_bits_max = 3,
        exponent_bias_available = FALSE, exponent_bias = 0,
        required_low_zero_bits = 0, required_high_zero_bits = 0,
        has_zero = TRUE, has_signed_zero = FALSE, has_subnormal = TRUE,
        has_infinity = TRUE, has_quiet_nan = TRUE,
        has_signaling_nan = FALSE
    };
end;

pure func HiF8DecodeDotField(value: bits(8))
    => (HiF8DotField, integer {0..4}, integer {1..3})
begin
    if value[6:3] == '0000' then
        return (HiF8DotField_Denormal, 0, 3);
    elsif value[6:3] == '0001' then
        return (HiF8DotField_D0, 0, 3);
    elsif value[6:4] == '001' then
        return (HiF8DotField_D1, 1, 3);
    elsif value[6:5] == '01' then
        return (HiF8DotField_D2, 2, 3);
    elsif value[6:5] == '10' then
        return (HiF8DotField_D3, 3, 2);
    else return (HiF8DotField_D4, 4, 1);
    end;
end;

pure func HiF8FiniteDecomposition(value: bits(8))
    => (boolean, boolean, Word, integer {-1074..1023})
begin
    if value == '10000000' || value == '01101111' ||
       value == '11101111' then
        return (FALSE, FALSE, Zeros{PTO_XLEN}, 0);
    end;
    let (dot, exponent_bits, fraction_bits) = HiF8DecodeDotField(value);
    case dot of
        when HiF8DotField_Denormal =>
            let mantissa = value[2:0];
            if mantissa == Zeros{3} then
                return (TRUE, FALSE, Zeros{PTO_XLEN}, 0);
            else return (TRUE, value[7] == '1', Zeros{PTO_XLEN} + 1,
                         (UInt(mantissa) - 23)
                             as integer {-1074..1023});
            end;
        when HiF8DotField_D0 =>
            return (TRUE, value[7] == '1',
                    LSL(Zeros{PTO_XLEN} + 1, 3) +
                        ZeroExtend{PTO_XLEN}(value[2:0]), -3);
        when HiF8DotField_D1 =>
            var actual_exponent: integer {-15..15} = 1;
            if value[3] == '1' then actual_exponent = -1; end;
            return (TRUE, value[7] == '1',
                    LSL(Zeros{PTO_XLEN} + 1, 3) +
                        ZeroExtend{PTO_XLEN}(value[2:0]),
                    (actual_exponent - 3) as integer {-1074..1023});
        when HiF8DotField_D2 =>
            let magnitude = 2 + UInt(value[3]);
            var actual_exponent: integer {-15..15} = magnitude;
            if value[4] == '1' then actual_exponent = 0 - magnitude; end;
            return (TRUE, value[7] == '1',
                    LSL(Zeros{PTO_XLEN} + 1, 3) +
                        ZeroExtend{PTO_XLEN}(value[2:0]),
                    (actual_exponent - 3) as integer {-1074..1023});
        when HiF8DotField_D3 =>
            let magnitude = 4 + UInt(value[3:2]);
            var actual_exponent: integer {-15..15} = magnitude;
            if value[4] == '1' then actual_exponent = 0 - magnitude; end;
            return (TRUE, value[7] == '1',
                    LSL(Zeros{PTO_XLEN} + 1, 2) +
                        ZeroExtend{PTO_XLEN}(value[1:0]),
                    (actual_exponent - 2) as integer {-1074..1023});
        when HiF8DotField_D4 =>
            let magnitude = 8 + UInt(value[3:1]);
            var actual_exponent: integer {-15..15} = magnitude;
            if value[4] == '1' then actual_exponent = 0 - magnitude; end;
            return (TRUE, value[7] == '1',
                    LSL(Zeros{PTO_XLEN} + 1, 1) +
                        ZeroExtend{PTO_XLEN}(value[0:0]),
                    (actual_exponent - 1) as integer {-1074..1023});
    end;
end;
pure func ClassifyHiF8(value: bits(8)) => NumericValueClass
begin
    if value == '10000000' then return NumericValue_QuietNaN;
    elsif value == '01101111' then return NumericValue_PositiveInfinity;
    elsif value == '11101111' then return NumericValue_NegativeInfinity;
    elsif value == Zeros{8} then return NumericValue_PositiveZero;
    elsif UInt(value[6:0]) <= 7 then
        return NumericValueClassFromFiniteSign(value[7], FALSE, TRUE);
    else return NumericValueClassFromFiniteSign(value[7], FALSE, FALSE);
    end;
end;

pure func HiF8CanonicalNaN() => Word
begin
    return Zeros{PTO_XLEN} + 0x80;
end;
// DOC-END: operation
```
<!-- GENERATED-ASL-END: unit -->
