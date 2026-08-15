<!-- GENERATED FROM: asl/tile/model/execution/unary.asl -->
# Unary

**Normative ASL source:** `asl/tile/model/execution/unary.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-UNARY}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/unary.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-UNARY","surface":"tile","classification":["model","execution","unary"],"depends_on":["PTO-TILE-MODEL-EXECUTION-ELEMENTWISE"]}

pure func TileIntegerUnaryValue(
    operation: TileUnaryOperation,
    data_type: TileDataType,
    value: Word) => Word
begin
    assert TileDataTypeIsInteger(data_type);

    let unsigned_value = TileUnsignedElementValue(value, data_type);
    let signed_value = TileIntegerOperandValue(value, data_type);
    case operation of
        when TileUnary_ABS =>
            if TileDataTypeIsSigned(data_type) &&
               SInt(signed_value) < 0 then
                return TileUnsignedElementValue(
                    Zeros{PTO_XLEN} - signed_value,
                    data_type);
            else
                return unsigned_value;
            end;
        when TileUnary_NOT =>
            return TileUnsignedElementValue(
                NOT unsigned_value,
                data_type);
        when TileUnary_NEG =>
            return TileUnsignedElementValue(
                Zeros{PTO_XLEN} - unsigned_value,
                data_type);
        when TileUnary_RELU =>
            if TileDataTypeIsSigned(data_type) &&
               SInt(signed_value) < 0 then
                return Zeros{PTO_XLEN};
            else
                return unsigned_value;
            end;
        otherwise =>
            unreachable;
    end;
end;

pure func TileUnaryUsesClosedElementwiseContract(
    operation: TileUnaryOperation) => boolean
begin
    return operation == TileUnary_ABS ||
           operation == TileUnary_NOT ||
           operation == TileUnary_NEG ||
           operation == TileUnary_RELU;
end;

pure func TileUnaryUsesSFUElementwiseContract(
    operation: TileUnaryOperation) => boolean
begin
    return operation == TileUnary_EXP ||
           operation == TileUnary_LOG ||
           operation == TileUnary_RECIP ||
           operation == TileUnary_SQRT ||
           operation == TileUnary_RSQRT;
end;

pure func TileUnaryUsesCompleteElementwiseSchema(
    operation: TileUnaryOperation) => boolean
begin
    return TileUnaryUsesClosedElementwiseContract(operation) ||
           TileUnaryUsesSFUElementwiseContract(operation);
end;

pure func TileUnaryScalarIntegerDataType(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_S64 ||
           data_type == TileDataType_S32 ||
           data_type == TileDataType_S16 ||
           data_type == TileDataType_S8 ||
           data_type == TileDataType_U64 ||
           data_type == TileDataType_U32 ||
           data_type == TileDataType_U16 ||
           data_type == TileDataType_U8;
end;

pure func TileUnaryDataTypeSupported(
    operation: TileUnaryOperation,
    data_type: TileDataType) => boolean
begin
    if operation == TileUnary_NOT then
        return TileUnaryScalarIntegerDataType(data_type);
    end;
    if operation == TileUnary_ABS ||
       operation == TileUnary_NEG ||
       operation == TileUnary_RELU then
        return TileUnaryScalarIntegerDataType(data_type) ||
               data_type == TileDataType_FP64 ||
               data_type == TileDataType_FP32 ||
               data_type == TileDataType_TF32 ||
               data_type == TileDataType_HF32 ||
               data_type == TileDataType_FP16 ||
               data_type == TileDataType_BF16 ||
               data_type == TileDataType_E4M3 ||
               data_type == TileDataType_E5M2;
    end;
    if TileUnaryUsesSFUElementwiseContract(operation) then
        return data_type == TileDataType_FP64 ||
               data_type == TileDataType_FP32 ||
               data_type == TileDataType_TF32 ||
               data_type == TileDataType_HF32 ||
               data_type == TileDataType_FP16 ||
               data_type == TileDataType_BF16 ||
               data_type == TileDataType_E4M3 ||
               data_type == TileDataType_E5M2;
    end;
    return FALSE;
end;

pure func TileFloatingUnaryCarrier(
    data_type: TileDataType,
    value: Word) => Word
begin
    case data_type of
        when TileDataType_FP64 =>
            return value;
        when TileDataType_FP32, TileDataType_TF32, TileDataType_HF32 =>
            return ZeroExtend{PTO_XLEN}(value[31:0]);
        when TileDataType_FP16, TileDataType_BF16 =>
            return ZeroExtend{PTO_XLEN}(value[15:0]);
        when TileDataType_E4M3, TileDataType_E5M2 =>
            return ZeroExtend{PTO_XLEN}(value[7:0]);
        otherwise =>
            unreachable;
    end;
end;

pure func TileFloatingUnarySignMask(
    data_type: TileDataType) => Word
begin
    case data_type of
        when TileDataType_FP64 =>
            return Zeros{PTO_XLEN} + 0x8000000000000000;
        when TileDataType_FP32, TileDataType_TF32, TileDataType_HF32 =>
            return Zeros{PTO_XLEN} + 0x80000000;
        when TileDataType_FP16, TileDataType_BF16 =>
            return Zeros{PTO_XLEN} + 0x8000;
        when TileDataType_E4M3, TileDataType_E5M2 =>
            return Zeros{PTO_XLEN} + 0x80;
        otherwise =>
            unreachable;
    end;
end;

pure func TileFloatingUnaryOneEncoding(
    data_type: TileDataType) => Word
begin
    case data_type of
        when TileDataType_FP64 =>
            return Zeros{PTO_XLEN} + 0x3ff0000000000000;
        when TileDataType_FP32, TileDataType_TF32,
             TileDataType_HF32 =>
            return Zeros{PTO_XLEN} + 0x3f800000;
        when TileDataType_FP16 =>
            return Zeros{PTO_XLEN} + 0x3c00;
        when TileDataType_BF16 =>
            return Zeros{PTO_XLEN} + 0x3f80;
        when TileDataType_E4M3 =>
            return Zeros{PTO_XLEN} + 0x38;
        when TileDataType_E5M2 =>
            return Zeros{PTO_XLEN} + 0x3c;
        otherwise =>
            unreachable;
    end;
end;

pure func TileFloatingUnaryInfinityEncoding(
    data_type: TileDataType,
    negative: boolean) => (boolean, Word)
begin
    var positive = Zeros{PTO_XLEN};
    case data_type of
        when TileDataType_FP64 =>
            positive = Zeros{PTO_XLEN} + 0x7ff0000000000000;
        when TileDataType_FP32, TileDataType_TF32,
             TileDataType_HF32 =>
            positive = Zeros{PTO_XLEN} + 0x7f800000;
        when TileDataType_FP16 =>
            positive = Zeros{PTO_XLEN} + 0x7c00;
        when TileDataType_BF16 =>
            positive = Zeros{PTO_XLEN} + 0x7f80;
        when TileDataType_E5M2 =>
            positive = Zeros{PTO_XLEN} + 0x7c;
        when TileDataType_E4M3 =>
            return (FALSE, Zeros{PTO_XLEN});
        otherwise =>
            unreachable;
    end;
    if negative then
        return (
            TRUE,
            positive OR TileFloatingUnarySignMask(data_type));
    end;
    return (TRUE, positive);
end;

pure func TileFloatingUnaryUnboundedResult(
    data_type: TileDataType,
    negative: boolean) => Word
begin
    let (infinity_available, infinity) =
        TileFloatingUnaryInfinityEncoding(
            data_type,
            negative);
    if infinity_available then
        return infinity;
    end;

    // E4M3 has no infinity encoding.  These SFU operations do not admit
    // saturation, so the OFP8 non-saturating destination result is NaN.
    let (nan_available, quiet_nan) =
        HardwareNumericCanonicalNaNResult(data_type);
    assert nan_available;
    return quiet_nan;
end;

pure func TileNumericValueClassIsNegative(
    value_class: NumericValueClass) => boolean
begin
    return value_class == NumericValue_NegativeZero ||
           value_class == NumericValue_NegativeSubnormal ||
           value_class == NumericValue_NegativeNormal ||
           value_class == NumericValue_NegativeInfinity;
end;

pure func TileSFUUnarySpecialValue(
    operation: TileUnaryOperation,
    data_type: TileDataType,
    value: Word) => (boolean, Word, bits(5))
begin
    assert TileUnaryUsesSFUElementwiseContract(operation);
    assert TileUnaryDataTypeSupported(operation, data_type);
    assert TileNumericEncodingValid(data_type, value);

    let carrier = TileFloatingUnaryCarrier(data_type, value);
    let value_class = TileNumericValueClass(data_type, carrier);
    let (nan_available, quiet_nan) =
        HardwareNumericCanonicalNaNResult(data_type);
    let (zero_available, positive_zero, negative_zero) =
        HardwareNumericSignedZeroEncodings(data_type);
    assert nan_available;
    assert zero_available;

    if NumericValueClassIsNaN(value_class) then
        var nan_flags = Zeros{5};
        if value_class == NumericValue_SignalingNaN then
            nan_flags = Zeros{5} + 1;
        end;
        return (TRUE, quiet_nan, nan_flags);
    end;

    if operation == TileUnary_EXP then
        if NumericValueClassIsZero(value_class) then
            return (
                TRUE,
                TileFloatingUnaryOneEncoding(data_type),
                Zeros{5});
        elsif value_class == NumericValue_PositiveInfinity then
            return (TRUE, carrier, Zeros{5});
        elsif value_class == NumericValue_NegativeInfinity then
            return (TRUE, positive_zero, Zeros{5});
        end;
    elsif operation == TileUnary_LOG then
        if carrier == TileFloatingUnaryOneEncoding(data_type) then
            return (TRUE, positive_zero, Zeros{5});
        elsif NumericValueClassIsZero(value_class) then
            return (
                TRUE,
                TileFloatingUnaryUnboundedResult(data_type, TRUE),
                Zeros{5} + 2);
        elsif value_class == NumericValue_PositiveInfinity then
            return (TRUE, carrier, Zeros{5});
        elsif TileNumericValueClassIsNegative(value_class) then
            return (TRUE, quiet_nan, Zeros{5} + 1);
        end;
    elsif operation == TileUnary_RECIP then
        if NumericValueClassIsZero(value_class) then
            let negative = value_class == NumericValue_NegativeZero;
            return (
                TRUE,
                TileFloatingUnaryUnboundedResult(data_type, negative),
                Zeros{5} + 2);
        elsif NumericValueClassIsInfinity(value_class) then
            if value_class == NumericValue_NegativeInfinity then
                return (TRUE, negative_zero, Zeros{5});
            end;
            return (TRUE, positive_zero, Zeros{5});
        end;
    elsif operation == TileUnary_SQRT then
        if NumericValueClassIsZero(value_class) ||
           value_class == NumericValue_PositiveInfinity then
            return (TRUE, carrier, Zeros{5});
        elsif TileNumericValueClassIsNegative(value_class) then
            return (TRUE, quiet_nan, Zeros{5} + 1);
        end;
    else
        assert operation == TileUnary_RSQRT;
        if NumericValueClassIsZero(value_class) then
            let negative = value_class == NumericValue_NegativeZero;
            return (
                TRUE,
                TileFloatingUnaryUnboundedResult(data_type, negative),
                Zeros{5} + 2);
        elsif value_class == NumericValue_PositiveInfinity then
            return (TRUE, positive_zero, Zeros{5});
        elsif TileNumericValueClassIsNegative(value_class) then
            return (TRUE, quiet_nan, Zeros{5} + 1);
        end;
    end;
    return (FALSE, Zeros{PTO_XLEN}, Zeros{5});
end;

pure func TileFloatingUnaryValue(
    operation: TileUnaryOperation,
    data_type: TileDataType,
    value: Word) => (Word, boolean)
begin
    assert TileDataTypeIsFloating(data_type);
    assert TileNumericEncodingValid(data_type, value);

    let carrier = TileFloatingUnaryCarrier(data_type, value);
    let sign_mask = TileFloatingUnarySignMask(data_type);
    if operation == TileUnary_ABS then
        return (carrier AND NOT sign_mask, FALSE);
    elsif operation == TileUnary_NEG then
        return (carrier XOR sign_mask, FALSE);
    end;

    assert operation == TileUnary_RELU;
    let value_class = TileNumericValueClass(data_type, carrier);
    case value_class of
        when NumericValue_NegativeZero,
             NumericValue_NegativeSubnormal,
             NumericValue_NegativeNormal,
             NumericValue_NegativeInfinity,
             NumericValue_PositiveZero =>
            return (Zeros{PTO_XLEN}, FALSE);
        when NumericValue_PositiveSubnormal,
             NumericValue_PositiveNormal,
             NumericValue_PositiveInfinity =>
            return (carrier, FALSE);
        when NumericValue_QuietNaN, NumericValue_SignalingNaN =>
            let (available, quiet_nan) =
                HardwareNumericCanonicalNaNResult(data_type);
            assert available;
            return (
                quiet_nan,
                value_class == NumericValue_SignalingNaN);
        otherwise =>
            unreachable;
    end;
end;

pure func TileFixedUnaryValue(
    operation: TileUnaryOperation,
    data_type: TileDataType,
    value: Word) => (Word, boolean)
begin
    assert TileUnaryUsesClosedElementwiseContract(operation);
    assert TileUnaryDataTypeSupported(operation, data_type);
    if TileDataTypeIsInteger(data_type) then
        return (
            TileIntegerUnaryValue(operation, data_type, value),
            FALSE);
    end;
    return TileFloatingUnaryValue(operation, data_type, value);
end;

func TileUnaryValue(operation: TileUnaryOperation, value: Word) => Word
begin
    case operation of
        when TileUnary_ABS =>
            if SInt(value) < 0 then
                return Zeros{PTO_XLEN} - value;
            else
                return value;
            end;
        when TileUnary_NOT =>
            return NOT value;
        when TileUnary_NEG =>
            return Zeros{PTO_XLEN} - value;
        when TileUnary_RELU =>
            if SInt(value) < 0 then
                return Zeros{PTO_XLEN};
            else
                return value;
            end;
        when TileUnary_SQRT =>
            return TileSquareRoot(value);
        when TileUnary_LOG =>
            return TileLogarithm(value);
        when TileUnary_RECIP =>
            return TileReciprocal(value);
        when TileUnary_EXP =>
            return TileExponential(value);
        when TileUnary_RSQRT =>
            return TileReciprocalSquareRoot(value);
    end;
end;

impdef func TileProfileUnary(
    op: TileUnaryOperation,
    data_type: TileDataType,
    value: Word) => (Word, bits(5))
begin
    if TileUnaryUsesClosedElementwiseContract(op) then
        let (result, invalid) = TileFixedUnaryValue(
            op,
            data_type,
            value);
        return (
            result,
            if invalid then Zeros{5} + 1 else Zeros{5});
    end;
    return (
        TileUnaryValue(op, value),
        Zeros{5});
end;

func ExecuteTileUnary(
    operation: TileUnaryOperation,
    destination: TileIndex,
    source: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    assert source_tile.allocated;
    assert TileShapesMatch(_Tiles[[destination]], source_tile);
    assert _Tiles[[destination]].data_type == source_tile.data_type;

    let source_payload = source_tile.payload;
    var result_payload = _Tiles[[destination]].payload;
    var flags = Zeros{5};
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(
                source_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            if TileUnaryUsesClosedElementwiseContract(operation) then
                let (result, element_invalid) = TileFixedUnaryValue(
                    operation,
                    source_tile.data_type,
                    source_payload[[element]]);
                result_payload[[element]] = result;
                if element_invalid then
                    flags = flags OR (Zeros{5} + 1);
                end;
            else
                let (handled, special_result, special_flags) =
                    TileSFUUnarySpecialValue(
                        operation,
                        source_tile.data_type,
                        source_payload[[element]]);
                var result = special_result;
                var element_flags = special_flags;
                if !handled then
                    let (profile_result, profile_flags) = TileProfileUnary(
                        operation,
                        source_tile.data_type,
                        source_payload[[element]]);
                    result = profile_result;
                    element_flags = profile_flags;
                end;
                result_payload[[element]] = result;
                flags = flags OR element_flags;
            end;
        end;
    end;
    _Tiles[[destination]].payload = result_payload;
    MarkTileValidRegionDefined(destination);
    if TileUnaryUsesCompleteElementwiseSchema(operation) then
        ApplyTilePadding(destination, CurrentBundlePadValue());
    end;
    ScalarFPRecordFlags(flags);
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
