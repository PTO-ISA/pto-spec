<!-- GENERATED FROM: asl/scalar/model/fsu/reference-quantization.asl -->
# Reference Quantization

**Normative ASL source:** `asl/scalar/model/fsu/reference-quantization.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-FSU-REFERENCE-QUANTIZATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-fsu-reference-quantization-purpose role=purpose-scope -->
## Purpose and scope

This unit is the finite part of the reference numeric profile. It converts FP32 and FP64 encodings to exact real values, and rounds real values back into FP32, FP64, or FP16 encodings with a flag vector. It also classifies scalar carriers, builds the special encodings (NaN, infinity, signed zero), and defines `ReferenceScalarFPBinarySpecial`, the NaN, infinity, and zero cases for ADD, SUB, MUL, and DIV.

The scalar profile hooks in [scalar FP](scalar-fp.md) and the special-value unit call it. Some tile units reuse its FP32 and FP64 helpers, for example matrix quantization and reference conversion.

<!-- PTO-READER-BLOCK: scalar-model-fsu-reference-quantization-concepts role=concepts-state -->
## Concepts and visible state

A finite value is a number that is not a NaN or an infinity. `ReferenceFP32FiniteValue` and `ReferenceFP64FiniteValue` decode normal and subnormal encodings exactly and assert that the exponent field is not all ones.

A finite encoder takes an exact real result and a rounding mode, and returns an encoding and a 5-bit flag vector. The flag bits, from bit 0 upward, are NV, DZ, OF, UF, and NX. The FP32 and FP64 finite encoders produce three nonzero combinations:

| Flags | Bits | Meaning |
| --- | --- | --- |
| 0x10 | NX | the normal result was rounded |
| 0x14 | OF and NX | the result overflowed to infinity |
| 0x18 | UF and NX | a value below the normal range was rounded (the result may be zero or the smallest normal) |

The type codes used here are 0 for FP64, 1 for FP32, 4 for FP16, and 5 for BF16. `ReferenceScalarFPDataType` maps them to tile data types.

<!-- PTO-READER-BLOCK: scalar-model-fsu-reference-quantization-rules role=rules-interactions -->
## Rules and interactions

`ReferenceFP32FiniteEncoding` works in four cases:

1. An exact zero returns +0.0 with no flags.
2. The value is normalized to a significand in [1, 2) and an exponent. An exponent above 127 returns a signed infinity with 0x14.
3. An exponent below -126 is scaled by 2^149 and rounded to an integer subnormal significand. The result keeps its sign. A rounded result reports 0x18, including one that rounds to zero; an exact subnormal reports nothing.
4. Otherwise the significand is scaled by 2^23 and rounded. A carry to 2^24 bumps the exponent, which can then overflow to infinity with 0x14. A rounded result reports 0x10.

`ReferenceFP64FiniteEncoding` follows the same steps with FP64 limits. FP16 results go to `ReferenceBinary16Encoding`, owned by tile matrix quantization.

Design point: the FP32 and FP64 encoders receive one real value and round it once, through `FloatingToInteger`. For fused operations that value is the exact real `product + addend` from `FloatingFused`, so the product is not rounded separately.

Design point: overflow returns infinity in every rounding mode, because step 2 and the carry check do not look at the mode. A directed mode does not produce the largest finite value on overflow.

`ReferenceScalarFPSpecialEncoding` builds a canonical quiet NaN, a signed infinity, or a signed zero for type codes 0, 1, 4, and 5. The NaN comes from `TileNumericCanonicalNaN`, for example 0x7FC00000 for FP32.

<!-- PTO-READER-BLOCK: scalar-model-fsu-reference-quantization-boundaries role=boundaries -->
## Architectural boundaries

`ReferenceScalarFPFiniteValue` accepts only type codes 0, 1, and 4; `ReferenceScalarFPFiniteEncoding` asserts the same set. BF16 finite values use `ReferenceBinary16FiniteValue` directly from the profile hooks.

Callers must remove NaN and infinity inputs before calling the finite functions. For scalar arithmetic, `ReferenceScalarFPBinarySpecial` in this unit and the unary and fused special functions in the special-value unit do this.

The ASL comment above `ReferenceScalarFPDataType` states that scalar FP operations follow IEEE 754-2008 and that non-finite and signed-zero handling is kept outside the finite kernel, so an overflowed infinity stays a legal input to the next instruction.

`ReferenceFP16FiniteEncoding` has no caller in the ASL tree; the scalar FP16 path uses `ReferenceBinary16Encoding` instead.

<!-- PTO-READER-BLOCK: scalar-model-fsu-reference-quantization-example role=example-usage -->
## Non-normative reading example

Encode the exact value 1/3 as FP32 with RNE.

- Normalizing gives significand 4/3 and exponent -2.
- The scaled significand is 4/3 x 2^23 = 11184810.67.
- RNE rounds it to 11184811, which is 0xAAAAAB.
- The encoded exponent is -2 + 127 = 125, and the fraction is 0xAAAAAB - 0x800000.
- The result is 0x3EAAAAAB with flags 0x10, because the rounding was inexact.

With RTZ the significand would be 11184810, giving 0x3EAAAAAA with flags 0x10.

<!-- PTO-READER-BLOCK: scalar-model-fsu-reference-quantization-related role=related-owners-navigation -->
## Related owners

- [Scalar FP](scalar-fp.md) calls this unit through the profile hooks.
- [Reference special values](reference-scalar-fp-specials.md) handles NaN, infinity, and zero before the finite path.
- [FSU arithmetic](arithmetic.md) owns `FloatingToInteger` and the rounding modes.
- [Matrix quantization](../../../tile/model/execution/matrix-quantization.md) owns `ReferenceBinary16Encoding`.
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
