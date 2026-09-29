<!-- GENERATED FROM: asl/scalar/model/fsu/reference-scalar-fp-specials.asl -->
# Reference Scalar Fp Specials

**Normative ASL source:** `asl/scalar/model/fsu/reference-scalar-fp-specials.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-FSU-REFERENCE-SCALAR-FP-SPECIALS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-fsu-reference-scalar-fp-specials-purpose role=purpose-scope -->
## 用途与范围

本单元处理参考标量浮点配置档中的特殊值：NaN、无穷大和零。每个运算先询问特殊情形函数，输入是否强制产生固定结果。只有在不强制时，运算才计算有限值结果：`ABS` 清除符号位，其他运算求出实数值，并通过[参考量化](reference-quantization.md)编码，BF16 则通过 `ReferenceBinary16Encoding` 编码。

它定义一元与融合运算的特殊情形和配置档：`ReferenceScalarFPUnarySpecial`、`ReferenceScalarFPUnaryProfile`、`ReferenceScalarFPFusedSpecial` 和 `ReferenceScalarFPFusedProfile`。二元特殊情形以 `ReferenceScalarFPBinarySpecial` 的形式位于参考量化中。

<!-- PTO-READER-BLOCK: scalar-model-fsu-reference-scalar-fp-specials-concepts role=concepts-state -->
## 概念与可见状态

每个特殊函数返回三个值：是否已处理的标志、结果编码和 5 位标志向量。标志值 1 为 NV（无效运算），标志值 2 为 DZ（除以零）。

输入由 `ReferenceScalarFPClass` 分类，它返回安静 NaN、信号 NaN、正无穷大、负零或负正规数等类别。

信号 NaN 是其编码要求在使用时发出无效运算信号的 NaN。安静 NaN 则不要求。

每个 NaN 结果都是该类型的规范安静 NaN，因此不传播输入 NaN 的载荷。

<!-- PTO-READER-BLOCK: scalar-model-fsu-reference-scalar-fp-specials-rules role=rules-interactions -->
## 规则与交互

一元特殊情形：

| 运算 | 输入 | 结果 | 标志 |
| --- | --- | --- | --- |
| 任意 | 安静 NaN | 安静 NaN | 无 |
| 任意 | 信号 NaN | 安静 NaN | NV |
| `EXP` | +无穷大或 -无穷大 | +无穷大或 +0.0 | 无 |
| `RECIP` | 零 | 与该零同号的无穷大 | DZ |
| `RECIP` | 无穷大 | 与该无穷大同号的零 | 无 |
| `SQRT` | 零 | 同一个零 | 无 |
| `SQRT` | +无穷大 | +无穷大 | 无 |
| `SQRT` | 其他任何负值 | 安静 NaN | NV |

NaN 行同样适用于 `ABS`。对于其他任何 `ABS` 输入，特殊函数报告没有特殊情形，`ReferenceScalarFPUnaryProfile` 对 FP32 清除位 31，对其他所有类型码清除位 63。当前没有调用者到达该分支，因为 FSU 分派处理 `FABS` 时不调用一元配置档。

设计要点：`SQRT(-0.0)` 返回 -0.0 且不带标志，而 `SQRT(-1.0)` 返回 NaN 并带 NV。零检查先于负数检查，因此负零不被当作负数。

融合特殊情形按以下顺序判断：任一 NaN 给出安静 NaN，若任一输入为信号 NaN 则带 NV。无穷大乘以零给出带 NV 的 NaN。无穷乘积加上有效符号相反的无穷加数给出带 NV 的 NaN。否则，无穷乘积或无穷加数给出符号正确的无穷大。

设计要点：对于 `MSUB` 和 `NMSUB`，有效加数符号翻转；对于 `NMADD` 和 `NMSUB`，最终符号翻转。这使特殊结果与 `NMSUB` 的有限值公式 `-(product - addend)` 一致。

<!-- PTO-READER-BLOCK: scalar-model-fsu-reference-scalar-fp-specials-boundaries role=boundaries -->
## 架构边界

对于零乘积加有限加数，`ReferenceScalarFPFusedSpecial` 不返回特殊结果。该情形进入有限值路径。对于 FP32 和 FP64，只要精确结果为零，有限值编码器就返回 +0.0，而不管操作数的符号。

这些函数经由 `ScalarFPUnaryProfile` 和 `ScalarFPFusedProfile` 到达。这些钩子断言所支持的类型码：一元为 FP64、FP32、FP16 和 BF16，融合为 FP64、FP32 和 FP16。

已译码分派中的 `FABS` 自行清除符号位，不调用一元配置档。

<!-- PTO-READER-BLOCK: scalar-model-fsu-reference-scalar-fp-specials-example role=example-usage -->
## 非规范阅读示例

FP32 上的 `FNMSUB` 计算 `-(left x right - addend)`。取 left = +无穷大，right = 2.0，addend = +无穷大。

- 没有输入是 NaN，也没有无穷大乘以零。
- 乘积为 +无穷大，因此乘积不为负。
- `NMSUB` 翻转加数符号，因此有效加数为负。
- 两者符号不同且都是无穷大，因此结果为安静 NaN 0x7FC00000，并带 NV。

若改为 addend = -无穷大，有效加数为正，结果为无穷大。由于 `NMSUB` 对正乘积取负，其符号为负，得到 0xFF800000。

<!-- PTO-READER-BLOCK: scalar-model-fsu-reference-scalar-fp-specials-related role=related-owners-navigation -->
## 相关所有者

- [参考量化](reference-quantization.md)拥有二元特殊情形、特殊编码和有限值路径。
- [标量 FP](scalar-fp.md)定义调用这些函数的配置档钩子。
- [FSU 算术](arithmetic.md)拥有本层之后使用的实数运算。
- [FSU 分派](../dispatch/fsu.md)记录返回的标志。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/fsu/reference-scalar-fp-specials.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-FSU-REFERENCE-SCALAR-FP-SPECIALS","surface":"scalar","classification":["model","fsu","reference-scalar-fp-specials"],"depends_on":["PTO-TILE-MODEL-EXECUTION-MATRIX-QUANTIZATION","PTO-SCALAR-MODEL-FSU-REFERENCE-QUANTIZATION"]}
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
