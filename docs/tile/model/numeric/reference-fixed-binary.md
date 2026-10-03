<!-- GENERATED FROM: asl/tile/model/numeric/reference-fixed-binary.asl -->
# Reference Fixed Binary

**Normative ASL source:** `asl/tile/model/numeric/reference-fixed-binary.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-NUMERIC-REFERENCE-FIXED-BINARY}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-numeric-reference-fixed-binary-purpose role=purpose-scope -->
## Purpose and scope

This unit supplies deterministic finite encoders shared by the Tile reference-conversion path. It owns the finite endpoints for the ordinary and reduced floating formats and the exact rounding construction for `TF32`, `HF32`, and `E5M2` destinations.

<!-- PTO-READER-BLOCK: tile-model-numeric-reference-fixed-binary-concepts role=concepts-state -->
## Concepts and visible state

`ReferenceCommonFloatingEndpoint` returns the largest finite encoding, with the requested sign, for `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, and `E5M2`. `ReferenceCommonReducedFloatingEncoding` accepts a real finite input, a reduced destination type, and the resolved rounding and saturation control, and returns one encoded `Word` plus five numeric-status bits.

The reduced formats share an exponent-normalization algorithm but keep their own fraction scale, bias, normal and subnormal limits, low-zero-bit rule, infinity encoding, and finite endpoint.

<!-- PTO-READER-BLOCK: tile-model-numeric-reference-fixed-binary-rules role=rules-interactions -->
## Rules and interactions

Zero encodes exactly as positive zero. Other finite inputs are normalized to a value in `[1,2)` with an integer exponent, then rounded once under the selected mode. Subnormal results are scaled to the format's minimum exponent before rounding.

Overflow returns the signed finite endpoint when saturation is enabled and the signed infinity encoding otherwise; both report OF and NX. Inexact normal results report NX. An inexact subnormal reports UF and NX unless rounding promotes it to the minimum normal value, in which case it reports NX.

`TF32` preserves 10 fraction bits and clears 13 low carrier bits. `HF32` preserves 11 fraction bits and clears 12. `E5M2` uses its two fraction bits and eight-bit encoding directly.

<!-- PTO-READER-BLOCK: tile-model-numeric-reference-fixed-binary-boundaries role=boundaries -->
## Architectural boundaries

This unit encodes finite values only. NaN, infinity, signed zero propagation, source classification, integer conversion, and the decision to record status remain in the reference-conversion caller.

The broader TCVT type set does not add scalar opcodes or change scalar conversion's accepted pairs. Scalar conversion continues to use only its established subset with saturation disabled.

<!-- PTO-READER-BLOCK: tile-model-numeric-reference-fixed-binary-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative rule.

For an `E5M2` destination, a positive finite input above the representable exponent range returns `0x7B` when saturation is enabled and `0x7C` otherwise. Both paths return status `0x14` (OF and NX). A representable result that lies between two E5M2 values follows the selected rounding mode and reports NX.

<!-- PTO-READER-BLOCK: tile-model-numeric-reference-fixed-binary-related role=related-owners-navigation -->
## Related owners

- [Reference conversion](reference-conversion.md) classifies inputs and routes finite reduced-format results here.
- [Numeric formats](formats.md) supplies format classification and decomposition.
- [Matrix quantization](../execution/matrix-quantization.md) supplies the common rounding primitive.
- [TCVT conversion](tcvt-conversion.md) owns closed scale and packed conversion families.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/numeric/reference-fixed-binary.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-NUMERIC-REFERENCE-FIXED-BINARY","surface":"tile","classification":["model","numeric","reference-fixed-binary"],"depends_on":["PTO-TILE-MODEL-EXECUTION-MATRIX-QUANTIZATION","PTO-TILE-MODEL-NUMERIC-FORMATS"]}

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
        when TileDataType_TF32 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xff7fe000 else 0x7f7fe000);
        when TileDataType_HF32 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xff7ff000 else 0x7f7ff000);
        when TileDataType_FP16 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xfbff else 0x7bff);
        when TileDataType_BF16 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xff7f else 0x7f7f);
        when TileDataType_E4M3 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xfe else 0x7e);
        when TileDataType_E5M2 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xfb else 0x7b);
        otherwise => unreachable;
    end;
end;

func ReferenceCommonReducedFloatingEncoding(
    value: real,
    destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    assert destination_type == TileDataType_TF32 ||
           destination_type == TileDataType_HF32 ||
           destination_type == TileDataType_E5M2;
    if value == 0.0 then return (Zeros{PTO_XLEN}, Zeros{5}); end;
    let negative = value < 0.0;
    var normalized = if negative then -value else value;
    var exponent: integer {-137..128} = 0;
    for step = 1 to 128 looplimit 128 do
        if normalized >= 2.0 && exponent < 128 then
            normalized = normalized / 2.0;
            exponent = (exponent + 1) as integer {-137..128};
        end;
    end;
    for step = 1 to 137 looplimit 137 do
        if normalized < 1.0 && exponent > -137 then
            normalized = normalized * 2.0;
            exponent = (exponent - 1) as integer {-137..128};
        end;
    end;
    let tf32 = destination_type == TileDataType_TF32;
    let hf32 = destination_type == TileDataType_HF32;
    let fraction_scale = if tf32 then 0x400
        else if hf32 then 0x800 else 4;
    let bias = if destination_type == TileDataType_E5M2 then 15 else 127;
    let maximum_exponent = if destination_type == TileDataType_E5M2
        then 15 else 127;
    let minimum_exponent = if destination_type == TileDataType_E5M2
        then -14 else -126;
    let minimum_subnormal_exponent = if tf32 then -136
        else if hf32 then -137 else -16;
    let low_zero_bits = if tf32 then 13 else if hf32 then 12 else 0;
    let sign = if negative then
        (if destination_type == TileDataType_E5M2
            then 0x80 else 0x80000000)
        else 0;
    let infinity = if destination_type == TileDataType_E5M2
        then 0x7c else 0x7f800000;
    if exponent > maximum_exponent then
        return (
            if control.saturating then
                ReferenceCommonFloatingEndpoint(destination_type, negative)
            else Zeros{PTO_XLEN} + sign + infinity,
            Zeros{5} + 0x14);
    end;
    if exponent < minimum_exponent then
        let scaled = normalized * ReferencePowerOfTwo(
            (exponent - minimum_subnormal_exponent)
                as integer {-1074..1023});
        var rounded = MatrixRoundMagnitude(
            scaled, control.rounding_mode, negative);
        if rounded < 0 then rounded = 0; end;
        let encoded = Zeros{PTO_XLEN} + sign + LSL(
            Zeros{PTO_XLEN} + rounded, low_zero_bits);
        let inexact = Real(rounded) != scaled;
        return (
            encoded,
            if !inexact then Zeros{5}
            else if rounded >= fraction_scale then Zeros{5} + 0x10
            else Zeros{5} + 0x18);
    end;
    let scaled = normalized * Real(fraction_scale);
    var rounded = MatrixRoundMagnitude(
        scaled, control.rounding_mode, negative);
    var encoded_exponent = exponent + bias;
    if rounded == 2 * fraction_scale then
        rounded = fraction_scale;
        encoded_exponent =
            (encoded_exponent + 1) as integer {-122..255};
    end;
    if encoded_exponent >= 2 * bias + 1 then
        return (
            if control.saturating then
                ReferenceCommonFloatingEndpoint(destination_type, negative)
            else Zeros{PTO_XLEN} + sign + infinity,
            Zeros{5} + 0x14);
    end;
    let fraction = rounded - fraction_scale;
    let code = encoded_exponent * fraction_scale + fraction;
    return (
        Zeros{PTO_XLEN} + sign +
            LSL(Zeros{PTO_XLEN} + code, low_zero_bits),
        if Real(rounded) == scaled then Zeros{5}
        else Zeros{5} + 0x10);
end;
```
<!-- GENERATED-ASL-END: unit -->
