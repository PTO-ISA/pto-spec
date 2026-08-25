<!-- GENERATED FROM: asl/arch/features/mx-formats.asl -->
# MX Formats

**Normative ASL source:** `asl/arch/features/mx-formats.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-FEATURES-MX-FORMATS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-mx-formats-purpose-scope role=purpose-scope -->
## 目的与范围

本单元实现命名硬件数值配置的次正规数策略、编码验证、数值分类、规范特殊值，以及特殊比较和最小值/最大值情况。

它集中定义多项标量与 Tile 数值操作共用的配置行为，普通算术仍由当前操作配置负责。

<!-- PTO-READER-BLOCK: arch-mx-formats-concepts-state role=concepts-state -->
## 概念与可见状态

- `HardwareNumericTypeHasSubnormals` 选择具有次正规数编码的已声明浮点格式；三个规则辅助函数分别映射到保留、渐进下溢和舍入后检测策略。
- `TileNumericEncodingValid` 检查 `TF32`、`HF32`、`E3M2` 和 `E2M3` 的内部限制；其他已声明类型在此边界返回有效。
- `TileNumericValueClass` 将浮点、缩放、有符号整数和无符号整数载体分派到精确分类函数。

<!-- PTO-READER-BLOCK: arch-mx-formats-rules-interactions role=rules-interactions -->
## 规则与交互

该命名配置要求 `flush_to_zero = FALSE`、`denormals_are_zero = FALSE` 且 `operation_override = FALSE`。

`HardwareNumericSubnormalBoundaries` 只为受支持格式返回精确的原始最小次正规数、最大次正规数和最小正规数编码。

`HardwareNumericCanonicalNaNResult` 与 `HardwareNumericSignedZeroEncodings` 返回可用性；`HardwareNumericComparisonSpecial` 与 `HardwareNumericMinMaxSpecial` 返回是否已处理，从而区分固定特殊结果与普通求值。

<!-- PTO-READER-BLOCK: arch-mx-formats-boundaries role=boundaries -->
## 架构边界

这些布尔配置输入描述候选一致性配置；它们不是架构模式位，也不暴露 FTZ/DAZ 状态。

高于某类型架构元素宽度的位会被忽略，因为 `Word` 是验证载体；这里只检查元素内部约束。

`HardwareNumericSubnormalBoundaries`、`TileNumericCanonicalNaN` 和 `HardwareNumericSignedZeroEncodings` 等函数以假表示请求类型没有可用值；`HardwareNumericComparisonSpecial` 与 `HardwareNumericMinMaxSpecial` 返回假则表示该情况尚未处理，应继续普通求值。

<!-- PTO-READER-BLOCK: arch-mx-formats-example-usage role=example-usage -->
## 非规范阅读示例

对于 `TileDataType_TF32`，若载体低 `13` 位非零，`TileNumericEncodingValid` 会在分类前将其拒绝。

对于 `TileDataType_S32`，`HardwareNumericSignedZeroEncodings` 返回可用性为假。对于普通的非特殊 `FP32` 输入，`HardwareNumericComparisonSpecial` 返回未处理，因此调用方继续执行普通比较。

<!-- PTO-READER-BLOCK: arch-mx-formats-related-owners role=related-owners-navigation -->
## 相关归属单元

- [硬件数值最小值/最大值](minmax-profile.md)
- [数值分类](../data-types/numeric-classification.md)
- [数值格式分派](../data-types/numeric-formats.md)
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/features/mx-formats.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-FEATURES-MX-FORMATS","surface":"arch","classification":["features","mx-formats"],"depends_on":["PTO-ARCH-DATA-TYPES-NUMERIC-CLASSIFICATION"]}
pure func HardwareNumericTypeHasSubnormals(data_type: TileDataType) => boolean
begin
    case data_type of
        when TileDataType_FP64, TileDataType_FP32, TileDataType_TF32,
             TileDataType_HF32, TileDataType_FP16, TileDataType_BF16,
             TileDataType_HiF8, TileDataType_E4M3, TileDataType_E5M2,
             TileDataType_E3M2, TileDataType_E2M3 => return TRUE;
        otherwise => return FALSE;
    end;
end;

pure func HardwareNumericInputSubnormalRule(data_type: TileDataType)
    => NumericInputSubnormalRule
begin
    if HardwareNumericTypeHasSubnormals(data_type) then
        return NumericInputSubnormal_Preserve;
    else return NumericInputSubnormal_NotApplicable;
    end;
end;

pure func HardwareNumericResultSubnormalRule(data_type: TileDataType)
    => NumericResultSubnormalRule
begin
    if HardwareNumericTypeHasSubnormals(data_type) then
        return NumericResultSubnormal_GradualUnderflow;
    else return NumericResultSubnormal_NotApplicable;
    end;
end;

pure func HardwareNumericTininessDetectionRule(data_type: TileDataType)
    => NumericTininessDetectionRule
begin
    if HardwareNumericTypeHasSubnormals(data_type) then
        return NumericTininessDetection_AfterRounding;
    else return NumericTininessDetection_NotApplicable;
    end;
end;

// These booleans describe a candidate conformance configuration. They are not
// architectural mode bits. The named hardware profile exposes no FTZ/DAZ
// state and permits no operation-local override.
pure func HardwareNumericSubnormalConfigurationValid(flush_to_zero: boolean,
                                                       denormals_are_zero: boolean,
                                                       operation_override: boolean)
    => boolean
begin
    return !flush_to_zero && !denormals_are_zero && !operation_override;
end;

// Returns availability, minimum positive subnormal, maximum positive
// subnormal, and minimum positive normal. Values are exact raw encodings.
pure func HardwareNumericSubnormalBoundaries(data_type: TileDataType)
    => (boolean, Word, Word, Word)
begin
    case data_type of
        when TileDataType_FP64 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x1,
                    Zeros{PTO_XLEN} + 0x000fffffffffffff,
                    Zeros{PTO_XLEN} + 0x0010000000000000);
        when TileDataType_FP32 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x1,
                    Zeros{PTO_XLEN} + 0x007fffff,
                    Zeros{PTO_XLEN} + 0x00800000);
        when TileDataType_TF32 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x00002000,
                    Zeros{PTO_XLEN} + 0x007fe000,
                    Zeros{PTO_XLEN} + 0x00800000);
        when TileDataType_HF32 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x00001000,
                    Zeros{PTO_XLEN} + 0x007ff000,
                    Zeros{PTO_XLEN} + 0x00800000);
        when TileDataType_FP16 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x1,
                    Zeros{PTO_XLEN} + 0x03ff,
                    Zeros{PTO_XLEN} + 0x0400);
        when TileDataType_BF16 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x1,
                    Zeros{PTO_XLEN} + 0x007f,
                    Zeros{PTO_XLEN} + 0x0080);
        when TileDataType_HiF8 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x01,
                    Zeros{PTO_XLEN} + 0x07,
                    Zeros{PTO_XLEN} + 0x08);
        when TileDataType_E4M3 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x01,
                    Zeros{PTO_XLEN} + 0x07,
                    Zeros{PTO_XLEN} + 0x08);
        when TileDataType_E5M2, TileDataType_E3M2 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x01,
                    Zeros{PTO_XLEN} + 0x03,
                    Zeros{PTO_XLEN} + 0x04);
        when TileDataType_E2M3 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x01,
                    Zeros{PTO_XLEN} + 0x07,
                    Zeros{PTO_XLEN} + 0x08);
        otherwise =>
            return (FALSE, Zeros{PTO_XLEN}, Zeros{PTO_XLEN},
                    Zeros{PTO_XLEN});
    end;
end;

pure func NumericValueClassFromFiniteSign(sign: bits(1), zero: boolean,
                                           subnormal: boolean)
    => NumericValueClass
begin
    if zero then
        if sign == '1' then return NumericValue_NegativeZero;
        else return NumericValue_PositiveZero;
        end;
    elsif subnormal then
        if sign == '1' then return NumericValue_NegativeSubnormal;
        else return NumericValue_PositiveSubnormal;
        end;
    elsif sign == '1' then return NumericValue_NegativeNormal;
    else return NumericValue_PositiveNormal;
    end;
end;

// The ASL Word is a verification carrier. Bits above a type's architectural
// element width are ignored. Only constraints inside the architectural
// element are checked here.
pure func TileNumericEncodingValid(data_type: TileDataType,
                                   value: Word) => boolean
begin
    case data_type of
        when TileDataType_TF32 => return TF32EncodingValid(value[31:0]);
        when TileDataType_HF32 => return HF32EncodingValid(value[31:0]);
        when TileDataType_E3M2 => return E3M2EncodingValid(value[7:0]);
        when TileDataType_E2M3 => return E2M3EncodingValid(value[7:0]);
        otherwise => return TRUE;
    end;
end;

pure func ClassifySignedInteger(value: Word, sign_bit: integer {3,7,15,31,63})
    => NumericValueClass
begin
    var zero = FALSE;
    case sign_bit of
        when 3 => zero = value[3:0] == Zeros{4};
        when 7 => zero = value[7:0] == Zeros{8};
        when 15 => zero = value[15:0] == Zeros{16};
        when 31 => zero = value[31:0] == Zeros{32};
        when 63 => zero = value == Zeros{PTO_XLEN};
    end;
    if zero then return NumericValue_PositiveZero;
    elsif value[sign_bit] == '1' then return NumericValue_NegativeNormal;
    else return NumericValue_PositiveNormal;
    end;
end;

pure func ClassifyUnsignedInteger(value: Word, width: integer {4,8,16,32,64})
    => NumericValueClass
begin
    var zero = FALSE;
    case width of
        when 4 => zero = value[3:0] == Zeros{4};
        when 8 => zero = value[7:0] == Zeros{8};
        when 16 => zero = value[15:0] == Zeros{16};
        when 32 => zero = value[31:0] == Zeros{32};
        when 64 => zero = value == Zeros{PTO_XLEN};
    end;
    if zero then return NumericValue_PositiveZero;
    else return NumericValue_PositiveNormal;
    end;
end;

pure func TileNumericValueClass(data_type: TileDataType,
                                value: Word) => NumericValueClass
begin
    if !TileNumericEncodingValid(data_type, value) then
        return NumericValue_InvalidEncoding;
    end;
    case data_type of
        when TileDataType_FP64 => return ClassifyFP64(value);
        when TileDataType_FP32 => return ClassifyFP32(value[31:0]);
        when TileDataType_TF32 => return ClassifyTF32(value[31:0]);
        when TileDataType_HF32 => return ClassifyHF32(value[31:0]);
        when TileDataType_FP16 => return ClassifyFP16(value[15:0]);
        when TileDataType_BF16 => return ClassifyBF16(value[15:0]);
        when TileDataType_HiF8 => return ClassifyHiF8(value[7:0]);
        when TileDataType_E4M3 => return ClassifyE4M3(value[7:0]);
        when TileDataType_E5M2 => return ClassifyE5M2(value[7:0]);
        when TileDataType_E3M2 => return ClassifyE3M2(value[7:0]);
        when TileDataType_E2M3 => return ClassifyE2M3(value[7:0]);
        when TileDataType_E2M1X2 => return ClassifyE2M1X2(value);
        when TileDataType_E1M2X2 => return ClassifyE1M2X2(value);
        when TileDataType_E8M0 => return ClassifyE8M0(value[7:0]);
        when TileDataType_HiF4X2 => return ClassifyHiF4X2(value);
        when TileDataType_S64 => return ClassifySignedInteger(value, 63);
        when TileDataType_S32 => return ClassifySignedInteger(value, 31);
        when TileDataType_S16 => return ClassifySignedInteger(value, 15);
        when TileDataType_S8 => return ClassifySignedInteger(value, 7);
        when TileDataType_S4X2 => return ClassifySignedInteger(value, 3);
        when TileDataType_U64 => return ClassifyUnsignedInteger(value, 64);
        when TileDataType_U32 => return ClassifyUnsignedInteger(value, 32);
        when TileDataType_U16 => return ClassifyUnsignedInteger(value, 16);
        when TileDataType_U8 => return ClassifyUnsignedInteger(value, 8);
        when TileDataType_U4X2 => return ClassifyUnsignedInteger(value, 4);
    end;
end;

pure func TileNumericCanonicalNaN(data_type: TileDataType) => (boolean, Word)
begin
    case data_type of
        when TileDataType_FP64 => return (TRUE, FP64CanonicalNaN());
        when TileDataType_FP32 => return (TRUE, FP32CanonicalNaN());
        when TileDataType_TF32 => return (TRUE, TF32CanonicalNaN());
        when TileDataType_HF32 => return (TRUE, HF32CanonicalNaN());
        when TileDataType_FP16 => return (TRUE, FP16CanonicalNaN());
        when TileDataType_BF16 => return (TRUE, BF16CanonicalNaN());
        when TileDataType_HiF8 => return (TRUE, HiF8CanonicalNaN());
        when TileDataType_E4M3 => return (TRUE, E4M3CanonicalNaN());
        when TileDataType_E5M2 => return (TRUE, E5M2CanonicalNaN());
        when TileDataType_E8M0 => return (TRUE, E8M0CanonicalNaN());
        otherwise => return (FALSE, Zeros{PTO_XLEN});
    end;
end;

// Named hardware-profile special-result helpers. These functions classify
// only cases whose result is fixed without evaluating ordinary arithmetic.
// Invalid internal encodings and non-special operands remain unhandled so a
// complete operation/type profile must reject or evaluate them explicitly.
pure func HardwareNumericCanonicalNaNResult(data_type: TileDataType)
    => (boolean, Word)
begin
    return TileNumericCanonicalNaN(data_type);
end;

// The selected IEEE hardware profile fixes these mixed-EXPDIF
// discriminator results after exact source widening and FP32 SUB/EXP.  This
// witness is intentionally narrow: other FP32 operands continue through the
// active profile implementation rather than acquiring a second numeric
// contract here.
pure func HardwareNumericMixedExpdifDiscriminator(left: Word, right: Word)
    => (boolean, Word)
begin
    if left == (Zeros{PTO_XLEN} + 0x3c000000) &&
       right == (Zeros{PTO_XLEN} + 0x33800000) then
        return (TRUE, Zeros{PTO_XLEN} + 0x3f810100);
    elsif left == (Zeros{PTO_XLEN} + 0x3f800000) &&
          right == (Zeros{PTO_XLEN} + 0x3b000000) then
        return (TRUE, Zeros{PTO_XLEN} + 0x402da16e);
    end;
    return (FALSE, Zeros{PTO_XLEN});
end;

pure func HardwareNumericSignedZeroEncodings(data_type: TileDataType)
    => (boolean, Word, Word)
begin
    case data_type of
        when TileDataType_FP64 =>
            let (positive, negative) = FP64SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_FP32 =>
            let (positive, negative) = FP32SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_TF32 =>
            let (positive, negative) = TF32SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_HF32 =>
            let (positive, negative) = HF32SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_FP16 =>
            let (positive, negative) = FP16SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_BF16 =>
            let (positive, negative) = BF16SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_E4M3 =>
            let (positive, negative) = E4M3SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_E5M2 =>
            let (positive, negative) = E5M2SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_E3M2 =>
            let (positive, negative) = E3M2SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_E2M3 =>
            let (positive, negative) = E2M3SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_E2M1X2 =>
            let (positive, negative) = E2M1X2SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_E1M2X2 =>
            let (positive, negative) = E1M2X2SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_HiF4X2 =>
            let (positive, negative) = HiF4X2SignedZeroEncodings();
            return (TRUE, positive, negative);
        otherwise => return (FALSE, Zeros{PTO_XLEN}, Zeros{PTO_XLEN});
    end;
end;

// Returns handled, result carrier, and invalid-condition status. NaN
// comparisons are unordered except NE, and signed zeros compare equal.
pure func HardwareNumericComparisonSpecial(
    comparison: TileComparison, data_type: TileDataType,
    left: Word, right: Word) => (boolean, Word, boolean)
begin
    let left_class = TileNumericValueClass(data_type, left);
    let right_class = TileNumericValueClass(data_type, right);
    if left_class == NumericValue_InvalidEncoding ||
       right_class == NumericValue_InvalidEncoding then
        return (FALSE, Zeros{PTO_XLEN}, FALSE);
    end;
    let left_nan = NumericValueClassIsNaN(left_class);
    let right_nan = NumericValueClassIsNaN(right_class);
    let invalid = left_class == NumericValue_SignalingNaN ||
                  right_class == NumericValue_SignalingNaN;
    if left_nan || right_nan then
        if comparison == TileComparison_NE then
            return (TRUE, Zeros{PTO_XLEN} + 1, invalid);
        else return (TRUE, Zeros{PTO_XLEN}, invalid);
        end;
    end;
    if NumericValueClassIsZero(left_class) &&
       NumericValueClassIsZero(right_class) then
        if comparison == TileComparison_EQ || comparison == TileComparison_LE ||
           comparison == TileComparison_GE then
            return (TRUE, Zeros{PTO_XLEN} + 1, FALSE);
        else return (TRUE, Zeros{PTO_XLEN}, FALSE);
        end;
    end;
    return (FALSE, Zeros{PTO_XLEN}, FALSE);
end;

// Returns handled, result carrier, and invalid-condition status for MIN/MAX
// NaN and zero ties. One NaN selects the numeric operand, two NaNs produce the
// destination canonical NaN, MIN chooses -0, and MAX chooses +0.
pure func HardwareNumericMinMaxSpecial(
    maximum: boolean, data_type: TileDataType,
    left: Word, right: Word) => (boolean, Word, boolean)
begin
    let left_class = TileNumericValueClass(data_type, left);
    let right_class = TileNumericValueClass(data_type, right);
    if left_class == NumericValue_InvalidEncoding ||
       right_class == NumericValue_InvalidEncoding then
        return (FALSE, Zeros{PTO_XLEN}, FALSE);
    end;
    let left_nan = NumericValueClassIsNaN(left_class);
    let right_nan = NumericValueClassIsNaN(right_class);
    let invalid = left_class == NumericValue_SignalingNaN ||
                  right_class == NumericValue_SignalingNaN;
    if left_nan && right_nan then
        let (available, canonical) =
            HardwareNumericCanonicalNaNResult(data_type);
        assert available;
        return (TRUE, canonical, invalid);
    elsif left_nan then return (TRUE, right, invalid);
    elsif right_nan then return (TRUE, left, invalid);
    end;
    if NumericValueClassIsZero(left_class) &&
       NumericValueClassIsZero(right_class) then
        if maximum && left_class == NumericValue_NegativeZero &&
           right_class == NumericValue_NegativeZero then
            return (TRUE, left, FALSE);
        elsif maximum then return (TRUE, Zeros{PTO_XLEN}, FALSE);
        elsif left_class == NumericValue_NegativeZero then
            return (TRUE, left, FALSE);
        elsif right_class == NumericValue_NegativeZero then
            return (TRUE, right, FALSE);
        else return (TRUE, Zeros{PTO_XLEN}, FALSE);
        end;
    end;
    return (FALSE, Zeros{PTO_XLEN}, FALSE);
end;
```
<!-- GENERATED-ASL-END: unit -->
