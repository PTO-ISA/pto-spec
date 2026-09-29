<!-- GENERATED FROM: asl/tile/model/execution/matrix-postprocess.asl -->
# Matrix Postprocess

**Normative ASL source:** `asl/tile/model/execution/matrix-postprocess.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-MATRIX-POSTPROCESS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-matrix-postprocess-purpose role=purpose-scope -->
## 用途与范围

本单元把一个 CUBE 累加器元素转换为其最终的 D 值。它应用 B.FPATR 的激活、缩放、偏移、舍入、饱和和特殊值规则。

`MatrixPostQuantBaseWithFlags` 是逐元素入口，经由后处理单元中的 `TileProfileMatrixPostProcessWithFlags` 到达。本单元还为 MaxAbs 归约提供 `MatrixReductionAbsoluteWithFlags`。它承载 NDF 条款 `PTO-MATRIX-POSTPROCESS-BITEXACT-001`。

<!-- PTO-READER-BLOCK: tile-model-execution-matrix-postprocess-concepts role=concepts-state -->
## 概念与可见状态

- 源类型是转换所见的累加器类型：PreQuantMode 为 0 时为输出类型，S32 模式为 S32，其他情况为 FP32。
- ReluMode 0 表示不激活，1 表示 ReLU，2 或 3 表示取自标量或向量参数的 leaky 斜率。
- 量化缩放是参数位 `[31:13]` 中的 FP19 值。有符号偏移宽度为 0、5、9 或 17 位，由 `BundleFPATRModeOffsetWidth` 选择。

标志从位 0 起依次为 NV、DZ、OF、UF、NX。`0x14` 是 OF 加 NX。

<!-- PTO-READER-BLOCK: tile-model-execution-matrix-postprocess-rules role=rules-interactions -->
## 规则与交互

当 PreQuantMode 和 ReluMode 都为 0 时，值原样通过。移位模式 12 和 13 直接进入 `MatrixShiftS32ToS16`，移位量为参数位 `[35:32]` 加一。

对其他模式，`MatrixSelectedMultiplier` 选择一个乘数。对非负源或 ReluMode 0，它是缩放值。对负源，ReluMode 1 下为 0，ReluMode 2 或 3 下为 FP19 ReLU 参数。

NaN 或无穷的 FP32 源由 `MatrixPostQuantSpecialValue` 处理。整数目标得到 0 或饱和规则所选的端点值，并引发 NV 或 OF 加 NX。浮点目标得到 NaN、零、无穷或最大有限值。乘数为 0 时，负无穷改为被视为 0.0。

有限源乘以乘数。偏移宽度非零时，`MatrixQuantizedAffine` 在该宽度上舍入并饱和，加上偏移，再对结果编码。否则加上偏移后由 `MatrixEncodeReal` 编码其和。

`MatrixFPATREffectiveControl` 对模式 25 和 28 强制 RHB，对其他固定舍入模式强制 RNE。其余模式保留 B.DATR 的舍入。

设计要点：当 FP32 源为负零、乘数非零、偏移为零且目标为浮点时，返回 `MatrixFloatingSignedZero(output_type, TRUE)`：对 FP32、FP16、BF16 和 E4M3 为负零，对 HiF8 为 `0x00`。在格式具有负零时符号得以保留，而实数路径会丢失它。

设计要点：除使用算术移位的移位模式外，每个步骤都以精确实数算术书写，每个阶段有一个明确的舍入点；NDF 要求结果逐位精确，因此每个实现都发布相同的 D。

<!-- PTO-READER-BLOCK: tile-model-execution-matrix-postprocess-boundaries role=boundaries -->
## 架构边界

`MatrixFloatingLargestFinite` 没有 FP64 或 E5M2 条目，`MatrixFloatingInfinity` 对 FP32、FP16、BF16 和 HiF8 以外的每种类型返回规范 NaN。PreQuantMode 非零时，目标类型是 `BundleFPATROutputType` 为该模式列出的类型。

对 MaxAbs，`MatrixReductionAbsoluteWithFlags` 把 S32 `0x80000000` 映射为 `0x7fffffff` 并置 OF。合法性只允许 FP32、FP16 和 BF16 归约，它们使用浮点 ABS。

<!-- PTO-READER-BLOCK: tile-model-execution-matrix-postprocess-example role=example-usage -->
## 非规范阅读示例

一个 TMATMUL 具有 FP32 累加器、PreQuantMode 1 和 ReluMode 1。模式 1 输出 FP16，不使用缩放参数，并固定使用 RNE。

1. 累加器元素 2.5 非负，因此乘数为 1.0。结果 2.5 精确编码为 FP16 `0x4100`。
2. 累加器元素 -3.0 在 ReLU 下为负，因此乘数为 0。结果 0.0 编码为 `0x0000`。
3. 乘数为 0 时，累加器元素负无穷被视为 0.0，因此 ReLU 同样得到 `0x0000`，且无标志。

<!-- PTO-READER-BLOCK: tile-model-execution-matrix-postprocess-related role=related-owners-navigation -->
## 相关所有者

- [矩阵量化](matrix-quantization.md)拥有舍入、饱和和编码辅助函数。
- [后处理](postprocess.md)路由参数并发布结果。
- [B.FPATR](../../../block/attributes/B.FPATR.md)定义模式表。
- [参考量化](../../../scalar/model/fsu/reference-quantization.md)拥有 FP32 有限值解码。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/matrix-postprocess.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-MATRIX-POSTPROCESS","surface":"tile","classification":["model","execution","matrix-postprocess"],"depends_on":["PTO-TILE-MODEL-EXECUTION-MATRIX-QUANTIZATION","PTO-TILE-MODEL-EXECUTION-MATRIX-SCALE"]}
// Bit-exact B.FPATR conversion, activation, auxiliary reduction, and flags.
// NDF-BEGIN: PTO-MATRIX-POSTPROCESS-BITEXACT-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// Matrix post-processing MUST apply the existing CScale, activation,
// quantization, rounding, saturation, and special-value rules to each logical
// accumulator element and encode the final D value in EffectiveDType before
// reduction. RowMax and GroupMax MUST consume those final encoded D values in
// increasing-column order; MaxAbs and RowMaxInit use the same effective type.
// The model MUST publish D, enabled auxiliary outputs, and sticky flags as one
// non-faulting commit.
// NDF-END: PTO-MATRIX-POSTPROCESS-BITEXACT-001


pure func MatrixFloatingSignedZero(
    data_type: TileDataType, negative: boolean) => Word
begin
    if !negative then return Zeros{PTO_XLEN}; end;
    case data_type of
        when TileDataType_FP32 => return Zeros{PTO_XLEN} + 0x80000000;
        when TileDataType_FP16, TileDataType_BF16 =>
            return Zeros{PTO_XLEN} + 0x8000;
        when TileDataType_E4M3 => return Zeros{PTO_XLEN} + 0x80;
        when TileDataType_HiF8 => return Zeros{PTO_XLEN};
        otherwise => return Zeros{PTO_XLEN};
    end;
end;

pure func MatrixFloatingInfinity(
    data_type: TileDataType, negative: boolean) => Word
begin
    case data_type of
        when TileDataType_FP32 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xff800000 else 0x7f800000);
        when TileDataType_FP16 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xfc00 else 0x7c00);
        when TileDataType_BF16 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xff80 else 0x7f80);
        when TileDataType_HiF8 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xef else 0x6f);
        otherwise =>
            let (available, quiet_nan) =
                HardwareNumericCanonicalNaNResult(data_type);
            assert available;
            return quiet_nan;
    end;
end;

pure func MatrixFloatingLargestFinite(
    data_type: TileDataType, negative: boolean) => Word
begin
    case data_type of
        when TileDataType_FP32 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xff7fffff else 0x7f7fffff);
        when TileDataType_FP16 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xfbff else 0x7bff);
        when TileDataType_BF16 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xff7f else 0x7f7f);
        when TileDataType_E4M3 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xfe else 0x7e);
        when TileDataType_HiF8 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xee else 0x6e);
        otherwise => unreachable;
    end;
end;

func MatrixEncodeReal(
    value: real, data_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    if TileDataTypeIsInteger(data_type) then
        return ReferenceMatrixIntegerEncoding(value, data_type, control);
    end;
    return ReferenceMatrixFloatingEncoding(value, data_type, control);
end;

func MatrixPostQuantSpecialValue(
    value: Word, source_type: TileDataType,
    destination_type: TileDataType,
    control: NumericExecutionControl)
    => (boolean, Word, bits(5))
begin
    if !TileDataTypeIsFloating(source_type) then
        return (FALSE, Zeros{PTO_XLEN}, Zeros{5});
    end;
    let value_class = TileNumericValueClass(source_type, value);
    if NumericValueClassIsNaN(value_class) then
        if TileDataTypeIsInteger(destination_type) then
            return (TRUE,
                if control.saturating then Zeros{PTO_XLEN}
                else TileIntegerMinimum(destination_type),
                Zeros{5} + 1);
        end;
        if control.saturating then
            return (TRUE, Zeros{PTO_XLEN},
                if value_class == NumericValue_SignalingNaN then
                    Zeros{5} + 1 else Zeros{5});
        end;
        let (available, quiet_nan) =
            HardwareNumericCanonicalNaNResult(destination_type);
        assert available;
        return (TRUE, quiet_nan,
            if value_class == NumericValue_SignalingNaN then
                Zeros{5} + 1 else Zeros{5});
    elsif NumericValueClassIsInfinity(value_class) then
        let negative = value_class == NumericValue_NegativeInfinity;
        if TileDataTypeIsInteger(destination_type) then
            let endpoint = if !control.saturating then
                TileIntegerMinimum(destination_type)
            else if negative then
                TileIntegerMinimum(destination_type)
            else
                TileIntegerMaximum(destination_type);
            return (TRUE, endpoint,
                if control.saturating then Zeros{5} + 0x14
                else Zeros{5} + 1);
        elsif control.saturating then
            return (TRUE,
                MatrixFloatingLargestFinite(destination_type, negative),
                Zeros{5} + 0x14);
        else
            return (TRUE,
                MatrixFloatingInfinity(destination_type, negative),
                if destination_type == TileDataType_E4M3 then
                    Zeros{5} + 0x14 else Zeros{5});
        end;
    end;
    return (FALSE, Zeros{PTO_XLEN}, Zeros{5});
end;

pure func MatrixValueClassNegative(
    value_class: NumericValueClass) => boolean
begin
    return value_class == NumericValue_NegativeNormal ||
           value_class == NumericValue_NegativeSubnormal ||
           value_class == NumericValue_NegativeInfinity ||
           value_class == NumericValue_NegativeZero;
end;

pure func MatrixSelectedMultiplier(
    source_negative: boolean, relu_mode: bits(3),
    quant_scale: real, relu_param: Word) => real
begin
    if !source_negative || UInt(relu_mode) == 0 then
        return quant_scale;
    elsif UInt(relu_mode) == 1 then
        return 0.0;
    end;
    return FP19FiniteValue(relu_param[18:0]);
end;

func MatrixActivationWithFlags(
    value: real, source_negative: boolean, relu_mode: bits(3),
    quant_scale: real, relu_param: Word) => (real, bits(5))
begin
    let multiplier = MatrixSelectedMultiplier(
        source_negative, relu_mode, quant_scale, relu_param);
    return (value * multiplier, Zeros{5});
end;

pure func MatrixFPATREffectiveControl(
    pre_quant_mode: bits(6), control: NumericExecutionControl)
    => NumericExecutionControl
begin
    var result = control;
    let mode = UInt(pre_quant_mode);
    if mode == 25 || mode == 28 then
        result.rounding_mode = NumericRound_RHB;
    elsif BundleFPATRModeFixedRounding(pre_quant_mode) then
        result.rounding_mode = NumericRound_RNE;
    end;
    return result;
end;

func MatrixPostQuantBaseWithFlags(
    value: Word, pre_quant_mode: bits(6), output_type: TileDataType,
    relu_mode: bits(3), quant_param: Word, relu_param: Word,
    control: NumericExecutionControl)
    => (Word, bits(5))
begin
    if UInt(pre_quant_mode) == 0 && UInt(relu_mode) == 0 then
        return (value, Zeros{5});
    end;
    if BundleFPATRModeIsShift(pre_quant_mode) then
        let shift = UInt(quant_param[35:32]) + 1;
        return MatrixShiftS32ToS16(
            value[31:0], shift as integer {1..16});
    end;

    let source_type = if UInt(pre_quant_mode) == 0 then output_type
    else if BundleFPATRModeUsesS32Accumulator(
        pre_quant_mode) then TileDataType_S32 else TileDataType_FP32;
    let source_class = if source_type == TileDataType_FP32 then
        TileNumericValueClass(source_type, value)
    else
        NumericValue_PositiveNormal;
    let source_negative = if source_type == TileDataType_S32 then
        SInt(value[31:0]) < 0
    else
        MatrixValueClassNegative(source_class);
    let scale = if BundleFPATRModeUsesScalarParameter(pre_quant_mode) ||
                   BundleFPATRModeUsesVectorParameter(pre_quant_mode) then
        FP19FiniteValue(quant_param[31:13])
    else
        1.0;
    let multiplier = MatrixSelectedMultiplier(
        source_negative, relu_mode, scale, relu_param);
    let (special, special_result, special_flags) =
        MatrixPostQuantSpecialValue(
            value, source_type, output_type, control);
    if special &&
       !(source_class == NumericValue_NegativeInfinity &&
         multiplier == 0.0) then
        return (special_result, special_flags);
    end;

    let source_value = if source_type == TileDataType_S32 then
        Real(SInt(value[31:0]))
    else if source_type == TileDataType_U32 then
        Real(UInt(value[31:0]))
    else if source_class == NumericValue_NegativeInfinity then
        0.0
    else
        ReferenceFP32FiniteValue(value[31:0]);
    let (activated, activation_flags) = MatrixActivationWithFlags(
        source_value, source_negative, relu_mode, scale, relu_param);
    let offset = MatrixQuantOffset(
        quant_param, BundleFPATRModeOffsetWidth(pre_quant_mode));
    let intermediate_width =
        BundleFPATRModeOffsetWidth(pre_quant_mode);
    if source_class == NumericValue_NegativeZero &&
       multiplier != 0.0 && offset == 0 &&
       TileDataTypeIsFloating(output_type) then
        return (
            MatrixFloatingSignedZero(output_type, TRUE),
            activation_flags);
    end;
    if intermediate_width != 0 then
        let (encoded, encoding_flags) = MatrixQuantizedAffine(
            activated, 1.0, offset, intermediate_width,
            output_type, control);
        return (encoded, activation_flags OR encoding_flags);
    end;
    let (encoded, encoding_flags) = MatrixEncodeReal(
        activated + Real(offset), output_type, control);
    return (encoded, activation_flags OR encoding_flags);
end;




pure func MatrixReductionAbsoluteWithFlags(
    value: Word, data_type: TileDataType) => (Word, bits(5))
begin
    if data_type == TileDataType_U32 then
        return (ZeroExtend{PTO_XLEN}(value[31:0]), Zeros{5});
    elsif data_type == TileDataType_S32 then
        if value[31] == '0' then
            return (SignExtend{PTO_XLEN}(value[31:0]), Zeros{5});
        end;
        let magnitude = Zeros{32} - value[31:0];
        if value[31:0] == '10000000000000000000000000000000' then
            return (Zeros{PTO_XLEN} + 0x7fffffff, Zeros{5} + 4);
        end;
        return (
            SignExtend{PTO_XLEN}(magnitude),
            Zeros{5});
    end;
    let (result, invalid) = TileFixedUnaryValue(
        TileUnary_ABS, data_type, value);
    return (result, if invalid then Zeros{5} + 1 else Zeros{5});
end;
```
<!-- GENERATED-ASL-END: unit -->
