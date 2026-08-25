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
// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-REFERENCE-QUANTIZATION","surface":"arch","classification":["profile","reference-quantization"],"depends_on":["PTO-ARCH-PROFILE-REFERENCE-PROFILE","PTO-TILE-MODEL-NUMERIC-FORMATS"]}
pure func ReferencePowerOfTwo(exponent: integer {-149..127}) => real
begin
    var result: real = 1.0;
    if exponent > 0 then
        for step = 1 to exponent looplimit 127 do
            result = result * 2.0;
        end;
    elsif exponent < 0 then
        for step = 1 to -exponent looplimit 149 do
            result = result / 2.0;
        end;
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
    for step = 1 to 128 looplimit 128 do
        if normalized >= 2.0 && exponent < 128 then
            normalized = normalized / 2.0;
            exponent = (exponent + 1) as integer {-149..128};
        end;
    end;
    for step = 1 to 149 looplimit 149 do
        if normalized < 1.0 && exponent > -149 then
            normalized = normalized * 2.0;
            exponent = (exponent - 1) as integer {-149..128};
        end;
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
