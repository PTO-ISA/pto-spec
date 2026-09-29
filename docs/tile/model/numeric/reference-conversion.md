<!-- GENERATED FROM: asl/tile/model/numeric/reference-conversion.asl -->
# Reference Conversion

**Normative ASL source:** `asl/tile/model/numeric/reference-conversion.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-NUMERIC-REFERENCE-CONVERSION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-numeric-reference-conversion-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the common conversion rule shared by scalar conversion and `TCVT`, plus three reference numeric helpers used by Tile execution units.

- `ReferenceCommonConvert` converts between types in the common set.
- `ReferenceTileFloatingModulo` computes floating remainder for `TREM`-style operations.
- `ReferenceTileUnaryFinite` computes EXP, LOG, RECIP, SQRT, and RSQRT for finite inputs.
- `ReferenceMatrixOrdinaryFloatingAccumulate` computes one multiply-accumulate step in FP32.

<!-- PTO-READER-BLOCK: tile-model-numeric-reference-conversion-concepts role=concepts-state -->
## Concepts and visible state

The common set is FP64, FP32, FP16, E4M3, S64, S32, S16, S8, U64, U32, U16, and U8 (`ReferenceCommonConversionTypeSupported`). BF16 is not in it. `ReferenceCommonConvert` asserts that both types are in the set.

Each helper returns a result word and a five-bit flag set: `0x01` NV, `0x02` DZ, `0x04` OF, `0x08` UF, `0x10` NX.

The helpers accept different floating types:

| Helper | Accepted floating types |
| --- | --- |
| `ReferenceCommonConvert` | FP64, FP32, FP16, E4M3 |
| `ReferenceTileFloatingModulo` | FP32, FP16, BF16 |
| `ReferenceTileUnaryFinite` | FP32, FP16, BF16 |
| `ReferenceMatrixOrdinaryFloatingAccumulate` inputs | FP32, TF32, HF32, FP16, BF16 |

<!-- PTO-READER-BLOCK: tile-model-numeric-reference-conversion-rules role=rules-interactions -->
## Rules and interactions

For a floating source, `ReferenceCommonConvertSpecial` handles special values first.

- NaN or invalid encoding: a floating destination gets its canonical NaN, with NV only for a signaling NaN or invalid encoding. An integer destination gets 0 with NV.
- Infinity: FP64, FP32, and FP16 destinations get infinity with no flag. E4M3 has no infinity, so it gets the finite endpoint `0x7e` or `0xfe` with OF and NX when saturating, and its canonical NaN with OF and NX otherwise. An integer destination gets its minimum or maximum with NV.
- Zero to a floating destination keeps its sign.

A finite value is then rounded once to the destination with `ReferenceMatrixFloatingEncoding` or `ReferenceMatrixIntegerEncoding`. An integer source converts exactly to a real first. Integer to integer uses `TileConvertIntegerValue` and produces no flag.

Design point: floating to integer overflow sets OF and NX. With saturation the result clamps; without it the rounded integer is truncated to the destination width, so it wraps. NDF `PTO-COMMON-CONVERSION-001` requires scalar conversion to pass saturation disabled and requires identical results and flags for equal inputs, so scalar code and `TCVT` agree bit for bit whenever they convert the same value between the same types under the same control, which for scalar code always has saturation disabled.

Floating modulo truncates the quotient toward zero, so the result has the dividend's sign. An infinite dividend or zero divisor gives canonical NaN with NV. An infinite divisor or zero dividend returns the dividend. The result is encoded with the default control, RNE and no saturation.

`ReferenceTileUnaryFinite` computes the real result, using a series approximation for EXP and LOG, and encodes it with RNE. `ReferenceMatrixOrdinaryFloatingAccumulate` rounds the product to FP32, then rounds the sum to FP32, under the supplied control, and discards both flag sets.

<!-- PTO-READER-BLOCK: tile-model-numeric-reference-conversion-boundaries role=boundaries -->
## Architectural boundaries

Callers include `TileProfileConvert` and `ReferenceTCVTConvert` for TCVT, the scalar FSU conversion model, the elementwise modulo profile, the unary profile `TileProfileUnary` for SFU operations whose callers found no special value, and the matrix-scale unit when the destination is FP32, both operand types are supported ordinary floating types, and the accumulator and both operands are finite.

This unit does not record flags. Each caller decides whether to record or discard them; for example, the elementwise modulo result helper discards them.

<!-- PTO-READER-BLOCK: tile-model-numeric-reference-conversion-example role=example-usage -->
## Non-normative reading example

Convert FP32 300.0 (`0x43960000`) to S8 with RNE.

- The rounded integer is 300, which is above 127, so flags are OF and NX (`0x14`).
- Without saturation, the low 8 bits of 300 give `0x2C` (44).
- With saturation, the result is `0x7F` (127).

Convert FP32 negative 2.5 (`0xC0200000`) to S8.

- RNE gives -2 (`0xFE`), because the tie goes to the even integer, with NX.
- RTZ also gives -2, with NX.

Convert FP32 positive infinity (`0x7F800000`) to S8: the result is `0x7F` with NV only.

<!-- PTO-READER-BLOCK: tile-model-numeric-reference-conversion-related role=related-owners-navigation -->
## Related owners

- [Formats](formats.md) owns the TCVT dispatch into this rule.
- [TCVT conversion](tcvt-conversion.md) owns the closed scale and packed formats.
- [Matrix quantization](../execution/matrix-quantization.md) owns the finite encoders.
- [Numeric classification](../../../arch/data-types/numeric-classification.md) owns value classes.
- [Scalar FP model](../../../scalar/model/fsu/scalar-fp.md) is the scalar user of the common rule.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/numeric/reference-conversion.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-NUMERIC-REFERENCE-CONVERSION","surface":"tile","classification":["model","numeric","reference-conversion"],"depends_on":["PTO-ARCH-FEATURES-MX-FORMATS","PTO-TILE-MODEL-EXECUTION-MATRIX-QUANTIZATION","PTO-SCALAR-MODEL-FSU-SCALAR-FP","PTO-TILE-MODEL-NUMERIC-FORMATS"]}

// NDF-BEGIN: PTO-COMMON-CONVERSION-001
// ndf: kind=executable level=L3 layer=architecture status=accepted
// Scalar conversion and TCVT MUST use this common result rule whenever both
// types are in the shared FP64/FP32/FP16/E4M3 or signed/unsigned 64/32/16/8
// set. Scalar conversion MUST supply saturation disabled. Exact, inexact,
// underflow, overflow, saturation, wrap, signed-zero, NaN, infinity, and flag
// results MUST be identical for equal source, destination, and control inputs.
// NDF-END: PTO-COMMON-CONVERSION-001

pure func ReferenceCommonConversionTypeSupported(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP64 ||
           data_type == TileDataType_FP32 ||
           data_type == TileDataType_FP16 ||
           data_type == TileDataType_E4M3 ||
           data_type == TileDataType_S64 ||
           data_type == TileDataType_S32 ||
           data_type == TileDataType_S16 ||
           data_type == TileDataType_S8 ||
           data_type == TileDataType_U64 ||
           data_type == TileDataType_U32 ||
           data_type == TileDataType_U16 ||
           data_type == TileDataType_U8;
end;

pure func ReferenceCommonFloatingFiniteValue(
    value: Word, data_type: TileDataType) => real
begin
    case data_type of
        when TileDataType_FP64 => return ReferenceFP64FiniteValue(value);
        when TileDataType_FP32 =>
            return ReferenceFP32FiniteValue(value[31:0]);
        when TileDataType_FP16, TileDataType_BF16 =>
            return ReferenceBinary16FiniteValue(value, data_type);
        when TileDataType_E4M3 =>
            return ReferenceFP8FiniteValue(data_type, value[7:0]);
        otherwise => unreachable;
    end;
end;

pure func ReferenceCommonFloatingEndpoint(
    data_type: TileDataType, negative: boolean) => Word
begin
    case data_type of
        when TileDataType_FP64 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xffefffffffffffff
                 else 0x7fefffffffffffff);
        when TileDataType_FP32 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xff7fffff else 0x7f7fffff);
        when TileDataType_FP16 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xfbff else 0x7bff);
        when TileDataType_E4M3 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xfe else 0x7e);
        otherwise => unreachable;
    end;
end;

pure func ReferenceCommonFloatingInfinity(
    data_type: TileDataType, negative: boolean) => (boolean, Word)
begin
    case data_type of
        when TileDataType_FP64 =>
            return (TRUE, Zeros{PTO_XLEN} +
                (if negative then 0xfff0000000000000
                 else 0x7ff0000000000000));
        when TileDataType_FP32 =>
            return (TRUE, Zeros{PTO_XLEN} +
                (if negative then 0xff800000 else 0x7f800000));
        when TileDataType_FP16 =>
            return (TRUE, Zeros{PTO_XLEN} +
                (if negative then 0xfc00 else 0x7c00));
        when TileDataType_E4M3 => return (FALSE, Zeros{PTO_XLEN});
        otherwise => unreachable;
    end;
end;

func ReferenceCommonConvertSpecial(
    value: Word,
    source_type: TileDataType,
    destination_type: TileDataType,
    control: NumericExecutionControl) => (boolean, Word, bits(5))
begin
    let value_class = TileNumericValueClass(source_type, value);
    if NumericValueClassIsNaN(value_class) ||
       value_class == NumericValue_InvalidEncoding then
        if TileDataTypeIsFloating(destination_type) then
            let (available, canonical) =
                TileNumericCanonicalNaN(destination_type);
            assert available;
            return (
                TRUE, canonical,
                if value_class == NumericValue_SignalingNaN ||
                   value_class == NumericValue_InvalidEncoding then
                    Zeros{5} + 1
                else Zeros{5});
        end;
        return (TRUE, Zeros{PTO_XLEN}, Zeros{5} + 1);
    elsif NumericValueClassIsInfinity(value_class) then
        let negative = value_class == NumericValue_NegativeInfinity;
        if TileDataTypeIsFloating(destination_type) then
            let (has_infinity, infinity) =
                ReferenceCommonFloatingInfinity(
                    destination_type, negative);
            if has_infinity then return (TRUE, infinity, Zeros{5}); end;
            if control.saturating then
                return (
                    TRUE,
                    ReferenceCommonFloatingEndpoint(
                        destination_type, negative),
                    Zeros{5} + 0x14);
            end;
            let (available, canonical) =
                TileNumericCanonicalNaN(destination_type);
            assert available;
            return (TRUE, canonical, Zeros{5} + 0x14);
        end;
        let endpoint = if negative then
            TileIntegerMinimum(destination_type)
            else TileIntegerMaximum(destination_type);
        return (TRUE, endpoint, Zeros{5} + 1);
    elsif NumericValueClassIsZero(value_class) &&
          TileDataTypeIsFloating(destination_type) then
        let (available, positive_zero, negative_zero) =
            HardwareNumericSignedZeroEncodings(destination_type);
        assert available;
        return (
            TRUE,
            if value_class == NumericValue_NegativeZero then negative_zero
            else positive_zero,
            Zeros{5});
    end;
    return (FALSE, Zeros{PTO_XLEN}, Zeros{5});
end;

func ReferenceCommonConvert(
    value: Word,
    source_type: TileDataType,
    destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    assert ReferenceCommonConversionTypeSupported(source_type);
    assert ReferenceCommonConversionTypeSupported(destination_type);

    if TileDataTypeIsFloating(source_type) then
        let (handled, special, special_flags) =
            ReferenceCommonConvertSpecial(
                value, source_type, destination_type, control);
        if handled then return (special, special_flags); end;

        let finite = ReferenceCommonFloatingFiniteValue(
            value, source_type);
        if TileDataTypeIsFloating(destination_type) then
            return ReferenceMatrixFloatingEncoding(
                finite, destination_type, control);
        end;
        return ReferenceMatrixIntegerEncoding(
            finite, destination_type, control);
    end;

    if TileDataTypeIsFloating(destination_type) then
        return ReferenceMatrixFloatingEncoding(
            Real(ReferenceIntegerValue(value, source_type)),
            destination_type, control);
    end;
    return (
        TileConvertIntegerValue(
            value, source_type, destination_type, control.saturating),
        Zeros{5});
end;

pure func ReferenceMatrixOrdinaryFloatingInputSupported(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP32 ||
           data_type == TileDataType_TF32 ||
           data_type == TileDataType_HF32 ||
           data_type == TileDataType_FP16 ||
           data_type == TileDataType_BF16;
end;

pure func ReferenceMatrixOrdinaryFloatingValue(
    value: Word, data_type: TileDataType) => real
begin
    assert ReferenceMatrixOrdinaryFloatingInputSupported(data_type);
    if data_type == TileDataType_FP16 ||
       data_type == TileDataType_BF16 then
        return ReferenceBinary16FiniteValue(value, data_type);
    end;
    return ReferenceFP32FiniteValue(value[31:0]);
end;

pure func ReferenceMatrixOrdinaryFloatingCarrierFinite(
    value: Word, data_type: TileDataType) => boolean
begin
    if !ReferenceMatrixOrdinaryFloatingInputSupported(data_type) then
        return FALSE;
    end;
    let value_class = TileNumericValueClass(data_type, value);
    return value_class == NumericValue_PositiveZero ||
           value_class == NumericValue_NegativeZero ||
           value_class == NumericValue_PositiveSubnormal ||
           value_class == NumericValue_NegativeSubnormal ||
           value_class == NumericValue_PositiveNormal ||
           value_class == NumericValue_NegativeNormal;
end;

func ReferenceMatrixOrdinaryFloatingAccumulate(
    accumulator: Word, left: Word, right: Word,
    left_type: TileDataType, right_type: TileDataType,
    control: NumericExecutionControl) => Word
begin
    let left_value = ReferenceMatrixOrdinaryFloatingValue(left, left_type);
    let right_value = ReferenceMatrixOrdinaryFloatingValue(right, right_type);
    let (product, -) = ReferenceMatrixFloatingEncoding(
        left_value * right_value, TileDataType_FP32, control);
    let accumulator_value = ReferenceFP32FiniteValue(accumulator[31:0]);
    let product_value = ReferenceFP32FiniteValue(product[31:0]);
    let (result, -) = ReferenceMatrixFloatingEncoding(
        accumulator_value + product_value, TileDataType_FP32, control);
    return result;
end;

func ReferenceTileFloatingModulo(
    data_type: TileDataType, left: Word, right: Word) => (Word, bits(5))
begin
    assert data_type == TileDataType_FP32 ||
           data_type == TileDataType_FP16 ||
           data_type == TileDataType_BF16;
    let left_class = TileNumericValueClass(data_type, left);
    let right_class = TileNumericValueClass(data_type, right);
    let signaling_nan = left_class == NumericValue_SignalingNaN ||
        right_class == NumericValue_SignalingNaN;
    let invalid = NumericValueClassIsInfinity(left_class) ||
        NumericValueClassIsZero(right_class);
    if NumericValueClassIsNaN(left_class) ||
       NumericValueClassIsNaN(right_class) || invalid then
        let (available, quiet_nan) = TileNumericCanonicalNaN(data_type);
        assert available;
        return (
            quiet_nan,
            if signaling_nan || invalid then Zeros{5} + 1 else Zeros{5});
    elsif NumericValueClassIsInfinity(right_class) ||
          NumericValueClassIsZero(left_class) then
        return (left, Zeros{5});
    end;
    let left_value = ReferenceCommonFloatingFiniteValue(left, data_type);
    let right_value = ReferenceCommonFloatingFiniteValue(right, data_type);
    let quotient = FloatingToInteger(
        left_value / right_value, NumericRound_RTZ);
    return ReferenceMatrixFloatingEncoding(
        left_value - Real(quotient) * right_value,
        data_type,
        DefaultNumericExecutionControl());
end;

pure func ReferenceTileExponentialFinite(value: real) => real
begin
    var reduced = value;
    for reduction = 0 to 5 do
        reduced = reduced / 2.0;
    end;
    var result: real = 1.0;
    var term: real = 1.0;
    for index = 1 to 24 do
        term = (term * reduced) / Real(index);
        result = result + term;
    end;
    for expansion = 0 to 5 do
        result = result * result;
    end;
    return result;
end;

pure func ReferenceTileLogarithmFinite(value: real) => real
begin
    assert value > 0.0;
    var normalized = value;
    var exponent: integer {-149..127} = 0;
    while normalized >= 2.0 && exponent < 127 looplimit 127 do
        normalized = normalized / 2.0;
        exponent = (exponent + 1) as integer {-149..127};
    end;
    while normalized < 1.0 && exponent > -149 looplimit 149 do
        normalized = normalized * 2.0;
        exponent = (exponent - 1) as integer {-149..127};
    end;
    let ratio = (normalized - 1.0) / (normalized + 1.0);
    let ratio_squared = ratio * ratio;
    var power = ratio;
    var series: real = 0.0;
    for index = 0 to 31 do
        series = series + power / Real(2 * index + 1);
        power = power * ratio_squared;
    end;
    return 2.0 * series + Real(exponent) *
        0.693147180559945309417232121458176568;
end;

func ReferenceTileUnaryFinite(
    operation: TileUnaryOperation,
    data_type: TileDataType,
    value: Word) => (Word, bits(5))
begin
    assert data_type == TileDataType_FP32 ||
           data_type == TileDataType_FP16 ||
           data_type == TileDataType_BF16;
    let input = ReferenceCommonFloatingFiniteValue(value, data_type);
    var result: real = input;
    case operation of
        when TileUnary_EXP => result = ReferenceTileExponentialFinite(input);
        when TileUnary_LOG => result = ReferenceTileLogarithmFinite(input);
        when TileUnary_RECIP => result = 1.0 / input;
        when TileUnary_SQRT => result = SqrtRounded(input, 100);
        when TileUnary_RSQRT => result = 1.0 / SqrtRounded(input, 100);
        otherwise => unreachable;
    end;
    return ReferenceMatrixFloatingEncoding(
        result, data_type, DefaultNumericExecutionControl());
end;
```
<!-- GENERATED-ASL-END: unit -->
