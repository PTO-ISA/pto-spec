<!-- GENERATED FROM: asl/tile/model/execution/matrix-postprocess.asl -->
# Matrix Postprocess

**Normative ASL source:** `asl/tile/model/execution/matrix-postprocess.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-MATRIX-POSTPROCESS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-matrix-postprocess-purpose role=purpose-scope -->
## Purpose and scope

This unit converts one CUBE accumulator element into its final D value. It applies the B.FPATR activation, scale, offset, rounding, saturation, and special-value rules.

`MatrixPostQuantBaseWithFlags` is the per-element entry point, reached through `TileProfileMatrixPostProcessWithFlags` in the post-processing unit. The unit also supplies `MatrixReductionAbsoluteWithFlags` for MaxAbs reductions. It carries NDF clause `PTO-MATRIX-POSTPROCESS-BITEXACT-001`.

<!-- PTO-READER-BLOCK: tile-model-execution-matrix-postprocess-concepts role=concepts-state -->
## Concepts and visible state

- The source type is the accumulator type seen by conversion: the output type when PreQuantMode is 0, S32 for the S32 modes, and FP32 otherwise.
- ReluMode 0 selects no activation, 1 selects ReLU, and 2 or 3 select a leaky slope from a scalar or vector parameter.
- The quantization scale is an FP19 value in parameter bits `[31:13]`. The signed offset width is 0, 5, 9, or 17 bits, chosen by `BundleFPATRModeOffsetWidth`.

Flags use the bit order NV, DZ, OF, UF, NX from bit 0. `0x14` is OF plus NX.

<!-- PTO-READER-BLOCK: tile-model-execution-matrix-postprocess-rules role=rules-interactions -->
## Rules and interactions

When PreQuantMode and ReluMode are both 0, the value passes through unchanged. Shift modes 12 and 13 go straight to `MatrixShiftS32ToS16`, with a shift of parameter bits `[35:32]` plus one.

For the other modes, `MatrixSelectedMultiplier` picks one multiplier. It is the scale for a non-negative source or for ReluMode 0. For a negative source it is 0 under ReluMode 1 and the FP19 ReLU parameter under ReluMode 2 or 3.

A NaN or infinite FP32 source is handled by `MatrixPostQuantSpecialValue`. An integer destination receives 0 or the endpoint that the saturation rule selects, and raises NV or OF plus NX. A floating destination receives NaN, zero, infinity, or the largest finite value. Negative infinity with multiplier 0 is instead treated as 0.0.

A finite source is multiplied by the multiplier. With a nonzero offset width, `MatrixQuantizedAffine` rounds and saturates at that width, adds the offset, and encodes the result. Otherwise the offset is added and `MatrixEncodeReal` encodes the sum.

`MatrixFPATREffectiveControl` forces RHB for modes 25 and 28 and RNE for the other fixed-rounding modes. The remaining modes keep the B.DATR rounding.

Design point: a negative-zero FP32 source with a nonzero multiplier, zero offset, and a floating destination returns `MatrixFloatingSignedZero(output_type, TRUE)`: negative zero for FP32, FP16, BF16, and E4M3, and `0x00` for HiF8. The sign survives where the format has a negative zero, which the real-number path would lose.

Design point: apart from the shift modes, which use an arithmetic shift, each step is written in exact real arithmetic with one defined rounding point per stage; the NDF requires the result to be bit-exact, so every implementation publishes the same D.

<!-- PTO-READER-BLOCK: tile-model-execution-matrix-postprocess-boundaries role=boundaries -->
## Architectural boundaries

`MatrixFloatingLargestFinite` has no FP64 or E5M2 entry, and `MatrixFloatingInfinity` returns the canonical NaN for every type other than FP32, FP16, BF16, and HiF8. For a nonzero PreQuantMode, the destination type is the one that `BundleFPATROutputType` lists for that mode.

For MaxAbs, `MatrixReductionAbsoluteWithFlags` maps S32 `0x80000000` to `0x7fffffff` with OF. Legality only admits FP32, FP16, and BF16 reductions, which use the floating ABS.

<!-- PTO-READER-BLOCK: tile-model-execution-matrix-postprocess-example role=example-usage -->
## Non-normative reading example

A TMATMUL has an FP32 accumulator, PreQuantMode 1, and ReluMode 1. Mode 1 outputs FP16, uses no scale parameter, and fixes RNE.

1. Accumulator element 2.5 is non-negative, so the multiplier is 1.0. The result 2.5 encodes exactly as FP16 `0x4100`.
2. Accumulator element -3.0 is negative under ReLU, so the multiplier is 0. The result 0.0 encodes as `0x0000`.
3. Accumulator element negative infinity with multiplier 0 is treated as 0.0, so ReLU also yields `0x0000` with no flags.

<!-- PTO-READER-BLOCK: tile-model-execution-matrix-postprocess-related role=related-owners-navigation -->
## Related owners

- [Matrix quantization](matrix-quantization.md) owns the rounding, saturation, and encoding helpers.
- [Post-processing](postprocess.md) routes the parameters and publishes the results.
- [B.FPATR](../../../block/attributes/B.FPATR.md) defines the mode tables.
- [Reference quantization](../../../scalar/model/fsu/reference-quantization.md) owns FP32 finite value decoding.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/matrix-postprocess.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-MATRIX-POSTPROCESS","surface":"tile","classification":["model","execution","matrix-postprocess"],"depends_on":["PTO-TILE-MODEL-EXECUTION-MATRIX-QUANTIZATION","PTO-TILE-MODEL-EXECUTION-MATRIX-SCALE"]}
// Bit-exact B.FPATR conversion, activation, auxiliary reduction, and flags.
// NDF-BEGIN: PTO-MATRIX-POSTPROCESS-BITEXACT-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// Matrix post-processing MUST apply the existing CScale, activation,
// quantization, rounding, saturation, and special-value rules to each logical
// accumulator element and encode the final D value in EffectiveDType before
// reduction. RowMax and GroupMax MUST consume those final encoded D values in
// increasing-column order; MaxAbs and RowMaxInit use the same effective type.
// The model MUST publish D, enabled auxiliary outputs, and sticky flags as one
// non-faulting commit.
// NDF-END: PTO-MATRIX-POSTPROCESS-BITEXACT-001


pure func MatrixFloatingSignedZero(
    data_type: TileDataType, negative: boolean) => Word
begin
    if !negative then return Zeros{PTO_XLEN}; end;
    case data_type of
        when TileDataType_FP32 => return Zeros{PTO_XLEN} + 0x80000000;
        when TileDataType_FP16, TileDataType_BF16 =>
            return Zeros{PTO_XLEN} + 0x8000;
        when TileDataType_E4M3 => return Zeros{PTO_XLEN} + 0x80;
        when TileDataType_HiF8 => return Zeros{PTO_XLEN};
        otherwise => return Zeros{PTO_XLEN};
    end;
end;

pure func MatrixFloatingInfinity(
    data_type: TileDataType, negative: boolean) => Word
begin
    case data_type of
        when TileDataType_FP32 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xff800000 else 0x7f800000);
        when TileDataType_FP16 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xfc00 else 0x7c00);
        when TileDataType_BF16 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xff80 else 0x7f80);
        when TileDataType_HiF8 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xef else 0x6f);
        otherwise =>
            let (available, quiet_nan) =
                HardwareNumericCanonicalNaNResult(data_type);
            assert available;
            return quiet_nan;
    end;
end;

pure func MatrixFloatingLargestFinite(
    data_type: TileDataType, negative: boolean) => Word
begin
    case data_type of
        when TileDataType_FP32 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xff7fffff else 0x7f7fffff);
        when TileDataType_FP16 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xfbff else 0x7bff);
        when TileDataType_BF16 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xff7f else 0x7f7f);
        when TileDataType_E4M3 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xfe else 0x7e);
        when TileDataType_HiF8 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xee else 0x6e);
        otherwise => unreachable;
    end;
end;

func MatrixEncodeReal(
    value: real, data_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    if TileDataTypeIsInteger(data_type) then
        return ReferenceMatrixIntegerEncoding(value, data_type, control);
    end;
    return ReferenceMatrixFloatingEncoding(value, data_type, control);
end;

func MatrixPostQuantSpecialValue(
    value: Word, source_type: TileDataType,
    destination_type: TileDataType,
    control: NumericExecutionControl)
    => (boolean, Word, bits(5))
begin
    if !TileDataTypeIsFloating(source_type) then
        return (FALSE, Zeros{PTO_XLEN}, Zeros{5});
    end;
    let value_class = TileNumericValueClass(source_type, value);
    if NumericValueClassIsNaN(value_class) then
        if TileDataTypeIsInteger(destination_type) then
            return (TRUE,
                if control.saturating then Zeros{PTO_XLEN}
                else TileIntegerMinimum(destination_type),
                Zeros{5} + 1);
        end;
        if control.saturating then
            return (TRUE, Zeros{PTO_XLEN},
                if value_class == NumericValue_SignalingNaN then
                    Zeros{5} + 1 else Zeros{5});
        end;
        let (available, quiet_nan) =
            HardwareNumericCanonicalNaNResult(destination_type);
        assert available;
        return (TRUE, quiet_nan,
            if value_class == NumericValue_SignalingNaN then
                Zeros{5} + 1 else Zeros{5});
    elsif NumericValueClassIsInfinity(value_class) then
        let negative = value_class == NumericValue_NegativeInfinity;
        if TileDataTypeIsInteger(destination_type) then
            let endpoint = if !control.saturating then
                TileIntegerMinimum(destination_type)
            else if negative then
                TileIntegerMinimum(destination_type)
            else
                TileIntegerMaximum(destination_type);
            return (TRUE, endpoint,
                if control.saturating then Zeros{5} + 0x14
                else Zeros{5} + 1);
        elsif control.saturating then
            return (TRUE,
                MatrixFloatingLargestFinite(destination_type, negative),
                Zeros{5} + 0x14);
        else
            return (TRUE,
                MatrixFloatingInfinity(destination_type, negative),
                if destination_type == TileDataType_E4M3 then
                    Zeros{5} + 0x14 else Zeros{5});
        end;
    end;
    return (FALSE, Zeros{PTO_XLEN}, Zeros{5});
end;

pure func MatrixValueClassNegative(
    value_class: NumericValueClass) => boolean
begin
    return value_class == NumericValue_NegativeNormal ||
           value_class == NumericValue_NegativeSubnormal ||
           value_class == NumericValue_NegativeInfinity ||
           value_class == NumericValue_NegativeZero;
end;

pure func MatrixSelectedMultiplier(
    source_negative: boolean, relu_mode: bits(3),
    quant_scale: real, relu_param: Word) => real
begin
    if !source_negative || UInt(relu_mode) == 0 then
        return quant_scale;
    elsif UInt(relu_mode) == 1 then
        return 0.0;
    end;
    return FP19FiniteValue(relu_param[18:0]);
end;

func MatrixActivationWithFlags(
    value: real, source_negative: boolean, relu_mode: bits(3),
    quant_scale: real, relu_param: Word) => (real, bits(5))
begin
    let multiplier = MatrixSelectedMultiplier(
        source_negative, relu_mode, quant_scale, relu_param);
    return (value * multiplier, Zeros{5});
end;

pure func MatrixFPATREffectiveControl(
    pre_quant_mode: bits(6), control: NumericExecutionControl)
    => NumericExecutionControl
begin
    var result = control;
    let mode = UInt(pre_quant_mode);
    if mode == 25 || mode == 28 then
        result.rounding_mode = NumericRound_RHB;
    elsif BundleFPATRModeFixedRounding(pre_quant_mode) then
        result.rounding_mode = NumericRound_RNE;
    end;
    return result;
end;

func MatrixPostQuantBaseWithFlags(
    value: Word, pre_quant_mode: bits(6), output_type: TileDataType,
    relu_mode: bits(3), quant_param: Word, relu_param: Word,
    control: NumericExecutionControl)
    => (Word, bits(5))
begin
    if UInt(pre_quant_mode) == 0 && UInt(relu_mode) == 0 then
        return (value, Zeros{5});
    end;
    if BundleFPATRModeIsShift(pre_quant_mode) then
        let shift = UInt(quant_param[35:32]) + 1;
        return MatrixShiftS32ToS16(
            value[31:0], shift as integer {1..16});
    end;

    let source_type = if UInt(pre_quant_mode) == 0 then output_type
    else if BundleFPATRModeUsesS32Accumulator(
        pre_quant_mode) then TileDataType_S32 else TileDataType_FP32;
    let source_class = if source_type == TileDataType_FP32 then
        TileNumericValueClass(source_type, value)
    else
        NumericValue_PositiveNormal;
    let source_negative = if source_type == TileDataType_S32 then
        SInt(value[31:0]) < 0
    else
        MatrixValueClassNegative(source_class);
    let scale = if BundleFPATRModeUsesScalarParameter(pre_quant_mode) ||
                   BundleFPATRModeUsesVectorParameter(pre_quant_mode) then
        FP19FiniteValue(quant_param[31:13])
    else
        1.0;
    let multiplier = MatrixSelectedMultiplier(
        source_negative, relu_mode, scale, relu_param);
    let (special, special_result, special_flags) =
        MatrixPostQuantSpecialValue(
            value, source_type, output_type, control);
    if special &&
       !(source_class == NumericValue_NegativeInfinity &&
         multiplier == 0.0) then
        return (special_result, special_flags);
    end;

    let source_value = if source_type == TileDataType_S32 then
        Real(SInt(value[31:0]))
    else if source_type == TileDataType_U32 then
        Real(UInt(value[31:0]))
    else if source_class == NumericValue_NegativeInfinity then
        0.0
    else
        ReferenceFP32FiniteValue(value[31:0]);
    let (activated, activation_flags) = MatrixActivationWithFlags(
        source_value, source_negative, relu_mode, scale, relu_param);
    let offset = MatrixQuantOffset(
        quant_param, BundleFPATRModeOffsetWidth(pre_quant_mode));
    let intermediate_width =
        BundleFPATRModeOffsetWidth(pre_quant_mode);
    if source_class == NumericValue_NegativeZero &&
       multiplier != 0.0 && offset == 0 &&
       TileDataTypeIsFloating(output_type) then
        return (
            MatrixFloatingSignedZero(output_type, TRUE),
            activation_flags);
    end;
    if intermediate_width != 0 then
        let (encoded, encoding_flags) = MatrixQuantizedAffine(
            activated, 1.0, offset, intermediate_width,
            output_type, control);
        return (encoded, activation_flags OR encoding_flags);
    end;
    let (encoded, encoding_flags) = MatrixEncodeReal(
        activated + Real(offset), output_type, control);
    return (encoded, activation_flags OR encoding_flags);
end;




pure func MatrixReductionAbsoluteWithFlags(
    value: Word, data_type: TileDataType) => (Word, bits(5))
begin
    if data_type == TileDataType_U32 then
        return (ZeroExtend{PTO_XLEN}(value[31:0]), Zeros{5});
    elsif data_type == TileDataType_S32 then
        if value[31] == '0' then
            return (SignExtend{PTO_XLEN}(value[31:0]), Zeros{5});
        end;
        let magnitude = Zeros{32} - value[31:0];
        if value[31:0] == '10000000000000000000000000000000' then
            return (Zeros{PTO_XLEN} + 0x7fffffff, Zeros{5} + 4);
        end;
        return (
            SignExtend{PTO_XLEN}(magnitude),
            Zeros{5});
    end;
    let (result, invalid) = TileFixedUnaryValue(
        TileUnary_ABS, data_type, value);
    return (result, if invalid then Zeros{5} + 1 else Zeros{5});
end;
```
<!-- GENERATED-ASL-END: unit -->
