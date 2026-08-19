// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-MATRIX-POSTPROCESS","surface":"arch","classification":["profile","matrix-postprocess"],"depends_on":["PTO-ARCH-PROFILE-MATRIX-QUANTIZATION","PTO-ARCH-PROFILE-REFERENCE-PROFILE"]}
// Bit-exact B.FPATR conversion, activation, auxiliary reduction, and flags.
// NDF-BEGIN: PTO-MATRIX-POSTPROCESS-BITEXACT-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// Matrix post-processing MUST reduce the raw accumulator before conversion,
// select an activation-dependent multiplier before destination conversion,
// canonicalize special results, and publish D, enabled auxiliary outputs, and
// sticky flags as one non-faulting commit.
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

implementation func TileProfileMatrixPostProcessWithFlags(
    value: Word, pre_quant_mode: bits(6), relu_mode: bits(3),
    group_n_code: bits(4), output_type: TileDataType,
    quant_param: Word, relu_param: Word,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    return MatrixPostQuantBaseWithFlags(
        value, pre_quant_mode, output_type, relu_mode,
        quant_param, relu_param, control);
end;

implementation func TileProfileMatrixPostProcess(
    value: Word, pre_quant_mode: bits(6), relu_mode: bits(3),
    group_n_code: bits(4), output_type: TileDataType,
    quant_param: Word, relu_param: Word,
    control: NumericExecutionControl) => Word
begin
    let (result, -) = TileProfileMatrixPostProcessWithFlags(
        value, pre_quant_mode, relu_mode, group_n_code,
        output_type, quant_param, relu_param, control);
    return result;
end;

implementation func TileProfileMatrixReductionStep(
    current: Word, candidate: Word, max_abs: boolean,
    data_type: TileDataType) => Word
begin
    let (result, -) = TileProfileMatrixReductionStepWithFlags(
        current, candidate, max_abs, data_type);
    return result;
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

implementation func TileProfileMatrixReductionStepWithFlags(
    current: Word, candidate: Word, max_abs: boolean,
    data_type: TileDataType) => (Word, bits(5))
begin
    let (lhs_abs, lhs_flags) = if max_abs then
        MatrixReductionAbsoluteWithFlags(current, data_type)
    else
        (current, Zeros{5});
    let (rhs_abs, rhs_flags) = if max_abs then
        MatrixReductionAbsoluteWithFlags(candidate, data_type)
    else
        (candidate, Zeros{5});
    let lhs = if max_abs then lhs_abs else current;
    let rhs = if max_abs then rhs_abs else candidate;
    let (selected, -, flags) = TileReductionStepWithFlags(
        TileReduction_MAX, data_type, lhs, rhs);
    return (selected, flags OR lhs_flags OR rhs_flags);
end;
