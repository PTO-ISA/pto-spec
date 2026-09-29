<!-- GENERATED FROM: asl/scalar/model/fsu/reference-quantization.asl -->
# Reference Quantization

**Normative ASL source:** `asl/scalar/model/fsu/reference-quantization.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-FSU-REFERENCE-QUANTIZATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-fsu-reference-quantization-purpose role=purpose-scope -->
## 用途与范围

本单元是参考数值配置档的有限值部分。它把 FP32 和 FP64 编码转换为精确的实数值，并把实数值连同标志向量舍入回 FP32、FP64 或 FP16 编码。它还对标量载体做分类，构造特殊编码（NaN、无穷大、带符号零），并定义 `ReferenceScalarFPBinarySpecial`，即 ADD、SUB、MUL 和 DIV 的 NaN、无穷大和零情形。

[标量 FP](scalar-fp.md)中的标量配置档钩子和特殊值单元调用它。一些 Tile 单元复用其 FP32 和 FP64 辅助函数，例如矩阵量化和参考转换。

<!-- PTO-READER-BLOCK: scalar-model-fsu-reference-quantization-concepts role=concepts-state -->
## 概念与可见状态

有限值是既不是 NaN 也不是无穷大的数。`ReferenceFP32FiniteValue` 和 `ReferenceFP64FiniteValue` 精确地译码正规和次正规编码，并断言指数字段不是全一。

有限值编码器接收精确的实数结果和舍入模式，返回编码和 5 位标志向量。标志位从位 0 向上依次为 NV、DZ、OF、UF 和 NX。FP32 和 FP64 有限值编码器产生三种非零组合：

| 标志 | 位 | 含义 |
| --- | --- | --- |
| 0x10 | NX | 正规结果经过了舍入 |
| 0x14 | OF 和 NX | 结果上溢为无穷大 |
| 0x18 | UF 和 NX | 低于正规范围的值经过了舍入（结果可能为零或最小正规数） |

此处使用的类型码为：0 表示 FP64，1 表示 FP32，4 表示 FP16，5 表示 BF16。`ReferenceScalarFPDataType` 把它们映射为 Tile 数据类型。

<!-- PTO-READER-BLOCK: scalar-model-fsu-reference-quantization-rules role=rules-interactions -->
## 规则与交互

`ReferenceFP32FiniteEncoding` 分四种情况处理：

1. 精确的零返回 +0.0，不带标志。
2. 把值规范化为 [1, 2) 内的有效数和一个指数。指数大于 127 时返回带符号无穷大，标志为 0x14。
3. 指数小于 -126 时，按 2^149 缩放并舍入为整数次正规有效数。结果保留其符号。经过舍入的结果报告 0x18（包括舍入为零的结果）；精确的次正规结果不报告标志。
4. 其他情况把有效数按 2^23 缩放并舍入。进位到 2^24 时指数加一，随后可能以 0x14 上溢为无穷大。经过舍入的结果报告 0x10。

`ReferenceFP64FiniteEncoding` 以 FP64 的界限执行相同步骤。FP16 结果交给 Tile 矩阵量化所拥有的 `ReferenceBinary16Encoding`。

设计要点：FP32 和 FP64 编码器接收一个实数值，并通过 `FloatingToInteger` 只舍入一次。对于融合运算，该值是 `FloatingFused` 给出的精确实数 `product + addend`，因此乘积不单独舍入。

设计要点：上溢在每种舍入模式下都返回无穷大，因为第 2 步和进位检查都不查看模式。定向模式在上溢时不会产生最大有限值。

`ReferenceScalarFPSpecialEncoding` 为类型码 0、1、4 和 5 构造规范安静 NaN、带符号无穷大或带符号零。NaN 来自 `TileNumericCanonicalNaN`，例如 FP32 为 0x7FC00000。

<!-- PTO-READER-BLOCK: scalar-model-fsu-reference-quantization-boundaries role=boundaries -->
## 架构边界

`ReferenceScalarFPFiniteValue` 只接受类型码 0、1 和 4；`ReferenceScalarFPFiniteEncoding` 断言同一集合。BF16 有限值由配置档钩子直接使用 `ReferenceBinary16FiniteValue`。

调用者必须在调用有限值函数之前去除 NaN 和无穷大输入。对于标量算术，这由本单元中的 `ReferenceScalarFPBinarySpecial` 以及特殊值单元中的一元和融合特殊函数完成。

`ReferenceScalarFPDataType` 上方的 ASL 注释说明，标量 FP 运算遵循 IEEE 754-2008，并且非有限值和带符号零处理放在有限值内核之外，因此上溢得到的无穷大仍是下一条指令的合法输入。

`ReferenceFP16FiniteEncoding` 在 ASL 树中没有调用者；标量 FP16 路径改用 `ReferenceBinary16Encoding`。

<!-- PTO-READER-BLOCK: scalar-model-fsu-reference-quantization-example role=example-usage -->
## 非规范阅读示例

用 RNE 把精确值 1/3 编码为 FP32。

- 规范化得到有效数 4/3 和指数 -2。
- 缩放后的有效数为 4/3 x 2^23 = 11184810.67。
- RNE 把它舍入为 11184811，即 0xAAAAAB。
- 编码指数为 -2 + 127 = 125，小数部分为 0xAAAAAB - 0x800000。
- 结果为 0x3EAAAAAB，标志为 0x10，因为舍入不精确。

若使用 RTZ，有效数为 11184810，得到 0x3EAAAAAA，标志为 0x10。

<!-- PTO-READER-BLOCK: scalar-model-fsu-reference-quantization-related role=related-owners-navigation -->
## 相关所有者

- [标量 FP](scalar-fp.md)通过配置档钩子调用本单元。
- [参考特殊值](reference-scalar-fp-specials.md)在有限值路径之前处理 NaN、无穷大和零。
- [FSU 算术](arithmetic.md)拥有 `FloatingToInteger` 和各舍入模式。
- [矩阵量化](../../../tile/model/execution/matrix-quantization.md)拥有 `ReferenceBinary16Encoding`。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/fsu/reference-quantization.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-FSU-REFERENCE-QUANTIZATION","surface":"scalar","classification":["model","fsu","reference-quantization"],"depends_on":["PTO-SCALAR-MODEL-FSU-SCALAR-FP","PTO-TILE-MODEL-NUMERIC-FORMATS"]}
pure func ReferencePowerOfTwo(exponent: integer {-1074..1023}) => real
begin
    var result: real = 1.0;
    let negative = exponent < 0;
    var remaining: integer {0..1074} =
        if negative then (-exponent) as integer {0..1074}
        else exponent as integer {0..1074};
    var factor: real = if negative then 0.5 else 2.0;
    while remaining > 0 looplimit 11 do
        if remaining MOD 2 == 1 then result = result * factor; end;
        factor = factor * factor;
        remaining = (remaining DIVRM 2) as integer {0..1074};
    end;
    return result;
end;

pure func ReferenceFP32FiniteValue(value: bits(32)) => real
begin
    let exponent = UInt(value[30:23]);
    let fraction = UInt(value[22:0]);
    assert exponent != 255;
    var magnitude: real = 0.0;
    if exponent == 0 then
        magnitude = Real(fraction) * ReferencePowerOfTwo(-149);
    else
        let significand = Real(0x800000 + fraction) / Real(0x800000);
        magnitude = significand * ReferencePowerOfTwo(
            (exponent - 127) as integer {-126..127});
    end;
    if value[31] == '1' then return -magnitude; end;
    return magnitude;
end;

pure func ReferenceFP64FiniteValue(value: bits(64)) => real
begin
    let exponent = UInt(value[62:52]);
    let fraction = UInt(value[51:0]);
    assert exponent != 2047;
    var magnitude: real = 0.0;
    if exponent == 0 then
        magnitude = Real(fraction) * ReferencePowerOfTwo(-1074);
    else
        let significand =
            Real(0x10000000000000 + fraction) /
            Real(0x10000000000000);
        magnitude = significand * ReferencePowerOfTwo(
            (exponent - 1023) as integer {-1022..1023});
    end;
    if value[63] == '1' then return -magnitude; end;
    return magnitude;
end;

pure func ReferenceIntegerValue(value: Word,
                                data_type: TileDataType) => integer
begin
    let normalized = NormalizeTileInteger(value, data_type);
    if TileDataTypeIsSigned(data_type) then return SInt(normalized); end;
    return UInt(normalized);
end;

func ReferenceFP32FiniteEncoding(
    value: real,
    rounding_mode: NumericRoundingMode) => (Word, bits(5))
begin
    if value == 0.0 then return (Zeros{PTO_XLEN}, Zeros{5}); end;
    let negative = value < 0.0;
    var normalized = if negative then -value else value;
    var exponent: integer {-149..128} = 0;
    while normalized >= 2.0 && exponent < 128 looplimit 128 do
        normalized = normalized / 2.0;
        exponent = (exponent + 1) as integer {-149..128};
    end;
    while normalized < 1.0 && exponent > -149 looplimit 149 do
        normalized = normalized * 2.0;
        exponent = (exponent - 1) as integer {-149..128};
    end;

    let sign = if negative then 0x80000000 else 0;
    if exponent > 127 then
        return (
            Zeros{PTO_XLEN} + sign + 0x7f800000,
            Zeros{5} + 0x14);
    end;

    if exponent < -126 then
        let scaled = value / ReferencePowerOfTwo(-149);
        let rounded = FloatingToInteger(scaled, rounding_mode);
        let magnitude = if rounded < 0 then -rounded else rounded;
        if magnitude == 0 then
            return (Zeros{PTO_XLEN} + sign, Zeros{5} + 0x18);
        end;
        return (
            Zeros{PTO_XLEN} + sign + magnitude,
            if Real(rounded) == scaled then Zeros{5}
            else Zeros{5} + 0x18);
    end;

    let scaled = if negative then
        -(normalized * Real(0x800000))
        else normalized * Real(0x800000);
    let rounded = FloatingToInteger(scaled, rounding_mode);
    var magnitude = if rounded < 0 then -rounded else rounded;
    var encoded_exponent = exponent + 127;
    if magnitude == 0x1000000 then
        magnitude = 0x800000;
        encoded_exponent =
            (encoded_exponent + 1) as integer {-22..255};
    end;
    if encoded_exponent >= 255 then
        return (
            Zeros{PTO_XLEN} + sign + 0x7f800000,
            Zeros{5} + 0x14);
    end;
    let fraction = magnitude - 0x800000;
    return (
        Zeros{PTO_XLEN} + sign + encoded_exponent * 0x800000 + fraction,
        if Real(rounded) == scaled then Zeros{5} else Zeros{5} + 0x10);
end;

func ReferenceFP64FiniteEncoding(
    value: real,
    rounding_mode: NumericRoundingMode) => (Word, bits(5))
begin
    if value == 0.0 then return (Zeros{PTO_XLEN}, Zeros{5}); end;
    let negative = value < 0.0;
    var normalized = if negative then -value else value;
    var exponent: integer {-1074..1024} = 0;
    while normalized >= 2.0 && exponent < 1024 looplimit 1024 do
        normalized = normalized / 2.0;
        exponent = (exponent + 1) as integer {-1074..1024};
    end;
    while normalized < 1.0 && exponent > -1074 looplimit 1074 do
        normalized = normalized * 2.0;
        exponent = (exponent - 1) as integer {-1074..1024};
    end;

    let sign = if negative then 0x8000000000000000 else 0;
    if exponent > 1023 then
        return (
            Zeros{PTO_XLEN} + sign + 0x7ff0000000000000,
            Zeros{5} + 0x14);
    end;

    if exponent < -1022 then
        let scaled = value / ReferencePowerOfTwo(-1074);
        let rounded = FloatingToInteger(scaled, rounding_mode);
        let magnitude = if rounded < 0 then -rounded else rounded;
        if magnitude == 0 then
            return (Zeros{PTO_XLEN} + sign, Zeros{5} + 0x18);
        end;
        return (
            Zeros{PTO_XLEN} + sign + magnitude,
            if Real(rounded) == scaled then Zeros{5}
            else Zeros{5} + 0x18);
    end;

    let scaled = if negative then
        -(normalized * Real(0x10000000000000))
        else normalized * Real(0x10000000000000);
    let rounded = FloatingToInteger(scaled, rounding_mode);
    var magnitude = if rounded < 0 then -rounded else rounded;
    var encoded_exponent = exponent + 1023;
    if magnitude == 0x20000000000000 then
        magnitude = 0x10000000000000;
        encoded_exponent =
            (encoded_exponent + 1) as integer {-51..2047};
    end;
    if encoded_exponent >= 2047 then
        return (
            Zeros{PTO_XLEN} + sign + 0x7ff0000000000000,
            Zeros{5} + 0x14);
    end;
    let fraction = magnitude - 0x10000000000000;
    return (
        Zeros{PTO_XLEN} + sign +
            encoded_exponent * 0x10000000000000 + fraction,
        if Real(rounded) == scaled then Zeros{5} else Zeros{5} + 0x10);
end;

func ReferenceFP16FiniteEncoding(
    value: real,
    rounding_mode: NumericRoundingMode) => (Word, bits(5))
begin
    if value == 0.0 then return (Zeros{PTO_XLEN}, Zeros{5}); end;
    let negative = value < 0.0;
    var normalized = if negative then -value else value;
    var exponent: integer {-24..16} = 0;
    while normalized >= 2.0 && exponent < 16 looplimit 16 do
        normalized = normalized / 2.0;
        exponent = (exponent + 1) as integer {-24..16};
    end;
    while normalized < 1.0 && exponent > -24 looplimit 24 do
        normalized = normalized * 2.0;
        exponent = (exponent - 1) as integer {-24..16};
    end;

    let sign = if negative then 0x8000 else 0;
    if exponent > 15 then
        return (
            Zeros{PTO_XLEN} + sign + 0x7c00,
            Zeros{5} + 0x14);
    end;

    if exponent < -14 then
        let scaled = value / ReferencePowerOfTwo(-24);
        let rounded = FloatingToInteger(scaled, rounding_mode);
        let magnitude = if rounded < 0 then -rounded else rounded;
        let exact = Real(rounded) == scaled;
        let flags = if exact then Zeros{5}
            else if magnitude < 0x400 then Zeros{5} + 0x18
            else Zeros{5} + 0x10;
        return (
            Zeros{PTO_XLEN} + sign + magnitude,
            flags);
    end;

    let scaled = if negative then
        -(normalized * Real(0x400))
        else normalized * Real(0x400);
    let rounded = FloatingToInteger(scaled, rounding_mode);
    var magnitude = if rounded < 0 then -rounded else rounded;
    var encoded_exponent = exponent + 15;
    if magnitude == 0x800 then
        magnitude = 0x400;
        encoded_exponent =
            (encoded_exponent + 1) as integer {-8..31};
    end;
    if encoded_exponent >= 31 then
        return (
            Zeros{PTO_XLEN} + sign + 0x7c00,
            Zeros{5} + 0x14);
    end;
    let fraction = magnitude - 0x400;
    return (
        Zeros{PTO_XLEN} + sign + encoded_exponent * 0x400 + fraction,
        if Real(rounded) == scaled then Zeros{5} else Zeros{5} + 0x10);
end;

pure func ReferenceScalarFPFiniteValue(value: Word,
                                       data_type: bits(5)) => real
begin
    if data_type == '00001' then
        return ReferenceFP32FiniteValue(value[31:0]);
    elsif data_type == '00100' then
        return ReferenceBinary16FiniteValue(value, TileDataType_FP16);
    end;
    assert data_type == '00000';
    return ReferenceFP64FiniteValue(value);
end;

func ReferenceScalarFPFiniteEncoding(
    value: real,
    data_type: bits(5),
    rounding_mode: NumericRoundingMode) => (Word, bits(5))
begin
    if data_type == '00001' then
        return ReferenceFP32FiniteEncoding(value, rounding_mode);
    elsif data_type == '00100' then
        return ReferenceBinary16Encoding(
            value,
            TileDataType_FP16,
            NumericExecutionControl {
                rounding_mode = rounding_mode,
                saturating = FALSE
            });
    end;
    assert data_type == '00000';
    return ReferenceFP64FiniteEncoding(value, rounding_mode);
end;

func ReferenceScalarFPFusedFinite(
    operation: FloatingFusedOperation,
    rounding_mode: NumericRoundingMode,
    source_type: bits(5),
    addend: Word,
    left: Word,
    right: Word) => (Word, bits(5))
begin
    return ReferenceScalarFPFiniteEncoding(
        FloatingFused(
            operation,
            ReferenceScalarFPFiniteValue(addend, source_type),
            ReferenceScalarFPFiniteValue(left, source_type),
            ReferenceScalarFPFiniteValue(right, source_type)),
        source_type,
        rounding_mode);
end;

// Linx scalar FP operations follow IEEE 754-2008. Keep non-finite and
// signed-zero handling outside the rational finite kernel so an overflowed
// infinity remains a legal input to the next instruction.
pure func ReferenceScalarFPDataType(source_type: bits(5)) => TileDataType
begin
    if source_type == '00001' then return TileDataType_FP32; end;
    if source_type == '00100' then return TileDataType_FP16; end;
    if source_type == '00101' then return TileDataType_BF16; end;
    assert source_type == '00000';
    return TileDataType_FP64;
end;

pure func ReferenceScalarFPClass(value: Word, source_type: bits(5))
    => NumericValueClass
begin
    return TileNumericValueClass(ReferenceScalarFPDataType(source_type),
        NormalizeScalarFPSource(value, source_type));
end;

pure func ReferenceScalarFPClassIsNegative(value_class: NumericValueClass)
    => boolean
begin
    return value_class == NumericValue_NegativeZero ||
           value_class == NumericValue_NegativeSubnormal ||
           value_class == NumericValue_NegativeNormal ||
           value_class == NumericValue_NegativeInfinity;
end;

pure func ReferenceScalarFPSpecialEncoding(
    source_type: bits(5), value_class: NumericValueClass) => Word
begin
    if NumericValueClassIsNaN(value_class) then
        let (available, quiet_nan) = TileNumericCanonicalNaN(
            ReferenceScalarFPDataType(source_type));
        assert available;
        return quiet_nan;
    end;
    let negative = ReferenceScalarFPClassIsNegative(value_class);
    if NumericValueClassIsInfinity(value_class) then
        if source_type == '00001' then return Zeros{PTO_XLEN} +
            (if negative then 0xff800000 else 0x7f800000); end;
        if source_type == '00100' then return Zeros{PTO_XLEN} +
            (if negative then 0xfc00 else 0x7c00); end;
        if source_type == '00101' then return Zeros{PTO_XLEN} +
            (if negative then 0xff80 else 0x7f80); end;
        return Zeros{PTO_XLEN} + (if negative then 0xfff0000000000000
            else 0x7ff0000000000000);
    end;
    assert NumericValueClassIsZero(value_class);
    if source_type == '00001' then return Zeros{PTO_XLEN} +
        (if negative then 0x80000000 else 0); end;
    if source_type == '00100' then return Zeros{PTO_XLEN} +
        (if negative then 0x8000 else 0); end;
    if source_type == '00101' then return Zeros{PTO_XLEN} +
        (if negative then 0x8000 else 0); end;
    return Zeros{PTO_XLEN} +
        (if negative then 0x8000000000000000 else 0);
end;

pure func ReferenceScalarFPSignedInfinity(source_type: bits(5),
                                           negative: boolean) => Word
begin
    return ReferenceScalarFPSpecialEncoding(source_type, if negative then
        NumericValue_NegativeInfinity else NumericValue_PositiveInfinity);
end;

pure func ReferenceScalarFPSignedZero(source_type: bits(5),
                                       negative: boolean) => Word
begin
    return ReferenceScalarFPSpecialEncoding(source_type, if negative then
        NumericValue_NegativeZero else NumericValue_PositiveZero);
end;

pure func ReferenceScalarFPBinarySpecial(
    operation: FloatingBinaryOperation, source_type: bits(5),
    left: Word, right: Word) => (boolean, Word, bits(5))
begin
    let left_class = ReferenceScalarFPClass(left, source_type);
    let right_class = ReferenceScalarFPClass(right, source_type);
    let signaling_nan = left_class == NumericValue_SignalingNaN ||
        right_class == NumericValue_SignalingNaN;
    if NumericValueClassIsNaN(left_class) ||
       NumericValueClassIsNaN(right_class) then
        return (TRUE, ReferenceScalarFPSpecialEncoding(
            source_type, NumericValue_QuietNaN),
            if signaling_nan then Zeros{5} + 1 else Zeros{5});
    end;
    let left_infinity = NumericValueClassIsInfinity(left_class);
    let right_infinity = NumericValueClassIsInfinity(right_class);
    let left_zero = NumericValueClassIsZero(left_class);
    let right_zero = NumericValueClassIsZero(right_class);
    let left_negative = ReferenceScalarFPClassIsNegative(left_class);
    let right_negative = ReferenceScalarFPClassIsNegative(right_class);
    let result_negative = left_negative != right_negative;
    if operation == FloatingBinary_ADD || operation == FloatingBinary_SUB then
        let effective_right_negative = if operation == FloatingBinary_SUB then
            !right_negative else right_negative;
        if left_infinity && right_infinity &&
           left_negative != effective_right_negative then return (TRUE,
            ReferenceScalarFPSpecialEncoding(source_type,
                NumericValue_QuietNaN), Zeros{5} + 1);
        elsif left_infinity then return (TRUE,
            ReferenceScalarFPSignedInfinity(source_type, left_negative),
            Zeros{5});
        elsif right_infinity then return (TRUE,
            ReferenceScalarFPSignedInfinity(source_type,
                effective_right_negative), Zeros{5}); end;
    elsif operation == FloatingBinary_MUL then
        if (left_zero && right_infinity) ||
           (left_infinity && right_zero) then return (TRUE,
            ReferenceScalarFPSpecialEncoding(source_type,
                NumericValue_QuietNaN), Zeros{5} + 1);
        elsif left_infinity || right_infinity then return (TRUE,
            ReferenceScalarFPSignedInfinity(source_type, result_negative),
            Zeros{5});
        elsif left_zero || right_zero then return (TRUE,
            ReferenceScalarFPSignedZero(source_type, result_negative),
            Zeros{5}); end;
    elsif operation == FloatingBinary_DIV then
        if (left_zero && right_zero) ||
           (left_infinity && right_infinity) then return (TRUE,
            ReferenceScalarFPSpecialEncoding(source_type,
                NumericValue_QuietNaN), Zeros{5} + 1);
        elsif left_infinity then return (TRUE,
            ReferenceScalarFPSignedInfinity(source_type, result_negative),
            Zeros{5});
        elsif right_infinity then return (TRUE,
            ReferenceScalarFPSignedZero(source_type, result_negative),
            Zeros{5});
        elsif right_zero then return (TRUE,
            ReferenceScalarFPSignedInfinity(source_type, result_negative),
            Zeros{5} + 2);
        elsif left_zero then return (TRUE,
            ReferenceScalarFPSignedZero(source_type, result_negative),
            Zeros{5}); end;
    end;
    return (FALSE, Zeros{PTO_XLEN}, Zeros{5});
end;
```
<!-- GENERATED-ASL-END: unit -->
