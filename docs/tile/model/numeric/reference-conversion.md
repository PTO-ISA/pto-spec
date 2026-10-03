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

The common Tile conversion set is FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, and U8 (`ReferenceCommonConversionTypeSupported`). Scalar conversion continues to use its established subset. `ReferenceCommonConvert` asserts that both selected types are in the applicable set.

Each helper returns a result word and a five-bit flag set: `0x01` NV, `0x02` DZ, `0x04` OF, `0x08` UF, `0x10` NX.

The helpers accept different floating types:

| Helper | Accepted floating types |
| --- | --- |
| `ReferenceCommonConvert` | FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2 |
| `ReferenceTileFloatingModulo` | FP64, FP32, FP16, BF16 |
| `ReferenceTileUnaryFinite` | FP64, FP32, FP16, BF16 |
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

`ReferenceTileUnaryFinite` includes the applicable FP64 SFU path. FP64 exponential uses a wider range reduction, logarithm accepts the FP64 exponent range, and square root and reciprocal square root use the FP64 finite helper. Floating modulo likewise admits FP64. Reduced `TF32`, `HF32`, and `E5M2` finite destination encoding is delegated to the fixed-binary owner.

<!-- PTO-READER-BLOCK: tile-model-numeric-reference-conversion-boundaries role=boundaries -->
## Architectural boundaries

Callers include `TileProfileConvert` and `ReferenceTCVTConvert` for the broader Tile conversion set, the scalar FSU conversion model for its unchanged subset, elementwise FP64-capable modulo, and the unary SFU profile. The new Tile support does not add scalar opcodes or expand scalar conversion pairs.

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
// PTO-UNIT: {"id":"PTO-TILE-MODEL-NUMERIC-REFERENCE-CONVERSION","surface":"tile","classification":["model","numeric","reference-conversion"],"depends_on":["PTO-ARCH-FEATURES-MX-FORMATS","PTO-TILE-MODEL-NUMERIC-REFERENCE-FIXED-BINARY","PTO-SCALAR-MODEL-FSU-SCALAR-FP","PTO-TILE-MODEL-NUMERIC-FORMATS"]}

// NDF-BEGIN: PTO-COMMON-CONVERSION-001
// ndf: kind=executable level=L3 layer=architecture status=accepted
// TCVT MUST use this common result rule for FP64, FP32, TF32, HF32, FP16,
// BF16, E4M3, E5M2, and signed/unsigned 64/32/16/8 conversions. Scalar
// conversion MUST use it for its FP64/FP32/FP16/E4M3 and integer subset and
// MUST supply saturation disabled. Exact, inexact, underflow, overflow,
// saturation, wrap, signed-zero, NaN, infinity, and flag results MUST be
// identical for equal source, destination, and control inputs.
// NDF-END: PTO-COMMON-CONVERSION-001

pure func ReferenceCommonConversionTypeSupported(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP64 ||
           data_type == TileDataType_FP32 ||
           data_type == TileDataType_TF32 ||
           data_type == TileDataType_HF32 ||
           data_type == TileDataType_FP16 ||
           data_type == TileDataType_BF16 ||
           data_type == TileDataType_E4M3 ||
           data_type == TileDataType_E5M2 ||
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
        when TileDataType_FP32, TileDataType_TF32, TileDataType_HF32 =>
            return ReferenceFP32FiniteValue(value[31:0]);
        when TileDataType_FP16, TileDataType_BF16 =>
            return ReferenceBinary16FiniteValue(value, data_type);
        when TileDataType_E4M3 =>
            return ReferenceFP8FiniteValue(data_type, value[7:0]);
        when TileDataType_E5M2 =>
            let (available, negative, significand, exponent) =
                TileNumericFiniteDecomposition(data_type, value);
            assert available;
            let magnitude = Real(UInt(significand)) *
                ReferencePowerOfTwo(exponent);
            return if negative then -magnitude else magnitude;
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
        when TileDataType_FP32, TileDataType_TF32, TileDataType_HF32 =>
            return (TRUE, Zeros{PTO_XLEN} +
                (if negative then 0xff800000 else 0x7f800000));
        when TileDataType_FP16 =>
            return (TRUE, Zeros{PTO_XLEN} +
                (if negative then 0xfc00 else 0x7c00));
        when TileDataType_BF16 =>
            return (TRUE, Zeros{PTO_XLEN} +
                (if negative then 0xff80 else 0x7f80));
        when TileDataType_E5M2 =>
            return (TRUE, Zeros{PTO_XLEN} +
                (if negative then 0xfc else 0x7c));
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
            if destination_type == TileDataType_TF32 ||
               destination_type == TileDataType_HF32 ||
               destination_type == TileDataType_E5M2 then
                return ReferenceCommonReducedFloatingEncoding(
                    finite, destination_type, control);
            end;
            return ReferenceMatrixFloatingEncoding(
                finite, destination_type, control);
        end;
        return ReferenceMatrixIntegerEncoding(
            finite, destination_type, control);
    end;

    if TileDataTypeIsFloating(destination_type) then
        if destination_type == TileDataType_TF32 ||
           destination_type == TileDataType_HF32 ||
           destination_type == TileDataType_E5M2 then
            return ReferenceCommonReducedFloatingEncoding(
                Real(ReferenceIntegerValue(value, source_type)),
                destination_type, control);
        end;
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
    assert data_type == TileDataType_FP64 ||
           data_type == TileDataType_FP32 ||
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

pure func ReferenceTileLogarithmFinite(
    value: real, data_type: TileDataType) => real
begin
    assert value > 0.0;
    assert data_type == TileDataType_FP64 ||
           data_type == TileDataType_FP32 ||
           data_type == TileDataType_FP16 ||
           data_type == TileDataType_BF16;
    var normalized = value;
    var exponent: integer {-1074..1023} = 0;
    let maximum_exponent = if data_type == TileDataType_FP64
        then 1023 else 127;
    let minimum_exponent = if data_type == TileDataType_FP64
        then -1074 else -149;
    while normalized >= 2.0 &&
          exponent < maximum_exponent looplimit 1023 do
        normalized = normalized / 2.0;
        exponent = (exponent + 1) as integer {-1074..1023};
    end;
    while normalized < 1.0 &&
          exponent > minimum_exponent looplimit 1074 do
        normalized = normalized * 2.0;
        exponent = (exponent - 1) as integer {-1074..1023};
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

func ReferenceTileFP64ExponentialFinite(value: real) => real
begin
    let logarithm_two =
        0.693147180559945309417232121458176568;
    let rounded_exponent = FloatingToInteger(
        value / logarithm_two, NumericRound_RNE);
    assert rounded_exponent >= -1076 && rounded_exponent <= 1024;
    let exponent = rounded_exponent as integer {-1076..1024};
    let reduced = value - Real(exponent) * logarithm_two;
    var result: real = 1.0;
    var term: real = 1.0;
    for index = 1 to 24 do
        term = (term * reduced) / Real(index);
        result = result + term;
    end;
    if exponent == -1076 then
        return result * ReferencePowerOfTwo(-1074) * 0.25;
    elsif exponent == -1075 then
        return result * ReferencePowerOfTwo(-1074) * 0.5;
    elsif exponent == 1024 then
        return result * ReferencePowerOfTwo(1023) * 2.0;
    end;
    return result * ReferencePowerOfTwo(
        exponent as integer {-1074..1023});
end;

func ReferenceTileFP64SquareRootFinite(value: real) => real
begin
    assert value > 0.0;
    var normalized = value;
    var scale: integer {-537..512} = 0;
    while normalized >= 4.0 && scale < 512 looplimit 512 do
        normalized = normalized / 4.0;
        scale = (scale + 1) as integer {-537..512};
    end;
    while normalized < 1.0 && scale > -537 looplimit 537 do
        normalized = normalized * 4.0;
        scale = (scale - 1) as integer {-537..512};
    end;
    return SqrtRounded(normalized, 100) *
        ReferencePowerOfTwo(scale as integer {-1074..1023});
end;

func ReferenceTileUnaryFinite(
    operation: TileUnaryOperation,
    data_type: TileDataType,
    value: Word) => (Word, bits(5))
begin
    assert data_type == TileDataType_FP64 ||
           data_type == TileDataType_FP32 ||
           data_type == TileDataType_FP16 ||
           data_type == TileDataType_BF16;
    let input = ReferenceCommonFloatingFiniteValue(value, data_type);
    var result: real = input;
    case operation of
        when TileUnary_EXP =>
            if data_type == TileDataType_FP64 then
                if input > 710.0 then
                    return (
                        Zeros{PTO_XLEN} + 0x7ff0000000000000,
                        Zeros{5} + 0x14);
                elsif input < -746.0 then
                    return (Zeros{PTO_XLEN}, Zeros{5} + 0x18);
                end;
                result = ReferenceTileFP64ExponentialFinite(input);
            else
                result = ReferenceTileExponentialFinite(input);
            end;
        when TileUnary_LOG =>
            result = ReferenceTileLogarithmFinite(input, data_type);
        when TileUnary_RECIP => result = 1.0 / input;
        when TileUnary_SQRT =>
            if data_type == TileDataType_FP64 then
                result = ReferenceTileFP64SquareRootFinite(input);
            else
                result = SqrtRounded(input, 100);
            end;
        when TileUnary_RSQRT =>
            if data_type == TileDataType_FP64 then
                result = 1.0 / ReferenceTileFP64SquareRootFinite(input);
            else
                result = 1.0 / SqrtRounded(input, 100);
            end;
        otherwise => unreachable;
    end;
    return ReferenceMatrixFloatingEncoding(
        result, data_type, DefaultNumericExecutionControl());
end;
```
<!-- GENERATED-ASL-END: unit -->
