<!-- GENERATED FROM: asl/arch/profile/reference-scalar-fp-specials.asl -->
# Reference Scalar Fp Specials

**Normative ASL source:** `asl/arch/profile/reference-scalar-fp-specials.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROFILE-REFERENCE-SCALAR-FP-SPECIALS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->

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
