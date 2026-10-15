// PTO-UNIT: {"id":"PTO-TILE-MODEL-NUMERIC-TCVT-CONVERSION","surface":"tile","classification":["model","numeric","tcvt-conversion"],"depends_on":["PTO-TILE-MODEL-NUMERIC-REFERENCE-CONVERSION","PTO-TILE-MODEL-EXECUTION-MATRIX-QUANTIZATION","PTO-TILE-MODEL-NUMERIC-PACKED-CONVERSION"]}

pure func TCVTSameTypeRoundIntegralType(data_type: TileDataType)
    => boolean
begin
    return data_type == TileDataType_FP16 ||
           data_type == TileDataType_BF16 ||
           data_type == TileDataType_FP32 ||
           data_type == TileDataType_FP64;
end;

readonly func TCVTExplicitRoundIntegralSelected(
    source_operation_type: TileDataType,
    destination_type: TileDataType) => boolean
begin
    let selection = DecodeBundleRoundingSelection(
        _BundleDataAttributes.rounding_mode);
    return source_operation_type == destination_type &&
           TCVTSameTypeRoundIntegralType(source_operation_type) &&
           !selection.use_operation_default;
end;

func ReferenceTCVTRoundIntegral(
    value: Word,
    data_type: TileDataType,
    mode: NumericRoundingMode,
    saturating: boolean) => (Word, bits(5))
begin
    assert TCVTSameTypeRoundIntegralType(data_type);
    assert mode != NumericRound_RTO;
    let control = NumericExecutionControl {
        rounding_mode = mode,
        saturating = saturating
    };
    let (handled, special, special_flags) = ReferenceCommonConvertSpecial(
        value, data_type, data_type, control);
    if handled then return (special, special_flags); end;

    let finite = ReferenceCommonFloatingFiniteValue(value, data_type);
    // Every finite binary value at or beyond 2^(precision-1) is already an
    // integer. Preserve its exact encoding without passing a potentially
    // out-of-range FP64 value through the model's integer type.
    let precision_boundary = if data_type == TileDataType_FP16 then 1024.0
        else if data_type == TileDataType_BF16 then 128.0
        else if data_type == TileDataType_FP32 then 8388608.0
        else 4503599627370496.0;
    if finite >= precision_boundary || finite <= -precision_boundary then
        return (value, Zeros{5});
    end;
    let rounded = FloatingToInteger(finite, mode);
    let inexact = Real(rounded) != finite;
    let flags = if inexact then Zeros{5} + 0x10 else Zeros{5};
    if rounded == 0 && finite < 0.0 then
        let (available, positive_zero, negative_zero) =
            HardwareNumericSignedZeroEncodings(data_type);
        assert available;
        return (negative_zero, flags);
    end;
    let (encoded, encoding_flags) = ReferenceMatrixFloatingEncoding(
        Real(rounded), data_type,
        NumericExecutionControl {
            rounding_mode = NumericRound_RNE,
            saturating = saturating
        });
    return (encoded, flags OR encoding_flags);
end;

pure func ReferenceTCVTOrdinaryFloatingSourceSupported(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP32 ||
           data_type == TileDataType_FP16 ||
           data_type == TileDataType_BF16;
end;

pure func ReferenceTCVTOrdinaryFloatingFiniteValue(
    value: Word, data_type: TileDataType) => real
begin
    assert ReferenceTCVTOrdinaryFloatingSourceSupported(data_type);
    if data_type == TileDataType_FP32 then
        return ReferenceFP32FiniteValue(value[31:0]);
    end;
    return ReferenceBinary16FiniteValue(value, data_type);
end;

func ReferenceTCVTConvertPacked4(
    value: Word, source_type: TileDataType,
    destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    assert ReferenceTCVTOrdinaryFloatingSourceSupported(source_type);
    let value_class = TileNumericValueClass(source_type, value);
    if NumericValueClassIsNaN(value_class) ||
       value_class == NumericValue_InvalidEncoding then
        return (Zeros{PTO_XLEN},
            if value_class == NumericValue_SignalingNaN ||
               value_class == NumericValue_InvalidEncoding then
                Zeros{5} + 1 else Zeros{5});
    end;
    if NumericValueClassIsInfinity(value_class) then
        let negative = value_class == NumericValue_NegativeInfinity;
        let maximum_code = if destination_type == TileDataType_E2M1X2
            then 6 else 7;
        return (Zeros{PTO_XLEN} +
                (if negative then maximum_code + 8 else maximum_code),
                Zeros{5} + 0x14);
    end;
    if NumericValueClassIsZero(value_class) then
        let (available, positive, negative) =
            HardwareNumericSignedZeroEncodings(destination_type);
        assert available;
        return (if value_class == NumericValue_NegativeZero then negative
                else positive, Zeros{5});
    end;
    return ReferencePacked4Encoding(
        ReferenceTCVTOrdinaryFloatingFiniteValue(value, source_type),
        destination_type, control);
end;

func ReferenceTCVTConvertFromPacked4(
    value: Word, source_type: TileDataType,
    destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    let value_class = TileNumericValueClass(source_type, value);
    if NumericValueClassIsZero(value_class) then
        let (available, positive, negative) =
            HardwareNumericSignedZeroEncodings(destination_type);
        assert available;
        return (if value_class == NumericValue_NegativeZero then negative
                else positive, Zeros{5});
    end;
    return ReferenceMatrixFloatingEncoding(
        ReferencePacked4FiniteValue(source_type, UInt(value[3:0])),
        destination_type, control);
end;

func ReferenceTCVTConvertToE6M2(
    value: Word, source_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    assert ReferenceTCVTOrdinaryFloatingSourceSupported(source_type);
    let value_class = TileNumericValueClass(source_type, value);
    if NumericValueClassIsNaN(value_class) ||
       value_class == NumericValue_InvalidEncoding then
        return (Zeros{PTO_XLEN} + 0xff,
            if value_class == NumericValue_SignalingNaN ||
               value_class == NumericValue_InvalidEncoding then
                Zeros{5} + 1 else Zeros{5});
    end;
    if value_class == NumericValue_NegativeZero ||
       value_class == NumericValue_PositiveZero then
        return (Zeros{PTO_XLEN}, Zeros{5} + 0x18);
    end;
    if value_class == NumericValue_NegativeInfinity ||
       value_class == NumericValue_NegativeNormal ||
       value_class == NumericValue_NegativeSubnormal then
        return (Zeros{PTO_XLEN} + 0xff, Zeros{5} + 1);
    end;
    if value_class == NumericValue_PositiveInfinity then
        return (
            if control.saturating then Zeros{PTO_XLEN} + 0xfe
            else Zeros{PTO_XLEN} + 0xff,
            Zeros{5} + 0x14);
    end;
    return ReferenceE6M2Encoding(
        ReferenceTCVTOrdinaryFloatingFiniteValue(value, source_type),
        control);
end;

func ReferenceTCVTConvertFromE6M2(
    value: Word, destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    let value_class = TileNumericValueClass(
        TileDataType_E6M2, value);
    if NumericValueClassIsNaN(value_class) ||
       value_class == NumericValue_InvalidEncoding then
        let (available, canonical) =
            TileNumericCanonicalNaN(destination_type);
        assert available;
        return (canonical, Zeros{5});
    end;
    return ReferenceMatrixFloatingEncoding(
        E6M2FiniteValue(value[7:0]), destination_type, control);
end;

func ReferenceTCVTConvertFromRCPE6M2(
    value: Word, destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    let value_class = TileNumericValueClass(
        TileDataType_RCPE6M2, value);
    if NumericValueClassIsNaN(value_class) ||
       value_class == NumericValue_InvalidEncoding then
        let (available, canonical) =
            TileNumericCanonicalNaN(destination_type);
        assert available;
        return (canonical, Zeros{5});
    end;
    return ReferenceMatrixFloatingEncoding(
        RCPE6M2FiniteValue(value[7:0]), destination_type, control);
end;

func ReferenceTCVTConvertFromE8M0(
    value: Word, destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    assert destination_type == TileDataType_FP16 ||
           destination_type == TileDataType_BF16 ||
           destination_type == TileDataType_FP32;
    if value[7:0] == Ones{8} then
        let (available, canonical) =
            TileNumericCanonicalNaN(destination_type);
        assert available;
        return (canonical, Zeros{5});
    end;
    let exponent = (UInt(value[7:0]) - 127)
        as integer {-1074..1023};
    return ReferenceMatrixFloatingEncoding(
        ReferencePowerOfTwo(exponent), destination_type, control);
end;

func ReferenceTCVTConvert(
    value: Word, source_type: TileDataType,
    destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    if source_type == TileDataType_E8M0 then
        return ReferenceTCVTConvertFromE8M0(
            value, destination_type, control);
    elsif destination_type == TileDataType_E2M1X2 ||
       destination_type == TileDataType_E1M2X2 then
        return ReferenceTCVTConvertPacked4(
            value, source_type, destination_type, control);
    elsif source_type == TileDataType_E2M1X2 ||
          source_type == TileDataType_E1M2X2 then
        return ReferenceTCVTConvertFromPacked4(
            value, source_type, destination_type, control);
    elsif destination_type == TileDataType_E6M2 then
        return ReferenceTCVTConvertToE6M2(value, source_type, control);
    elsif source_type == TileDataType_E6M2 then
        return ReferenceTCVTConvertFromE6M2(
            value, destination_type, control);
    elsif source_type == TileDataType_RCPE6M2 then
        return ReferenceTCVTConvertFromRCPE6M2(
            value, destination_type, control);
    end;
    return ReferenceCommonConvert(
        value, source_type, destination_type, control);
end;
