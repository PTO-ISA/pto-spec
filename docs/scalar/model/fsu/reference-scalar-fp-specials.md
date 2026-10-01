<!-- GENERATED FROM: asl/scalar/model/fsu/reference-scalar-fp-specials.asl -->
# Reference Scalar Fp Specials

**Normative ASL source:** `asl/scalar/model/fsu/reference-scalar-fp-specials.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-FSU-REFERENCE-SCALAR-FP-SPECIALS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-fsu-reference-scalar-fp-specials-purpose role=purpose-scope -->
## Purpose and scope

This unit handles the special values of the reference scalar floating-point profile: NaNs, infinities, and zeros. Each operation first asks a special-case function whether the inputs force a fixed result. Only when they do not does the operation compute a finite result: `ABS` clears a sign bit, and the other operations evaluate a real value and encode it through [reference quantization](reference-quantization.md) or, for BF16, `ReferenceBinary16Encoding`.

It defines the unary and fused special cases and profiles: `ReferenceScalarFPUnarySpecial`, `ReferenceScalarFPUnaryProfile`, `ReferenceScalarFPFusedSpecial`, and `ReferenceScalarFPFusedProfile`. The binary special cases live in reference quantization as `ReferenceScalarFPBinarySpecial`.

<!-- PTO-READER-BLOCK: scalar-model-fsu-reference-scalar-fp-specials-concepts role=concepts-state -->
## Concepts and visible state

Each special function returns three values: a handled flag, the result encoding, and a 5-bit flag vector. Flag value 1 is NV (invalid operation) and flag value 2 is DZ (division by zero).

Inputs are classified with `ReferenceScalarFPClass`, which returns classes such as quiet NaN, signaling NaN, positive infinity, negative zero, or negative normal.

A signaling NaN is a NaN whose encoding requests an invalid-operation signal when used. A quiet NaN does not.

Every NaN result is the canonical quiet NaN of the type, so input NaN payloads are not propagated.

<!-- PTO-READER-BLOCK: scalar-model-fsu-reference-scalar-fp-specials-rules role=rules-interactions -->
## Rules and interactions

Unary special cases:

| Operation | Input | Result | Flags |
| --- | --- | --- | --- |
| any | quiet NaN | quiet NaN | none |
| any | signaling NaN | quiet NaN | NV |
| `EXP` | +infinity or -infinity | +infinity or +0.0 | none |
| `RECIP` | a zero | infinity with the zero's sign | DZ |
| `RECIP` | an infinity | zero with the infinity's sign | none |
| `SQRT` | a zero | the same zero | none |
| `SQRT` | +infinity | +infinity | none |
| `SQRT` | any other negative value | quiet NaN | NV |

The NaN rows apply to `ABS` too. For any other `ABS` input the special function reports no special case, and `ReferenceScalarFPUnaryProfile` clears bit 31 for FP32 and bit 63 for every other type code. No current caller reaches this arm, because FSU dispatch handles `FABS` without calling the unary profile.

Design point: `SQRT(-0.0)` returns -0.0 without a flag, while `SQRT(-1.0)` returns NaN with NV. The zero check runs before the negative check, so a negative zero is not treated as a negative number.

Fused special cases run in this order: any NaN gives a quiet NaN, with NV if any input is signaling. An infinity times a zero gives NaN with NV. An infinite product plus an infinite addend of the opposite effective sign gives NaN with NV. Otherwise an infinite product or an infinite addend gives an infinity with the correct sign.

Design point: the effective addend sign flips for `MSUB` and `NMSUB`, and the final sign flips for `NMADD` and `NMSUB`. This makes the special results agree with the finite formula `-(product - addend)` for `NMSUB`.

<!-- PTO-READER-BLOCK: scalar-model-fsu-reference-scalar-fp-specials-boundaries role=boundaries -->
## Architectural boundaries

`ReferenceScalarFPFusedSpecial` returns no special result for a zero product with a finite addend. That case goes to the finite path. For FP32 and FP64 the finite encoder returns +0.0 whenever the exact result is zero, whatever the operand signs.

These functions are reached through `ScalarFPUnaryProfile` and `ScalarFPFusedProfile`. Those hooks assert the supported type codes: FP64, FP32, FP16, and BF16 for unary, and FP64, FP32, and FP16 for fused.

`FABS` in decoded dispatch clears the sign bit itself and does not call the unary profile.

<!-- PTO-READER-BLOCK: scalar-model-fsu-reference-scalar-fp-specials-example role=example-usage -->
## Non-normative reading example

`FNMSUB` on FP32 computes `-(left x right - addend)`. Take left = +infinity, right = 2.0, addend = +infinity.

- No input is a NaN, and no infinity is multiplied by zero.
- The product is +infinity, so the product is not negative.
- `NMSUB` flips the addend sign, so the effective addend is negative.
- The signs differ and both are infinite, so the result is the quiet NaN 0x7FC00000 with NV.

With addend = -infinity instead, the effective addend is positive, and the result is an infinity. Its sign is negative, because `NMSUB` negates the positive product, giving 0xFF800000.

<!-- PTO-READER-BLOCK: scalar-model-fsu-reference-scalar-fp-specials-related role=related-owners-navigation -->
## Related owners

- [Reference quantization](reference-quantization.md) owns the binary special cases, the special encodings, and the finite path.
- [Scalar FP](scalar-fp.md) defines the profile hooks that call these functions.
- [FSU arithmetic](arithmetic.md) owns the real-number operations used after this layer.
- [FSU dispatch](../dispatch/fsu.md) records the returned flags.
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
