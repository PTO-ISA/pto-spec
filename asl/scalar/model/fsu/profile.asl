// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-FSU-PROFILE","surface":"scalar","classification":["model","fsu","profile"],"depends_on":["PTO-SCALAR-MODEL-FSU-ARITHMETIC","PTO-ARCH-STATE-NUMERIC-STATUS"]}
// Raw scalar floating-point execution. The portable model fixes carrier,
// control/status, comparison, NaN, signed-zero, and destination rules. Numeric
// operations that require a concrete floating-point implementation cross one
// of the explicit profile hooks below.

pure func ScalarFPSourceTypeCode(source_type: bits(2)) => bits(5)
begin
    if source_type == '00' then return '00000';
    elsif source_type == '01' then return '00001';
    else return '11111';
    end;
end;

pure func ScalarSignedIntegerSourceTypeCode(source_type: bits(2)) => bits(5)
begin
    if source_type == '00' then return '01000';
    elsif source_type == '01' then return '01001';
    else return '11111';
    end;
end;

pure func ScalarUnsignedIntegerSourceTypeCode(source_type: bits(2)) => bits(5)
begin
    if source_type == '00' then return '00000';
    elsif source_type == '01' then return '00001';
    else return '11111';
    end;
end;

pure func ScalarFPTypeCodeSupported(data_type: bits(5)) => boolean
begin
    return UInt(data_type) <= 14;
end;

pure func ScalarIntegerTypeCodeSupported(data_type: bits(5)) => boolean
begin
    return UInt(data_type) <= 14;
end;

pure func ScalarFPToIntegerDestinationRawLegal(encoded: bits(5))
    => boolean
begin
    return UInt(encoded) <= 7;
end;

pure func ScalarFPToIntegerDestinationTypeCode(encoded: bits(5))
    => bits(5)
begin
    if UInt(encoded) <= 3 then
        return encoded;
    elsif UInt(encoded) <= 7 then
        return encoded + (Zeros{5} + 4);
    else
        return Ones{5};
    end;
end;

readonly func ScalarFPActiveRoundingMode() => NumericRoundingMode
begin
    return ResolveScalarFPActiveRoundingMode(_SystemRegisters.core_state[39:37]);
end;

pure func ScalarFPFixedConversionRoundingMode(operation: ScalarOperation)
                                                => NumericRoundingMode
begin
    if operation == ScalarOperation_FCVTA then return NumericRound_RNA;
    elsif operation == ScalarOperation_FCVTM then return NumericRound_RTM;
    elsif operation == ScalarOperation_FCVTN then return NumericRound_RNE;
    elsif operation == ScalarOperation_FCVTP then return NumericRound_RTP;
    elsif operation == ScalarOperation_FCVTZ then return NumericRound_RTZ;
    else unreachable;
    end;
end;

readonly func ScalarFPFlags() => bits(5)
begin
    return NumericStatusFlags();
end;

func ScalarFPRecordFlags(flags: bits(5))
begin
    RecordNumericStatusFlags(flags);
end;

pure func NormalizeScalarFPSource(value: Word, data_type: bits(5)) => Word
begin
    if data_type == '00001' then
        return ZeroExtend{PTO_XLEN}(value[31:0]);
    else
        return value;
    end;
end;

pure func NormalizeScalarIntegerSource(value: Word, data_type: bits(5)) => Word
begin
    if data_type == '00001' then return ZeroExtend{PTO_XLEN}(value[31:0]);
    elsif data_type == '01001' then return SignExtend{PTO_XLEN}(value[31:0]);
    else return value;
    end;
end;

pure func NormalizeScalarFPResult(value: Word, data_type: bits(5)) => Word
begin
    case UInt(data_type) of
        when 0 => return value;
        when 1, 3 => return ZeroExtend{PTO_XLEN}(value[31:0]);
        when 2 => return ZeroExtend{PTO_XLEN}(value[18:0]);
        when 4, 5 => return ZeroExtend{PTO_XLEN}(value[15:0]);
        when 6, 7, 8, 13 => return ZeroExtend{PTO_XLEN}(value[7:0]);
        when 9, 10 => return ZeroExtend{PTO_XLEN}(value[5:0]);
        when 11, 12 => return ZeroExtend{PTO_XLEN}(value[3:0]);
        when 14 => return ZeroExtend{PTO_XLEN}(value[8:0]);
        otherwise => unreachable;
    end;
end;

pure func NormalizeScalarIntegerResult(value: Word, data_type: bits(5)) => Word
begin
    case UInt(data_type) of
        when 0, 8 => return value;
        when 1 => return ZeroExtend{PTO_XLEN}(value[31:0]);
        when 2 => return ZeroExtend{PTO_XLEN}(value[15:0]);
        when 3 => return ZeroExtend{PTO_XLEN}(value[7:0]);
        when 4 => return ZeroExtend{PTO_XLEN}(value[3:0]);
        when 5 => return ZeroExtend{PTO_XLEN}(value[1:0]);
        when 6, 7 => return ZeroExtend{PTO_XLEN}(value[0:0]);
        when 9 => return SignExtend{PTO_XLEN}(value[31:0]);
        when 10 => return SignExtend{PTO_XLEN}(value[15:0]);
        when 11 => return SignExtend{PTO_XLEN}(value[7:0]);
        when 12 => return SignExtend{PTO_XLEN}(value[3:0]);
        when 13 => return SignExtend{PTO_XLEN}(value[1:0]);
        when 14 => return SignExtend{PTO_XLEN}(value[0:0]);
        otherwise => unreachable;
    end;
end;

pure func ScalarFP64IsNaN(value: Word) => boolean
begin
    return NumericValueClassIsNaN(
        TileNumericValueClass(TileDataType_FP64, value));
end;

pure func ScalarFP64IsSignalingNaN(value: Word) => boolean
begin
    return TileNumericValueClass(TileDataType_FP64, value) ==
        NumericValue_SignalingNaN;
end;

pure func ScalarFP64IsZero(value: Word) => boolean
begin
    return NumericValueClassIsZero(
        TileNumericValueClass(TileDataType_FP64, value));
end;

pure func ScalarFP64OrderKey(value: Word) => Word
begin
    if value[63] == '1' then return NOT(value);
    else return value XOR (Zeros{PTO_XLEN} + 0x8000000000000000);
    end;
end;

pure func ScalarFP32IsNaN(value: bits(32)) => boolean
begin
    return NumericValueClassIsNaN(TileNumericValueClass(
        TileDataType_FP32, ZeroExtend{PTO_XLEN}(value)));
end;

pure func ScalarFP32IsSignalingNaN(value: bits(32)) => boolean
begin
    return TileNumericValueClass(TileDataType_FP32,
        ZeroExtend{PTO_XLEN}(value)) == NumericValue_SignalingNaN;
end;

pure func ScalarFP32IsZero(value: bits(32)) => boolean
begin
    return NumericValueClassIsZero(TileNumericValueClass(
        TileDataType_FP32, ZeroExtend{PTO_XLEN}(value)));
end;

pure func ScalarFPCarrierIsZero(value: Word, data_type: bits(5)) => boolean
begin
    if data_type == '00001' then return ScalarFP32IsZero(value[31:0]);
    else return ScalarFP64IsZero(value);
    end;
end;

pure func ScalarFP32OrderKey(value: bits(32)) => bits(32)
begin
    if value[31] == '1' then return NOT(value);
    else return value XOR (Zeros{32} + 0x80000000);
    end;
end;

pure func ScalarFPIsNaN(value: Word, source_type: bits(2)) => boolean
begin
    if source_type == '01' then return ScalarFP32IsNaN(value[31:0]);
    else return ScalarFP64IsNaN(value);
    end;
end;

pure func ScalarFPIsSignalingNaN(value: Word, source_type: bits(2)) => boolean
begin
    if source_type == '01' then return ScalarFP32IsSignalingNaN(value[31:0]);
    else return ScalarFP64IsSignalingNaN(value);
    end;
end;

pure func ScalarFPEncodingEqual(left: Word, right: Word,
                                source_type: bits(2)) => boolean
begin
    if ScalarFPIsNaN(left, source_type) || ScalarFPIsNaN(right, source_type) then
        return FALSE;
    elsif source_type == '01' then
        let left32 = left[31:0];
        let right32 = right[31:0];
        return left32 == right32 ||
               (ScalarFP32IsZero(left32) && ScalarFP32IsZero(right32));
    else
        return left == right ||
               (ScalarFP64IsZero(left) && ScalarFP64IsZero(right));
    end;
end;

pure func ScalarFPEncodingLess(left: Word, right: Word,
                               source_type: bits(2)) => boolean
begin
    if ScalarFPIsNaN(left, source_type) || ScalarFPIsNaN(right, source_type) then
        return FALSE;
    elsif source_type == '01' then
        let left32 = left[31:0];
        let right32 = right[31:0];
        if ScalarFP32IsZero(left32) && ScalarFP32IsZero(right32) then return FALSE;
        else return UInt(ScalarFP32OrderKey(left32)) < UInt(ScalarFP32OrderKey(right32));
        end;
    else
        if ScalarFP64IsZero(left) && ScalarFP64IsZero(right) then return FALSE;
        else return UInt(ScalarFP64OrderKey(left)) < UInt(ScalarFP64OrderKey(right));
        end;
    end;
end;

pure func ScalarFPEncodingCompare(operation: FloatingCompareOperation,
                                  left: Word, right: Word,
                                  source_type: bits(2)) => boolean
begin
    if ScalarFPIsNaN(left, source_type) || ScalarFPIsNaN(right, source_type) then
        return FALSE;
    end;
    let equal = ScalarFPEncodingEqual(left, right, source_type);
    let less = ScalarFPEncodingLess(left, right, source_type);
    case operation of
        when FloatingCompare_EQ => return equal;
        when FloatingCompare_NE => return !equal;
        when FloatingCompare_LT => return less;
        when FloatingCompare_LE => return less || equal;
        when FloatingCompare_GT => return !less && !equal;
        when FloatingCompare_GE => return !less;
    end;
end;

pure func ScalarFPQuietNaN(source_type: bits(2)) => Word
begin
    let data_type = if source_type == '01' then TileDataType_FP32
                    else TileDataType_FP64;
    let (available, value) = TileNumericCanonicalNaN(data_type);
    assert available;
    return value;
end;

pure func ScalarFPMinMax(operation: FloatingBinaryOperation,
                         left: Word, right: Word,
                         source_type: bits(2)) => Word
begin
    let left_nan = ScalarFPIsNaN(left, source_type);
    let right_nan = ScalarFPIsNaN(right, source_type);
    if left_nan && right_nan then return ScalarFPQuietNaN(source_type);
    elsif left_nan then return NormalizeScalarFPSource(right, ScalarFPSourceTypeCode(source_type));
    elsif right_nan then return NormalizeScalarFPSource(left, ScalarFPSourceTypeCode(source_type));
    end;

    if source_type == '01' then
        let left32 = left[31:0];
        let right32 = right[31:0];
        if ScalarFP32IsZero(left32) && ScalarFP32IsZero(right32) then
            if operation == FloatingBinary_MAX && left32[31] == '1' &&
               right32[31] == '1' then
                return Zeros{PTO_XLEN} + 0x80000000;
            elsif operation == FloatingBinary_MAX then return Zeros{PTO_XLEN};
            elsif left32[31] == '1' || right32[31] == '1' then
                return Zeros{PTO_XLEN} + 0x80000000;
            else return Zeros{PTO_XLEN};
            end;
        end;
    elsif ScalarFP64IsZero(left) && ScalarFP64IsZero(right) then
        if operation == FloatingBinary_MAX && left[63] == '1' &&
           right[63] == '1' then
            return Zeros{PTO_XLEN} + 0x8000000000000000;
        elsif operation == FloatingBinary_MAX then return Zeros{PTO_XLEN};
        elsif left[63] == '1' || right[63] == '1' then
            return Zeros{PTO_XLEN} + 0x8000000000000000;
        else return Zeros{PTO_XLEN};
        end;
    end;

    let less = ScalarFPEncodingLess(left, right, source_type);
    if operation == FloatingBinary_MIN then
        if less then return left; else return right; end;
    else
        if less then return right; else return left; end;
    end;
end;

impdef func ScalarFPBinaryProfile(operation: FloatingBinaryOperation,
                                  rounding_mode: NumericRoundingMode, source_type: bits(5),
                                  left: Word, right: Word) => (Word, bits(5))
begin
    // Executable identity default. A named numeric profile supplies the
    // correctly rounded arithmetic result and IEEE exception flags.
    assert ScalarFPTypeCodeSupported(source_type);
    return (left, Zeros{5});
end;

impdef func ScalarFPUnaryProfile(operation: FloatingUnaryOperation,
                                 rounding_mode: NumericRoundingMode, source_type: bits(5),
                                 value: Word) => (Word, bits(5))
begin
    assert ScalarFPTypeCodeSupported(source_type);
    return (value, Zeros{5});
end;

impdef func ScalarFPFusedProfile(operation: FloatingFusedOperation,
                                 rounding_mode: NumericRoundingMode, source_type: bits(5),
                                 addend: Word, left: Word, right: Word)
                                 => (Word, bits(5))
begin
    assert ScalarFPTypeCodeSupported(source_type);
    return (addend, Zeros{5});
end;

impdef func ScalarFPToIntegerProfile(rounding_mode: NumericRoundingMode,
                                     destination_type: bits(5),
                                     source_type: bits(5), value: Word)
                                     => (Word, bits(5))
begin
    assert ScalarIntegerTypeCodeSupported(destination_type);
    assert ScalarFPTypeCodeSupported(source_type);
    return (value, Zeros{5});
end;

impdef func ScalarFPConvertProfile(rounding_mode: NumericRoundingMode,
                                   destination_type: bits(5),
                                   source_type: bits(5), value: Word)
                                   => (Word, bits(5))
begin
    assert ScalarFPTypeCodeSupported(destination_type);
    assert ScalarFPTypeCodeSupported(source_type);
    return (value, Zeros{5});
end;

impdef func ScalarIntegerToFPProfile(rounding_mode: NumericRoundingMode,
                                     source_type: bits(5),
                                     destination_type: bits(5), value: Word)
                                     => (Word, bits(5))
begin
    assert ScalarIntegerTypeCodeSupported(source_type);
    assert ScalarFPTypeCodeSupported(destination_type);
    return (value, Zeros{5});
end;
