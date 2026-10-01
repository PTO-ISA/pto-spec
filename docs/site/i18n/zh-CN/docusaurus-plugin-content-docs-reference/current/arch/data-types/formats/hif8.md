<!-- GENERATED FROM: asl/arch/data-types/formats/hif8.asl -->
# Hif8

**Normative ASL source:** `asl/arch/data-types/formats/hif8.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-FORMAT-HIF8}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-hif8-purpose-scope role=purpose-scope -->
## 用途与范围

`HiF8` 是已分配的 PTO 数值格式，存储在 `8` 位载体中；本单元拥有它的描述符、点字段解码、有限值分解、值分类和规范 NaN。

`HiF8` 不是固定指数宽度的格式：指数与尾数之间小数点的位置取决于数值本身，因此该格式对小量值少用指数位、对大量值多用指数位。

设计要点：该记录把载体宽度与逻辑 lane 宽度分开，因此打包类型在一个载体中报告两个 lane，而单 lane 类型在其载体中只报告自己的 lane 宽度。

<!-- PTO-READER-BLOCK: arch-hif8-concepts-state role=concepts-state -->
## 载体与字段

描述符使用 `8` 位载体、`8` 位逻辑 lane，并且每个载体包含 `1` 个 lane，指数位数为 `0` 到 `4`，尾数位数为 `1` 到 `3`，没有固定指数偏置。

描述符报告正零、次正规数、无穷大和静默 NaN，但不报告带符号零和信号 NaN，并选择 `NumericFormatKind_HiF8`。

设计要点：指数宽度以范围而不是单一数字报告，因此需要某个载体的字段宽度的调用方必须调用 `HiF8DecodeDotField`，而不能直接读描述符。

只需要值类别的读者可以在分类之后停止，因为分类从不要求分解可用。

<!-- PTO-READER-BLOCK: arch-hif8-rules-interactions role=rules-interactions -->
## 分解与分类

`HiF8DecodeDotField` 把载体的 `6:3` 位映射为 `HiF8DotField_Denormal` 以及 `HiF8DotField_D0` 到 `HiF8DotField_D4` 中的一个点字段，同时给出该载体生效的指数位数和尾数位数。

`HiF8FiniteDecomposition` 先排除三个非有限载体，然后返回可用性、符号、整数有效数和二进制指数，使精确值为 `(-1)^sign * UInt(significand) * 2^exponent`；`ClassifyHiF8` 返回对应的值类别。

载体 `0x80`、`0x6f` 和 `0xef` 是非有限值：`0x80` 是静默 NaN，`0x6f` 是正无穷大，`0xef` 是负无穷大；其余每个载体都是有限值。

设计要点：为可用性写 `FALSE` 而不是任意有效数，可以避免调用方把非有限载体的占位字段当作数值读取，因此必须先查看可用性标志。

<!-- PTO-READER-BLOCK: arch-hif8-boundaries role=boundaries -->
## 边界与确切编码

全零载体是正零；低七位在 `1` 到 `7` 范围内的载体分类为带符号的次正规数，其余有限载体分类为带符号的正规数。

设计要点：延后的点字段查找正是能够先做一次非有限检查的前提，因此解码器只在分解仍然有意义的载体上运行。

设计要点：只有全零载体表示零，因为符号位为 1 且量值字段全为零的载体被分配给静默 NaN，所以描述符报告没有带符号零。

按函数顺序阅读本页：先从描述符取得字段位置，在需要值类别时调用分类函数，在需要精确有效数与指数时调用分解函数。

<!-- PTO-READER-BLOCK: arch-hif8-example-usage role=example-usage -->
## 非规范阅读示例

本例说明当前的 ASL 归属单元，不替代规范操作。

`HiF8CanonicalNaN` 返回 `0x80`，这与分类报告为静默 NaN 的载体相同，因此不存在需要协调的第二个 NaN 编码。

`0x01` 经 `HiF8DotField_Denormal` 解码，分解为有效数 `1` 和指数 `-22`，即 `2^-22`；`0x10` 经 `HiF8DotField_D1` 解码，分解为有效数 `8` 和指数 `-2`，即 `2`。

<!-- PTO-READER-BLOCK: arch-hif8-related-owners role=related-owners-navigation -->
## 相关归属单元

- [数值格式描述符](../format-descriptor.md)定义公共元数据记录。

- [数值格式](../numeric-formats.md)把 Tile 数据类型分派到各格式自己的辅助函数。

- [数值分类](../numeric-classification.md)定义本页返回的类别。
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
