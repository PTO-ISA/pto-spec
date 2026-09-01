// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-REFERENCE-CONVERSION","surface":"arch","classification":["profile","reference-conversion"],"depends_on":["PTO-ARCH-FEATURES-MX-FORMATS","PTO-ARCH-PROFILE-MATRIX-QUANTIZATION","PTO-SCALAR-MODEL-FSU-PROFILE","PTO-TILE-MODEL-NUMERIC-FORMATS"]}

// NDF-BEGIN: PTO-COMMON-CONVERSION-PROFILE-001
// ndf: kind=executable level=L3 layer=architecture status=accepted
// Scalar conversion and TCVT MUST use this common result rule whenever both
// types are in the shared FP64/FP32/FP16/E4M3 or signed/unsigned 64/32/16/8
// set. Scalar conversion MUST supply saturation disabled. Exact, inexact,
// underflow, overflow, saturation, wrap, signed-zero, NaN, infinity, and flag
// results MUST be identical for equal source, destination, and control inputs.
// NDF-END: PTO-COMMON-CONVERSION-PROFILE-001

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
        when TileDataType_FP16 =>
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

func ReferenceTileFloatingModulo(
    data_type: TileDataType, left: Word, right: Word) => (Word, bits(5))
begin
    assert data_type == TileDataType_FP32 ||
           data_type == TileDataType_FP16;
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
           data_type == TileDataType_FP16;
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

implementation func ScalarFPToIntegerProfile(
    rounding_mode: NumericRoundingMode, destination_type: bits(5),
    source_type: bits(5), value: Word) => (Word, bits(5))
begin
    assert ScalarConvertIntegerTypeCodeSupported(destination_type);
    assert ScalarConvertFloatingTypeCodeSupported(source_type);
    let control = NumericExecutionControl {
        rounding_mode = rounding_mode,
        saturating = FALSE
    };
    return ReferenceCommonConvert(
        value,
        ScalarConvertFloatingTileDataType(source_type),
        ScalarConvertIntegerTileDataType(destination_type),
        control);
end;

implementation func ScalarFPConvertProfile(
    rounding_mode: NumericRoundingMode, destination_type: bits(5),
    source_type: bits(5), value: Word) => (Word, bits(5))
begin
    assert ScalarConvertFloatingTypeCodeSupported(destination_type);
    assert ScalarConvertFloatingTypeCodeSupported(source_type);
    let control = NumericExecutionControl {
        rounding_mode = rounding_mode,
        saturating = FALSE
    };
    return ReferenceCommonConvert(
        value,
        ScalarConvertFloatingTileDataType(source_type),
        ScalarConvertFloatingTileDataType(destination_type),
        control);
end;

implementation func ScalarIntegerToFPProfile(
    rounding_mode: NumericRoundingMode, source_type: bits(5),
    destination_type: bits(5), value: Word) => (Word, bits(5))
begin
    assert ScalarConvertIntegerTypeCodeSupported(source_type);
    assert ScalarConvertFloatingTypeCodeSupported(destination_type);
    let control = NumericExecutionControl {
        rounding_mode = rounding_mode,
        saturating = FALSE
    };
    return ReferenceCommonConvert(
        value,
        ScalarConvertIntegerTileDataType(source_type),
        ScalarConvertFloatingTileDataType(destination_type),
        control);
end;
