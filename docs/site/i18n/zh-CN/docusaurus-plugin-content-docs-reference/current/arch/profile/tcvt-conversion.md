<!-- GENERATED FROM: asl/arch/profile/tcvt-conversion.asl -->
# Tcvt Conversion

**Normative ASL source:** `asl/arch/profile/tcvt-conversion.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROFILE-TCVT-CONVERSION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/profile/tcvt-conversion.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-TCVT-CONVERSION","surface":"arch","classification":["profile","tcvt-conversion"],"depends_on":["PTO-ARCH-PROFILE-REFERENCE-CONVERSION","PTO-ARCH-PROFILE-MATRIX-QUANTIZATION","PTO-ARCH-PROFILE-PACKED-CONVERSION"]}

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
```
<!-- GENERATED-ASL-END: unit -->
