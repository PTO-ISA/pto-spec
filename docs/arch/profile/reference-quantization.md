<!-- GENERATED FROM: asl/arch/profile/reference-quantization.asl -->
# Reference Quantization

**Normative ASL source:** `asl/arch/profile/reference-quantization.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROFILE-REFERENCE-QUANTIZATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-reference-quant-purpose role=purpose-scope -->
## Purpose and scope

This unit supplies deterministic PTO v0 reference implementations for FP32 finite conversion, affine quantization to `S8` or `U8`, and dequantization back to `FP32`.

<!-- PTO-READER-BLOCK: arch-reference-quant-concepts role=concepts-state -->
## Value helpers

- `ReferencePowerOfTwo` constructs powers from exponent `-149` through `127`.
- `ReferenceFP32FiniteValue` decodes finite FP32 sign, exponent, and fraction into a real value.
- `ReferenceIntegerValue` normalizes a Tile integer and interprets it with the source type's signedness.
- `ReferenceFP32FiniteEncoding` performs the inverse finite encoding with status.

<!-- PTO-READER-BLOCK: arch-reference-quant-rules role=rules-interactions -->
## Quantize and dequantize

`TileProfileQuantize` accepts `FP32` input and `S8` or `U8` output. It checks that the FP32 scale is finite and nonzero, computes `source * scale + zero_point`, rounds under the selected mode, and optionally clamps to the destination range.

`TileProfileDequantize` accepts `S8` or `U8` input and `FP32` output. It computes `(source - zero_point) * scale` and returns the reference FP32 encoding.

<!-- PTO-READER-BLOCK: arch-reference-quant-boundaries role=boundaries -->
## Exceptional and profile boundaries

Quantizing NaN produces zero with `NV`; infinity selects the signed integer endpoint with overflow/inexact status. The scale may not be NaN, infinite, or zero. These are PTO v0 `implementation` functions, so other named profiles require their own reviewed definitions.

<!-- PTO-READER-BLOCK: arch-reference-quant-example role=example-usage -->
## Non-normative affine example

Use this example block only as a reading aid: apply the rules above, then confirm the result in the normative ASL owner. It does not add an architectural contract.

<!-- PTO-READER-BLOCK: arch-reference-quant-related role=related-owners-navigation -->
## Related owners

- Reference profile supplies common numeric policy such as rounding selection.
- Tile numeric formats classify encodings; matrix quantization reuses these reference helpers for broader formats.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/profile/reference-quantization.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-REFERENCE-QUANTIZATION","surface":"arch","classification":["profile","reference-quantization"],"depends_on":["PTO-SCALAR-MODEL-FSU-PROFILE","PTO-TILE-MODEL-NUMERIC-FORMATS"]}
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


implementation func TileProfileQuantize(value: Word, scale: Word,
                                         zero_point: Word,
                                         source_type: TileDataType,
                                         destination_type: TileDataType,
                                         control: NumericExecutionControl)
                                         => (Word, bits(5))
begin
    assert source_type == TileDataType_FP32;
    assert destination_type == TileDataType_S8 ||
           destination_type == TileDataType_U8;
    let source_class = TileNumericValueClass(source_type, value);
    let scale_class = TileNumericValueClass(TileDataType_FP32, scale);
    assert !NumericValueClassIsNaN(scale_class);
    assert !NumericValueClassIsInfinity(scale_class);
    assert !NumericValueClassIsZero(scale_class);
    let minimum = ReferenceIntegerValue(
        TileIntegerMinimum(destination_type), destination_type);
    let maximum = ReferenceIntegerValue(
        TileIntegerMaximum(destination_type), destination_type);
    if NumericValueClassIsNaN(source_class) then
        return (Zeros{PTO_XLEN}, Zeros{5} + 1);
    elsif NumericValueClassIsInfinity(source_class) then
        let saturated = if value[31] == '1' then minimum else maximum;
        return (
            NormalizeTileInteger(
                Zeros{PTO_XLEN} + saturated,
                destination_type),
            Zeros{5} + 0x14);
    end;
    let affine = ReferenceFP32FiniteValue(value[31:0]) *
        ReferenceFP32FiniteValue(scale[31:0]) +
        Real(ReferenceIntegerValue(zero_point, destination_type));
    let rounded = FloatingToInteger(affine, control.rounding_mode);
    var selected = rounded;
    let flags = if Real(rounded) == affine then Zeros{5}
        else Zeros{5} + 0x10;
    if control.saturating then
        if selected < minimum then selected = minimum;
        elsif selected > maximum then selected = maximum;
        end;
    end;
    return (
        NormalizeTileInteger(Zeros{PTO_XLEN} + selected, destination_type),
        flags);
end;

implementation func TileProfileDequantize(value: Word, scale: Word,
                                           zero_point: Word,
                                           source_type: TileDataType,
                                           destination_type: TileDataType,
                                           control: NumericExecutionControl)
                                           => (Word, bits(5))
begin
    assert source_type == TileDataType_S8 ||
           source_type == TileDataType_U8;
    assert destination_type == TileDataType_FP32;
    let scale_class = TileNumericValueClass(TileDataType_FP32, scale);
    assert !NumericValueClassIsNaN(scale_class);
    assert !NumericValueClassIsInfinity(scale_class);
    assert !NumericValueClassIsZero(scale_class);
    let source_value = ReferenceIntegerValue(value, source_type);
    let zero_value = ReferenceIntegerValue(zero_point, source_type);
    let dequantized = Real(source_value - zero_value) *
        ReferenceFP32FiniteValue(scale[31:0]);
    return ReferenceFP32FiniteEncoding(
        dequantized,
        control.rounding_mode);
end;
```
<!-- GENERATED-ASL-END: unit -->
