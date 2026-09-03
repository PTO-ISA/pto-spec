<!-- GENERATED FROM: asl/arch/profile/reference-scalar-fp-specials.asl -->
# Reference Scalar Fp Specials

**Normative ASL source:** `asl/arch/profile/reference-scalar-fp-specials.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROFILE-REFERENCE-SCALAR-FP-SPECIALS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-profile-reference-scalar-fp-specials-purpose role=purpose-scope -->
## 目的与范围

本页是一个架构 `ASL` owner 的稳定阅读入口。下方生成的单元仍是架构含义的完整来源。

<!-- PTO-READER-BLOCK: arch-profile-reference-scalar-fp-specials-concepts role=concepts-state -->
## 概念与可见状态

通过生成的声明和嵌入式 requirement 区域识别该 owner 引用的概念与状态。本指南不增加状态，也不重命名现有概念。

<!-- PTO-READER-BLOCK: arch-profile-reference-scalar-fp-specials-rules role=rules-interactions -->
## 规则与交互

沿生成单元中的依赖元数据和调用关系找到交互 owner。生成文档与证据始终只是这些源文件的投影。

<!-- PTO-READER-BLOCK: arch-profile-reference-scalar-fp-specials-boundaries role=boundaries -->
## 架构边界

固定边界、profile hook、故障及未规定情况均以生成 owner 的原文为准。本阅读指南不会提升任何实现行为。

<!-- PTO-READER-BLOCK: arch-profile-reference-scalar-fp-specials-example role=example-usage -->
## 非规范阅读示例

先从生成的单元标识开始，定位相关 requirement 区域，再沿引用的 owner 导航，最后查阅可执行证据。

<!-- PTO-READER-BLOCK: arch-profile-reference-scalar-fp-specials-related role=related-owners-navigation -->
## 相关 owner

下方依赖列表和源文件链接构成相关架构 owner 的导航索引；当前含义最终都应回到命名的 `ASL` 源文件。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/profile/reference-scalar-fp-specials.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-REFERENCE-SCALAR-FP-SPECIALS","surface":"arch","classification":["profile","reference-scalar-fp-specials"],"depends_on":["PTO-ARCH-PROFILE-MATRIX-QUANTIZATION","PTO-ARCH-PROFILE-REFERENCE-QUANTIZATION"]}
// IEEE 754 special-value handling remains outside the rational finite kernel.

pure func ReferenceScalarFPUnarySpecial(
    operation: FloatingUnaryOperation, source_type: bits(5), value: Word)
    => (boolean, Word, bits(5))
begin
    let value_class = ReferenceScalarFPClass(value, source_type);
    if NumericValueClassIsNaN(value_class) then
        return (TRUE, ReferenceScalarFPSpecialEncoding(
            source_type, NumericValue_QuietNaN),
            if value_class == NumericValue_SignalingNaN then Zeros{5} + 1
            else Zeros{5});
    end;
    let negative = ReferenceScalarFPClassIsNegative(value_class);
    case operation of
        when FloatingUnary_EXP =>
            if value_class == NumericValue_PositiveInfinity then
                return (TRUE, ReferenceScalarFPSignedInfinity(
                    source_type, FALSE), Zeros{5});
            elsif value_class == NumericValue_NegativeInfinity then
                return (TRUE, ReferenceScalarFPSignedZero(
                    source_type, FALSE), Zeros{5});
            end;
        when FloatingUnary_RECIP =>
            if NumericValueClassIsZero(value_class) then
                return (TRUE, ReferenceScalarFPSignedInfinity(
                    source_type, negative), Zeros{5} + 2);
            elsif NumericValueClassIsInfinity(value_class) then
                return (TRUE, ReferenceScalarFPSignedZero(
                    source_type, negative), Zeros{5});
            end;
        when FloatingUnary_SQRT =>
            if NumericValueClassIsZero(value_class) then
                return (TRUE, ReferenceScalarFPSignedZero(
                    source_type, negative), Zeros{5});
            elsif value_class == NumericValue_PositiveInfinity then
                return (TRUE, ReferenceScalarFPSignedInfinity(
                    source_type, FALSE), Zeros{5});
            elsif negative then
                return (TRUE, ReferenceScalarFPSpecialEncoding(
                    source_type, NumericValue_QuietNaN), Zeros{5} + 1);
            end;
        when FloatingUnary_ABS => return (
            FALSE, Zeros{PTO_XLEN}, Zeros{5});
    end;
    return (FALSE, Zeros{PTO_XLEN}, Zeros{5});
end;

func ReferenceScalarFPUnaryProfile(
    operation: FloatingUnaryOperation, rounding_mode: NumericRoundingMode,
    source_type: bits(5), value: Word) => (Word, bits(5))
begin
    let (special, special_result, special_flags) =
        ReferenceScalarFPUnarySpecial(operation, source_type, value);
    if special then return (special_result, special_flags); end;
    case operation of
        when FloatingUnary_ABS =>
            if source_type == '00001' then
                return (ZeroExtend{PTO_XLEN}(value[30:0]), Zeros{5});
            else return (
                value AND (Zeros{PTO_XLEN} + 0x7fffffffffffffff), Zeros{5});
            end;
        when FloatingUnary_SQRT, FloatingUnary_EXP =>
            if source_type == '00101' then
                return ReferenceBinary16Encoding(
                    FloatingUnary(operation,
                        ReferenceBinary16FiniteValue(
                            value, TileDataType_BF16)),
                    TileDataType_BF16,
                    NumericExecutionControl {
                        rounding_mode = rounding_mode,
                        saturating = FALSE
                    });
            end;
            return ReferenceScalarFPFiniteEncoding(
                FloatingUnary(operation,
                    ReferenceScalarFPFiniteValue(value, source_type)),
                source_type, rounding_mode);
        when FloatingUnary_RECIP =>
            if source_type == '00101' then
                return ReferenceBinary16Encoding(
                    FloatingUnary(operation,
                        ReferenceBinary16FiniteValue(
                            value, TileDataType_BF16)),
                    TileDataType_BF16,
                    NumericExecutionControl {
                        rounding_mode = rounding_mode,
                        saturating = FALSE
                    });
            end;
            return ReferenceScalarFPFiniteEncoding(
                FloatingUnary(operation,
                    ReferenceScalarFPFiniteValue(value, source_type)),
                source_type, rounding_mode);
    end;
end;

pure func ReferenceScalarFPFusedSpecial(
    operation: FloatingFusedOperation, source_type: bits(5), addend: Word,
    left: Word, right: Word) => (boolean, Word, bits(5))
begin
    let addend_class = ReferenceScalarFPClass(addend, source_type);
    let left_class = ReferenceScalarFPClass(left, source_type);
    let right_class = ReferenceScalarFPClass(right, source_type);
    let signaling_nan = addend_class == NumericValue_SignalingNaN ||
        left_class == NumericValue_SignalingNaN ||
        right_class == NumericValue_SignalingNaN;
    if NumericValueClassIsNaN(addend_class) ||
       NumericValueClassIsNaN(left_class) ||
       NumericValueClassIsNaN(right_class) then
        return (TRUE, ReferenceScalarFPSpecialEncoding(
            source_type, NumericValue_QuietNaN),
            if signaling_nan then Zeros{5} + 1 else Zeros{5});
    end;
    let left_infinity = NumericValueClassIsInfinity(left_class);
    let right_infinity = NumericValueClassIsInfinity(right_class);
    let left_zero = NumericValueClassIsZero(left_class);
    let right_zero = NumericValueClassIsZero(right_class);
    if (left_infinity && right_zero) ||
       (right_infinity && left_zero) then
        return (TRUE, ReferenceScalarFPSpecialEncoding(
            source_type, NumericValue_QuietNaN), Zeros{5} + 1);
    end;
    let product_infinity = left_infinity || right_infinity;
    let product_negative = ReferenceScalarFPClassIsNegative(left_class) !=
        ReferenceScalarFPClassIsNegative(right_class);
    let addend_infinity = NumericValueClassIsInfinity(addend_class);
    var effective_addend_negative =
        ReferenceScalarFPClassIsNegative(addend_class);
    if operation == FloatingFused_MSUB ||
       operation == FloatingFused_NMSUB then
        effective_addend_negative = !effective_addend_negative;
    end;
    let negate_result = operation == FloatingFused_NMADD ||
        operation == FloatingFused_NMSUB;
    if product_infinity && addend_infinity &&
       product_negative != effective_addend_negative then
        return (TRUE, ReferenceScalarFPSpecialEncoding(
            source_type, NumericValue_QuietNaN), Zeros{5} + 1);
    elsif product_infinity then
        return (TRUE, ReferenceScalarFPSignedInfinity(source_type,
            product_negative != negate_result), Zeros{5});
    elsif addend_infinity then
        return (TRUE, ReferenceScalarFPSignedInfinity(source_type,
            effective_addend_negative != negate_result), Zeros{5});
    end;
    return (FALSE, Zeros{PTO_XLEN}, Zeros{5});
end;

func ReferenceScalarFPFusedProfile(
    operation: FloatingFusedOperation, rounding_mode: NumericRoundingMode,
    source_type: bits(5), addend: Word, left: Word, right: Word)
    => (Word, bits(5))
begin
    let (special, special_result, special_flags) =
        ReferenceScalarFPFusedSpecial(
            operation, source_type, addend, left, right);
    if special then return (special_result, special_flags); end;
    return ReferenceScalarFPFusedFinite(
        operation, rounding_mode, source_type, addend, left, right);
end;
```
<!-- GENERATED-ASL-END: unit -->
