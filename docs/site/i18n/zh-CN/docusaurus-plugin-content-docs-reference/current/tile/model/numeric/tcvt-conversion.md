<!-- GENERATED FROM: asl/tile/model/numeric/tcvt-conversion.asl -->
# Tcvt Conversion

**Normative ASL source:** `asl/tile/model/numeric/tcvt-conversion.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-NUMERIC-TCVT-CONVERSION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-numeric-tcvt-conversion-purpose role=purpose-scope -->
## 作用与范围

本单元拥有 `ReferenceTCVTConvert`，即封闭缩放格式与打包格式的 TCVT 转换规则，以及它的包装函数。

- `ReferenceTCVTConvertPacked4` 与 `ReferenceTCVTConvertFromPacked4` 在 E2M1X2、E1M2X2 与其他格式之间转换。
- `ReferenceTCVTConvertToE6M2` 与 `ReferenceTCVTConvertFromE6M2` 在 E6M2 与其他格式之间转换。
- `ReferenceTCVTConvertFromRCPE6M2` 从 RCPE6M2 转换，RCPE6M2 是 E6M2 编码的倒数解读。
- `ReferenceTCVTConvertFromE8M0` 从 E8M0 转换。

每个包装函数先处理特殊值，然后调用有限值编码器。

<!-- PTO-READER-BLOCK: tile-model-numeric-tcvt-conversion-concepts role=concepts-state -->
## 概念与可见状态

`ReferenceTCVTConvert` 按以下顺序检查类型对：E8M0 源、打包目标、打包源、E6M2 目标、E6M2 源、RCPE6M2 源。其他任何类型对交给 `ReferenceCommonConvert`。

这些包装函数的普通浮点一侧为 FP32、FP16 或 BF16。对转换到打包格式与 E6M2 的情况，`ReferenceTCVTOrdinaryFloatingSourceSupported` 断言这一点；`ReferenceTCVTConvertFromE8M0` 对其目标断言这一点。合法类型对本身由 E8M0 conversion 单元中的 `HardwareTCVTTypePairSupported` 决定。

标志使用 `0x01` NV、`0x10` NX、`0x14` OF 加 NX，以及 `0x18` UF 加 NX。

<!-- PTO-READER-BLOCK: tile-model-numeric-tcvt-conversion-rules role=rules-interactions -->
## 规则与交互

转换到 E2M1X2 或 E1M2X2：

- NaN 或无效编码得到编码 0，仅当源为信号 NaN 或无效编码时带 NV。
- 无穷得到同号的最大有限编码（E2M1X2 为 6 或 14，E1M2X2 为 7 或 15），并带 OF 与 NX。
- 零保留符号；有限值交给 `ReferencePacked4Encoding`。

设计要点：四位格式没有 NaN 或无穷编码，因此这些包装函数把 NaN 映射为正零，把无穷映射为有限端点。可观察的结果是四位 Tile 从不保存特殊值：OF 记录被替换的无穷，NV 记录被替换的信号 NaN 或无效编码；被替换的静默 NaN 不产生标志。

从 E2M1X2 或 E1M2X2 转换：零保留符号，其他每个通道值都是精确的，并对目标舍入一次。

转换到 E6M2：

- NaN 或无效编码得到 `0xFF`，仅当源为信号 NaN 或无效编码时带 NV。
- 任一符号的零得到编码 0（2^-48），并带 UF 与 NX，因为 E6M2 没有零。
- 负值或负无穷得到 `0xFF`，并带 NV。
- 正无穷得到 `0xFF`，饱和时得到 `0xFE`，并带 OF 与 NX。

从 E6M2、RCPE6M2 或 E8M0 转换：NaN 编码 `0xFF` 得到目标的规范静默 NaN，不带标志。其他每个编码都被转换为其精确实数值（对 E8M0 为 2^(code - 127)），并对目标舍入一次。

设计要点：RCPE6M2 被解读为 E6M2 值的精确倒数，只应用最终的目标舍入。不存在中间舍入的 E6M2 或浮点值，因此结果可能不同于先转换 E6M2 值再取倒数。

<!-- PTO-READER-BLOCK: tile-model-numeric-tcvt-conversion-boundaries role=boundaries -->
## 架构边界

对涉及这些格式的已接受类型对，formats 单元中的 `TCVT` 直接调用本规则，`TileProfileConvert` 对打包格式、E6M2 以及 RCPE6M2 源也会到达本规则，但对 E8M0 源不会。转换到 E8M0 不在此处；它是 `ReferenceFloatToE8M0`。

舍入模式合法性在本规则运行之前检查：E6M2 与 RCPE6M2 类型对只接受 RNE 与 RNA。

<!-- PTO-READER-BLOCK: tile-model-numeric-tcvt-conversion-example role=example-usage -->
## 非规范阅读示例

以 RNE 把 E8M0 转换为 FP16 与 BF16：

- 编码 `0x7F` 为 2^0 = 1.0，得到 FP16 `0x3C00`，不带标志。
- 编码 `0x8F` 为 2^16 = 65536，超过 FP16 最大值 65504。结果为 FP16 无穷 `0x7C00`，并带 OF 与 NX；饱和时为 `0x7BFF`。
- 编码 `0x00` 为 2^-127。在 BF16 中它是精确的次正规数 `0x0040`，不带标志。在 FP16 中它小于最小次正规数 2^-24 的一半，因此舍入为 `0x0000`，并带 UF 与 NX。

E6M2 编码 `0xC0` 的指数字段为 48、小数为 0，因此其值为 1.0，转换为 FP16 `0x3C00`。

<!-- PTO-READER-BLOCK: tile-model-numeric-tcvt-conversion-related role=related-owners-navigation -->
## 相关归属

- [Packed conversion](packed-conversion.md) 拥有有限值四位与 E6M2 编码器。
- [E8M0 conversion](e8m0-conversion.md) 拥有类型对合法性以及到 E8M0 的转换。
- [Reference conversion](reference-conversion.md) 拥有其他类型对使用的公共规则。
- [RCPE6M2 format](../../../arch/data-types/formats/rcpe6m2.md) 与 [E6M2 format](../../../arch/data-types/formats/e6m2.md) 拥有缩放编码。
- [TCVT](../../elementwise-tile-tile/format-conversion/TCVT.md) 是指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/numeric/tcvt-conversion.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-NUMERIC-TCVT-CONVERSION","surface":"tile","classification":["model","numeric","tcvt-conversion"],"depends_on":["PTO-TILE-MODEL-NUMERIC-REFERENCE-CONVERSION","PTO-TILE-MODEL-EXECUTION-MATRIX-QUANTIZATION","PTO-TILE-MODEL-NUMERIC-PACKED-CONVERSION"]}

pure func ReferenceTCVTOrdinaryFloatingSourceSupported(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP32 ||
           data_type == TileDataType_FP16 ||
           data_type == TileDataType_BF16;
end;

pure func ReferenceTCVTOrdinaryFloatingFiniteValue(
    value: Word, data_type: TileDataType) => real
begin
    assert ReferenceTCVTOrdinaryFloatingSourceSupported(data_type);
    if data_type == TileDataType_FP32 then
        return ReferenceFP32FiniteValue(value[31:0]);
    end;
    return ReferenceBinary16FiniteValue(value, data_type);
end;

func ReferenceTCVTConvertPacked4(
    value: Word, source_type: TileDataType,
    destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    assert ReferenceTCVTOrdinaryFloatingSourceSupported(source_type);
    let value_class = TileNumericValueClass(source_type, value);
    if NumericValueClassIsNaN(value_class) ||
       value_class == NumericValue_InvalidEncoding then
        return (Zeros{PTO_XLEN},
            if value_class == NumericValue_SignalingNaN ||
               value_class == NumericValue_InvalidEncoding then
                Zeros{5} + 1 else Zeros{5});
    end;
    if NumericValueClassIsInfinity(value_class) then
        let negative = value_class == NumericValue_NegativeInfinity;
        let maximum_code = if destination_type == TileDataType_E2M1X2
            then 6 else 7;
        return (Zeros{PTO_XLEN} +
                (if negative then maximum_code + 8 else maximum_code),
                Zeros{5} + 0x14);
    end;
    if NumericValueClassIsZero(value_class) then
        let (available, positive, negative) =
            HardwareNumericSignedZeroEncodings(destination_type);
        assert available;
        return (if value_class == NumericValue_NegativeZero then negative
                else positive, Zeros{5});
    end;
    return ReferencePacked4Encoding(
        ReferenceTCVTOrdinaryFloatingFiniteValue(value, source_type),
        destination_type, control);
end;

func ReferenceTCVTConvertFromPacked4(
    value: Word, source_type: TileDataType,
    destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    let value_class = TileNumericValueClass(source_type, value);
    if NumericValueClassIsZero(value_class) then
        let (available, positive, negative) =
            HardwareNumericSignedZeroEncodings(destination_type);
        assert available;
        return (if value_class == NumericValue_NegativeZero then negative
                else positive, Zeros{5});
    end;
    return ReferenceMatrixFloatingEncoding(
        ReferencePacked4FiniteValue(source_type, UInt(value[3:0])),
        destination_type, control);
end;

func ReferenceTCVTConvertToE6M2(
    value: Word, source_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    assert ReferenceTCVTOrdinaryFloatingSourceSupported(source_type);
    let value_class = TileNumericValueClass(source_type, value);
    if NumericValueClassIsNaN(value_class) ||
       value_class == NumericValue_InvalidEncoding then
        return (Zeros{PTO_XLEN} + 0xff,
            if value_class == NumericValue_SignalingNaN ||
               value_class == NumericValue_InvalidEncoding then
                Zeros{5} + 1 else Zeros{5});
    end;
    if value_class == NumericValue_NegativeZero ||
       value_class == NumericValue_PositiveZero then
        return (Zeros{PTO_XLEN}, Zeros{5} + 0x18);
    end;
    if value_class == NumericValue_NegativeInfinity ||
       value_class == NumericValue_NegativeNormal ||
       value_class == NumericValue_NegativeSubnormal then
        return (Zeros{PTO_XLEN} + 0xff, Zeros{5} + 1);
    end;
    if value_class == NumericValue_PositiveInfinity then
        return (
            if control.saturating then Zeros{PTO_XLEN} + 0xfe
            else Zeros{PTO_XLEN} + 0xff,
            Zeros{5} + 0x14);
    end;
    return ReferenceE6M2Encoding(
        ReferenceTCVTOrdinaryFloatingFiniteValue(value, source_type),
        control);
end;

func ReferenceTCVTConvertFromE6M2(
    value: Word, destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    let value_class = TileNumericValueClass(
        TileDataType_E6M2, value);
    if NumericValueClassIsNaN(value_class) ||
       value_class == NumericValue_InvalidEncoding then
        let (available, canonical) =
            TileNumericCanonicalNaN(destination_type);
        assert available;
        return (canonical, Zeros{5});
    end;
    return ReferenceMatrixFloatingEncoding(
        E6M2FiniteValue(value[7:0]), destination_type, control);
end;

func ReferenceTCVTConvertFromRCPE6M2(
    value: Word, destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    let value_class = TileNumericValueClass(
        TileDataType_RCPE6M2, value);
    if NumericValueClassIsNaN(value_class) ||
       value_class == NumericValue_InvalidEncoding then
        let (available, canonical) =
            TileNumericCanonicalNaN(destination_type);
        assert available;
        return (canonical, Zeros{5});
    end;
    return ReferenceMatrixFloatingEncoding(
        RCPE6M2FiniteValue(value[7:0]), destination_type, control);
end;

func ReferenceTCVTConvertFromE8M0(
    value: Word, destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    assert destination_type == TileDataType_FP16 ||
           destination_type == TileDataType_BF16 ||
           destination_type == TileDataType_FP32;
    if value[7:0] == Ones{8} then
        let (available, canonical) =
            TileNumericCanonicalNaN(destination_type);
        assert available;
        return (canonical, Zeros{5});
    end;
    let exponent = (UInt(value[7:0]) - 127)
        as integer {-1074..1023};
    return ReferenceMatrixFloatingEncoding(
        ReferencePowerOfTwo(exponent), destination_type, control);
end;

func ReferenceTCVTConvert(
    value: Word, source_type: TileDataType,
    destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    if source_type == TileDataType_E8M0 then
        return ReferenceTCVTConvertFromE8M0(
            value, destination_type, control);
    elsif destination_type == TileDataType_E2M1X2 ||
       destination_type == TileDataType_E1M2X2 then
        return ReferenceTCVTConvertPacked4(
            value, source_type, destination_type, control);
    elsif source_type == TileDataType_E2M1X2 ||
          source_type == TileDataType_E1M2X2 then
        return ReferenceTCVTConvertFromPacked4(
            value, source_type, destination_type, control);
    elsif destination_type == TileDataType_E6M2 then
        return ReferenceTCVTConvertToE6M2(value, source_type, control);
    elsif source_type == TileDataType_E6M2 then
        return ReferenceTCVTConvertFromE6M2(
            value, destination_type, control);
    elsif source_type == TileDataType_RCPE6M2 then
        return ReferenceTCVTConvertFromRCPE6M2(
            value, destination_type, control);
    end;
    return ReferenceCommonConvert(
        value, source_type, destination_type, control);
end;
```
<!-- GENERATED-ASL-END: unit -->
